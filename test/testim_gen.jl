using FunctionWrappers; Fn = FunctionWrappers.FunctionWrapper
let
    #= line 1 =#
    var"|main|b_implicitStr"::String = "114514"::String
    var"|main|c_implicitInt"::Function = (x->begin
                    #= /home/tainez/github/MLFS/test/testim.jl:26 =#
                    parse(Int, x)
                end)::Function
    var"|main|d_+"::Function = (((x, y),)->begin
                    #= /home/tainez/github/MLFS/test/testim.jl:28 =#
                    x + y
                end)::Function
    var"|main|e_fun"::Function = function (var"|main|f_x",)
                #= /home/tainez/github/MLFS/test/testim.jl:30 =#
                function (var"|main|g_y",)
                        #= /home/tainez/github/MLFS/test/testim.jl:30 =#
                        (var"|main|d_+"::Function)((var"|main|f_x"::Any, var"|main|g_y"::Any)::Tuple{Any, Any})::Any
                    end::Function
            end::Function
    var"|main|h_var"::Any = (var"|main|e_fun"(var"|main|c_implicitInt"(var"|main|b_implicitStr"::String)::Any)::Function)(1::Any)::Any
    0
end
