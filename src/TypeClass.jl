function instanceResolve(
        globalTC::GlobalTC,
        localImplicits::InstResolCtx,
        target::HMT,
        ln::LineNumberNode,
    )::IR.Expr
    tcstate = globalTC.tcstate
    target = tcstate.prune(target)

    candicates = Pair{InstRec, Vector{HMT}}[]
    for rec in localImplicits
        if !rec.isPruned
            rec.t = tcstate.prune(rec.t)
        end
        is_less, evidences = less_than_under_evidences(target, rec.t)
        if is_less
            push!(candicates, rec => evidences)
        end
    end
    !isempty(candicates) && begin
        if length(candicates) === 1
            rec, evidences = candicates[1]
            explicits = [instanceResolve(globalTC, localImplicits, evi, ln) for evi in evidences]
            return IR.applyExplicits(IR.EVar(rec.gensym), explicits, targety, ln)
        else
            throw(MLError(
                ln,
                DuplicateInstanceError(candicates)))
        end
    end

    tHead = getTConsHead(target)
    globalImplicits = get!(GlobalTC.globalImplicits, tHead) do
        InstRec[]
    end
    for i in eachindex(globalImplicits)
        rec = globalImplicits[i]
        
        if !rec.isPruned
            rec.t = tcstate.prune(rec.t)
        end
        is_less, evidences = less_than_under_evidences(target, rec.t)
        if is_less
            push!(candicates, rec => evidences)
        end
    end
    !isempty(candicates) && begin
        if length(candicates) === 1
            rec, evidences = candicates[1]
            explicits = [instanceResolve(globalTC, localImplicits, evi, ln) for evi in evidences]
            return IR.applyExplicits(IR.EVar(rec.gensym), explicits, targety, ln)
        else
            throw(MLError(
                ln,
                DuplicateInstanceError(candicates)))
        end
    end

    throw(MLError(
        ln,
        InstanceNotFound(target)))
end
