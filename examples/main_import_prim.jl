let
    #= line 1 =#
    var"|Prim|b_op_Getter"::Function = function op_Getter(x)
                #= none:1 =#
                #= none:4 =#
                function (a,)
                    #= none:4 =#
                    #= none:7 =#
                    x(a)
                end
            end::Function
    var"|Prim|c_unit"::Symbol = Symbol("unit@5_|Prim|d")::Symbol
    var"|Prim|e_println"::Function = println::Function
    var"|Prim|f"::Function = function (_,)
            #= ../examples/prim.mlfsf:1 =#
            var"|Prim|e_println"
        end
    var"|Prim|g"::Function = function (_,)
            #= ../examples/prim.mlfsf:1 =#
            Symbol("unit@5_|Prim|d")
        end
    var"|Prim|h"::Function = function (_,)
            #= ../examples/prim.mlfsf:1 =#
            var"|Prim|b_op_Getter"
        end
    var"|Prim|"::Any = Symbol("Module Prim")
    Prim::Any = Symbol("namespace {Module Prim, {{unit, |Prim|c_unit, Type unit@5_|Prim|d}, {println, |Prim|e_println, forall a@7984536977918001748.a@7984536977918001748->unit@5_|Prim|d}, {op_Getter, |Prim|b_op_Getter, forall a@5397024297775275511 b@1976213804903537982 c@1526708158202369400.(field {a@5397024297775275511, b@1976213804903537982, c@1526708158202369400})->a@5397024297775275511->c@1526708158202369400}}}")
    ((op_Getter(var"|Prim|f"::Any))(var"|Prim|"::Any)::Function)(1::Any)::Any
    ((op_Getter(var"|Prim|f"::Any))(var"|Prim|"::Any)::Function)(:i64::Symbol)::Any
    var"|main|i"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|Prim|"
        end
    var"|main|"::Any = Symbol("Module main")
    main::Any = Symbol("namespace {Module main, {{Prim, |Prim|, Module Prim}}}")
    var"|Println|b_unit"::Symbol = Symbol("unit@2_|Println|c")::Symbol
    var"|Println|d_println"::Function = println::Function
    (var"|Println|d_println"::Function)("hello!"::String)::Any
    var"|Println|e"::Function = function (_,)
            #= ../examples/println.mlfsf:1 =#
            var"|Println|d_println"
        end
    var"|Println|f"::Function = function (_,)
            #= ../examples/println.mlfsf:1 =#
            Symbol("unit@2_|Println|c")
        end
    var"|Println|"::Any = Symbol("Module Println")
    Println::Any = Symbol("namespace {Module Println, {{unit, |Println|b_unit, Type unit@2_|Println|c}, {println, |Println|d_println, forall a@9382333071451287340.a@9382333071451287340->unit@2_|Println|c}}}")
    0
end
