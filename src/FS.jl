import Base
export TypeInfo, InstTo, NoProp
export TypeInfoKind, InstToKind, NoPropKind

@data TypeInfo begin
    InstTo(HMT)
    NoProp
end

@data TypeInfoKind begin
    InstToKind
    NoPropKind
end


(i::TypeInfoKind)(x :: HMT) =
    @match i begin
        InstToKind => InstTo(x)
        NoPropKind => NoProp
    end
