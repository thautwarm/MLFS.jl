using MLFS
using PrettyPrint
using Setfield
using MLFS.HM
using MLStyle

g = empty(GlobalTC)
l = empty(LocalTC)
l = @set l.typeEnv = l.typeEnv[
    [
    :Int => T(Nom(:int64)),
    :Str => T(Nom(:str)),
    :Bool => T(Nom(:bool)),
    :Type => T(Nom(:Type))
    ]
]


stmts = @surf_toplevel begin
    f :: implicit[Int]
    f = 1
    (+) :: ((Int, Int) -> Int)
    (+) = @julia(((x, y),) -> x + y)
    
    g :: (implicit[Int] -> Int -> Int)
    g = x -> y -> x + y
    
    z :: (implicit[Int] -> Int)
    z = z -> g(z)
end;
    
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

pprintln([postInfer(result) for result in results])