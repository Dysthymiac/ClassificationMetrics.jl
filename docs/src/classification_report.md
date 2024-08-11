```@meta
CurrentModule = ClassificationMetrics
DocTestSetup = quote
    using ClassificationMetrics
end
```

# Classification report

Aggregate statistics for the multiclass classification can be conveniently calculated and summarized using the [`classification_report`](@ref) function. 

```@setup 1
using Random
using ClassificationMetrics
Random.seed!(1)

```

```@example 1
classes = [:Class1, :Class2, :Class3]

predicted = rand(classes, 100)
actual = rand(classes, 100)

classification_report(predicted, actual, label_set=classes)
nothing # hide
```

It is possible to specify custom metrics and custom aggregation subsets. If it is necessary, for example, to only aggregate specific classes, it can be accomplished with the [`aggregate_subset`](@ref) that can be passed along other aggregations:


```@example 1
using ClassificationMetrics:precision

classification_report(predicted, 
                        actual, 
                        label_set=classes,
                        metrics=[precision, recall, F1_score, Fβ_score(2)],
                        aggregations=[
                            aggregate_subset(
                                macro_aggregation, 
                                name="Classes 1 and 2", 
                                predicate=∈([:Class1, :Class2])),
                            aggregate_subset(
                                macro_aggregation, 
                                name="Classes 2 and 3", 
                                predicate=∈([:Class2, :Class3])),
                            micro_aggregation,
                            macro_aggregation,
                            weighted_aggregation
                        ])
nothing # hide
```

The table is printed using [`PrettyTables`](https://github.com/ronisbr/PrettyTables.jl) and accepts keyword arguments defined in that package. For example, to print the table in the ``\LaTeX`` or Markdown formats, one can specify the `backend`:

```@example 1
using Markdown

markdown_table = classification_report(predicted, 
                        actual, 
                        label_set=classes,
                        metrics=[precision, recall, F1_score, Fβ_score(2)],
                        aggregations=[
                            aggregate_subset(
                                macro_aggregation, 
                                name="Classes 1 and 2", 
                                predicate=∈([:Class1, :Class2])),
                            aggregate_subset(
                                macro_aggregation, 
                                name="Classes 2 and 3", 
                                predicate=∈([:Class2, :Class3])),
                            micro_aggregation,
                            macro_aggregation,
                            weighted_aggregation
                        ],
                        io=String,
                        backend=Val(:markdown)) |> first
Markdown.parse(markdown_table) # hide
```

```@setup 1
struct LaTeXEquation 
    content::String
end

function Base.show(io::IO, ::MIME"text/latex", x::LaTeXEquation)
    # Wrap in $$ for display math printing
    return print(io, "\$\$ " * x.content * " \$\$")
end
```

```@example 1
latex_table = classification_report(predicted, 
                        actual, 
                        label_set=classes,
                        metrics=[precision, recall, F1_score, Fβ_score(2)],
                        aggregations=[
                            aggregate_subset(
                                macro_aggregation, 
                                name="Classes 1 and 2", 
                                predicate=∈([:Class1, :Class2])),
                            aggregate_subset(
                                macro_aggregation, 
                                name="Classes 2 and 3", 
                                predicate=∈([:Class2, :Class3])),
                            micro_aggregation,
                            macro_aggregation,
                            weighted_aggregation
                        ],
                        io=String,
                        backend=Val(:latex)) |> first

using Latexify # hide

latex_string = Latexify.LaTeXString(latex_table) # hide
render(latex_string, MIME("image/svg"), documentclass=("standalone"), name="table",open=false) # hide
# latex_table # hide
nothing # hide
```
![](table.svg)