```@meta
CurrentModule = ClassificationMetrics
DocTestSetup = quote
    using ClassificationMetrics
end
```

# Confusion matrix

Confusion matrix can be created from predicted and actual labels using [`confusion_matrix`](@ref):

```@example
using ClassificationMetrics

actual    = [0, 0, 0, 1, 1, 1, 2, 2, 2]
predicted = [1, 2, 0, 0, 0, 1, 0, 2, 0]

confusion_matrix(predicted, actual, sort_labels=true)
```

It is possible to provide full label set in case not all classes are present in the data. Optional argument `sort_labels` specifies whether the labels should be sorted or not. 
The confusion matrix is stored in a convenience struct [`ConfusionMatrix`](@ref) that holds the matrix itself and the labels. It can be passed to [`prediction_results`](@ref) and [`classification_report`](@ref) to get further results or "pretty printed" in the terminal. 