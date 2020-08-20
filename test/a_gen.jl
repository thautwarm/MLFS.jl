let
    #= line 1 =#
    var"|A|b_op_Getter"::Function = identity::Function
    var"|A|c_f"::Any = (x->begin
                    #= none:1 =#
                    #= none:4 =#
                    x
                end)::Any
    var"|A|d_x"::Any = 1::Any
    var"|A|e_g"::Function = function (var"|A|f_x",)
                #= /home/tainez/github/MLFS/test/a.jl:20 =#
                function (var"|A|g_y",)
                        #= /home/tainez/github/MLFS/test/a.jl:20 =#
                        (var"|A|b_op_Getter"::Function)((var"|A|c_f"::Any)(var"|A|g_y"::Any)::Any)::Any
                    end::Function
            end::Function
    var"|A|"::Tuple = ()
    A::Tuple = (("i64", "i32", "op_Getter", "str", "i16", "bool", "x", "module", "field", "char", "fieldnames", "g", "i8", "f"), (Type, Type, var"|A|b_op_Getter", Type, Type, Type, var"|A|d_x", Type, Type, Type, Type, var"|A|e_g", Type, var"|A|c_f"))
    0
end
