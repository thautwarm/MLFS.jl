export UnboundTypeVar, InvalidSyntax, RecursiveType, UnificationFail
export TypePartialOrderError, TypeVarEscape, PrincipalTypeSearchError, NoError
export Signal, MLError

@data Signal begin
    UnboundTypeVar(Symbol)
    UnboundVar(Symbol)
    UnusedAnnotation(Symbol)
    InvalidSyntax(String)
    DuplicateDeclaration(Symbol)
    DuplicateInstanceError(Vector{InstRec})
    InstanceNotFound(HMT)

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
