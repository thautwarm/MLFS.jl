module MLFS
using MLStyle
using Setfield
using DataStructures: list, cons, nil, LinkedList, Cons, Nil
include("TypedIO.jl")
import .TypedIO: fromVec, toVec, @typedIO


"""
forward declaration of IR.ExprImpl
"""
abstract type ExprImpl end

struct CFunc{A, B}
    f :: Function
end

_targs = [Symbol(:a_, i) for i = 1:3]
_args = [Symbol(:t_, i) for i = 1:3]
function (f::CFunc{R, Tuple{}})()::R where R
    f.f()
end

for i in 1:3
    let args = _args[1:i],
        targs = _targs[1:i],
        params = [:($a :: $t) for (a, t) in zip(args, targs)]

        Base.eval(MLFS, quote
            function (f::CFunc{R, Tuple{$(targs...)}})($(params...))::R where {R, $(targs...)}
                f.f($(args...))
            end
        end)
    end
end


include("HM.jl")
using .HM
export T
@active T(x) begin
    @match x begin
        App(Nom(:Type), x) => Some(x)
        _ => nothing
    end
end
(::Type{T})(x::HMT) = App(Nom(:Type), x)

include("Store.jl")
include("FS.jl")
include("Core.jl")
include("Signals.jl")
include("AST/Surf.jl")
include("AST/IR.jl")
include("AST/SurfBuild.jl")
include("TypeClass.jl")
include("Infer.jl")

include("TypeErasure.jl")
include("Compiler/ToJulia.jl")
include("Modular.jl")
# Write your package code here.

end
