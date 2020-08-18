export inferType

function inferType(globalTC::GlobalTC, localTC::LocalTC, exp::Surf.TyExpr)::HMT
    ln = localTC.ln
    typetype::HMT = @switch exp begin
    @case Surf.TSym(a)
        T(Nom(a))

    @case Surf.TVar(:self)
        T(Nom(Symbol(:nom, string(ln))))

    @case Surf.TVar(a)
        t = get(localTC.typeEnv, a, nothing)
        t === nothing && throw(MLError(
            localTC.ln,
            UnboundTypeVar(a)))
        t::HMT

    @case Surf.TApp(f, b)
        f = inferType(globalTC, localTC, f)
        a = inferType(globalTC, localTC, a)
        T(App(f, a))

    @case Surf.TTuple(args)
        T(Tup(Tuple(inferType(
            globalTC, localTC, arg) for arg in args)))

    @case Surf.TForall(tvars, p)
        any(tvars) do s; s isa Symbol end ||
            throw(MLError(ln, InvalidSyntax("$exp")))
        let typeEnv = localTC.typeEnv

            typeEnv = typeEnv[(k => T(Fresh(k)) for k in tvars)...]
            localTC = @set localTC.typeEnv = typeEnv
            p = inferType(globalTC, localTC, p)
            T(Forall(Tuple(tvars), p))
        end

    @case Surf.TArrow(a, b)
        a = inferType(globalTC, localTC, a)
        b = inferType(globalTC, localTC, b)
        T(Arrow(a, b))
    end

    tcstate = globalTC.tcstate
    unify = tcstate.unify
    new_tvar = tcstate.new_tvar
    prune = tcstate.prune

    @match typetype begin
        T(x) => x
        _ => begin
            targ = new_tvar()
            unify(T(targ), x) || throw(MLError(ln, UnificationFail))
            prune(targ)
        end
    end
end

function inferDecl(globalTC::GlobalTC, localTC::LocalTC, decls::Vector{Surf.Decl})
    annotated :: Set{Symbol} = Set{Symbol}()
    loweredDecls = IR.Decl[]
    for decl in decls
        @switch decl begin
        @case Surf.DLoc(ln)
            localTC = @set localTC.ln = ln
            nothing
        @case Surf.DAnn(sym, tyExpr)
            sym in annotated && throw(MLError(localTC.ln, UnusedAnnotation(sym)))
            gensym = symgen(globalTC)
            localTC = @set localTC.symmap = localTC.symmap[sym => gensym]
            annTy = inferType(globalTC, localTC, tyExpr)
            localTC = @set localTC.typeEnv = localTC.typeEnv[sym => annTy]
            push!(annotated, sym)
            nothing
        @case Surf.DBind(sym, expr)
            if sym === :_
                exprTyProp = inferExpr(globalTC, localTC, expr)
                typedIR = exprTyProp(NoProp)
                push!(
                    loweredDecls,
                    IR.Perform(typedIR))
                continue
            end
            (gensym, annTy) = if sym in annotated
                localTC.symmap[sym], localTC.typeEnv[sym]
            else
                gensym = symgen(globalTC)
                localTC = @set localTC.symmap = localTC.symmap[sym => gensym]
                tvar = globalTC.tcstate.new_tvar()
                gensym, tvar 
            end
            
            exprTyProp = inferExpr(globalTC, localTC, expr)
            typedIR =  exprTyProp(InstTo(
                @match annTy begin
                    Forall(ns, t) => t
                    _ => annTy
                end
            ))
            push!(
                loweredDecls,
                IR.Assign(gensym, annTy, typedIR))
        end
    end
    loweredDecls, localTC
end

function inferExpr(globalTC::GlobalTC, localTC::LocalTC, expr::Surf.Expr)
    tcstate = globalTC.tcstate
    unify = tcstate.unify
    prune = tcstate.prune

    @switch expr begin
    @case Surf.ELoc(ln, expr)
        inferExpr(globalTC, (@set localTC.ln = ln), expr)
    @case Surf.Var(n)
        n in localTC.typeEnv || throw(MLError(localTC.ln, UnboundVar(n)))
        function prop(t::TypeInfo)
            varTy = localTC.typeEnv[n] |> prune
            @switch t begin
            @case NoProp
                return varTy
            @case InstTo(instTy)
                @match (instTy, varTy) begin
                    (Forall(ns1, ty1), Forall(ns2, ty2)) => begin
                        
                    end
                end
                
            end
            



        end



        
    end
end