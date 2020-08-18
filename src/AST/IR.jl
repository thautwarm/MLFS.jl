export IR
module IR
using MLStyle
using MLFS.HM: HMT
import MLFS.HM

TForall = HM.Forall
TApp = HM.App
TArrow = HM.Arrow
TTuple = HM.Tup
TVar = HM.Var
TFresh = HM.Fresh
abstract type ExprImpl end

struct Expr
    ln :: LineNumberNode
    ty :: HMT
    expr :: ExprImpl
end

@data Decl begin
    Perform(impl::Expr)
    Assign(sym::Symbol, ty::HMT, impl::Expr)
end

IntType = Union{Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64}
FloatType = Union{Float16, Float32, Float64}

@data ExprImpl begin
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
    EInst(HMT)
    # specialization
    ETApp(Expr, Vector{Pair{Symbol, HMT}})
end
end # module