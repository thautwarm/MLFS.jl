module TypedIO
export toVec, fromVec, @typedIO, mkAltnertive, altnertiveToUnion

using MLStyle

function toVec end
function fromVec end

toVec(::Type{Any}, x::Expr) = ["Expr", string(x)]
toVec(::Type{Any}, x) = string(x)

fromVec(::Type{Any}, x::String) = Some(x)
fromVec(::Type{Any}, x::Vector) =
    if (length(x) === 2 && x[1] == "Expr")
        Some(Meta.parse(x[2]))
    else
        nothing
    end


toVec(::Type{Integer}, a::A) where A <: Signed = ["int", sizeof(a), string(a)]
toVec(::Type{Integer}, a::A) where A <: Unsigned = ["uint", sizeof(a), string(a)]
toVec(::Type{AbstractFloat}, a::A) where A <: AbstractFloat = ["float", sizeof(a), string(a)]

function fromVec(::Type{Integer}, a::Vector)
    tag = a[1]
    tag in ("int", "uint") || return nothing
    bit = a[2]
    s = a[3]
    if tag == "int"
        if bit === 1
            return Some(parse(Int8, s))
        elseif bit === 2
            return Some(parse(Int16, s))
        elseif bit === 4
            return Some(parse(Int32, s))
        elseif bit === 8
            return Some(parse(Int64, s))
        else
            return nothing
        end
    else
        if bit === 1
            return Some(parse(UInt8, s))
        elseif bit === 2
            return Some(parse(UInt16, s))
        elseif bit === 4
            return Some(parse(UInt32, s))
        elseif bit === 8
            return Some(parse(UInt64, s))
        else
            return nothing
        end
    end
end

function fromVec(::Type{AbstractFloat}, a::Vector)
    tag = a[1]
    tag == "float" || return nothing
    bit = a[2]
    s = a[3]
    if bit === 2
        return Some(parse(Float16, s))
    elseif bit === 4
        return Some(parse(Float32, s))
    elseif bit === 8
        return Some(parse(Float64, s))
    else
        return nothing
    end
end

toVec(::Type{Nothing}, ::Nothing) = nothing
fromVec(::Type{Nothing}, ::Nothing) = Some(nothing)

toVec(::Type{I}, x::I) where I <: Union{Int8, Int16, Int32, UInt8, UInt16, UInt32, Int64, UInt64} = I(x)
fromVec(::Type{I}, x::Integer) where I <: Union{Int8, Int16, Int32, UInt8, UInt16, UInt32,  Int64, UInt64} = Some(I(x))

toVec(::Type{Float64}, x::Float64) = x
fromVec(::Type{Float64}, x::Float64) = Some(x)

toVec(::Type{F}, x::F) where F <: AbstractFloat = x
fromVec(::Type{F}, x::AbstractFloat) where F <: AbstractFloat = Some(F(x))

toVec(::Type{String}, x::String) = x
fromVec(::Type{String}, x::String) = Some(x)

toVec(::Type{Char}, x::Char) = String([x])
fromVec(::Type{Char}, x::String) = Some(x[1])
fromVec(::Type{Char}, x::Char) = Some(x)

toVec(::Type{Symbol}, x::Symbol) = string(x)
fromVec(::Type{Symbol}, x::String) = Some(Symbol(x))

toVec(::Type{Bool}, x::Bool) = x
fromVec(::Type{Bool}, x::Bool) = Some(x)

toVec(::Type{Pair{A, B}}, x::Pair) where {A, B} = [toVec(A, x.first), toVec(B, x.second)]
function fromVec(::Type{Pair{A, B}}, x::Vector) where {A, B}
    length(x) === 2 && return nothing
    l = fromVec(A, x[1])
    l === nothing && return nothing
    r = fromVec(A, x[2])
    r === nothing && return nothing
    Pair{A, B}(l.value, r.value)
end

toVec(::Type{Vector{E}}, x::Vector) where E = [toVec(E, each) for each in x]
fromVec(::Type{Vector{E}}, x::Vector) where E = 
    let res = altnertiveToUnion(E)[]
        for v in x
            e = fromVec(E, v)
            e === nothing && return nothing
            push!(res, e.value)
        end
       Some(res)
    end

abstract type Altnertive end
struct UnionSig{A, B} <: Altnertive end
struct UnionEnd <: Altnertive end

toVec(::Type{UnionSig{A, B}}, x::A) where {A, B<:Altnertive} = toVec(A, x)
toVec(::Type{UnionSig{A, B}}, x) where {A, B <: Altnertive} = toVec(B, x)
toVec(::Type{UnionSig{A, UnionEnd}}, x::A) where A = toVec(A, x)

fromVec(_, _) = nothing

function fromVec(::Type{UnionSig{A, B}}, x) where {A, B<:Altnertive}
    l = fromVec(A, x)
    l === nothing && return fromVec(B, x)
    l
end

fromVec(::Type{UnionSig{A, UnionEnd}}, x) where A = fromVec(A, x)

function compileVariant(m::Module, T, targs)
    subpatterns = []
    yields = [Symbol(:_, i) for i = targs]
    fs = fieldnames(m.eval(T))
    @assert length(targs) == length(fs)
    
    tag = string(T)
    contentsToDict =  Any[tag]
    contentsFromDict = []
    n_targs = length(targs)
    for i in 1:n_targs
        targ = targs[i]
        targ = @match targ begin
            :(Union{$(uargs...)}) && if m.eval(Union) == Union end =>
                foldr(uargs, init=UnionEnd) do each, last
                    :($UnionSig{$each, $last})
                end
            _ => targ
        end
        arg = :(subject.$(fs[i]))
        push!(subpatterns, arg)
        push!(contentsToDict, :($toVec($targ, $arg)))
        push!(contentsFromDict, 
            quote
                $(yields[i]) = $fromVec($targ, subject[$(i + 1)])
                $(yields[i]) === nothing && return nothing
                $(yields[i]).value
            end)
    end
    to = T => :[$(contentsToDict...)]
    from = tag => :($length(subject) !== $(1 + n_targs) ? nothing : Some($T($(contentsFromDict...))))
    to, from

end

function asTypedVec(m::Module, absT::Any, fields::AbstractVector)
    variantsToDict = []
    variantsFromDict = []
    for field in fields
        @switch field begin
        @case :($T($(targs...)))
            to, from = compileVariant(m, T, targs)
            push!(variantsToDict,  to)
            push!(variantsFromDict, from)
            nothing
        @case ::LineNumberNode
            nothing
        end
    end

    variantsToDictExpr = foldr(variantsToDict, init = Expr(:call, error, "unknown $absT")) do (T, ret), last
        Expr(:if, :(subject isa $T), ret, last)
    end

    variantsFromDictExpr = foldr(variantsFromDict, init = Expr(:call, error, "cannot parse to $absT")) do (tag, ret), last
        Expr(:if, :(subject[1] == $tag), ret, last)
    end
    
    quote
        function $TypedIO.fromVec(::Type{$absT}, subject::Vector)
            $variantsFromDictExpr
        end

        function $TypedIO.toVec(::Type{$absT}, subject::$absT)
            $variantsToDictExpr
        end
    end
end

function typedIORecord(__module__, tname, targs)
    (_, to), (tag, from) = compileVariant(__module__, tname, targs)
    quote
        function $TypedIO.fromVec(::Type{$tname}, subject::Vector)
            $tag !== subject[1] && return nothing
            $from
        end

        function $TypedIO.toVec(::Type{$tname}, subject::$tname)
            $to
        end
    end
end

function typedIO(ex, __module__)
    @match ex begin
        :($absT = $(Expr(:block, stmts...))) => TypedIO.asTypedVec(__module__, absT, stmts)
        :($T($(targs...))) => typedIORecord(__module__, T, targs)
        :($absT => $(from::Symbol)) =>
            quote
                @inline function $TypedIO.toVec(::Type{$absT}, subject::$absT)
                    $TypedIO.toVec(::Type{$from}, subject)
                end
                @inline function $TypedIO.fromVec(::Type{$absT}, subject)
                    $TypedIO.fromVec(::Type{$from}, subject)
                end
            end
    end
end

macro typedIO(ex)
    esc(typedIO(ex, __module__))
end

@typedIO LineNumberNode(Int64, Union{Nothing, Symbol})

function mkAltnertive(head::Type, ts::Type...)
    isempty(ts) && return head
    foldr(ts, init = UnionSig{head, UnionEnd}) do each, last
        UnionSig{each, last}
    end
end

altnertiveToUnion(::Type{UnionSig{A, UnionEnd}}) where A = A
altnertiveToUnion(::Type{UnionSig{A, Tl}}) where {A, Tl} = Union{A, altnertiveToUnion(Tl)}
altnertiveToUnion(::Type{UnionEnd}) = Union{}
altnertiveToUnion(a) = a

const exprCommon = mkAltnertive(Expr, QuoteNode, Float64, Int, LineNumberNode, Char, Bool, Symbol, Nothing)

@typedIO QuoteNode(exprCommon)

@typedIO Expr(Symbol, Vector{exprCommon})

end

# using .TypedIO
# using MLStyle

# @data A begin
#     A1(Int, Int)
#     A2()
# end

# @typedIO A = begin
#     A1(Int, Int)
#     A2()
# end

# struct C
#     a :: Int
# end
# @typedIO C(Int)

# @data B begin
#     B1(A, Union{Nothing, A})
#     B2(Vector{A}, C)
# end

# @typedIO B = begin
#     B1(A, Union{Nothing, A})
#     B2(Vector{A}, C)
# end

# println(toVec(A, A1(1, 2)))
# println(fromVec(A, toVec(A, A1(1, 2))))

# a1 = A1(1, 2)
# a2 = A1(3, 4)
# a3 = A2()

# b1 = B2(A[a1, a2, a3], C(1))
# b2 = B1(a2, a3)
# b3 = B1(a2, nothing)

# println(toVec(Vector{B}, [b1, b2, b3]))
# println(fromVec(Vector{B}, toVec(Vector{B}, [b1, b2, b3])))
