let
    #= line 1 =#
    var"|Println|b_unit"::Symbol = Symbol("unit@3_|Println|c")::Symbol
    var"|Println|d_println"::Function = println::Function
    (var"|Println|d_println"::Function)("hello!"::String)::Any
    var"|Println|e"::Function = function (_,)
            #= println.mlfsf:1 =#
            var"|Println|d_println"
        end
    var"|Println|f"::Function = function (_,)
            #= println.mlfsf:1 =#
            Symbol("unit@3_|Println|c")
        end
    var"|Println|"::Any = Symbol("Module Println")
    Println::Any = Symbol("namespace {Module Println, {{unit, |Println|b_unit, Type unit@3_|Println|c}, {println, |Println|d_println, forall a@12674126722444159264.a@12674126722444159264->unit@3_|Println|c}}}")
    0
end
