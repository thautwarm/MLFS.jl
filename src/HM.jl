module HM
export HMT, TVar, mk_tcstate, UN, VerboseUN
export Var, Nom, Bound, Var, Arrow, App, Tup, Forall, Implicit
export gTrans, gTransCtx, gCheck
export tvar_of_int, int_of_tvar, IllFormedType
export ⪯, less_than_under_evidences

using MLFS: @typedIO
import MLFS
using MLStyle
import Base

const VerboseUN = Ref(false)


mutable struct UN # unique name
    name :: Symbol
    ts :: UInt64
end
const pool = Dict{Tuple{UInt64, UInt64}, UN}()

function UN(n::Symbol)
    un = UN(n, time_ns())
    pool[(un.ts, objectid(un))] = un
    un
end

MLFS.TypedIO.toVec(::Type{UN}, un::UN) = [toVec(Symbol, un.name), objectid(un), un.ts]
MLFS.TypedIO.fromVec(::Type{UN}, v::Vector) =
    let n = Symbol(v[1])
        objectid = fromVec(UInt64, v[2]).value,
        ts = fromVec(UInt64, v[3]).value,
        key = (ts, objectid)

        get!(pool, key) do
            un = UN(n, ts)
        end
    end

const noImplicits = Val(false)

Base.show(io::IO, unique_name::UN) =
    if VerboseUN[]
        Base.print(io, unique_name.name, "@", objectid(unique_name))
    else
        Base.print(io, unique_name.name)
    end

@data HMT begin
    Var(id::UInt)
    Nom(n::Symbol)
    Bound(n::UN)
    App(f::HMT, arg::HMT)
    Arrow(from::HMT, to::HMT)
    Tup(Vector{HMT})
    Forall(Vector{UN}, HMT)

    Implicit(HMT)
end

@typedIO Nom(Symbol)

@typedIO HMT = begin
    Var(UInt)
    Nom(Symbol)
    Bound(UN)
    App(HMT, HMT)
    Arrow(HMT, HMT)
    Tup(Vector{HMT})
    Forall(Vector{UN}, HMT)

    Implicit(HMT)
end

need_parens(hmt::HMT) =
    @match hmt begin
        ::App || ::Arrow || ::Forall => true
        _ => false
    end

with_parens(f::Function, io::IO, need_parens::Bool) =
    if need_parens
        print(io, '(')
        f()
        print(io, ')')
    else
        f()
    end

Base.show(io::IO, hmt::HMT) =
    @switch hmt begin
    @case Var(v)
        print(io, '\'')
        print(io, v)
        return
    @case Nom(n)
        print(io, n)
        return

    @case Bound(n)
        print(io, n)
        return

    @case App(f, a)
        Base.show(io, f)
        print(io, " ")
        with_parens(io, need_parens(a)) do
            Base.show(io, a)
        end
        return
    @case Arrow(a, r)
        with_parens(io, need_parens(a)) do
            Base.show(io, a)
        end
        print(io, "->")
        Base.show(io, r)
        return
    @case Tup(xs)
        print(io, "{")
        print(io, join(repr.(xs), ", "))
        print(io, "}")
        return
    @case Forall(ns, t)
        print(io, "forall ")
        print(io, join(string.(ns), " "), ".")
        Base.show(io, t)
        return
    @case Implicit(t)
        print(io, "implicit[$t]")
    end


function gTrans(self::Function, root::HMT)
    @match root begin
        Var(_) || Nom(_) || Bound(_) => root
        App(f, arg) => App(self(f), self(arg))
        Arrow(arg, ret) => Arrow(self(arg), self(ret))
        Tup(xs) => Tup(HMT[self(x) for x in xs])
        Forall(ns, p) => Forall(ns, self(p))
        Implicit(x) => Implicit(self(x))
    end
end

function gTransCtx(self′::Function, ctx::Ctx, root::HMT) where Ctx
    @inline self(root::HMT) = self′(ctx, root)
    @match root begin
        Var(_) || Nom(_) || Bound(_) => root
        App(f, arg) => App(self(f), self(arg))
        Arrow(arg, ret) => Arrow(self(arg), self(ret))
        Tup(xs) => Tup(HMT[self(x) for x in xs])
        Forall(ns, p) => Forall(ns, self(p))
        Implicit(x) => Implicit(self(x))
    end
end

function gCheck(self::Function, root::HMT)
    @match root begin
        Var(_) || Nom(_) || Bound(_) => true
        App(f, arg) => self(f) && self(arg)
        Arrow(arg, ret) => self(arg) && self(ret)
        Tup(xs) => all(self(x) for x in xs)
        Forall(_, p) => self(p)
        Implicit(x) => self(x)
    end
end

function fresh(substitutions::Dict{UN, V}, root::HMT) where V <: HMT
    substitutions = Dict{Bound, V}(Bound(k) => v for (k, v) in substitutions)
    fresh(substitutions, root)
end

function fresh(substitutions::Dict{Bound, V}, root::HMT) where V <: HMT
    function freshRec(root::HMT)
        @match root, substitutions begin
        (Bound(_), Dict(root => var)) => var
        # (Forall(ns, p), _) => let restore = Pair{Bound, HMT}[]
        #         for n in ns
        #             k = Bound(n)
        #             v = pop!(substitutions, k, nothing)
        #             if v !== nothing
        #                 push!(restore, k => v)
        #             end
        #         end
        #         r = isempty(substitutions) ? p : gTrans(freshRec, p)
        #         for (k, v) in restore
        #             substitutions[k] = v
        #         end
        #         Forall(ns, r)
        #     end
        (t, _) => gTrans(freshRec, t)
        end
    end
    freshRec(root)
end

function subst(substitutions::Dict{A, B}, root::HMT) where {A <: HMT, B <: HMT}
    @match substitutions begin
        Dict(root => replaced) => replaced
        _ => gTransCtx(subst, substitutions, root)
    end
end
struct IllFormedType <: Exception
    msg::String
end

function tvar_of_int(i::Integer)
    Var(i)
end

function int_of_tvar(x::Var)
    x.id
end

function un_of_bound(x::Bound)
    x.n
end

function bound_of_un(x::UN)
    Bound(x)
end

function mk_tcstate(tctx::Vector{HMT})
    bound_links = Dict{UN, Set{UInt}}()

    function unlink(un::Union{UN, Bound})
        unlink(un) do _::UInt
            nothing
        end
    end

    function unlink(f::Function, b::Bound)
        unlink(f, un_of_bound(b))
    end

    function unlink(f::Function, un::UN)
        rels = pop!(bound_links, un, nothing)
        rels === nothing && return
        for rel in rels
            tctx[rel] = Var(rel)
            f(rel)
        end
        empty!(rels)
        nothing
    end

    function new_tvar()::HMT
        vid = UInt(length(tctx) + 1)
        tvar = tvar_of_int(vid)
        push!(tctx, tvar)
        tvar
    end

    function new_tvar_id()::UInt
        vid = UInt(length(tctx) + 1)
        tvar = tvar_of_int(vid)
        push!(tctx, tvar)
        vid
    end

    function occur_in(i::UInt, ty::HMT)
        @switch ty begin
            @case Var(i′) && if i′ === i end
                return false
            @case _
                visit_func(x) =
                    @match x begin
                        Var(i′) && if i′ === i end => false
                        _ => gCheck(visit_func, x)
                    end
                return !visit_func(ty)
        end
    end

    function link!(typeref::UInt, b::Bound)
        un = un_of_bound(b)
        links = 
            get!(bound_links, un) do
                Set{UInt}(UInt[typeref])
            end
        typeref in links || begin
            push!(links, typeref)
            tctx[typeref] = b
        end
        b
    end

    function link!(typeref::UInt, t::HMT)
        tctx[typeref] = t
        t
    end
    

    function prune(a::HMT)
        @match a begin
            Var(i) =>
                @match tctx[i] begin
                    Var(i′) && if i′ === i end => a
                    t => link!(i, prune(t))
                end
            a => gTrans(prune, a)
        end
    end
    
    function instantiate(x::HMT)
        @match x begin
            Forall(ns, ty) =>
                let freshmap = Dict{Bound, Var}(Bound(a) => new_tvar() for a in ns)
                    subst(freshmap, ty)
                end
            _ => x
        end
    end

    function unifyImplicits!(lhs::HMT, rhs::HMT, implicits::Vector{HMT})
        lhs = prune(lhs)
        rhs = prune(rhs)
        lhs === rhs && return true
        
        @match lhs, rhs begin
            (Forall(_, lhs), _) => unifyImplicits!(lhs, rhs, implicits)
            (Var(_), _) ||
            (_, Var(_)) => 
                unifyINST(lhs, rhs)

            (_, Forall()) =>
                begin    
                    unifyImplicits!(lhs, instantiate(rhs), implicits)
                end
            
            (_, Arrow(Implicit(im), rhs)) =>
                begin # for debugger
                    push!(implicits, im)
                    unifyImplicits!(lhs, rhs, implicits)
                end
            
            _ => unifyINST(lhs, rhs)
        end
    end

    function unifyINST(lhs::HMT, rhs::HMT)
        lhs = prune(lhs)
        rhs = prune(rhs)
        lhs === rhs && return true
        # @info :INST lhs rhs
        
        @match lhs, rhs begin
            (Forall(_, lhs), _) => unifyINST(lhs, rhs)

            (Var(i && ai), b) ||
            (b, Var(i && ai)) =>
                if occur_in(ai, b)
                    throw(IllFormedType("a = a -> b"))
                else
                    link!(i, b)
                    true
                end


            (_, Forall()) =>
                begin # for debugger
                    unifyINST(lhs, instantiate(rhs))
                end
            
            (_, Implicit(rhs)) => unifyINST(lhs, rhs)
            (Implicit(lhs), _) => unifyINST(lhs, rhs)
            (Arrow(a1, r1), Arrow(a2, r2)) =>
                begin # for debugger
                    unifyINST(a2, a1) && unifyINST(r1, r2)
                end

            (App(f1, a1), App(f2, a2)) =>
                begin # for debugger
                    unifyINST(f1, f2) && unifyINST(a1, a2)
                end

            (Tup(xs1), Tup(xs2)) =>
                all(zip(xs1, xs2)) do (lhs, rhs)
                    unifyINST(lhs, rhs)
                end
            _ => false
        end
    end

    function unify(lhs::HMT, rhs::HMT)
        lhs = prune(lhs)
        rhs = prune(rhs)
        lhs === rhs && return true

        @match lhs, rhs begin
            (Forall(ns1, p1), Forall(ns2, p2)) =>
                (begin
                    N1, N2 = length(ns1), length(ns2)
                    N1 !== N2 && return false

                    subst1 = Dict{UN, Var}(a => new_tvar() for a in ns1)
                    generic = p2
                    unify(fresh(subst1, p1), generic) || return false

                    generic = prune(generic)
                    remap2 = Bound[Bound(n) for n in ns2]
                    remap1 = Dict{Bound, Bound}()
                    
                    for (k, v) in subst1
                        v = prune(v)
                        v in remap2 || return false
                        haskey(remap1, v) && return false
                        remap1[v] = Bound(k)
                    end

                    backmap1 = Dict{Bound, Bound}()
                    backmap2 = Dict{Bound, Bound}()

                    for un in ns2
                        unlink(un) do i::UInt
                            backmap1[Var(i)] = remap1[Bound(un)]
                            backmap2[Var(i)] = Bound(un)
                        end
                    end
                    
                    unify(subst(backmap2, p2), p2) &&
                    unify(subst(backmap1, p1), p1)
                end)

            (Var(i && ai), b) ||
            (b, Var(i && ai)) =>
            
                if occur_in(ai, b)
                    throw(IllFormedType("a = a -> b"))
                else
                    link!(i, b)
                    true
                end

            (Arrow(a1, r1), Arrow(a2, r2)) =>
                unify(a1, a2) && unify(r1, r2)

            (App(f1, a1), App(f2, a2)) =>
                unify(f1, f2) && unify(a1, a2)

            (Tup(xs1), Tup(xs2)) =>
                all(zip(xs1, xs2)) do (lhs, rhs)
                    unify(lhs, rhs)
                end
            _ => false
        end
    end

    (unifyINST = unifyINST,
     unifyImplicits! = unifyImplicits!,
     unify = unify,
     tctx = tctx,
     new_tvar = new_tvar,
     new_tvar_id = new_tvar_id,
     unlink = unlink,
     occur_in = occur_in,
     instantiate = instantiate,
     prune = prune)

end

(lhs::HMT) ⪯ (rhs::HMT)  = begin
    small_tc = mk_tcstate(HMT[])
    subst_table = Dict{UInt, Var}()
    function subst(root::HMT)
        @match root begin
            Var(i) =>
                get!(subst_table, i) do
                    small_tc.new_tvar()
                end
            
            _ => gTrans(subst, root)
        end
    end
    small_tc.unifyImplicits(subst(lhs), subst(rhs), HMT[])
end

function less_than_under_evidences(lhs::HMT, rhs ::HMT)
    evidences = HMT[]
    small_tc = mk_tcstate(HMT[])
    subst_table = Dict{UInt, Var}()
    function subst(root::HMT)
        @match root begin
            Var(i) =>
                get!(subst_table, i) do
                    small_tc.new_tvar()
                end
            
            _ => gTrans(subst, root)
        end
    end
    small_tc.unifyImplicits!(subst(lhs), subst(rhs), evidences), evidences
end

end