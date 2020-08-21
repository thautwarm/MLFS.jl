let
    #= line 1 =#
    var"|Record|b_op_Getter"::Function = (x->begin
                    #= none:1 =#
                    #= none:3 =#
                    x.get
                end)::Function
    var"|Record|c_tupleFirst"::Any = (((fst, snd),)->begin
                    #= none:1 =#
                    #= none:3 =#
                    (get = fst, set = (fst->begin
                                    #= none:3 =#
                                    #= none:5 =#
                                    (fst, snd)
                                end))
                end)::Any
    var"|Record|d_unit"::Type = Type::Type
    var"|Record|f_println"::Function = println::Function
    (var"|Record|f_println"::Function)((var"|Record|b_op_Getter"::Function)((var"|Record|c_tupleFirst"::Any)((1::Any, "3"::String)::Tuple)::Any)::Any)::Any
    (var"|Record|f_println"::Function)((var"|Record|b_op_Getter"::Function)((var"|Record|c_tupleFirst"::Any)(((1::Any, "3"::String)::Tuple, 2::Any)::Tuple)::Any)::Tuple)::Any
    (var"|Record|f_println"::Function)((var"|Record|b_op_Getter"::Function)((var"|Record|c_tupleFirst"::Any)((1::Any, "3"::String)::Tuple)::Any)::Any)::Any
    (var"|Record|f_println"::Function)((var"|Record|b_op_Getter"::Function)((var"|Record|c_tupleFirst"::Any)(((1.0::Any, 2.0::Any)::Tuple, 4.0::Any)::Tuple)::Any)::Tuple)::Any
    var"|Record|"::Tuple = ()
    Record::Tuple = (("f32", "f16", "i64", "i32", "op_Getter", "str", "f64", "bool", "i16", "unit", "field", "module", "char", "println", "fieldnames", "i8", "tupleFirst", "Type"), (Type, Type, Type, Type, var"|Record|b_op_Getter", Type, Type, Type, Type, Type, Type, Type, Type, var"|Record|f_println", Type, Type, var"|Record|c_tupleFirst", Type))
    0
end
