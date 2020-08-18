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

            typeEnv = typeEnv[[k => T(Fresh(k)) for k in tvars]]
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

const _InferPostponed = CFunc{IR.Decl, Tuple{}}

function inferDecls(globalTC::GlobalTC, localTC::LocalTC, decls::Vector{Surf.Decl})
    annotated :: Set{Symbol} = Set{Symbol}()
    loweredDeclFs = _InferPostponed[]
    @inline addDecl!(f::Function) = push!(loweredDeclFs, _InferPostponed(f))

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
                let exprTyProp = inferExpr(globalTC, localTC, expr)
                    addDecl!(() -> IR.Perform(exprTyProp(NoProp)))
                end
                continue
            end
            (gensym, annTy) = if sym in annotated
                pop!(annotated, sym)
                localTC.symmap[sym], localTC.typeEnv[sym]
            else
                gensym = symgen(globalTC)
                localTC = @set localTC.symmap = localTC.symmap[sym => gensym]
                tvar = globalTC.tcstate.new_tvar()
                gensym, tvar
            end

            let exprTyProp = inferExpr(globalTC, localTC, expr),
                gensym = gensym,
                annTy = annTy,
                prune = globalTC.tcstate.prune

                addDecl!(
                    () ->
                    IR.Assign(gensym, annTy, exprTyProp(InstTo(
                        @match prune(annTy) begin
                            Forall(ns, t) => t
                            _ => annTy
                        end
                    ))))
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

    @inline function prop(varTy::HMT, eImpl::IR.ExprImpl, ln::LineNumberNode)
        function propInner(ti::TypeInfo)
            varTy = prune(varTy)
            @switch ti begin
            @case NoProp
                IR.Expr(localTC.ln, varTy, eImpl)
            @case InstTo(instTy)
                unifyINST(instTy, varTy) || throw(MLError(ln, UnificationFail))
                IR.Expr(localTC.ln, instTy, eImpl)
            end
        end
    end

    @switch expr begin
    @case Surf.ELoc(ln, expr)
        inferExpr(globalTC, (@set localTC.ln = ln), expr)

    @case Surf.ETup(xs)

        let elty = CFunc{IR.Expr, Tuple{TypeInfo}},
            props = elty[elty(inferExpr(globalTC, localTC, x)) for x in xs],
            n_xs = length(xs),
            ln = localTC.ln

            function propTup(ti::TypeInfo)
                correctAnn = @match ti begin
                    InstTo(t && Tup(ts)) && if length(ts) === n_xs end =>
                        (t, ts)
                    _ => nothing
                end
                if correctAnn === nothing
                    let ts = [new_tvar() for i = 1:n_xs],
                        elts = IR.Expr[(prop(InstTo(t))) for (prop, t) in zip(props, ts)]

                        IR.Expr(ln, Tup(Tuple(ts)), IR.ETup(elts))
                    end
                else
                    let (t, ts) = correctAnn,
                        elts = IR.Expr[prop(InstTo(t)) for (prop, t) in zip(props, ts)]

                        IR.Expr(ln, t, IR.ETup(elts))
                    end
                end
            end
        end
    @case Surf.EApp(f, arg)
        let fProp = inferExpr(globalTC, localTC, f),
            argProp = inferExpr(globalTC, localTC, arg),
            ln = localTC.ln

            function propApp(ti::TypeInfo)
                @match ti begin
                    InstTo(t) =>
                        let argT = new_tvar(),
                            eF = fProp(InstTo(Arrow(argT, t))),
                            eArg = argProp(InstTo(argT))

                            IR.Expr(ln, t, IR.EApp(eF, eArg))
                        end
                    NoProp =>
                        let argT = new_tvar(),
                            retT = new_tvar(),
                            eF = fProp(InstTo(Arrow(argT, retT))),
                            eArg = argProp(InstTo(argT))

                            IR.Expr(ln, retT, IR.EApp(eF, eArg))
                        end
                end
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
                @match ti begin
                    InstTo(instTy) => begin
                        unifyINST(instTy, Arrow(argT, retT)) || throw(MLError(ln, UnificationFail))
                        nothing
                    end
                    NoProp => nothing
                end
                eBody = exprTyProp(InstTo(retT))
                IR.Expr(
                    ln,
                    Arrow(argT, retT),
                    IR.EFun(gensym, eBody))
            end
        end

    @case Surf.ELet(decls, expr)
        let (loweredDeclFs, localTC) = inferDecls(globalTC, localTC, decls),
            exprTyProp = inferExpr(globalTC, localTC, expr),
            ln = localTC.ln
            function propLet(t::TypeInfo)
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
                (ti, t) = @match ti begin
                    NoProp => let t = new_tvar()
                                (InstTo(t), t)
                              end
                    InstTo(t) => (ti, t)
                end
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
        n in localTC.typeEnv || throw(MLError(ln, UnboundVar(n)))
        gensym = localTC.symmap[n]
        varT = localTC.typeEnv[n]
        prop(varT, IR.EVar(gensym), localTC.ln)
    end
end