using JuliaGendUniv
using Documenter

DocMeta.setdocmeta!(JuliaGendUniv, :DocTestSetup, :(using JuliaGendUniv); recursive=true)

makedocs(;
    modules=[JuliaGendUniv],
    authors="Krishna Bhogaonker",
    repo="https://github.com/00krishna/JuliaGendUniv.jl/blob/{commit}{path}#{line}",
    sitename="JuliaGendUniv.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://00krishna.github.io/JuliaGendUniv.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/00krishna/JuliaGendUniv.jl",
    devbranch="main",
)
