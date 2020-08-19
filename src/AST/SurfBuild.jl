export @surf_expr, @surf_toplevel, @surf_type
function surf_type(s::Symbol)
    Surf.TVar(s)
end

function surf_type(ex)
    @match ex begin
        :(Fn[$a, $b]) => Surf.TArrow(surf_type(a), surf_type(b))
        :($a.?($label)) => Surf.TQuery(string(label), surf_type(a))
        :($f[$a]) => Surf.TApp(surf_type(f), surf_type(a))
        Expr(:tuple, args...) =>
            Surf.TTuple(Surf.TyExpr[surf_type(a) for a in args])
        Expr(:->, a, Expr(:block, ::LineNumberNode, b)) =>
            Surf.TArrow(surf_type(a), surf_type(b))
        :($t where {$(tvars...)}) =>
            Surf.TForall(Symbol[tvars...], surf_type(t))
    end
end

function surf_expr(n::Symbol)
    Surf.EVar(n)
end

function surf_expr(i::Union{Integer, AbstractString, AbstractChar, AbstractFloat})
    Surf.EVal(i)
end

function surf_expr(exp::Expr)
    @match exp begin
    :($a.?($label)) => Surf.EQuery(string(label), surf_expr(a))
    :($f($(args...))) =>
        length(args) === 1 ?
        Surf.EApp(surf_expr(f), surf_expr(args[1])) :
        Surf.EApp(
            surf_expr(f),
            Surf.ETup(Surf.Expr[surf_expr(arg) for arg in args]))
    Expr(:tuple, elts...) =>
        Surf.ETup(Surf.Expr[surf_expr(arg) for arg in elts])
    
    Expr(:->, s::Symbol, exp && Expr(:block, ln::LineNumberNode, _...)) =>
        Surf.ELoc(
            ln,
            Surf.EFun(s, surf_expr(exp)))
        
    Expr(:if, cond, arm1, arm2) =>
        Surf.EInt(surf_expr(cond), surf_expr(arm1), surf_expr(arm2))
    
    Expr(:let, :($_ = $_) && bind, body) =>
        surf_expr(Expr(:let, Expr(:block, bind), body))
    
    Expr(:let, Expr(:block, decls...), body) =>
        Surf.ELet(surf_decls(decls), surf_expr(body))
    
    Expr(:block, suite...) =>
        begin
            if isempty(suite)
                Surf.ETup(Surf.Expr[])
            else
                ret = surf_expr(suite[end])
                foldr((@view suite[1:end-1]), init=ret) do new, last
                    @match new begin
                        ln::LineNumberNode =>
                            @match last begin
                                Surf.ELet(vec, _) =>
                                    begin
                                        pushfirst!(vec, DLoc(ln))
                                        last
                                    end
                                _ => Surf.ELoc(ln, last)
                            end
                        :($_ :: $_) || :($_ = $_) || :($_.?($_)) => 
                            @match last begin
                                Surf.ELet(vec, _) =>
                                    begin
                                        pushfirst!(vec, surf_decl(new))
                                        last
                                    end
                                _ => Surf.ELet([surf_decl(new)], last)
                            end
                        _ => Surf.ELet([Surf.DBind(:_, surf_expr(new))], last)
                    end
                end
            end
        end
    end
end

surf_decl(decl::Any) = @match decl begin
    :($(x::Symbol).?($label)) => Surf.DQuery(string(label), x)
    :($(x::Symbol) :: $t) => Surf.DAnn(x, surf_type(t))
    :($(x::Symbol) = $v) => Surf.DBind(x, surf_expr(v))
    ln::LineNumberNode => Surf.DLoc(ln)
end

function surf_decls(decls::AbstractVector)
    Surf.Decl[surf_decl(decl) for decl in decls]
end

macro surf_toplevel(ex)
    @match ex begin
        Expr(:block, stmts...) => surf_decls(stmts)
        _ => error("syntax error")
    end
end

macro surf_expr(ex)
    surf_expr(ex)
end

macro surf_type(ex)
    surf_type(ex)
end