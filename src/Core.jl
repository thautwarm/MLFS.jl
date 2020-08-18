export arrowClass, generalClass, getTConsHead
export InstRec, GlobalTC, LocalTC
const TCState = Base._return_type(mk_tcstate, (Vector{HMT}, Function))
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
end

Base.empty(::Type{GlobalTC}) =
    GlobalTC(mk_tcstate(HMT[]), Ref(UInt(0)), Dict{Nom, InstanceNotFound}())

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
