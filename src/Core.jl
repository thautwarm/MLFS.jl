export arrowClass, generalClass, getTConsHead
export InstRec, GlobalTC, LocalTC, show_hints
const TCState = Base._return_type(mk_tcstate, (Vector{HMT}, ))
Gensym = Symbol

"""
datatype for type class instances
"""
mutable struct InstRec
    t :: HMT             # instance type
    ln :: LineNumberNode # where the instance defined
    gensym :: Gensym     # the actual gensym(IR level) to access this instance
    isPruned :: Bool     # is the instance type pruned?
end

const InstResolCtx = Vector{InstRec}

const arrowClass = Nom(:arrow_class)
const generalClass = Nom(:general_class)

getTConsHead(h::HMT) =
    @match h begin
        Nom(_) => h
        App(t, _) ||
        Forall(_, t) => getTConsHead(t)
        Arrow(_, _) => ArrowClass
        _ => generalClass
    end

struct GlobalTC
    tcstate :: TCState
    count :: Ref{UInt}
    globalImplicits :: Dict{Nom, InstResolCtx}
    queries :: Vector{Pair{String, HMT}}
end

Base.show(io::IO, ::GlobalTC) = Base.show(io, "<GlobalTC>")

Base.empty(::Type{GlobalTC}) =
    GlobalTC(mk_tcstate(HMT[]), Ref(UInt(0)), Dict{Nom, InstanceNotFound}(), Pair{String, HMT}[])

function show_hints(globalTC::GlobalTC)
    prune = globalTC.tcstate.prune
    for (k, v) in globalTC.queries
        println(k, ": ",  prune(v))
    end
end
struct LocalTC
    typeEnv :: Store{Symbol, HMT}
    symmap :: Store{Symbol, Gensym}
    localImplicits :: InstResolCtx
    ln :: LineNumberNode
end

Base.empty(::Type{LocalTC}) =
    LocalTC(
        Store{Symbol, HMT}(),
        Store{Symbol, Symbol}(),
        InstRec[],
        LineNumberNode(1, :unknown))

const αβ = UInt8[('a':'z')...]

symgen(g::GlobalTC) =
    let i = g.count[] + 1
        g.count[] = i
        chars = UInt8[]
        while i != 0
            j = i%26
            push!(chars, αβ[j + 1])
            i = div(i, 26)
        end
        Symbol(chars)
    end
