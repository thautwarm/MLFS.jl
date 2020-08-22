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
    var"|Prim|c_unit"::Symbol = Symbol("{}")::Symbol
    var"|Prim|d_Vec"::Symbol = Symbol("Vec@10_|Prim|e")::Symbol
    var"|Prim|f_make"::Function = function (var"|Prim|g_t",)
                #= prim.mlfs:14 =#
                var"|Prim|g_t"::Function
            end::Function
    var"|Prim|h_mkVec"::Function = (_->begin
                    #= none:1 =#
                    #= none:3 =#
                    []
                end)::Function
    var"|Prim|i_pushVec"::Any = (x->begin
                    #= none:1 =#
                    #= none:3 =#
                    function (a,)
                        #= none:3 =#
                        #= none:6 =#
                        push!(x, a)
                        #= none:8 =#
                        ()
                    end
                end)::Any
    var"|Prim|j_println"::Function = function (x,)
                #= none:1 =#
                #= none:4 =#
                println(x)
                #= none:6 =#
                ()
            end::Function
    var"|Prim|k"::Function = function (_,)
            #= prim.mlfsf:1 =#
            var"|Prim|j_println"
        end
    var"|Prim|l"::Function = function (_,)
            #= prim.mlfsf:1 =#
            var"|Prim|i_pushVec"
        end
    var"|Prim|m"::Function = function (_,)
            #= prim.mlfsf:1 =#
            var"|Prim|h_mkVec"
        end
    var"|Prim|n"::Function = function (_,)
            #= prim.mlfsf:1 =#
            var"|Prim|f_make"
        end
    var"|Prim|o"::Function = function (_,)
            #= prim.mlfsf:1 =#
            Symbol("Vec@10_|Prim|e")
        end
    var"|Prim|p"::Function = function (_,)
            #= prim.mlfsf:1 =#
            Symbol("{}")
        end
    var"|Prim|q"::Function = function (_,)
            #= prim.mlfsf:1 =#
            var"|Prim|b_op_Getter"
        end
    var"|Prim|"::Any = Symbol("Module Prim")
    Prim::Any = Symbol("namespace {Module Prim, {{make, |Prim|f_make, forall t@278297307682851090 a@677251371825795701.implicit[(Type t@278297307682851090)->t@278297307682851090 a@677251371825795701]->(Type t@278297307682851090)->t@278297307682851090 a@677251371825795701}, {unit, |Prim|c_unit, Type {}}, {mkVec, |Prim|h_mkVec, implicit[forall a@12749185122450227609.(Type Vec@10_|Prim|e)->Vec@10_|Prim|e a@12749185122450227609]}, {println, |Prim|j_println, forall a@15015868916553805062.a@15015868916553805062->{}}, {op_Getter, |Prim|b_op_Getter, forall a@6362263581973966468 b@2939671633312754496 c@6145940050701192650.(field {a@6362263581973966468, b@2939671633312754496, c@6145940050701192650})->a@6362263581973966468->c@6145940050701192650}, {Vec, |Prim|d_Vec, Type Vec@10_|Prim|e}, {pushVec, |Prim|i_pushVec, implicit[forall a@13075903652027498148.field {Vec@10_|Prim|e a@13075903652027498148, push, a@13075903652027498148->{}}]}}}")
    (var"|Prim|j_println"::Function)(1::Int64)::Tuple
    (var"|Prim|j_println"::Function)(:i64::Symbol)::Tuple
    var"|main|r_a"::Any = (var"|Prim|f_make"(var"|Prim|h_mkVec"::Function)::Function)(Symbol("Vec@10_|Prim|e")::Symbol)::Any
    var"|main|s_c"::Tuple = ((op_Getter(var"|Prim|i_pushVec"::Any))(var"|main|r_a"::Any)::Function)(1::Int64)::Tuple
    var"|main|t_mk2"::Function = function (var"|main|u_x",)
                #= main.mlfs:17 =#
                (var"|main|u_x"::Any, var"|main|u_x"::Any)::Tuple
            end::Function
    (var"|Prim|j_println"::Function)((var"|main|t_mk2"::Function)(var"|main|r_a"::Any)::Tuple)::Tuple
    var"|main|v_int_vec_add1"::Function = function (var"|main|w_x",)
                #= main.mlfs:22 =#
                var"|main|w_x"::Int64
            end::Function
    var"|main|x"::Function = function (_,)
            #= main.mlfsf:1 =#
            var"|main|v_int_vec_add1"
        end
    var"|main|y"::Function = function (_,)
            #= main.mlfsf:1 =#
            var"|main|t_mk2"
        end
    var"|main|z"::Function = function (_,)
            #= main.mlfsf:1 =#
            var"|main|s_c"
        end
    var"|main|ab"::Function = function (_,)
            #= main.mlfsf:1 =#
            var"|main|r_a"
        end
    var"|main|bb"::Function = function (_,)
            #= main.mlfsf:1 =#
            var"|Prim|i_pushVec"
        end
    var"|main|cb"::Function = function (_,)
            #= main.mlfsf:1 =#
            Symbol("Vec@10_|Prim|e")
        end
    var"|main|db"::Function = function (_,)
            #= main.mlfsf:1 =#
            var"|Prim|b_op_Getter"
        end
    var"|main|eb"::Function = function (_,)
            #= main.mlfsf:1 =#
            var"|Prim|j_println"
        end
    var"|main|fb"::Function = function (_,)
            #= main.mlfsf:1 =#
            var"|Prim|h_mkVec"
        end
    var"|main|gb"::Function = function (_,)
            #= main.mlfsf:1 =#
            Symbol("{}")
        end
    var"|main|hb"::Function = function (_,)
            #= main.mlfsf:1 =#
            var"|Prim|f_make"
        end
    var"|main|ib"::Function = function (_,)
            #= main.mlfsf:1 =#
            var"|Prim|"
        end
    var"|main|"::Any = Symbol("Module main")
    main::Any = Symbol("namespace {Module main, {{Prim, |Prim|, Module Prim}, {make, |Prim|f_make, forall t@278297307682851090 a@677251371825795701.implicit[(Type t@278297307682851090)->t@278297307682851090 a@677251371825795701]->(Type t@278297307682851090)->t@278297307682851090 a@677251371825795701}, {c, |main|s_c, {}}, {mkVec, |Prim|h_mkVec, implicit[forall a@12749185122450227609.(Type Vec@10_|Prim|e)->Vec@10_|Prim|e a@12749185122450227609]}, {op_Getter, |Prim|b_op_Getter, forall a@6362263581973966468 b@2939671633312754496 c@6145940050701192650.(field {a@6362263581973966468, b@2939671633312754496, c@6145940050701192650})->a@6362263581973966468->c@6145940050701192650}, {unit, |Prim|c_unit, Type {}}, {int_vec_add1, |main|v_int_vec_add1, i64->i64}, {println, |Prim|j_println, forall a@15015868916553805062.a@15015868916553805062->{}}, {mk2, |main|t_mk2, forall a@16231160820014051546.a@16231160820014051546->{a@16231160820014051546, a@16231160820014051546}}, {a, |main|r_a, Vec@10_|Prim|e i64}, {Vec, |Prim|d_Vec, Type Vec@10_|Prim|e}, {pushVec, |Prim|i_pushVec, implicit[forall a@13075903652027498148.field {Vec@10_|Prim|e a@13075903652027498148, push, a@13075903652027498148->{}}]}}}")
    0
end
