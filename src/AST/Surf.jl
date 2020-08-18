export Surf
module Surf

using MLStyle
abstract type TyExpr end
abstract type Decl end
abstract type Expr end

@data TyExpr begin
    TForall(Vector{Symbol}, TyExpr)
    TApp(TyExpr, TyExpr)
    TArrow(TyExpr, TyExpr)
    TTuple(Vector{TyExpr})
    TVar(Symbol)
    TSym(Symbol)
end

@data Decl begin
    DAnn(Symbol, TyExpr)
    DLoc(LineNumberNode)
    DBind(Symbol, Expr)
end

@data Expr begin
    ELoc(LineNumberNode, Expr)
    EVar(Symbol)
    EVal(Any)
    ELet(Vector{Decl}, Expr)
    EITE(Expr, Expr, Expr)
    EFun(Symbol, Expr)
    EApp(Expr, Expr)
    ETup(Vector{Expr})
end
end # module
