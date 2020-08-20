using FunctionWrappers; Fn = FunctionWrappers.FunctionWrapper
let
    #= line 1 =#
    b_implicitStr::String = "114514"::String
    c_implicitInt::Fn{Int64, Tuple{String}} = Fn{Int64, Tuple{String}}((x->begin
                    #= /home/tainez/github/MLFS/test/testim.jl:23 =#
                    parse(Int, x)
                end))
    var"d_+"::Fn{Int64, Tuple{Tuple{Int64, Int64}}} = Fn{Int64, Tuple{Tuple{Int64, Int64}}}((((x, y),)->begin
                    #= /home/tainez/github/MLFS/test/testim.jl:25 =#
                    x + y
                end))
    e_fun::Fn{Fn{Int64, Tuple{Int64}}, Tuple{Int64}} = Fn{Fn{Int64, Tuple{Int64}}, Tuple{Int64}}(function (f_x,)
                #= /home/tainez/github/MLFS/test/testim.jl:27 =#
                Fn{Int64, Tuple{Int64}}(function (g_y,)
                        #= /home/tainez/github/MLFS/test/testim.jl:27 =#
                        (Fn{Int64, Tuple{Tuple{Int64, Int64}}}(var"d_+"))((f_x::Int64, g_y::Int64)::Tuple{Int64, Int64})::Int64
                    end)
            end)
    h_var::Int64 = (Fn{Int64, Tuple{Int64}}(e_fun(c_implicitInt(b_implicitStr::String)::Int64)))(1::Int64)::Int64
    0
end
