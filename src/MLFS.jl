module MLFS
using MLStyle
using HMRowUnification
using Setfield

export T
@active T(x) begin
    @match x begin
        App(Nom(:Type), x) => Some(x)
        _ => nothing
    end
end
(::Type{T})(x::HMT) = App(Nom(:Type), x)

include("Store.jl")
include("Core.jl")
include("Signals.jl")
include("AST/Surf.jl")
include("AST/IR.jl")
include("AST/SurfBuild.jl")
include("TypeClass.jl")
include("Infer.jl")

# Write your package code here.

end
