import Base
export TypeInfo, InstTo, InstFrom, NoProp
export TypeInfoKind, InstToKind, InstFromKind, NoPropKind

@data TypeInfo begin
    InstTo(HMT)
    InstFrom(HMT)
    NoProp
end

@data TypeInfoKind begin
    InstToKind
    InstFromKind
    NoPropKind
end

Base.:!(i::TypeInfo) =
    @match i begin
        InstTo(x) => InstFrom(x)
        InstFrom(x) => InstTo(x)
        NoProp => NoProp
    end

Base.:!(i::TypeInfoKind) =
    @match i begin
        InstToKind => InstFromKind
        InstFromKind => InstToKind
        NoPropKind => NoPropKind
    end

(i::TypeInfoKind)(x :: HMT) =
    @match i begin
        InstFromKind => InstFrom(x)
        InstToKind => InstTo(x)
        NoPropKind => NoProp
    end
