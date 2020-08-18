function instanceResolve(
        globalTC::GlobalTC,
        localTC::LocalTC,
        target::HMT,
        ln::LineNumberNode,
    )::InstRec
    tcstate = globalTC.tcstate
    localImplicits = localTC.localImplicits
    target = tcstate.prune(target)

    candicates = InstRec[]
    for i in eachindex(localImplicits)
        rec = localImplicits[i]
        if !rec.isPruned
            rec.t = tcstate.prune(rec.t)
        end
        if target ⪯ rec.t
            push!(candicates, rec)
        end
    end
    !isempty(candicates) && begin
        if length(candicates) === 1
            return candicates[1]
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
        if target ⪯ rec.t
            push!(candicates, rec)
        end
    end
    !isempty(candicates) && begin
        if length(candicates) === 1
            return candicates[1]
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
