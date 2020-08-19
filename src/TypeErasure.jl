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
        App() => Any
        Implicit(t) => tyErase(t)
    end
end

function erasedToJuliaTy(e::ErasedType)
    ! = erasedToJuliaTy
    @match e begin
        ERArrow(a, r) => 
            :(Fn{$(!r), Tuple{$(!a)}})
        ERNom(name) =>
            @match name begin
                :int64 => :Int64
                :int32 => :Int32
                :int16 => :Int16
                :int8 => :Int8
                :float16 => :Float16
                :float32 => :Float32
                :float64 => :Float64
                :bool => :Bool
                :str => :String
                :char => :Char
                _ => :Any
            end
        ERTuple(xs) => :(Tuple{$(map(!, xs)...)})
        ERType(t) => :(Type{<: $(!t)})
        ERAny => :Any
    end
end