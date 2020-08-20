export Surf
module Surf

using MLStyle
using MLFS.TypedIO: @typedIO

abstract type TyExpr end
abstract type Decl end
abstract type Expr end

@data TyExpr begin
    TForall(Vector{Symbol}, TyExpr)
    TApp(TyExpr, TyExpr)
    TArrow(TyExpr, TyExpr)
    TTuple(Vector{TyExpr})
    TImplicit(TyExpr)
    TVar(Symbol)
    TSym(Symbol)
    TNew(Symbol)
    TQuery(String, TyExpr)
end

@typedIO TyExpr = begin
    TForall(Vector{Symbol}, TyExpr)
    TApp(TyExpr, TyExpr)
    TArrow(TyExpr, TyExpr)
    TTuple(Vector{TyExpr})
    TImplicit(TyExpr)
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

@typedIO Decl = begin
    DAnn(Symbol, TyExpr)
    DLoc(LineNumberNode)
    DBind(Symbol, Expr)
    DQuery(String, Symbol)
end


@data Expr begin
    ELoc(LineNumberNode, Expr)
    EVar(Symbol)
    EVal(Union{String, Char, Bool, Integer, AbstractFloat})
    ELet(Vector{Decl}, Expr)
    EITE(Expr, Expr, Expr)
    EFun(Symbol, Expr)
    EApp(Expr, Expr)
    ETup(Vector{Expr})
    EExt(Any)
    EQuery(String, Expr)
end

@typedIO Expr = begin
    ELoc(LineNumberNode, Expr)
    EVar(Symbol)
    EVal(Union{String, Char, Bool, Integer, AbstractFloat})
    ELet(Vector{Decl}, Expr)
    EITE(Expr, Expr, Expr)
    EFun(Symbol, Expr)
    EApp(Expr, Expr)
    ETup(Vector{Expr})
    EExt(Any)
    EQuery(String, Expr)
end

@as_record struct ModuleRecord
    name :: Symbol
    imports :: Vector{Pair{Symbol, Symbol}}
    decls :: Vector{Decl}
end

@typedIO ModuleRecord(Symbol, Vector{Pair{Symbol, Symbol}}, Vector{Decl})

end # module
