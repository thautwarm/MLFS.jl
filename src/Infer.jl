export inferType, inferModule, inferExpr, inferDecls

function inferType(globalTC::GlobalTC, localTC::LocalTC, exp::Surf.TyExpr)::HMT
    ln = localTC.ln
    typetype::HMT = @switch exp begin
    @case Surf.TNew(tn)
        T(Nom(Symbol(tn, '@', ln.line, "_", symgen(globalTC))))
    @case Surf.TImplicit(t)
        T(Implicit(inferType(globalTC, localTC, t)))
    @case Surf.TQuery(label, exp)
        let ret = T(inferType(globalTC, localTC, exp))
            push!(globalTC.queries, label => ret)
            ret
        end

    @case Surf.TSym(a)
        T(Nom(a))

    @case Surf.TVar(:_)
        T(globalTC.tcstate.new_tvar())

    @case Surf.TVar(a)
        t = get(localTC.typeEnv, a, nothing)
        t === nothing && throw(MLError(
            localTC.ln,
            UnboundTypeVar(a)))
        t::HMT

    @case Surf.TApp(f, b)
        f = inferType(globalTC, localTC, f)
        b = inferType(globalTC, localTC, b)
        T(App(f, b))

    @case Surf.TTuple(args)
        T(Tup(HMT[inferType(globalTC, localTC, arg) for arg in args]))

    @case Surf.TForall(tvars, p)
        any(tvars) do s; s isa Symbol end ||
            throw(MLError(ln, InvalidSyntax("$exp")))
        let typeEnv = localTC.typeEnv

            uniqueNames = UN[UN(k) for k in tvars]
            typeEnv = typeEnv[[un.name => T(Bound(un)) for un in uniqueNames]]
            localTC = @set localTC.typeEnv = typeEnv
            p = inferType(globalTC, localTC, p)
            T(Forall(uniqueNames, p))
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

function inferModule(globalTC::GlobalTC, localTC::LocalTC, decls::Vector{Surf.Decl})
    props, localTC = inferDecls(globalTC, localTC, decls, Val(true))
    IR.Decl[f() for f in props], localTC
end

function inferDecls(globalTC::GlobalTC, localTC::LocalTC, decls::Vector{Surf.Decl})
    inferDecls(globalTC, localTC, decls, Val(false))
end

function inferDecls(globalTC::GlobalTC, localTC::LocalTC, decls::Vector{Surf.Decl}, ::Val{isGlobal}) where isGlobal
    annotated :: Dict{Symbol, Vector{HM.UN}} = Dict{Symbol, Tuple}()
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
        @case Surf.DOpen(exp)
            let exprTyProp = inferExpr(globalTC, localTC, exp),
                ex = exprTyProp(NoProp, localTC.localImplicits),
                tcstate = globalTC.tcstate,
                namespaceTy = tcstate.new_tvar(),
                target = App(Nom(:namespace), Tup(HMT[ex.ty, namespaceTy])),
                (fromTy, _) = instanceResolveAndType(
                    globalTC, localTC.localImplicits, target, localImplicits.ln)

                unifyImplicits!(target, fromTy, HMT[]) || throw(MLError(ln, UnificationFail))

                namespaceTy = tcstate.prune(namespaceTy)
                @match namespaceTy begin
                    Tup(fields) =>
                        for field in fields
                            @match field begin
                                Tup([Nom(name), Nom(gensym), t]) =>
                                    begin
                                        localTC = @set localTC.symmap = localTC.symmap[name => gensym]
                                        localTC = @set localTC.typeEnv = localTC.typeEnv[name => t]
                                    end
                                _ => error(MLError(localTC.ln, InvalidNamespaceType(namespaceTy)))
                            end
                        end
                    _ => error(MLError(localTC.ln, InvalidNamespaceType(namespaceTy)))
                end
                IR.Perform(ex)
            end

            
        @case Surf.DAnn(sym, tyExpr)
            haskey(annotated, sym) && throw(MLError(localTC.ln, UnusedAnnotation(sym)))
            gensym = Symbol(symgen(globalTC), :_, sym)
            localTC = @set localTC.symmap = localTC.symmap[sym => gensym]
            annTy = inferType(globalTC, localTC, tyExpr)
            localTC = @set localTC.typeEnv = localTC.typeEnv[sym => annTy]
            @match annTy begin
                Forall(ns, _) => begin
                        annotated[sym] = ns
                    end
                Implicit(t) =>
                    if isGlobal
                        t = globalTC.tcstate.prune(t)
                        tConsHead = getTConsHead(t)
                        globalImplicits = get!(globalTC.globalImplicits, tConsHead) do
                            InstRec[]
                        end
                        push!(globalImplicits, InstRec(t, localTC.ln, gensym, false))
                        globalTC.globalImplicitDeltas[tConsHead] =
                            get(globalTC.globalImplicitDeltas, tConsHead, 0) + 1

                        annotated[sym] = HM.UN[]
                    else
                        inst = InstRec(t, localTC.ln, gensym, false)
                        localImplicits = cons(inst, localTC.localImplicits)
                        localTC = @set localTC.localImplicits = localImplicits
                        annotated[sym] = HM.UN[]
                    end
                _ => begin annotated[sym] = HM.UN[] end
            end
            nothing
        @case Surf.DBind(sym, expr)
            if sym === :_

                let exprTyProp = inferExpr(globalTC, localTC, expr),
                    localImplicits = localTC.localImplicits

                    addDecl!(() -> IR.Perform(exprTyProp(NoProp, localImplicits)))
                end
                continue
            end
            (gensym, annTy, typevars) = if haskey(annotated, sym)
                typevars = pop!(annotated, sym)
                localTC.symmap[sym], globalTC.tcstate.prune(localTC.typeEnv[sym]), typevars
            else
                gensym = Symbol(symgen(globalTC), :_, sym)
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
                prune = globalTC.tcstate.prune,
                localImplicits = localTC.localImplicits

                addDecl!(
                    () ->
                    IR.Assign(
                        gensym,
                        annTy,
                        exprTyProp(InstTo(annTy), localImplicits)))
            end
        end
    end
    loweredDeclFs, localTC
end

intTypes = Dict{Int, Nom}()
floatTypes = Dict{Int, Nom}()
for bit in (8, 16, 32, 64)
    intTypes[bit] = Nom(Symbol(:i, bit))
    floatTypes[bit] = Nom(Symbol(:f, bit))
end
strT = Nom(:str)
charT = Nom(:char)
boolT = Nom(:bool)

function inferExpr(globalTC::GlobalTC, localTC::LocalTC, expr::Surf.Expr)
    tcstate = globalTC.tcstate
    unifyINST = tcstate.unifyINST
    unifyImplicits! = tcstate.unifyImplicits!
    unify = tcstate.unify
    prune = tcstate.prune
    new_tvar = tcstate.new_tvar
    localImplicits = localTC.localImplicits
    ln = localTC.ln

    @inline function applyTI(ti::TypeInfo, me::HMT)
        local implicits
        implicits = HMT[]
        @match ti begin
            NoProp => (me, implicits)
            InstTo(instTy) => begin
                unifyImplicits!(instTy, me, implicits) || begin
                    # @info :UNIFY_FAIL prune(instTy) prune(me)
                    throw(MLError(ln, UnificationFail))
                end
                (instTy, implicits)
            end
        end
    end

    @inline function prop(varTy::HMT, eImpl::IR.ExprImpl)
        function propInner(ti::TypeInfo, localImplicits::InstResolCtx)
            local implicits
            varTy = prune(varTy)
            varTy, implicits = applyTI(ti, varTy)
            IR.applyImplicits(eImpl, implicits, varTy, ln, localImplicits)
        end
    end

    @switch expr begin
    @case Surf.EExt(jlex)

        function (ti::TypeInfo, localImplicits::InstResolCtx)
            local t, implicits
            t = new_tvar()
            t, implicits = applyTI(ti, t)
            IR.applyImplicits(IR.EExt(jlex), implicits, t, ln, localImplicits)
        end

    @case Surf.EQuery(label, e)
        exprTyProp = inferExpr(globalTC, localTC, e)
        queries = globalTC.queries
        function propQuery(ti::TypeInfo, localImplicits::InstResolCtx)
            e = exprTyProp(ti, localImplicits)
            push!(queries, label=>e.ty)
            e
        end
    @case Surf.ELoc(ln, expr)
        inferExpr(globalTC, (@set localTC.ln = ln), expr)

    @case Surf.EField(subject, field)

        exprTyProp = inferExpr(globalTC, localTC, subject)
        function propField(ti::TypeInfo, localImplicits::InstResolCtx)
            local eSub, retTV, retT, eRet, op_Getter
            eSub = exprTyProp(NoProp, localImplicits)
            retTV = new_tvar()
            target = App(Nom(:field), Tup(HMT[eSub.ty, Nom(field), retTV]))
            retT, eAccess = instanceResolveAndType(globalTC, localImplicits, target, ln)
            unifyImplicits!(target, retT, HMT[]) || throw(MLError(ln, UnificationFail))
            retTV, implicits = applyTI(ti, retTV)
            
            op_Getter = IR.Expr(ln, nothing, IR.EVar(:op_Getter))
            eRet = IR.EApp(IR.Expr(ln, nothing, IR.EApp(op_Getter, eAccess)), eSub)
            IR.applyImplicits(eRet, implicits, retTV, ln, localImplicits)
        end

    @case Surf.ETup(xs)

        let elty = CFunc{IR.Expr, Tuple{TypeInfo, InstResolCtx}},
            props = elty[elty(inferExpr(globalTC, localTC, x)) for x in xs],
            n_xs = length(xs)

            function propTup(ti::TypeInfo, localImplicits::InstResolCtx)
                local ts, tupT, elts, implicits
                ts = HMT[new_tvar() for i = 1:n_xs]
                tupT = Tup(ts)
                tupT, implicits = applyTI(ti, tupT)
                elts = IR.Expr[(prop(InstTo(t), localImplicits)) for (prop, t) in zip(props, ts)]
                IR.applyImplicits(IR.ETup(elts), implicits, tupT, ln, localImplicits)
            end
        end
    @case Surf.EApp(f, arg)
        let fProp = inferExpr(globalTC, localTC, f),
            argProp = inferExpr(globalTC, localTC, arg)

            function propApp(ti::TypeInfo, localImplicits::InstResolCtx)
                local argT, retT, eF, eArg, implicits
                argT = new_tvar()
                retT = new_tvar()
                retT, implicits = applyTI(ti, retT)
                eF = fProp(InstTo(Arrow(argT, retT)), localImplicits)
                eArg = argProp(InstTo(argT), localImplicits)
                IR.applyImplicits(IR.EApp(eF, eArg), implicits, retT, ln, localImplicits)
            end
        end

    @case Surf.EFun(n, expr)
        gensym = Symbol(symgen(globalTC), :_, n)
        localTC = @set localTC.symmap = localTC.symmap[n => gensym]
        argT = new_tvar()
        localTC = @set localTC.typeEnv = localTC.typeEnv[n => argT]
        retT = new_tvar()
        let exprTyProp = inferExpr(globalTC, localTC, expr),
            gensym = gensym

            function propFun(ti::TypeInfo, localImplicits::InstResolCtx)
                local arrowT, eBody, implicits
                arrowT, implicits = applyTI(ti, Arrow(argT, retT))
                localImplicits = @match prune(argT) begin
                    Implicit(instance) =>
                        cons(InstRec(instance, ln, gensym, false), localImplicits)
                    _ => localImplicits
                end
                eBody = exprTyProp(InstTo(retT), localImplicits)
                IR.applyImplicits(
                    IR.EFun(gensym, eBody),
                    implicits, arrowT, ln, localImplicits)
            end
        end

    @case Surf.ELet(decls, expr)
        let (loweredDeclFs, localTC) = inferDecls(globalTC, localTC, decls),
            exprTyProp = inferExpr(globalTC, localTC, expr)

            function propLet(t::TypeInfo, localImplicits::InstResolCtx)
                local eBody, loweredDecls, eI
                eBody = exprTyProp(t, localImplicits)
                loweredDecls = [f() for f in loweredDeclFs]
                eI = IR.ELet(loweredDecls, eBody)
                IR.Expr(ln, eBody.ty, eI)
            end
        end

    @case Surf.EITE(cond, arm1, arm2)
        let condProp = inferExpr(globalTC, localTC, cond),
            arm1Prop = inferExpr(globalTC, localTC, arm1),
            arm2Prop = inferExpr(globalTC, localTC, arm2),
            new_tvar = globalTC.tcstate.new_tvar

            function propITE(ti::TypeInfo, localImplicits::InstResolCtx)
                local t, eArm1, eArm2, eCond, eI, implicits
                t, implicits = applyTI(ti, new_tvar())
                ti = InstTo(t)
                eArm1 = arm1Prop(ti, localImplicits)
                eArm2 = arm2Prop(ti, localImplicits)
                eCond = condProp(InstTo(boolT), localImplicits)
                eI = IR.EITE(eCond, eArm1, eArm2)
                IR.applyImplicits(eI, implicits, t, ln, localImplicits)
            end
        end

    @case Surf.EVal(val)
        (eValI, eT) = @switch val begin
            @case ::Integer
                bit = 8 * sizeof(val)
                IR.EInt(val, bit), intTypes[bit]
            @case ::AbstractFloat
                bit = 8 * sizeof(val)
                IR.EFloat(val, bit), floatTypes[bit]
            @case ::String 
                IR.EStr(val), strT
            @case ::Char
                IR.EChar(val), charT
            @case ::Bool
                IR.EBool(val), boolT
        end
        prop(eT, eValI)

    @case Surf.EVar(n)
        n in localTC.typeEnv || throw(MLError(localTC.ln, UnboundVar(n)))
        varT = prune(localTC.typeEnv[n])
        @match varT begin
            T(t) =>
                function propTVar(ti::TypeInfo, _::InstResolCtx)
                    @match ti begin
                        InstTo(t′) =>
                            begin
                                unify(t′, varT) || throw(MLError(ln, UnificationFail))
                            end
                        _ => nothing
                    end

                    IR.Expr(ln, varT, IR.ETypeVal(t))
                end
            _ =>
                let gensym = localTC.symmap[n]
                    prop(varT, IR.EVar(gensym))
                end
        end
    end
end