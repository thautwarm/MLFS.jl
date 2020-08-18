#=
License: MIT
Description: Definition of Store for operational semantics
Copyright (c) 2020 thautwarm <twshere@outlook.com> and contributors
=#
export Store

ImD = Base.ImmutableDict
struct Store{K, O}
    unbox :: ImD{K, O}
end

# given σ ∈ Store{K, O} where K, O
# 'σ[k => v]' add a scoped pair k=>v and returns a new store
# where the old one is not affected.
function Store{K, O}() where {K, O}
    Store(ImD{K, O}())
end
Base.getindex(s::Store{K, O}, x::Pair{K, A}...) where {K, O, A<:O} =
    let im = s.unbox
        for each in x
            im = ImD(im, each)
        end
        Store(im)
    end
Base.getindex(s::Store{K, O}, x::K) where {K, O} = s.unbox[x]

Base.get(s::Store, k, default) = get(s.unbox, k, default)
Base.in(s::Store{K}, k::K) where K = haskey(s.unbox, k)