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
    # println(inferType(g, l, t))
    exp = @surf_expr f(1)
    # pprintln(exp)
    # pprintln(MLFS.inferExpr(g, l, exp)(NoProp))
    # Write your tests here.

    stmts = @surf_toplevel begin
        g :: (a -> a) where a
        g = x -> x

        h :: (((a -> a) where a) -> (Int, Str))
        h = f -> (f(1), f("1"))

        id :: ((a -> a) where a)
        id = x -> x

        choose :: ((a -> a -> a) where a)
        choose = x -> y -> x

        choose_id = choose(id)
        choose_id.?(hint_choose_id)
        
        J :: Fn[a, Fn[b, (a, b)] where b] where a
        J = x -> y -> (x, y)

        # c :: Fn[a, (Int, a)] where a
        c = J(1)
        c.?(hint_c)

        pair = (c(1), c("a")).?(hint_pair)
    end
    
    for f in MLFS.inferDecls(g, l, stmts)[1]
        f()
    end

    show_hints(g)

    
end
