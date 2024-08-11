```@meta
CurrentModule = ClassificationMetrics
DocTestSetup = quote
    using ClassificationMetrics
end
```

# Metrics

## Built-in metrics

A large number of classic classification metrics is defined in the package:

- [`binary_accuracy`](@ref)
- [`precision`](@ref)
- [`recall`](@ref)
- [`sensitivity`](@ref)
- [`fall_out`](@ref)
- [`miss_rate`](@ref)
- [`specificity`](@ref)
- [`jaccard`](@ref)
- [`support`](@ref)
- [`true_false_ratio`](@ref)
- [`Fβ_score`](@ref)

All metrics can be applied to four scalars `TP`, `FN`, `FP` and `TN`. 
```@example 1
using ClassificationMetrics

recall(25, 0, 1, 1)
```
If those arguments are not scalars but vectors, or [`ConfusionMatrix`](@ref), [`PredictionResults`](@ref), or predicted and actual labels, then the aggregation strategy will be used. 

```@example 1

actual    = [0, 0, 0, 1, 1, 1, 2, 2, 2]
predicted = [1, 0, 0, 0, 0, 1, 0, 2, 0]

recall(predicted, actual; aggregation=macro_aggregation)
```

It is also possible to specify [`no_aggregation`](@ref) as the aggregation strategy to return values for each class.
By default, it uses aggregation created by the [`default_aggregation`](@ref) function. The default can be changed by calling [`set_default_aggregation!`](@ref):

```@example 1

ClassificationMetrics.set_default_aggregation!(no_aggregation)

recall(predicted, actual, sort_labels=true)
```

## Aggregation

There are 4 standard aggregation strategies available:
- [`no_aggregation`](@ref)
- [`micro_aggregation`](@ref)
- [`macro_aggregation`](@ref)
- [`weighted_aggregation`](@ref)

By default, [`weighted_aggregation`](@ref) uses class supports to calculate weights, but it is possible to pass custom class weights as an optional keyword argument. For convenience of passing the function as the argument, it is possible to call [`weighted_aggregation`](@ref) with 1 argument to create a function with custom weights:
```@example 1


recall(predicted, actual, sort_labels=true, aggregation=weighted_aggregation([2, 1, 1]))
```

Custom aggregation can be used by defining your own function:
```@example 1
using Statistics

micro_median_aggregation(func, TP, FN, FP, TN) = median(func.(TP, FN, FP, TN))

recall(predicted, actual, sort_labels=true, aggregation=micro_median_aggregation)
```

## Custom metrics

Defining a custom metric is also made easy thanks to the [`@metric`](@ref) macro. In order to define a metric, one needs only to define a function that calculates it for scalar `TP`, `FN`, `FP` and `TN`, and the [`@metric`](@ref) macro will automatically define all other functions, allowing the metric to be called for [`ConfusionMatrix`](@ref), [`PredictionResults`](@ref), and predicted/actual labels. It also allows to optionally define a display name for a metric that will be used in the [`classification_report`](@ref):

```@example 1

using ClassificationMetrics: safe_div

# Option 1: define a function and then extend it in a separate macro call

true_negative_rate(TP, FN, FP, TN) = 1 − false_positive_rate(TP, FN, FP, TN)

@metric true_negative_rate

# Option 2: use macro on the function definition

@metric "Bookmaker informedness" informedness(TP, FN, FP, TN) = true_positive_rate(TP, FN, FP, TN) + true_negative_rate(TP, FN, FP, TN) − 1

classification_report(predicted, actual, sort_labels=true, metrics=[true_negative_rate, informedness])
nothing # hide
```

Note that a custom name can be assigned to the metric by passing a string before the function name. That name will be used in the [`classification_report`](@ref).