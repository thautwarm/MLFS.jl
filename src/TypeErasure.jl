using MLStyle
export ErasedType, ERArrow, ERNom, ERTuple, ERAny
export tyErase

@data ErasedType begin
    ERArrow(ErasedType, ErasedType)
    ERNom(Symbol)
    ERTuple(Vector{ErasedType})
    ERType(ErasedType)
    ERAny
end

function tyErase(hm::HMT)
    @match hm begin
        Arrow(a, r) => ERArrow(tyErase(a), tyErase(r))
        Forall(_, p) => tyErase(p)
        Var() => error("type variable should be solved")
        Bound() => ERAny
        Tup(xs) => ERTuple(ErasedType[tyErase(x) for x in xs])
        Nom(x) => ERNom(x)
        App(Nom(:Type), x) => ERType(tyErase(x))
        App() => ERAny
        Implicit(t) => tyErase(t)
    end
end
