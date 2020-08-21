[ -d "out" ] || mkdir out
[ -d "out/m1" ] || mkdir out/m1
[ -d "out/m2" ] || mkdir out/m2
[ -d "out/m3" ] || mkdir out/m3

cd examples

mlfsc ../examples/records.mlfs --o ../out/m1 --name records
mlfsc ../out/m1 --o ./records.jl
julia records.jl

mlfsc ../examples/println.mlfs --o ../out/m2 --name println
mlfsc ../out/m2 --o ./println.jl
julia println.jl


mlfsc ../examples/functor.mlfs --o ../out/m3 --name functor