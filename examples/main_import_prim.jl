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
    var"|Prim|d_Vec"::Symbol = Symbol("Type@10_|Prim|e")::Symbol
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
            Symbol("Type@10_|Prim|e")
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
    Prim::Any = Symbol("namespace {Module Prim, {{make, |Prim|f_make, forall t@6417424717805738618 a@10818170836948007856.implicit[(Type t@6417424717805738618)->t@6417424717805738618 a@10818170836948007856]->(Type t@6417424717805738618)->t@6417424717805738618 a@10818170836948007856}, {unit, |Prim|c_unit, Type {}}, {mkVec, |Prim|h_mkVec, implicit[forall a@18170854304361554767.(Type Type@10_|Prim|e)->Type@10_|Prim|e a@18170854304361554767]}, {println, |Prim|j_println, forall a@15146175433785041783.a@15146175433785041783->{}}, {op_Getter, |Prim|b_op_Getter, forall a@2248892095897267684 b@18361686972778045513 c@11582008445660295424.(field {a@2248892095897267684, b@18361686972778045513, c@11582008445660295424})->a@2248892095897267684->c@11582008445660295424}, {Vec, |Prim|d_Vec, Type Type@10_|Prim|e}, {pushVec, |Prim|i_pushVec, implicit[forall a@17884324859680380913.field {Type@10_|Prim|e a@17884324859680380913, push, a@17884324859680380913->{}}]}}}")
    var"|main|r_Vec"::Symbol = (op_Getter(var"|Prim|o"::Any))(var"|Prim|"::Any)::Symbol
    ((op_Getter(var"|Prim|k"::Any))(var"|Prim|"::Any)::Function)(1::Any)::Tuple
    ((op_Getter(var"|Prim|k"::Any))(var"|Prim|"::Any)::Function)(:i64::Symbol)::Tuple
    var"|main|s_a"::Any = (var"|Prim|f_make"(var"|Prim|h_mkVec"::Function)::Function)(Symbol("Type@10_|Prim|e")::Symbol)::Any
    var"|main|t_c"::Tuple = ((op_Getter(var"|Prim|i_pushVec"::Any))(var"|main|s_a"::Any)::Function)(1::Any)::Tuple
    var"|main|u"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|main|t_c"
        end
    var"|main|v"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|main|s_a"
        end
    var"|main|w"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|Prim|i_pushVec"
        end
    var"|main|x"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            Symbol("Type@10_|Prim|e")
        end
    var"|main|y"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|Prim|b_op_Getter"
        end
    var"|main|z"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|Prim|j_println"
        end
    var"|main|ab"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|Prim|h_mkVec"
        end
    var"|main|bb"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            Symbol("{}")
        end
    var"|main|cb"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|Prim|f_make"
        end
    var"|main|db"::Function = function (_,)
            #= ../examples/main.mlfsf:1 =#
            var"|Prim|"
        end
    var"|main|"::Any = Symbol("Module main")
    main::Any = Symbol("namespace {Module main, {{a, |main|s_a, Type@10_|Prim|e i64}, {Prim, |Prim|, Module Prim}, {make, |Prim|f_make, forall t@6417424717805738618 a@10818170836948007856.implicit[(Type t@6417424717805738618)->t@6417424717805738618 a@10818170836948007856]->(Type t@6417424717805738618)->t@6417424717805738618 a@10818170836948007856}, {unit, |Prim|c_unit, Type {}}, {mkVec, |Prim|h_mkVec, implicit[forall a@18170854304361554767.(Type Type@10_|Prim|e)->Type@10_|Prim|e a@18170854304361554767]}, {println, |Prim|j_println, forall a@15146175433785041783.a@15146175433785041783->{}}, {op_Getter, |Prim|b_op_Getter, forall a@2248892095897267684 b@18361686972778045513 c@11582008445660295424.(field {a@2248892095897267684, b@18361686972778045513, c@11582008445660295424})->a@2248892095897267684->c@11582008445660295424}, {c, |main|t_c, {}}, {Vec, |Prim|d_Vec, Type Type@10_|Prim|e}, {pushVec, |Prim|i_pushVec, implicit[forall a@17884324859680380913.field {Type@10_|Prim|e a@17884324859680380913, push, a@17884324859680380913->{}}]}}}")
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
    Println::Any = Symbol("namespace {Module Println, {{unit, |Println|b_unit, Type unit@2_|Println|c}, {println, |Println|d_println, forall a@13588831194101177332.a@13588831194101177332->unit@2_|Println|c}}}")
    0
end
