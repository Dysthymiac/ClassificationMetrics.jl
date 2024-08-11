
```@meta
CurrentModule = ClassificationMetrics
DocTestSetup = quote
    using ClassificationMetrics
end
```

# Prediction results

Prediction results refer to `TP`, `FN`, `FP` and `TN` values. They can be calculated using [`prediction_results`](@ref):

```@example
using ClassificationMetrics

actual    = [0, 0, 0, 1, 1, 1, 2, 2, 2]
predicted = [1, 2, 0, 0, 0, 1, 0, 2, 0]

prediction_results(predicted, actual, sort_labels=true)
```

It is possible to provide full label set in case not all classes are present in the data. Optional argument `sort_labels` specifies whether the labels should be sorted or not. 
The results are stored in a convenience struct [`PredictionResults`](@ref) that holds `TP`, `FN`, `FP` and `TN` values and the labels. It can be passed to [`classification_report`](@ref) to get further results or "pretty printed" in the terminal. 

It is also possible to index the results and concatenate them with `vcat`:

```@example
using ClassificationMetrics

actual    = [0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3]
predicted = [1, 2, 0, 0, 0, 1, 0, 2, 0, 2, 0, 3]

res = prediction_results(predicted, actual, sort_labels=true)
res1 = res[1:2]
res2 = res[4]

vcat(res1, res2)
```

The indexing uses the order of the labels stored in [`PredictionResults`](@ref).