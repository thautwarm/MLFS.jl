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
    gensym :: ExprImpl   # the actual gensym(IR level) to access this instance
    isPruned :: Bool     # is the instance type pruned?
end
@typedIO InstRec(HMT, LineNumberNode, ExprImpl, Bool)

const InstResolCtx = LinkedList{InstRec}

function toVec(t::Type{LinkedList{E}}, x::Cons{E}) where E
    [toVec(E, x.head), toVec(t, x.tail)]
end

function toVec(::Type{LinkedList{E}}, ::Nil{E}) where E
    nothing
end

function fromVec(::Type{LinkedList{E}}, x::Nothing) where E
    Some(nil(E))
end

function fromVec(t::Type{LinkedList{E}}, x::Vector) where E
    length(x) !== 2 && return nothing
    head = fromVec(E, x[1])
    head === nothing && return nothing
    tail = fromVec(t, x[2])
    tail === nothing && return nothing
    Some(cons(head.value, tail.value))
end

InstRec(t::HMT, ln::LineNumberNode, gensym::Symbol, isPruned::Bool) = InstRec(t, ln, IR.EVar(gensym), isPruned)

const arrowClass = Nom(:arrow_class)
const generalClass = Nom(:general_class)

getTConsHead(h::HMT) =
    @match h begin
        Nom(_) => h
        App(t, _) ||
        Forall(_, t) => getTConsHead(t)
        Arrow(Implicit(_), t) => getTConsHead(t)
        Arrow(_, _) => arrowClass
        _ => generalClass
    end

struct GlobalTC
    tcstate :: TCState
    count :: Ref{UInt}
    globalImplicits :: Dict{Nom, Vector{InstRec}}
    globalImplicitDeltas :: Dict{Nom, Int32}
    queries :: Vector{Pair{String, HMT}}
    moduleName :: Symbol
end

Base.show(io::IO, ::GlobalTC) = Base.show(io, "<GlobalTC>") 


Base.empty(::Type{GlobalTC}, moduleName::Symbol = :main) =
    GlobalTC(
        mk_tcstate(HMT[]),
        Ref(UInt(0)),
        Dict{Nom, Vector{InstRec}}(),
        Dict{Nom, UInt32}(),
        Pair{String, HMT}[],
        moduleName
    )

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
        nil(InstRec),
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
        Symbol(:|, g.moduleName, :|, Symbol(chars))
    end
