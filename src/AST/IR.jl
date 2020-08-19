export IR
module IR
using MLStyle
using MLFS.HM: HMT
import MLFS.HM
import MLFS: InstResolCtx
export applyImplicits, applyExplicits
using Setfield: @set
abstract type ExprImpl end

struct Expr
    ln :: LineNumberNode
    ty :: Union{Nothing, HMT}
    expr :: ExprImpl
end

@data Decl begin
    Perform(impl::Expr)
    Assign(sym::Symbol, ty::HMT, impl::Expr)
end

IntType = Union{Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64}
FloatType = Union{Float16, Float32, Float64}

@data ExprImpl begin
    ETypeVal(HMT)
    EExt(Any)
    EVar(Symbol)
    EVal(Any)
    ELet(Vector{Decl}, Expr)
    EITE(Expr, Expr, Expr)
    EFun(Symbol, Expr)
    EApp(Expr, Expr)
    ETup(Vector{Expr})
    EInt(IntType)
    EFloat(FloatType)
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
        e = EApp(e, explicit)
    end
    Expr(ln, targety, e)
end

end # module