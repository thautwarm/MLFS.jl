using MLFS
using Test
using PrettyPrint
using Setfield
using MLFS.HM
using MLFS.TypedIO

# @testset "MLFS.jl" begin
#     it = Symbol(:i, sizeof(Int) * 8)
#     t = Surf.TArrow(Surf.TVar(:Int), Surf.TVar(:Int))
#     g = empty(GlobalTC)
#     l = empty(LocalTC)
#     l = @set l.typeEnv = l.typeEnv[
#         [
#         :Int => T(Nom(it)),
#         :Str => T(Nom(:str)),
#         :Bool => T(Nom(:bool)),
#         :f => Arrow(Nom(it), Nom(it)),
#         :Type => T(Nom(:Type))
#         ]
#     ]
#     l = @set l.symmap = l.symmap[
#             :f => :f_0xa1
#         ]
#     # println(inferType(g, l, t))
#     exp = @surf_expr f(1)
#     # pprintln(exp)
#     # pprintln(MLFS.inferExpr(g, l, exp)(NoProp))
#     # Write your tests here.

#     stmts = @surf_toplevel begin
#         g :: (a -> a) where a
#         g = x -> x

#         h :: (((a -> a) where a) -> (Int, Str))
#         h = f -> (f(1), f("1"))

#         id :: ((a -> a) where a)
#         id = x -> x

#         choose :: ((b -> b -> b) where b)
#         choose = x -> y -> x

#         choose_id = choose(id)
#         # choose_id.?(hint_choose_id)
        
#         J :: Fn[a, Fn[b, (a, b)] where b] where a
#         J = x -> y -> (x, y)

#         # c :: Fn[a, (Int, a)] where a
#         c = J(1)
#         # c.?(hint_c)

#         pair = (c(1), c("a")) # .?(hint_pair)

#         choose_id′ :: ((Int -> Int) -> (Int -> Int))
#         choose_id′ = (choose(id)) # .?(stronger_assumptions_1)

#         choose_id′ = (choose(id)) # .?(stronger_assumptions_2)

#         choose_id′ :: Fn[Fn[c, c], Fn[c, c]] where c
#         choose_id′ =
#             choose(id) # .?(stronger_assumptions_3)

#         choose_id′ :: ((Fn[a, a] where a) -> (Int -> Int))
#             choose_id′ = (choose(id)) # .?(stronger_assumptions_4)
  
    
#         choose_id′′ :: ((a where a) -> (Int -> Int))
#         choose_id′′ = choose_id′

#         choose_id′ :: ((Fn[a, a] where a) -> (Fn[a, a] where a))
#             choose_id′ = (choose(id)) # .?(stronger_assumptions_5)

#         choose_id′′ :: ((a where a) -> (Int -> Int))
#         choose_id′′ =
#             let choose_id_ :: ((Fn[a, a] where a) -> (Int -> Int)),
#                 choose_id_ = choose(id)
                
#                 choose_id_
#             end
    
#         # choose_id′ :: ((Int -> Int) -> (Int -> Int))
#         # choose_id′ = choose_id

#         int_functional :: Fn[Fn[Int, Int], Int]
#         int_functional = f -> f(1)

#         int_number = int_functional(id) # .?(app_functional)

#         Vec :: Type[NewType(Vec)]
#         Vec = Vec

#         mkVec :: (() -> Vec[A]) where A
#         mkVec =  (@julia begin
#             T -> T[]
#         end)(A)

#         vecLen :: (Vec[A] -> Int) where A
#         vecLen = @julia begin
#             (x::Vector) -> length(x)
#         end

#         # mkVec.?(vec)

#         imVec :: implicit[Vec[Int]]
#         imVec = mkVec(())
#         # imVec.?(imVec)

#         ctxVecLen :: Fn[implicit[Vec[Int]], Int]
#         ctxVecLen =  x -> vecLen(x)

#         (+) :: Fn[Int, Fn[Int, Int]]
#         (+) = @julia(+)

#         ctxOp :: Fn[implicit[Vec[Int]], Int]
#         ctxOp = vec -> ctxVecLen.?("implicit_instance")

#         ctxVecLen.?("implicit_meth")

#         Eq :: Type[NewType(Eq)]
    
#         makeEqList :: implicit[(implicit[Eq[a]] -> Eq[a]) where a]
#         makeEqList = @julia(nothing)

#         getEq :: (Eq[a] -> (a, a) -> Bool) where a
#         getEq = @julia(nothing)

#         (==) :: (implicit[Eq[a]] -> (a, a) -> Bool) where a
#         (==) = eq -> ab -> getEq(eq)(ab)

#         aVec :: Vec[Int]
#         aVec = mkVec(())

#         _ = (aVec == aVec).?(instance_not_found)        

#         # List :: Type[NewType(List)]
#         # List = List

#         # Nil :: List[A] where A
#         # Nil = @julia begin
#         #     ()
#         # end

#         # Cons :: (A -> List[A] -> List[A]) where A
#         # Cons = (@julia begin
#         #     t -> x -> y -> (x :: t, y)
#         # end)(A)

#         # Cons.?(cons)
#         # Addable :: Type[NewType(Add1)]

#         # constructAddable :: ((A -> A -> A) -> Addable[A]) where A
#         # constructAddable = @julia begin
#         #     function constructAddable(a::Any)
#         #         a
#         #     end
#         # end

#         # getFieldA :: implict[Field[constructAddable[A], :plus, (A -> A -> A)] where A]
#         # getFieldA = @julia begin
#         #     function getFieldA(a::Any)
#         #         a
#         #     end
#         # end

#         # add :: Fn[implicit[Addable[A]], A -> A -> A] where A
#         # add = addable -> l -> r ->
#         #     addable.plus(l)(r)

#     end
    
#     for f in MLFS.inferDecls(g, l, stmts)[1]
#         f()
#     end

#     show_hints(g)

    
# end


# include("testim.jl")
# open("testim_gen.jl") do f
#     println(read(f, String))
# end

include("a.jl")