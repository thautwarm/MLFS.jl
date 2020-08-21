export IR
module IR
using MLStyle
using MLFS.HM: HMT
import MLFS.HM
import MLFS: InstResolCtx, ExprImpl
using MLFS.TypedIO: @typedIO
export applyImplicits, applyExplicits
using Setfield: @set

@as_record struct Expr
    ln :: LineNumberNode
    ty :: Union{Nothing, HMT}
    expr :: ExprImpl
end

@typedIO Expr(LineNumberNode, Union{Nothing, HMT}, ExprImpl)

@data Decl begin
    Perform(impl::Expr)
    Assign(sym::Symbol, ty::HMT, impl::Expr)
end

@typedIO Decl = begin
    Perform(Expr)
    Assign(Symbol, HMT, Expr)
end


@data ExprImpl′ <: ExprImpl begin
    ETypeVal(HMT)
    EExt(Any)
    EVar(Symbol)
    ELet(Vector{Decl}, Expr)
    EITE(Expr, Expr, Expr)
    EFun(Symbol, Expr)
    EApp(Expr, Expr)
    ETup(Vector{Expr})
    EInt(Int64, UInt8)
    EFloat(Float64, UInt8)
    EStr(String)
    EChar(Char)
    EBool(Bool)
    EIm(Expr, HMT, InstResolCtx)
end

@typedIO ExprImpl = begin
    ETypeVal(HMT)
    EExt(Any)
    EVar(Symbol)
    ELet(Vector{Decl}, Expr)
    EITE(Expr, Expr, Expr)
    EFun(Symbol, Expr)
    EApp(Expr, Expr)
    ETup(Vector{Expr})
    EInt(Int64, UInt8)
    EFloat(Float64, UInt8)
    EStr(String)
    EChar(Char)
    EBool(Bool)
    EIm(Expr, HMT, InstResolCtx)
end


function applyImplicits(e::ExprImpl, implicits::Vector{<:HMT}, finalty::HMT, ln::LineNumberNode, localImplicits::InstResolCtx)
    for im in implicits
        e = EIm(Expr(ln, nothing, e), im, localImplicits)
    end
    Expr(ln, finalty, e)
end

function applyExplicits(e::ExprImpl, explicits::Vector{Expr}, targety::HMT, ln::LineNumberNode)
    for explicit in explicits
        exp = Expr(ln, nothing, e)
        e = EApp(exp, explicit)
    end
    Expr(ln, targety, e)
end

function gTrans(self::Function, root::Decl)
    @match root begin
        Perform(impl) => Perform(self(impl))
        Assign(sym, t, impl) => Assign(sym, t, self(impl))
    end
end

function gTrans(self::Function, root::Expr)
    self(root.expr)
end

function gTrans(self::Function, root::ExprImpl)
    @match root begin
        ETypeVal() || EExt() || EVar() || EChar() ||
        EStr() || EBool() || EFloat() || EInt() =>
           root

        ELet(decls, expr) =>
            ELet(IR.Decl[self(decl) for decl in decls], self(expr))
        EITE(a1, a2, a3) =>
            EITE(self(a1), self(a2), self(a3))
        EFun(s, e) => EFun(s, self(e))
        EApp(f, a) => EApp(self(f), self(a))
        ETup(xs) => ETup(IR.Expr[self(x) for x in xs])
        EIm(expr, t, insts) => EIm(self(expr), t, insts)
    end
end


function gTransCtx(self::Function, ctx::Ctx, root::Decl) where Ctx
    !(root) = self(ctx, root)
    @match root begin
        Perform(impl) => Perform(!impl)
        Assign(sym, t, impl) => Assign(sym, t, !impl)
    end

end

function gTransCtx(self::Function, ctx::Ctx, root::Expr) where Ctx
    self(ctx, root.expr)
end

function gTransCtx(self::Function, ctx::Ctx, root::ExprImpl) where Ctx
    !(root) = self(ctx, root)
    @match root begin
        ETypeVal() || EExt() || EVar() || EChar() ||
        EStr() || EBool() || EFloat() || EInt() =>
           root

        ELet(decls, expr) =>
            ELet(IR.Decl[!decl for decl in decls], !expr)
        EITE(a1, a2, a3) =>
            EITE(!a1, !a2, !a3)
        EFun(s, e) => EFun(s, !e)
        EApp(f, a) => EApp(!f, !a)
        ETup(xs) => ETup(IR.Expr[!x for x in xs])
        EIm(expr, t, insts) => EIm(!expr, t, insts)
    end
end

end # module