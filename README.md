# MLFS

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://thautwarm.github.io/MLFS.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://thautwarm.github.io/MLFS.jl/dev)
[![Build Status](https://travis-ci.com/thautwarm/MLFS.jl.svg?branch=master)](https://travis-ci.com/thautwarm/MLFS.jl)
[![Coverage](https://codecov.io/gh/thautwarm/MLFS.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/thautwarm/MLFS.jl)


So far the following programs can be correctly inferred/checked.

```ocaml
val f : (forall a. a -> a) -> (Int, Str)
let f = fun x -> (x 1, x "1")

val id : forall a. a -> a
let id = fun x -> x

val choose : forall a. a -> a -> a
let choose = fun x -> fun y -> x

let _ = choose id
```

And without annotation, `choose id` has type `(forall a. a -> a) -> (forall a. a -> a)