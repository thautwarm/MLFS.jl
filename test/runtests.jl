using MLFS
using Test
using PrettyPrint
using Setfield
using HMRowUnification

@testset "MLFS.jl" begin
    t = Surf.TArrow(Surf.TVar(:Int), Surf.TVar(:Int))
    g = empty(GlobalTC)
    l = empty(LocalTC)
    l = @set l.typeEnv = l.typeEnv[
        :Int => T(Nom(:Int))
    ]    
    println(inferType(g, l, t))
    # Write your tests here.
end
