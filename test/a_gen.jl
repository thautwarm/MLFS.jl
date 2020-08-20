let
    #= line 1 =#
    var"|A|b_op_Getter"::Function = "identity"::Function
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
    var"|A|"::Tuple{} = ()
    A::Tuple{Tuple{String, String, String, String, String, String, String, String, String, String, String, String, String, String}, Tuple{Type{<:Any}, Type{<:Any}, Function, Type{<:String}, Type{<:Any}, Type{<:Bool}, Any, Type{<:Any}, Type{<:Any}, Type{<:Char}, Type{<:Any}, Function, Type{<:Any}, Any}} = (("i64", "i32", "op_Getter", "str", "i16", "bool", "x", "module", "field", "char", "fieldnames", "g", "i8", "f"), (Type{<:Any}, Type{<:Any}, var"|A|b_op_Getter", Type{<:String}, Type{<:Any}, Type{<:Bool}, var"|A|d_x", Type{<:Any}, Type{<:Any}, Type{<:Char}, Type{<:Any}, var"|A|e_g", Type{<:Any}, var"|A|c_f"))
    0
end
