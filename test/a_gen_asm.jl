let
    #= line 1 =#
    var"|a|b_op_Getter"::Function = identity::Function
    var"|a|c_f"::Any = (x->begin
                    #= none:1 =#
                    #= none:4 =#
                    x
                end)::Any
    var"|a|d_x"::Any = 1::Any
    var"|a|e_g"::Function = function (var"|a|f_x",)
                #= /home/tainez/github/MLFS/test/a.jl:20 =#
                function (var"|a|g_y",)
                        #= /home/tainez/github/MLFS/test/a.jl:20 =#
                        (var"|a|b_op_Getter"::Function)((var"|a|c_f"::Any)(var"|a|g_y"::Any)::Any)::Any
                    end::Function
            end::Function
    var"|a|"::Tuple = ()
    a::Tuple = (("f32", "f16", "i64", "i32", "op_Getter", "str", "f64", "bool", "i16", "x", "module", "field", "char", "fieldnames", "g", "i8", "f", "Type"), (Type, Type, Type, Type, var"|a|b_op_Getter", Type, Type, Type, Type, var"|a|d_x", Type, Type, Type, Type, var"|a|e_g", Type, var"|a|c_f", Type))
    0
end
