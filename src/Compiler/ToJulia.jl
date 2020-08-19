export irToJulia

function irToJulia(decl::IR.Decl, ln::LineNumberNode)
    @match decl begin
        IR.Perform(e) => irToJulia(e, ln)
        IR.Assign(s, t, e) => 
            let t = erasedToJuliaTy(tyErase(t))
                :($s :: $t = $(irToJulia(e, ln)))
            end
    end
end

function irToJulia(expr::IR.Expr, ln::LineNumberNode)
    @match expr begin
        IR.Expr(ln, t, e) =>
            let e = irToJulia(e, ln)
                if t === nothing
                    e
                else
                    erased = tyErase(t)
                    cons = erased isa ERArrow
                    t = erasedToJuliaTy(erased)
                    cons ?  :($t($e)) : :($e :: $t)
                end
            end
    end
end

function irToJulia(expr::IR.ExprImpl, ln::LineNumberNode)
    @switch expr begin
    @case IR.ETypeVal(t)
        erasedToJuliaTy(tyErase(t))

        
    @case IR.EExt(ex)
        ex

    @case IR.EVar(s)
        s
    @case IR.EVal(l)
        l
    @case IR.ELet(decls, expr)
        Expr(:block,
            ln,
            map(x -> irToJulia(x, ln), decls)...,
            irToJulia(expr, ln)
        )
    @case IR.EITE(a, b, e)
        Expr(:if,
            irToJulia(a, ln),
            irToJulia(b, ln),
            irToJulia(c, ln),
        )
    @case IR.EFun(s, d)
        Expr(
            :function,
            Expr(:tuple, s),
            Expr(:block,
                ln,
                irToJulia(d, ln)))
    @case IR.EApp(f, a)
        Expr(:call, irToJulia(f, ln), irToJulia(a, ln))
    @case IR.ETup(xs)
        Expr(:tuple, irToJulia.(xs, [ln])...)
    @case IR.EInt(i) || IR.EFloat(i) ||
          IR.EStr(i) || IR.EChar(i) ||
          IR.EBool(i)
        i
    @case IR.EIm()
        error("should be eliminated")
    end
end