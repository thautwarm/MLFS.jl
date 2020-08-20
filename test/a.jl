
using MLFS
using PrettyPrint
using Setfield
using MLFS.HM
using MLFS.TypedIO
using MLStyle
using JSON

stmts = @surf_toplevel begin
    x :: i64
    x = 1
end

mr = Surf.ModuleRecord(:main, [], stmts)
open("a.mlfs", "w") do f
    write(f, JSON.json(toVec(Surf.ModuleRecord, mr)))
end

smlfsCompile([:A => "a.mlfs"], String[], "a")


open("a.mlfso") do f
    open("a_gen.jl", "w") do ff
        d = JSON.Parser.parse(read(f, String))
        solvedIRs = fromVec(Vector{IR.Decl}, d).value

        ir = IR.ELet(solvedIRs,IR.Expr(LineNumberNode(1),nothing, IR.EInt(0, 8)))
        jl_exp = irToJulia(ir, LineNumberNode(1))
        println(ff, Expr(:let, Expr(:block), jl_exp))
    end
end

