using ClassificationMetrics
using Documenter

DocMeta.setdocmeta!(ClassificationMetrics, :DocTestSetup, :(using ClassificationMetrics); recursive=true)

makedocs(;
    modules=[ClassificationMetrics],
    authors="Fedor Zolotarev",
    sitename="ClassificationMetrics.jl",
    format=Documenter.HTML(;
        canonical="https://Dysthymiac.github.io/ClassificationMetrics.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Confusion matrix" => "confusion_matrix.md",
        "Prediction results" => "prediction_results.md",
        "Metrics" => "metrics.md",
        "Classification report" => "classification_report.md",
        "API reference" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/Dysthymiac/ClassificationMetrics.jl",
    devbranch="main",
)