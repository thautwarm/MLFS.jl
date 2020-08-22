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
    var"|Record|d_unit"::Symbol = Symbol("unit@9_|Record|e")::Symbol
    var"|Record|f_println"::Function = println::Function
    (var"|Record|f_println"::Function)((op_Getter(var"|Record|c_tupleFirst"::Any))((1::Int64, "3"::String)::Tuple)::Int64)::Any
    (var"|Record|f_println"::Function)((op_Getter(var"|Record|c_tupleFirst"::Any))(((1::Int64, "3"::String)::Tuple, 2::Int64)::Tuple)::Tuple)::Any
    (var"|Record|f_println"::Function)((op_Getter(var"|Record|c_tupleFirst"::Any))((1::Int64, "3"::String)::Tuple)::Int64)::Any
    (var"|Record|f_println"::Function)((op_Getter(var"|Record|c_tupleFirst"::Any))(((1.0::Float64, 2.0::Float64)::Tuple, 4.0::Float64)::Tuple)::Tuple)::Any
    var"|Record|g"::Function = function (_,)
            #= ../examples/records.mlfsf:1 =#
            var"|Record|f_println"
        end
    var"|Record|h"::Function = function (_,)
            #= ../examples/records.mlfsf:1 =#
            Symbol("unit@9_|Record|e")
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
    Record::Any = Symbol("namespace {Module Record, {{unit, |Record|d_unit, Type unit@9_|Record|e}, {println, |Record|f_println, forall a@16637042416609141449.a@16637042416609141449->unit@9_|Record|e}, {tupleFirst, |Record|c_tupleFirst, implicit[forall a@7926405980970808347 b@7837958566204397962.field {{a@7926405980970808347, b@7837958566204397962}, first, a@7926405980970808347}]}, {op_Getter, |Record|b_op_Getter, forall a@14405151252754402137 b@12698724006108591597 c@6952052581654061649.(field {a@14405151252754402137, b@12698724006108591597, c@6952052581654061649})->a@14405151252754402137->c@6952052581654061649}}}")
    0
end
