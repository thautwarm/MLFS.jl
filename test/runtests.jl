using MLFS
using Test
using PrettyPrint
using Setfield
using MLFS.HM

@testset "MLFS.jl" begin
    t = Surf.TArrow(Surf.TVar(:Int), Surf.TVar(:Int))
    g = empty(GlobalTC)
    l = empty(LocalTC)
    l = @set l.typeEnv = l.typeEnv[
        [
        :Int => T(Nom(:int64)),
        :Str => T(Nom(:str)),
        :f => Arrow(Nom(:int64), Nom(:int64))
        ]
    ]
    l = @set l.symmap = l.symmap[
            :f => :f_0xa1
        ]
    println(inferType(g, l, t))
    exp = @surf_expr f(1)
    pprintln(exp)
    pprintln(MLFS.inferExpr(g, l, exp)(NoProp))
    # Write your tests here.

    stmts = @surf_toplevel begin
        g :: (a -> a) where a
        g = x -> x

        h :: (((a -> a) where a) -> (Int, Str))
        h = f -> (f(1), f("1"))
    end
    pprintln([f() for f in MLFS.inferDecls(g, l, stmts)[1]])
    for (i, each) in enumerate(g.tcstate.tctx)
        println(i, ": ", each)
    end
end
