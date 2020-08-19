using MLFS
using Test
using PrettyPrint
using Setfield
using MLFS.HM
using Debugger


# @testset "MLFS.jl" begin
#     t = Surf.TArrow(Surf.TVar(:Int), Surf.TVar(:Int))
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


t1 = inferType(g, l, @surf_type Fn[a, (Int, a)] where a)
t2 = inferType(g, l, @surf_type Fn[a, Fn[b, (a, b)] where b] where a)
st = g.tcstate
v = st.new_tvar()
t1 = Arrow(v, t1)

t2_inst = st.instantiate(t2)
println(t2_inst)

println(st.unifyINST(t1, t2_inst))

@enter st.unifyINST(t1, t2_inst)