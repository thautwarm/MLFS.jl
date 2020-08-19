export inferType

function inferType(globalTC::GlobalTC, localTC::LocalTC, exp::Surf.TyExpr)::HMT
    ln = localTC.ln
    typetype::HMT = @switch exp begin
    @case Surf.TQuery(label, exp)
        let ret = T(inferType(globalTC, localTC, exp))
            push!(globalTC.queries, label => ret)
            ret
        end
    
    @case Surf.TSym(a)
        T(Nom(a))
    @case Surf.TVar(:_)
        T(globalTC.tcstate.new_tvar())
    
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
            
            uniqueNames = [UN(k) for k in tvars]
            typeEnv = typeEnv[[un.name => T(Bound(un)) for un in uniqueNames]]
            localTC = @set localTC.typeEnv = typeEnv
            p = inferType(globalTC, localTC, p)
            T(Forall(Tuple(uniqueNames), p))
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

const _InferPostponed = CFunc{IR.Decl, Tuple{}}

function inferDecls(globalTC::GlobalTC, localTC::LocalTC, decls::Vector{Surf.Decl})
    annotated :: Dict{Symbol, Tuple} = Dict{Symbol, Tuple}()
    loweredDeclFs = _InferPostponed[]
    @inline addDecl!(f::Function) = push!(loweredDeclFs, _InferPostponed(f))

    for decl in decls
        @switch decl begin
        @case Surf.DQuery(label, sym)
            annTy = if sym in localTC.typeEnv
                globalTC.tcstate.prune(localTC.typeEnv[sym])
            else
                throw(MLError(localTC.ln, UnboundVar(sym)))
            end
            push!(globalTC.queries, label=>annTy)
            nothing
        @case Surf.DLoc(ln)
            localTC = @set localTC.ln = ln
            nothing
        @case Surf.DAnn(sym, tyExpr)
            haskey(annotated, sym) && throw(MLError(localTC.ln, UnusedAnnotation(sym)))
            gensym = symgen(globalTC)
            localTC = @set localTC.symmap = localTC.symmap[sym => gensym]
            annTy = inferType(globalTC, localTC, tyExpr)
            localTC = @set localTC.typeEnv = localTC.typeEnv[sym => annTy]
            @match annTy begin
                Forall(ns, _) => begin annotated[sym] = ns end
                _ => begin annotated[sym] = () end
            end
            nothing
        @case Surf.DBind(sym, expr)
            if sym === :_
                let exprTyProp = inferExpr(globalTC, localTC, expr)
                    addDecl!(() -> IR.Perform(exprTyProp(NoProp)))
                end
                continue
            end
            (gensym, annTy, typevars) = if haskey(annotated, sym)
                typevars = pop!(annotated, sym)
                localTC.symmap[sym], globalTC.tcstate.prune(localTC.typeEnv[sym]), typevars
            else
                gensym = symgen(globalTC)
                localTC = @set localTC.symmap = localTC.symmap[sym => gensym]
                tvar = globalTC.tcstate.new_tvar()
                localTC = @set localTC.typeEnv = localTC.typeEnv[sym => tvar]
                gensym, tvar, ()
            end
            # @info :annotation sym annTy
            let localTC = if isempty(typevars)
                            localTC 
                        else
                           @set localTC.typeEnv =
                                localTC.typeEnv[[un.name => T(Bound(un)) for un in typevars]]
                        end,
                exprTyProp = inferExpr(globalTC, localTC, expr),
                gensym = gensym,
                annTy = annTy,
                prune = globalTC.tcstate.prune

                addDecl!(
                    () ->
                    IR.Assign(
                        gensym,
                        annTy,
                        exprTyProp(InstTo(annTy))))
            end
        end
    end
    loweredDeclFs, localTC
end

intTypes = Dict{Int, Nom}()
floatTypes = Dict{Int, Nom}()
for bit in (8, 16, 32, 64)
    intTypes[bit] = Nom(Symbol(:int, bit))
    floatTypes[bit] = Nom(Symbol(:float, bit))
end
strT = Nom(:str)
charT = Nom(:char)
boolT = Nom(:bool)

function inferExpr(globalTC::GlobalTC, localTC::LocalTC, expr::Surf.Expr)
    tcstate = globalTC.tcstate
    unifyINST = tcstate.unifyINST
    unify = tcstate.unify
    prune = tcstate.prune
    new_tvar = tcstate.new_tvar

    @inline function applyTI(ti::TypeInfo, me::HMT, ln)
        @match ti begin
            NoProp => (me, NoPropKind)
            InstTo(instTy) => begin
                # @info :InstTo prune(instTy) prune(me)
                unifyINST(instTy, me) || throw(MLError(ln, UnificationFail))
                (instTy, InstToKind)
            end
            InstFrom(genTy) => begin
                # @info :InstFrom prune(me) prune(genTy)
                unifyINST(me, genTy) || throw(MLError(ln, UnificationFail))
                (me, InstFromKind)
            end
        end
    end

    @inline function prop(varTy::HMT, eImpl::IR.ExprImpl, ln::LineNumberNode)
        function propInner(ti::TypeInfo)
            varTy = prune(varTy)
            varTy, _ = applyTI(ti, varTy, ln)
            IR.Expr(ln, varTy, eImpl)
        end
    end

    @switch expr begin
    @case Surf.EQuery(label, e)
        exprTyProp = inferExpr(globalTC, localTC, e)
        queries = globalTC.queries
        function propQuery(ti::TypeInfo)
            e = exprTyProp(ti)
            push!(queries, label=>e.ty)
            e
        end
    @case Surf.ELoc(ln, expr)
        inferExpr(globalTC, (@set localTC.ln = ln), expr)

    @case Surf.ETup(xs)

        let elty = CFunc{IR.Expr, Tuple{TypeInfo}},
            props = elty[elty(inferExpr(globalTC, localTC, x)) for x in xs],
            n_xs = length(xs),
            ln = localTC.ln

            function propTup(ti::TypeInfo)
                local ts, tupT, elts
                ts = [new_tvar() for i = 1:n_xs]
                tupT = Tup(Tuple(ts))
                tupT, makeTI = applyTI(ti, tupT, ln)
                
                elts = IR.Expr[(prop(makeTI(t))) for (prop, t) in zip(props, ts)]
                IR.Expr(ln, tupT, IR.ETup(elts))
            end
        end
    @case Surf.EApp(f, arg)
        let fProp = inferExpr(globalTC, localTC, f),
            argProp = inferExpr(globalTC, localTC, arg),
            ln = localTC.ln

            function propApp(ti::TypeInfo)
                local argT, retT, mkTI, eF, eArg
                argT = new_tvar()
                retT = new_tvar()
                retT, mkTI =  applyTI(ti, retT, ln)
                eF = fProp(InstTo(Arrow(argT, retT)))
                eArg = argProp(InstFrom(argT))
                IR.Expr(ln, retT, IR.EApp(eF, eArg))
            end
        end

    @case Surf.EFun(n, expr)
        gensym = symgen(globalTC)
        localTC = @set localTC.symmap = localTC.symmap[n => gensym]
        argT = new_tvar()
        localTC = @set localTC.typeEnv = localTC.typeEnv[n => argT]
        retT = new_tvar()
        let exprTyProp = inferExpr(globalTC, localTC, expr),
            ln = localTC.ln,
            gensym = gensym

            function propFun(ti::TypeInfo)
                local arrowT, eBody
                arrowT, _ = applyTI(ti, Arrow(argT, retT), ln)
                eBody = exprTyProp(InstTo(retT))
                IR.Expr(
                    ln,
                    arrowT,
                    IR.EFun(gensym, eBody))
            end
        end

    @case Surf.ELet(decls, expr)
        let (loweredDeclFs, localTC) = inferDecls(globalTC, localTC, decls),
            exprTyProp = inferExpr(globalTC, localTC, expr),
            ln = localTC.ln
            function propLet(t::TypeInfo)
                local eBody, loweredDecls, eI
                eBody = exprTyProp(t)
                loweredDecls = [f() for f in loweredDeclFs]
                eI = IR.ELet(loweredDecls, eBody)
                IR.Expr(ln, eBody.ty, eI)
            end
        end

    @case Surf.EITE(cond, arm1, arm2)
        let condProp = inferExpr(globalTC, localTC, cond),
            arm1Prop = inferExpr(globalTC, localTC, arm1),
            arm2Prop = inferExpr(globalTC, localTC, arm2),
            new_tvar = globalTC.tcstate.new_tvar,
            ln = localTC.ln

            function propITE(ti::TypeInfo)
                local t, eArm1, eArm2, eCond, eI, mkTI
                t, mkTI = applyTI(ti, new_tvar(), ln)
                ti = mkTI(t)
                eArm1 = arm1Prop(ti)
                eArm2 = arm2Prop(ti)
                eCond = condProp(InstTo(boolT))
                eI = IR.EITE(eCond, eArm1, eArm2)
                IR.Expr(ln, t, eI)
            end
        end

    @case Surf.EVal(val)
        (eValI, eT) = @match val begin
            ::Integer => (IR.EInt(val), intTypes[8 * sizeof(val)])
            ::AbstractFloat => (IR.EFloat(val), floatTypes[8 * sizeof(val)])
            ::String => (IR.EStr(val), strT)
            ::Char => (IR.EChar(val), charT)
            ::Bool => (IR.EBool(val), boolT)
        end
        prop(eT, eValI, localTC.ln)
    @case Surf.EVar(n)
        n in localTC.typeEnv || throw(MLError(localTC.ln, UnboundVar(n)))
        gensym = localTC.symmap[n]
        varT = localTC.typeEnv[n]
        prop(varT, IR.EVar(gensym), localTC.ln)
    end
end