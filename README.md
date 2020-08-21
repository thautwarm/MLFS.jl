# MLFS

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://thautwarm.github.io/MLFS.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://thautwarm.github.io/MLFS.jl/dev)
[![Build Status](https://travis-ci.com/thautwarm/MLFS.jl.svg?branch=master)](https://travis-ci.com/thautwarm/MLFS.jl)
[![Coverage](https://codecov.io/gh/thautwarm/MLFS.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/thautwarm/MLFS.jl)

MLFS is a type system to equip ML languages with Higher Rank Types. While having good expressivity, it also keeps the system as **simple** as the vanilla Damas-Hindley-Milner type system.

Instead of annotating types at function parameters in HMF, you can annotate types in the top level, just like what in Haskell:
```
val mk_pair : (forall a. a) -> (Int, Str)
let mk_pair = fun f -> (f 1, f "1")
```

MLFS works well with other important features:

This repo is an implementation of MLFS type system with

- Type classes(implicit arguments)
- Scoped type variables

## Installation && Usage

1. install Julia: there is an one-liner option for all operating system:

    https://github.com/abelsiqueira/jill

2. develop this package
    
    ```
    julia> ]
    pkg> dev .
    ```


3. install python CLI(require Python >= 3.7)

    ```
    cd cli && python setup.py install
    ```

Usage

1. Compile sources with signature files and produce new object files and signature files

    ```ocaml
    mlfsc a.mlfs b.mlfs --sig "sig1.mlfsa,sig2.mlfsa" --name <pkgname>
    ```

    This produces `<pkgname>.mlfsa` and `<pkgname>.mlfso`.

2. Compile all `.mlfso` files into single julia file:

    ```
    mlfsc <directory of all .mlfso> --o <out>.jl
    julia <out.jl>
    ```

## About

So far the following programs can be correctly inferred/checked.

```ocaml
val f : (forall a. a -> a) -> (Int, Str)
let f = fun x -> (x 1, x "1")

val id : forall a. a -> a
let id = fun x -> x

val choose : forall a. a -> a -> a
let choose = fun x -> fun y -> x

let _ = choose id

val choose_id' : (Int -> Int) -> (Int -> Int)
let choose_id' = choose id
```

And without annotation for `choose id`, it has the type `(forall a. a -> a) -> (forall a. a -> a)`.

In System F closed by η-expansion, `choose id` holds the type `forall a. (a -> a) -> a -> a`,
in MLFS you'll have to write this with explicit annotation.

```ocaml
val choose_id : forall c. (c -> c) -> (c -> c)
let choose_id = choose id
```


## Known Restrictions

Still, given `id` and `choose`, 
given any type `t2 ⪯ forall a. a -> a`,
and a type `t1`,

```ocaml 
val id : forall a. a -> a
val choose : forall a. a -> a -> a

val choose_id : t1 -> t2
let choose_id = choose id
```

If `t1` is 
1. more general than `t2`, and
2. more specific than `forall a. a -> a`

The annotation for `choose_id` works.

However, the second restriction is actually redundant.

For instance, given any type `t2 ⪯ forall a. a -> a`

```ocaml
val choose_id : (forall a. a) -> t2
let choose_id = choose id
```

Above annotation for `choose_id` is correct, however cannot get correctly checked in MLFS.

This is because the following inequation is difficult to solve:

```ocaml
monotype_var ->(forall a.a) -> (monotype0 -> monotype0) 
⪯
INST forall b.b->b->b
```

However, you can write 

```ocaml
val choose_id : (forall a. a) -> t2
let choose_id =
    let choose_id' : (forall a. a -> a) -> t2
    in choose_id'
```

which avoids solving that difficult inequation.
