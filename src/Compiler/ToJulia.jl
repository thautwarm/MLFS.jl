export irToJulia

function erasedToJuliaTy(e::ErasedType)
    ! = erasedToJuliaTy
    @match e begin
        ERArrow(a, r) => :Function
        ERNom(name) =>
            @match name begin
                :int64 => :Int64
                :int32 => :Int32
                :int16 => :Int16
                :int8 => :Int8
                :float16 => :Float16
                :float32 => :Float32
                :float64 => :Float64
                :bool => :Bool
                :str => :String
                :char => :Char
                _ => :Any
            end
        ERTuple(xs) => :Tuple
        ERType(t) => Symbol
        ERAny => :Any
    end
end

function irToJulia(decl, ln::LineNumberNode)
    a = MLFS.HM.VerboseUN[]
    MLFS.HM.VerboseUN[] = true
    r = irToJulia_(decl, ln)
    MLFS.HM.VerboseUN[] = a
    r
end

function irToJulia_(decl::IR.Decl, ln::LineNumberNode)
    @match decl begin
        IR.Perform(e) => irToJulia_(e, ln)
        IR.Assign(s, t, e) => 
            let t = erasedToJuliaTy(tyErase(t))
                :($s :: $t = $(irToJulia_(e, ln)))
            end
    end
end

function irToJulia_(expr::IR.Expr, ln::LineNumberNode)
    @match expr begin
        IR.Expr(ln, t, e) =>
            let e = irToJulia_(e, ln)
                if t === nothing
                    e
                else
                    t = erasedToJuliaTy(tyErase(t))
                    :($e :: $t)
                end
            end
    end
end

function irToJulia_(expr::IR.ExprImpl, ln::LineNumberNode)
    @switch expr begin
    @case IR.ETypeVal(t)
        QuoteNode(Symbol(string(t)))
        
    @case IR.EExt(ex)
        ex

    @case IR.EVar(s)
        s
    @case IR.ELet(decls, expr)
        Expr(:block,
            ln,
            map(x -> irToJulia_(x, ln), decls)...,
            irToJulia_(expr, ln)
        )
    @case IR.EITE(a, b, c)
        Expr(:if,
            irToJulia_(a, ln),
            irToJulia_(b, ln),
            irToJulia_(c, ln),
        )
    @case IR.EFun(s, d)
        Expr(
            :function,
            Expr(:tuple, s),
            Expr(:block,
                ln,
                irToJulia_(d, ln)))
    @case IR.EApp(f, a)
        Expr(:call, irToJulia_(f, ln), irToJulia_(a, ln))
    @case IR.ETup(xs)
        Expr(:tuple, irToJulia_.(xs, [ln])...)
    @case IR.EInt(i, _) || IR.EFloat(i, _) ||
          IR.EStr(i) || IR.EChar(i) ||
          IR.EBool(i)
        i
    @case IR.EIm()
        error("should be eliminated")
    end
end