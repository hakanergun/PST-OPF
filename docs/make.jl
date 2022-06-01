using Documenter, PSTOPF

makedocs(
    modules = [PSTOPF],
    format = Documenter.HTML(analytics = "UA-367975-10", mathengine = Documenter.MathJax()),
    sitename = "PSTOPF",
    authors = "Hakan&Marta",
    pages = [
        "Home" => "index.md",
        "Manual" => [
            "Getting Started" => "quickguide.md",
        ]
    ]
)

deploydocs(
    repo = "github.com/hakanergun/PST-OPF.git",
)