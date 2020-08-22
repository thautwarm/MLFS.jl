using MLFS
using PrettyPrint
using Setfield
using MLFS.HM
using MLStyle
import JSON
import FileIO

export smlfsCompile

macro _check_prune(a)
    quote
        let ret = pruneWithVarCheck(collect_unsolved, $a)
            !isempty(unsolved_vars) &&
                throw(MLError(ln, UnsolvedTypeVariables(unsolved_vars)))
            ret
        end
    end |> esc
end
function mkPostInfer(g::GlobalTC)
    pruneWithVarCheck = g.tcstate.pruneWithVarCheck
    unsolved_vars = Set{Var}()
    function collect_unsolved(v::Var)
        push!(unsolved_vars, v)
    end

    function postInfer(ln::LineNumberNode, root::IR.Decl)
        @match root begin
            IR.Perform(_) => IR.gTransCtx(postInfer, ln, root)
            IR.Assign(a, t, e) => 
                IR.Assign(a, @_check_prune(t), postInfer(ln, e))
        end
    end

    function postInfer(ln::LineNumberNode, root::IR.Expr)
        @match root begin
            IR.Expr(ln, ty, expr) =>
                let expr = postInfer(ln, expr),
                    ty = ty === nothing ? nothing : @_check_prune(ty)
                    
                    IR.Expr(ln, ty, expr)
                end 
        end
    end

    function postInfer(ln::LineNumberNode, root::IR.ExprImpl)
        @match root begin
            IR.EIm(expr, t, insts) => 
                let expr = postInfer(ln, expr),
                    t = @_check_prune(t)

                    IR.EApp(expr, instanceResolve(g, insts, t, ln))
                end
            IR.ETypeVal(t) => IR.ETypeVal(@_check_prune(t))
            _ => IR.gTransCtx(postInfer, ln, root)
        end
    end
    postInfer
end

const preDefinedTypeEnv = Store{Symbol, HMT}()[[
    a => T(Nom(a)) for a in Symbol[
        :i8, :i16, :i32, :i64,
        :i16, :i32, :i64,
        :f16, :f32, :f64,
        :char, :str, :bool,
        :Module,
        :field,
        :namespace,
        :Type
    ]
]]

const Path = String

moduleGensym(moduleName::Symbol) = Symbol(:|, moduleName, :|)
moduleExportName(moduleName::Symbol) = Symbol(moduleName)

PostInfer = Base._return_type(mkPostInfer, (GlobalTC, ))

const Signature = Pair{Vector{Symbol}, Vector{Pair{Nom, Vector{InstRec}}}}


"""
smlfs-c A=a.mlfs B=b.mlfs C=c.mlfs -sigdir -o pkgA
"""
function smlfsCompile(
    srcFiles::Vector{Path},
    sigFiles::Vector{Path},
    outName::String,
    outDir::String="./")
    
    loadedModules = Set{Symbol}()
    g = empty(GlobalTC)
    loadSigs(sigFiles, loadedModules, g)

    decls, signature = loadSrcs(srcFiles, loadedModules, g)
    show_hints(g)

    declsJSON = toVec(Vector{IR.Decl}, decls)
    open(joinpath(outDir, "$outName.mlfso"), "w") do f
        write(f, JSON.json(declsJSON))
    end
   
    sigJSON = toVec(Signature, signature)
    open(joinpath(outDir, "$outName.mlfsa"), "w") do f
        write(f, JSON.json(sigJSON))
    end
end


const FieldClass = Nom(:field)
const NamespaceClass = Nom(:namespace)

function loadSigs(sigFiles::Vector{Path}, loadedModules::Set{Symbol}, g::GlobalTC)
    for each in sigFiles
        sig = open(each) do f
            srcCode = read(f, String)
            fromVec(
                Signature,
                JSON.Parser.parse(srcCode))
        end
        sig === nothing && error("unrecognised signature file at $each.")
        newModuleNames, implicits = sig.value
        reloadedModules = intersect(loadedModules,  newModuleNames)
        isempty(reloadedModules) ||
            error("module name conflicts: duplicate modules with the same names: $reloadedModules")
        for (tConsHead, insts) in implicits
            append!(g.globalImplicits[tConsHead], insts)
        end
    end
end

function loadSrcs(srcFiles::Vector{Path}, loadedModules::Set{Symbol}, g::GlobalTC)
    globalImplicitDeltas = g.globalImplicitDeltas
    decls = IR.Decl[]
    moduleNames = Symbol[]
    for path in srcFiles
        mR = open(path) do f
            srcCode = read(f, String)
            mR = fromVec(Surf.ModuleRecord, JSON.Parser.parse(srcCode))
            if mR === nothing
                error("Invalid surface file at $path")
            end
            mR = mR.value
            moduleName = mR.name
            moduleName in loadedModules &&
                error("module name conflicts: duplicate modules with the same names: $moduleName")
            push!(loadedModules, moduleName)
            push!(moduleNames, moduleName)
            append!(
                decls,
                loadModule(moduleName, mR.imports, mR.decls, path, g))
        end
    end

    prune = g.tcstate.prune
    pruneRel(x::InstRec) = begin
        x.isPruned || (x.t = prune(x.t))
        x
    end
    signature = Pair{Nom, Vector{InstRec}}[
        nom =>
            pruneRel.(g.globalImplicits[nom][end-n+1:end])
        for (nom, n) in globalImplicitDeltas
    ]
    decls, (moduleNames=>signature)
end

function loadModule(
    moduleName::Symbol,
    imports::Vector{Pair{Symbol, Symbol}},
    decls::Vector{Surf.Decl},
    path::Path,
    g::GlobalTC)

    tcstate = g.tcstate
    prune = tcstate.prune

    g = @set g.moduleName = moduleName
    l = empty(LocalTC)
    l = @set l.typeEnv = preDefinedTypeEnv
    for (importModule, alias) in imports
        moduleType = App(Nom(:Module), Nom(importModule))
        l = @set l.typeEnv = l.typeEnv[alias => moduleType]
        l = @set l.symmap = l.symmap[alias => moduleGensym(importModule)]
    end

    results, localTC = inferModule(g, l, decls)
    ln = LineNumberNode(1, path)
    globalImplicits = get!(g.globalImplicits, FieldClass) do
        InstRec[]
    end

    globalImplicitDeltas = g.globalImplicitDeltas
    get!(globalImplicitDeltas, FieldClass, 0)
    
    moduleType = App(Nom(:Module), Nom(moduleName))
    
    function mkField(usersym::Symbol, genexp::ExprImpl, pruned_type::HMT)
        local instanceTy
        instanceTy = App(FieldClass, Tup(HMT[
            moduleType, Nom(usersym), pruned_type]))
        push!(globalImplicits, InstRec(instanceTy, ln, genexp, true))
    end

    fields = Dict{Symbol, Tuple{Gensym, HMT}}()
    for (usersym, type) in localTC.typeEnv.unbox
        if haskey(fields, usersym) || type === get(preDefinedTypeEnv, usersym, nothing)
            # shadowing
            continue
        end
    
        gensym = get(localTC.symmap, usersym, nothing)
        method_gensym = symgen(g)
        type = prune(type)
        genexp = @match type begin
            T(type) => IR.ETypeVal(type)
            
            # TODO: what does this mean?
            if gensym === nothing end => IR.EInt(0, 8)

            _ => IR.EVar(gensym::Symbol)
        end
        fields[usersym] = (gensym, type)
        genexp = IR.Expr(ln, nothing, IR.EFun(:_, IR.Expr(ln, nothing, genexp)))
        push!(results, IR.Assign(method_gensym, Arrow(HM.⊤, type), genexp))
        mkField(usersym, IR.EVar(method_gensym), prune(type))
    end
    globalImplicitDeltas[FieldClass] += length(fields)

    globalImplicits = get!(g.globalImplicits, Nom(:Module)) do
        InstRec[]
    end
    push!(globalImplicits, InstRec(moduleType, ln, IR.ETypeVal(moduleType), true))

    get!(globalImplicitDeltas, Nom(:Module), 0)
    globalImplicitDeltas[Nom(:Module)] += 1

    globalImplicits = get!(g.globalImplicits, NamespaceClass) do
        InstRec[]
    end

    get!(globalImplicitDeltas, NamespaceClass, 0)
    instanceTy = App(
        NamespaceClass,
        Tup(
            HMT[
                moduleType,
                Tup(HMT[Tup([Nom(k), Nom(gensym), t]) for (k, (gensym, t)) in fields])]))

    
    push!(globalImplicits, InstRec(instanceTy, ln, IR.ETypeVal(instanceTy), true))
    globalImplicitDeltas[NamespaceClass] += 1

    # type class, etc
    postInfer = mkPostInfer(g)
    for i in eachindex(results)
        results[i] = postInfer(ln, results[i])
    end

    push!(results,
        IR.Assign(moduleGensym(moduleName), moduleType, 
            IR.Expr(ln, nothing, IR.ETypeVal(moduleType))),
        IR.Assign(moduleExportName(moduleName), instanceTy,
            IR.Expr(ln, nothing, IR.ETypeVal(instanceTy))),
    )
    results
end
