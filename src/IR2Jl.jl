export ir2jl
function ir2jl(directory::String, o::String)
    decls = IR.Decl[]
    for each in readdir(directory)
        each = joinpath(directory, each)
        isfile(each) || continue
        endswith(each, ".mlfso") || continue


        d = open(each) do f
            JSON.Parser.parse(read(f, String))
        end
        solvedIRs = fromVec(Vector{IR.Decl}, d).value
        append!(decls, solvedIRs)
    end
    ir = IR.ELet(decls, IR.Expr(LineNumberNode(1),nothing, IR.EInt(0, 8)))
    jl_exp = irToJulia(ir, LineNumberNode(1))
    open(o, "w") do ff
        println(ff, Expr(:let, Expr(:block), jl_exp))
    end
end
