using MLFS
using PrettyPrint
using Setfield
using MLFS.HM

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
    
results = [f() for f in MLFS.inferDecls(g, l, stmts, Val(true))[1]];

pprintln(results)

pprintln(g.globalImplicits)