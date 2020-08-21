export Signal, MLError
export UnboundTypeVar, UnboundVar
export UnusedAnnotation, InvalidSyntax
export DuplicateDeclaration, DuplicateInstanceError
export InstanceNotFound

export RecursiveType
export UnificationFail, NoError
export TypeVarEscape


@data Signal begin
    UnboundTypeVar(Symbol)
    UnboundVar(Symbol)
    UnusedAnnotation(Symbol)
    InvalidSyntax(String)
    DuplicateDeclaration(Symbol)
    DuplicateInstanceError(Vector{InstRec})
    InstanceNotFound(HMT)
    UnsolvedTypeVariables(Set{Var})

    RecursiveType
    UnificationFail
    TypePartialOrderError
    TypeVarEscape
    PrincipalTypeSearchError
    NoError
end

struct MLError <: Exception
    ln :: LineNumberNode  # where the error occurs
    signal :: Signal
end
