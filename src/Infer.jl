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
    @switch x begin
    @case Surf.DLoc(ln)
        localTC = @set 
    
    end
end
