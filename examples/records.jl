let
    #= line 1 =#
    var"|Record|b_op_Getter"::Function = function op_Getter(x)
                #= none:1 =#
                #= none:4 =#
                function (a,)
                    #= none:4 =#
                    #= none:7 =#
                    x(a)
                end
            end::Function
    var"|Record|c_tupleFirst"::Any = function (x,)
                #= none:1 =#
                #= none:4 =#
                #= none:4 =# @inbounds x[1]
            end::Any
    var"|Record|d_unit"::Symbol = Symbol("unit@8_|Record|e")::Symbol
    var"|Record|f_println"::Function = println::Function
    (var"|Record|f_println"::Function)((op_Getter(var"|Record|c_tupleFirst"::Any))((1::Any, "3"::String)::Tuple)::Any)::Any
    (var"|Record|f_println"::Function)((op_Getter(var"|Record|c_tupleFirst"::Any))(((1::Any, "3"::String)::Tuple, 2::Any)::Tuple)::Tuple)::Any
    (var"|Record|f_println"::Function)((op_Getter(var"|Record|c_tupleFirst"::Any))((1::Any, "3"::String)::Tuple)::Any)::Any
    (var"|Record|f_println"::Function)((op_Getter(var"|Record|c_tupleFirst"::Any))(((1.0::Any, 2.0::Any)::Tuple, 4.0::Any)::Tuple)::Tuple)::Any
    var"|Record|g"::Function = function (_,)
            #= ../examples/records.mlfsf:1 =#
            var"|Record|f_println"
        end
    var"|Record|h"::Function = function (_,)
            #= ../examples/records.mlfsf:1 =#
            Symbol("unit@8_|Record|e")
        end
    var"|Record|i"::Function = function (_,)
            #= ../examples/records.mlfsf:1 =#
            var"|Record|c_tupleFirst"
        end
    var"|Record|j"::Function = function (_,)
            #= ../examples/records.mlfsf:1 =#
            var"|Record|b_op_Getter"
        end
    var"|Record|"::Any = Symbol("Module Record")
    Record::Any = Symbol("namespace {Module Record, {{unit, |Record|d_unit, Type unit@8_|Record|e}, {println, |Record|f_println, forall a@8437611567325153797.a@8437611567325153797->unit@8_|Record|e}, {tupleFirst, |Record|c_tupleFirst, implicit[forall a@896127623198258117 b@4537129684137169411.field {{a@896127623198258117, b@4537129684137169411}, first, a@896127623198258117}]}, {op_Getter, |Record|b_op_Getter, forall a@7077967455713989146 b@17374103258525171164 c@7858606227020666397.(field {a@7077967455713989146, b@17374103258525171164, c@7858606227020666397})->a@7077967455713989146->c@7858606227020666397}}}")
    0
end
