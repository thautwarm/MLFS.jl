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
    TNew(Symbol)
    TQuery(String, TyExpr)
end

@data Decl begin
    DAnn(Symbol, TyExpr)
    DLoc(LineNumberNode)
    DBind(Symbol, Expr)
    DQuery(String, Symbol)
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
    EExt(Any)
    EQuery(String, Expr)
end

end # module
