export IR
module IR
using MLStyle
import HMRowUnification
using HMRowUnification: HMT


TForall = HMRowUnification.Forall
TApp = HMRowUnification.App
TArrow = HMRowUnification.Arrow
TTuple = HMRowUnification.Tup
TVar = HMRowUnification.Var
TFresh = HMRowUnification.Fresh
abstract type ExprImpl end

struct Expr
    ln :: LineNumberNode
    ty :: UInt
    expr :: ExprImpl
end

struct Decl
    sym :: Symbol
    ty :: UInt
    impl :: Expr
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
    EBool(Bool)
    EInst(HMT)
end
end # module