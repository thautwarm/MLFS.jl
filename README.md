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

val choose_id' : (forall a. a) -> (Int -> Int)
let choose_id' = choose id

(* error: *)
val choose_id' : (Int -> Int) -> (Int -> Int)
let choose_id' = choose id
```

And without annotation for `choose id`, it has the type `(forall a. a -> a) -> (forall a. a -> a)`.

In System F closed by η-expansion, `choose id` holds the type `forall a. (a -> a) -> a -> a`,
in MLFS you'll have to write this type under the help of scoped type variables or explicit instantiation.

```ocaml
val choose_id : forall c. (c -> c) -> (c -> c)
let choose_id = choose (id : c -> _)
```

or 

```ocaml
val choose_id : forall c. (c -> c) -> c -> c
let choose_id = choose (INST id)
```


Support for Type classes is WIP.
