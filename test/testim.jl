using MLFS
using PrettyPrint
using Setfield
using MLFS.HM
using MLStyle
it = Symbol(:int, sizeof(Int) * 8)
g = empty(GlobalTC)
l = empty(LocalTC)
l = @set l.typeEnv = l.typeEnv[
    [
    :Int => T(Nom(it)),
    :Str => T(Nom(:str)),
    :Bool => T(Nom(:bool)),
    :Type => T(Nom(:Type))
    ]
]


stmts = @surf_toplevel begin
    implicitStr :: implicit[Str]
    implicitStr = "114514"
    implicitInt :: implicit[implicit[Str] -> Int]
    implicitInt = @julia(x -> parse(Int, x))
    (+) :: ((Int, Int) -> Int)
    (+) = @julia(((x, y),) -> x + y)
    fun :: (implicit[Int] -> Int -> Int)
    fun = x -> y -> x + y
    var :: Int
    var = fun(1)
end;
begin    
    results = inferModule(g, l, stmts);

    prune = g.tcstate.prune


    function postInfer(root::IR.Decl)
        @match root begin
            IR.Perform() => IR.gTrans(postInfer, root)
            IR.Assign(a, t, e) => 
                IR.Assign(a, prune(t), postInfer(e))
        end
    end

    function postInfer(root::IR.Expr)
        @match root begin
            IR.Expr(ln, ty, expr) =>
                let expr = postInferE(expr, ln),
                    ty = ty === nothing ? nothing : prune(ty)
                    
                    IR.Expr(ln, ty, expr)
                end 
        end
    end

    function postInferE(root::IR.ExprImpl, ln::LineNumberNode)
        @match root begin
            IR.EIm(expr, t, insts) => 
                let expr = postInfer(expr),
                    t = prune(t)

                    IR.EApp(expr, instanceResolve(g, insts, t, ln))
                end
            IR.ETypeVal(t) => IR.ETypeVal(prune(t))
            _ => IR.gTrans(postInfer, root)
        end
    end

    pprintln(results)
    pprintln(g.globalImplicits)
    solvedIRs = [postInfer(result) for result in results]
end; open("test/testim_gen.jl", "w") do f; println(f, "using FunctionWrappers; Fn = FunctionWrappers.FunctionWrapper"); println(f,Expr(:let, Expr(:block),
    irToJulia(IR.ELet(solvedIRs,IR.Expr(LineNumberNode(1),nothing, IR.EInt(0))), LineNumberNode(1))))
end
