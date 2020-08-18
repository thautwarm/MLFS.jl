module HM
export HMT, TVar, mk_tcstate
export Refvar, Genvar
export Var, Nom, Fresh, Var, Arrow, App, Tup, Forall
export gTrans, gTransCtx, gCheck
export tvar_of_int, int_of_tvar, IllFormedType
export ⪯

using MLStyle
import Base
abstract type TVar end
@data TVar begin
    Refvar(i::UInt)
    Genvar(g::UInt, n::Symbol)
end

function Base.show(io::IO, x::TVar)
    @match x begin
        Genvar(g, n) => print(io, "'$n($g)")
        Refvar(i) => print(io, '\'', i)
    end
end

@data HMT begin
    Var(var::TVar)
    Nom(n::Symbol)
    Fresh(Symbol)
    App(f::HMT, arg::HMT)
    Arrow(from::HMT, to::HMT)
    Tup{N}::(NTuple{N,HMT}) => HMT
    Forall{N}::(NTuple{N,Symbol}, HMT) => HMT
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
        print(io, v)
        return
    @case Nom(n)
        print(io, n)
        return

    @case Fresh(n)
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
    end


function gTrans(self::Function, root::HMT)
    @match root begin
        Var(_) || Nom(_) || Fresh(_) => root
        App(f, arg) => App(self(f), self(arg))
        Arrow(arg, ret) => Arrow(self(arg), self(ret))
        Tup(xs) => Tup(Tuple(self(x) for x in xs))
        Forall(ns, p) => Forall(ns, self(p))
    end
end

function gTransCtx(self′::Function, ctx::Ctx, root::HMT) where Ctx
    self(root::HMT) = self′(ctx, root)
    @match root begin
        Var(_) || Nom(_) || Fresh(_) => root
        App(f, arg) => App(self(f), self(arg))
        Arrow(arg, ret) => Arrow(self(arg), self(ret))
        Tup(xs) => Tup(Tuple(self(x) for x in xs))
        Forall(ns, p) => Forall(ns, self(p))
    end
end

function gCheck(self::Function, root::HMT)
    @match root begin
        Var(_) || Nom(_) || Fresh(_) => true
        App(f, arg) => self(f) && self(arg)
        Arrow(arg, ret) => self(arg) && self(ret)
        Tup(xs) => all(self(x) for x in xs)
        Forall(_, p) => self(p)
    end
end

function fresh(substitutions::Dict{Symbol, V}, root::HMT) where V <: HMT
    substitutions = Dict{Fresh, V}(Fresh(k) => v for (k, v) in substitutions)
    fresh(substitutions, root)
end

function fresh(substitutions::Dict{Fresh, V}, root::HMT) where V <: HMT
    function freshRec(root::HMT)
        @match root, substitutions begin
        (Fresh(_), Dict(root => var)) => var
        (Forall(ns, p), _) => let restore = Pair{Fresh, HMT}[]
                for n in ns
                    k = Fresh(n)
                    v = pop!(substitutions, k, nothing)
                    if v !== nothing
                        push!(restore, k => v)
                    end
                end
                r = isempty(substitutions) ? p : gTrans(freshRec, p)
                for (k, v) in restore
                    substitutions[k] = v
                end
                r
            end
        (t, _) => gTrans(freshRec, t)
        end
    end
    freshRec(root)
end

struct IllFormedType <: Exception
    msg::String
end

function tvar_of_int(i::Integer)
    Var(Refvar(i))
end

function int_of_tvar(x::Var)
    @match x begin
        Var(Refvar(i)) => i
        _ => nothing
    end
end

function mk_tcstate(tctx::Vector{HMT}, new_tvar_hook::Union{Nothing, Function}=nothing)
    genvars = Genvar[]
    genvar_links = Set{UInt}[]
    function new_genvar(s::Symbol)::Var
        genlevel = length(genvars) + 1
        genvar = Genvar(genlevel, s)
        push!(genvars, genvar)
        push!(genvar_links, Set{UInt}())
        Var(genvar)
    end

    function unlink(maxlevel :: Integer)
        while true
            level = length(genvars)
            if level <= maxlevel
                break
            end
            pop!(genvars)
            vars = pop!(genvar_links) :: Set{UInt}
            for typevar_id in vars
                tctx[typevar_id] = Var(Refvar(typevar_id))
            end
        end
    end

    function unlink(f::Function, maxlevel :: Integer)
        while true
            level = length(genvars)
            if level <= maxlevel
                break
            end
            gen = pop!(genvars)
            vars = pop!(genvar_links) :: Set{UInt}
            for typevar_id in vars
                v = Var(Refvar(typevar_id))
                tctx[typevar_id] = v
                f(Var(gen), v)
            end
        end
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

    function occur_in(i::Refvar, ty::HMT)
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

    function prune(a::HMT)
        @match a begin
            Var(Refvar(i)) =>
                @match tctx[i] begin
                    Var(Refvar(i′)) && if i′ === i end => a
                    a => let t = prune(a)
                            tctx[i] = t
                            t
                         end
                end
            a => gTrans(prune, a)
        end
    end

    function unifyINST(lhs::HMT, rhs::HMT)
        lhs = prune(lhs)
        rhs = prune(rhs)
        lhs === rhs && return true
        @match lhs, rhs begin
            (Forall(ns1, ty1), Forall(ns2, ty2)) =>
            begin
                genlevel = length(genvar_links)
                subst1 = Dict{Fresh, Var}(Fresh(a) => new_genvar(a) for a in ns1)
                subst2 = Dict{Fresh, Var}(Fresh(a) => new_tvar() for a in ns2)
                unifyINST(fresh(subst1, ty1), fresh(subst2, ty2)) || return false
                unlink(genlevel)
                true
            end

            (Var(Refvar(i) && ai), b) ||
            (b, Var(Refvar(i) && ai)) =>
                if occur_in(ai, b)
                    throw(IllFormedType("a = a -> b"))
                else
                    @match b begin
                        Genvar(genlevel, _) =>
                            push!(genvar_links[genlevel], i)
                        _ => nothing
                    end
                    tctx[i] = b
                    true
                end

            (ty1, Forall(ns2, ty2)) =>
                begin
                    subst2 = Dict{Fresh, Var}(Fresh(a) => new_tvar() for a in ns2)
                    unifyINST(ty1, fresh(subst2, ty2))
                end

            
            (Arrow(a1, r1), Arrow(a2, r2)) =>
                unifyINST(a2, a1) && unifyINST(r1, r2)

            (App(f1, a1), App(f2, a2)) =>
                unifyINST(f1, f2) && unifyINST(a1, a2)

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
            (Forall{N1}(ns1, p1) where N1, Forall{N2}(ns2, p2) where N2) =>
                N1 === N2 &&
                (begin
                    pt = Pair{Symbol, HMT}
                    subst1 = Dict{Symbol, Var}(a => new_tvar() for a in ns1)
                    genlevel = length(genvar_links)
                    subst2 = Dict{Symbol, Var}(a => new_genvar(a) for a in ns2)
                    generic = fresh(subst2, p2)
                    unify(fresh(subst1, p1), generic) || return false

                    generic = prune(generic)
                    remap2 = Dict{Var, Fresh}(v => Fresh(k) for (k, v) in subst2)
                    remap1 = Dict{Var, Fresh}()
                    for (k, v) in subst1
                        v = prune(v)
                        haskey(remap2, v) || return false
                        haskey(remap1, v) && return false
                        remap1[v] = Fresh(k)
                    end
                    backmap1 = Dict{Var, Fresh}()
                    backmap2 = Dict{Var, Fresh}()

                    unlink(genlevel) do v::Var, i::Var
                        backmap1[i] = remap1[v]
                        backmap2[i] = remap2[v]
                    end

                    unify(subst(backmap2, p2), p2) &&
                    unify(subst(backmap1, p1), p1)
                end)

            (Var(Refvar(i) && ai), b) ||
            (b, Var(Refvar(i) && ai)) =>
            
                if occur_in(ai, b)
                    throw(IllFormedType("a = a -> b"))
                else
                    @match b begin
                        Genvar(genlevel, _) =>
                            push!(genvar_links[genlevel], i)
                        _ => nothing
                    end
                    tctx[i] = b
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
     unify = unify,
     tctx = tctx,
     new_tvar = new_tvar,
     new_tvar_id = new_tvar_id,
     genvar_links = genvar_links,
     unlink = unlink,
     occur_in = occur_in,
     prune = prune)

end

(lhs::HMT) ⪯ (rhs::HMT)  = begin
    small_tc = mk_tcstate(HMT[])
    subst_table = Dict{UInt, Var}()
    function subst(root::HMT)
        @match root begin
            Var(Refvar(i)) =>
                get!(subst_table, i) do
                    small_tc.new_tvar()
                end
            
            _ => gTrans(subst, root)
        end
    end
    small_tc.unifyINST(subst(lhs), subst(rhs))
end

end