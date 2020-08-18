using MLFS
using Documenter

makedocs(;
    modules=[MLFS],
    authors="thautwarm <twshere@outlook.com> and contributors",
    repo="https://github.com/thautwarm/MLFS.jl/blob/{commit}{path}#L{line}",
    sitename="MLFS.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://thautwarm.github.io/MLFS.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/thautwarm/MLFS.jl",
)
