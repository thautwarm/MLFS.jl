module MLFS
using MLStyle
using Setfield
using FunctionWrappers
CFunc = FunctionWrappers.FunctionWrapper

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

# Write your package code here.

end
