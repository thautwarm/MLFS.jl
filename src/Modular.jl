using MLFS
using PrettyPrint
using Setfield
using MLFS.HM
using MLStyle
import JSON
import FileIO

export smlfsCompile

function mkPostInfer(g::GlobalTC)
    prune = g.tcstate.prune

    function postInfer(root::IR.Decl)
        @match root begin
            IR.Perform() => IR.gTrans(postInfer, root)
            IR.Assign(a, t, e) => 
                IR.Assign(a, prune(t), postInfer(e))
        end
    end

    function postInfer(root::IR.Expr)
        @match root begin
            IR.Expr(ln, ty, expr) =>
                let expr = postInferE(expr, ln),
                    ty = ty === nothing ? nothing : prune(ty)
                    
                    IR.Expr(ln, ty, expr)
                end 
        end
    end

    function postInferE(root::IR.ExprImpl, ln::LineNumberNode)
        @match root begin
            IR.EIm(expr, t, insts) => 
                let expr = postInfer(expr),
                    t = prune(t)

                    IR.EApp(expr, instanceResolve(g, insts, t, ln))
                end
            IR.ETypeVal(t) => IR.ETypeVal(prune(t))
            _ => IR.gTrans(postInfer, root)
        end
    end
    postInfer
end

const preDefinedTypeEnv = Store{Symbol, HMT}()[[
    a => T(Nom(a)) for a in Symbol[
        :i8, :i16, :i32, :i64,
        :i16, :i32, :i64,
        :char, :str, :bool,
        :module,
        :field,
        :fieldnames,
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
const FieldNamesClass = Nom(:fieldnames)

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
        moduleType = App(Nom(:module), Nom(importModule))
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
    
    moduleType = App(Nom(:module), Nom(moduleName))
    
    function mkField(usersym::Symbol, genexp::ExprImpl, pruned_type::HMT)
        local instanceTy
        instanceTy = App(FieldClass, Tup(HMT[
            moduleType, Nom(usersym), pruned_type]))
        push!(globalImplicits, InstRec(instanceTy, ln, genexp, true))
    end

    fields = Dict{Symbol, Tuple{HMT, IR.ExprImpl}}()
    for (usersym, type) in localTC.typeEnv.unbox
        if haskey(fields, usersym)
            # shadowing
            continue
        end
        gensym = get(localTC.symmap, usersym, nothing)
        type = prune(type)
        genexp = @match type begin
            T(_) => IR.ETypeVal(type)
            
            # TODO: what does this mean?
            if gensym === nothing end => IR.EInt(0, 8)

            _ => IR.EVar(gensym::Symbol)
        end
        fields[usersym] = (type, genexp)
        
        mkField(usersym, genexp, prune(type))
    end
    globalImplicitDeltas[FieldClass] += length(fields)

    globalImplicits = get!(g.globalImplicits, FieldNamesClass) do
        InstRec[]
    end

    get!(globalImplicitDeltas, FieldNamesClass, 0)
    instanceTy = App(
        FieldNamesClass,
        Tup(
            HMT[
                moduleType,
                Tup(HMT[Nom(k) for (k, _) in fields])]))

    
    push!(globalImplicits, InstRec(instanceTy, ln, IR.ETypeVal(instanceTy), true))
    globalImplicitDeltas[FieldNamesClass] += 1
    push!(
        results,
        IR.Assign(moduleGensym(moduleName), Tup(HMT[]), IR.Expr(ln, nothing, IR.ETup([]))),
        IR.Assign(
            moduleExportName(moduleName),
            Tup(
              HMT[
                Tup(HMT[strT for _ in fields])
              , Tup(HMT[prune(t) for (_, (t, _)) in fields])
              ]),
            IR.Expr(ln, nothing,
            IR.ETup([
                IR.Expr(ln, nothing,
                IR.ETup(
                [
                    IR.Expr(ln, nothing, IR.EStr(string(k)))
                    for (k, _) in fields
                ])),
                IR.Expr(ln, nothing,
                IR.ETup(
                [
                    IR.Expr(ln, nothing, e)
                    for (_, (_, e)) in fields
                ]))
            ]))))

    # type class, etc
    postInfer = mkPostInfer(g)
    for i in eachindex(results)
        results[i] = postInfer(results[i])
    end

    results
end
