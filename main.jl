let
    #= line 1 =#
    var"|main|b_main"::Any = 1::Any
    var"|main|c_x"::Any = 1::Any
    var"|main|d_unit"::Type = Type::Type
    var"|main|f_println"::Function = println::Function
    var"|main|g_eq"::Function = (x->begin
                    #= none:1 =#
                    #= none:3 =#
                    y->begin
                            #= none:3 =#
                            #= none:5 =#
                            x == y
                        end
                end)::Function
    (var"|main|f_println"::Function)(if ((var"|main|g_eq"::Function)(1::Any)::Function)(2::Any)::Bool
                    1::Any
                else
                    2::Any
                end::Any)::Any
    var"|main|h_id"::Function = function (var"|main|i_x",)
                #= main.mlfs:23 =#
                var"|main|i_x"::Any
            end::Function
    var"|main|j_choose"::Function = function (var"|main|k_x",)
                #= main.mlfs:26 =#
                function (var"|main|l_y",)
                        #= main.mlfs:26 =#
                        var"|main|k_x"::Any
                    end::Function
            end::Function
    var"|main|m_choose_id"::Function = (var"|main|j_choose"::Function)(var"|main|h_id"::Function)::Function
    var"|main|n_x"::Function = (var"|main|m_choose_id"::Function)(var"|main|h_id"::Function)::Function
    var"|main|o_Nat"::Type = Type::Type
    var"|main|q_S"::Function = (x::UInt->begin
                    #= none:1 =#
                    #= none:3 =#
                    1 + x
                end)::Function
    var"|main|r_Z"::Any = UInt(0)::Any
    var"|main|s_matchNat"::Function = (f1->begin
                    #= none:1 =#
                    #= none:3 =#
                    f2->begin
                            #= none:3 =#
                            #= none:5 =#
                            x->begin
                                    #= none:5 =#
                                    #= none:7 =#
                                    if x == 0
                                        #= none:8 =#
                                        f2(x)
                                    else
                                        #= none:10 =#
                                        f1(x)
                                    end
                                end
                        end
                end)::Function
    (var"|main|f_println"::Function)((var"|main|n_x"::Function)("hellow world!"::String)::String)::Any
    (var"|main|f_println"::Function)((((var"|main|s_matchNat"::Function)(function (var"|main|t_x",)
                                    #= main.mlfs:50 =#
                                    "isS"::String
                                end::Function)::Function)(function (var"|main|u_x",)
                                #= main.mlfs:50 =#
                                "isZ"::String
                            end::Function)::Function)((var"|main|q_S"::Function)(var"|main|r_Z"::Any)::Any)::String)::Any
    var"|main|"::Tuple = ()
    main::Tuple = (("eq", "i64", "main", "i32", "str", "S", "i16", "choose", "bool", "matchNat", "x", "Z", "unit", "field", "module", "char", "println", "Nat", "fieldnames", "choose_id", "i8", "id", "Type"), (var"|main|g_eq", Type, var"|main|b_main", Type, Type, var"|main|q_S", Type, var"|main|j_choose", Type, var"|main|s_matchNat", var"|main|n_x", var"|main|r_Z", Type, Type, Type, Type, var"|main|f_println", Type, Type, var"|main|m_choose_id", Type, var"|main|h_id", Type))
    0
end
