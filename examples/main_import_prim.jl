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
                #= ../examples/prim.mlfs:14 =#
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
            #= ../examples/prim.mlfsf:1 =#
            var"|Prim|j_println"
        end
    var"|Prim|l"::Function = function (_,)
            #= ../examples/prim.mlfsf:1 =#
            var"|Prim|i_pushVec"
        end
    var"|Prim|m"::Function = function (_,)
            #= ../examples/prim.mlfsf:1 =#
            var"|Prim|h_mkVec"
        end
    var"|Prim|n"::Function = function (_,)
            #= ../examples/prim.mlfsf:1 =#
            var"|Prim|f_make"
        end
    var"|Prim|o"::Function = function (_,)
            #= ../examples/prim.mlfsf:1 =#
            Symbol("Vec@10_|Prim|e")
        end
    var"|Prim|p"::Function = function (_,)
            #= ../examples/prim.mlfsf:1 =#
            Symbol("{}")
        end
    var"|Prim|q"::Function = function (_,)
            #= ../examples/prim.mlfsf:1 =#
            var"|Prim|b_op_Getter"
        end
    var"|Prim|"::Any = Symbol("Module Prim")
    Prim::Any = Symbol("namespace {Module Prim, {{make, |Prim|f_make, forall t@16717406246530913357 a@11801433591169035571.implicit[(Type t@16717406246530913357)->t@16717406246530913357 a@11801433591169035571]->(Type t@16717406246530913357)->t@16717406246530913357 a@11801433591169035571}, {unit, |Prim|c_unit, Type {}}, {mkVec, |Prim|h_mkVec, implicit[forall a@2639846991040923967.(Type Vec@10_|Prim|e)->Vec@10_|Prim|e a@2639846991040923967]}, {println, |Prim|j_println, forall a@14789764477938173110.a@14789764477938173110->{}}, {op_Getter, |Prim|b_op_Getter, forall a@13273300418021105656 b@3807507219835817512 c@8018476648388466368.(field {a@13273300418021105656, b@3807507219835817512, c@8018476648388466368})->a@13273300418021105656->c@8018476648388466368}, {Vec, |Prim|d_Vec, Type Vec@10_|Prim|e}, {pushVec, |Prim|i_pushVec, implicit[forall a@6414539978683314118.field {Vec@10_|Prim|e a@6414539978683314118, push, a@6414539978683314118->{}}]}}}")
    (var"|Prim|j_println"::Function)(1::Int64)::Tuple
    (var"|Prim|j_println"::Function)(:i64::Symbol)::Tuple
    var"|main|r_a"::Any = (var"|Prim|f_make"(var"|Prim|h_mkVec"::Function)::Function)(Symbol("Vec@10_|Prim|e")::Symbol)::Any
    var"|main|s_c"::Tuple = ((op_Getter(var"|Prim|i_pushVec"::Any))(var"|main|r_a"::Any)::Function)(1::Int64)::Tuple
    var"|main|t_mk2"::Function = function (var"|main|u_x",)
                #= ../examples/main.mlfs:17 =#
                (var"|main|u_x"::Any, var"|main|u_x"::Any)::Tuple
            end::Function
    (var"|Prim|j_println"::Function)((var"|main|t_mk2"::Function)(var"|main|r_a"::Any)::Tuple)::Tuple
    var"|main|v_index"::Function = (x::Vector->begin
                    #= none:1 =#
                    #= none:3 =#
                    i::Int64->begin
                            #= none:3 =#
                            #= none:5 =#
                            x[i]
                        end
                end)::Function
    var"|main|w_CanAdd1"::Symbol = Symbol("CanAdd1@24_|main|x")::Symbol
    var"|main|y_int_add1"::Function = (_->begin
                    #= none:1 =#
                    #= none:3 =#
                    x::Int64->begin
                            #= none:3 =#
                            #= none:5 =#
                            x + 1
                        end
                end)::Function
    var"|main|z_float_add1"::Function = (_->begin
                    #= none:1 =#
                    #= none:3 =#
                    x::Float64->begin
                            #= none:3 =#
                            #= none:5 =#
                            x + 1.0
                        end
                end)::Function
    var"|main|ab_vec_head_add1"::Function = function (var"|main|bb_instance",)
                #= ../examples/main.mlfs:35 =#
                function (var"|main|cb_x",)
                        #= ../examples/main.mlfs:35 =#
                        ((var"|main|bb_instance"::Function)(Symbol("CanAdd1@24_|main|x")::Symbol)::Function)(((var"|main|v_index"::Function)(var"|main|cb_x"::Any)::Function)(1::Int64)::Any)::Any
                    end::Function
            end::Function
    (var"|Prim|j_println"::Function)((var"|main|ab_vec_head_add1"(var"|main|y_int_add1"::Function)::Function)(var"|main|r_a"::Any)::Int64)::Tuple
    var"|main|db"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|main|ab_vec_head_add1"
        end
    var"|main|eb"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|main|z_float_add1"
        end
    var"|main|fb"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|main|y_int_add1"
        end
    var"|main|gb"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            Symbol("CanAdd1@24_|main|x")
        end
    var"|main|hb"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|main|v_index"
        end
    var"|main|ib"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|main|t_mk2"
        end
    var"|main|jb"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|main|s_c"
        end
    var"|main|kb"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|main|r_a"
        end
    var"|main|lb"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|Prim|i_pushVec"
        end
    var"|main|mb"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            Symbol("Vec@10_|Prim|e")
        end
    var"|main|nb"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|Prim|b_op_Getter"
        end
    var"|main|ob"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|Prim|j_println"
        end
    var"|main|pb"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|Prim|h_mkVec"
        end
    var"|main|qb"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            Symbol("{}")
        end
    var"|main|rb"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|Prim|f_make"
        end
    var"|main|sb"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|Prim|"
        end
    var"|main|"::Any = Symbol("Module main")
    main::Any = Symbol("namespace {Module main, {{Prim, |Prim|, Module Prim}, {make, |Prim|f_make, forall t@16717406246530913357 a@11801433591169035571.implicit[(Type t@16717406246530913357)->t@16717406246530913357 a@11801433591169035571]->(Type t@16717406246530913357)->t@16717406246530913357 a@11801433591169035571}, {c, |main|s_c, {}}, {mkVec, |Prim|h_mkVec, implicit[forall a@2639846991040923967.(Type Vec@10_|Prim|e)->Vec@10_|Prim|e a@2639846991040923967]}, {int_add1, |main|y_int_add1, implicit[(Type CanAdd1@24_|main|x)->i64->i64]}, {op_Getter, |Prim|b_op_Getter, forall a@13273300418021105656 b@3807507219835817512 c@8018476648388466368.(field {a@13273300418021105656, b@3807507219835817512, c@8018476648388466368})->a@13273300418021105656->c@8018476648388466368}, {float_add1, |main|z_float_add1, implicit[(Type CanAdd1@24_|main|x)->f64->f64]}, {CanAdd1, |main|w_CanAdd1, Type CanAdd1@24_|main|x}, {index, |main|v_index, forall a@4254833402377063326.(Vec@10_|Prim|e a@4254833402377063326)->i64->a@4254833402377063326}, {unit, |Prim|c_unit, Type {}}, {println, |Prim|j_println, forall a@14789764477938173110.a@14789764477938173110->{}}, {mk2, |main|t_mk2, forall a@5738057159966553334.a@5738057159966553334->{a@5738057159966553334, a@5738057159966553334}}, {a, |main|r_a, Vec@10_|Prim|e i64}, {vec_head_add1, |main|ab_vec_head_add1, forall a@12684631950850326000.implicit[(Type CanAdd1@24_|main|x)->a@12684631950850326000->a@12684631950850326000]->(Vec@10_|Prim|e a@12684631950850326000)->a@12684631950850326000}, {Vec, |Prim|d_Vec, Type Vec@10_|Prim|e}, {pushVec, |Prim|i_pushVec, implicit[forall a@6414539978683314118.field {Vec@10_|Prim|e a@6414539978683314118, push, a@6414539978683314118->{}}]}}}")
    0
end
