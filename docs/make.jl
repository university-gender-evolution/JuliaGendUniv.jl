using JuliaGendUniv
using Documenter

DocMeta.setdocmeta!(JuliaGendUniv, :DocTestSetup, :(using JuliaGendUniv); recursive=true)

makedocs(;
    modules=[JuliaGendUniv],
    authors="Krishna Bhogaonker",
    repo="https://github.com/university-gender-evolution/JuliaGendUniv.jl/blob/{commit}{path}#{line}",
    sitename="JuliaGendUniv.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://university-gender-evolution.github.io/JuliaGendUniv.jl/",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="https://github.com/university-gender-evolution/JuliaGendUniv.jl",
    devbranch="main",
)
