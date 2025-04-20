using InformalDAX
using Documenter

DocMeta.setdocmeta!(InformalDAX, :DocTestSetup, :(using InformalDAX); recursive=true)

makedocs(;
    modules=[InformalDAX],
    authors="C. Naaktgeboren <NaaktgeborenC.PhD@gmail.com> and contributors",
    sitename="InformalDAX.jl",
    format=Documenter.HTML(;
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
