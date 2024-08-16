"""
    no_aggregation(func, TP, FN, FP, TN)

One of possible aggregation options. Does not perform aggregation and instead returns metrics for each class.
"""
no_aggregation(func, TP, FN, FP, TN) = func.(TP, FN, FP, TN)
"""
    micro_aggregation(func, TP, FN, FP, TN)

One of possible aggregation options. Performs micro aggregation, i.e. applies metric to each class and reports the mean.
"""
micro_aggregation(func, TP, FN, FP, TN) = nonzero_mean(func.(TP, FN, FP, TN))
"""
    macro_aggregation(func, TP, FN, FP, TN)

One of possible aggregation options. Performs macro aggregation, i.e. sums values of all classes and applies the metric.
"""
macro_aggregation(func, TP, FN, FP, TN) = func(sum(TP), sum(FN), sum(FP), sum(TN))
"""
    weighted_aggregation(func, TP, FN, FP, TN; weights=TP .+ FN)
    weighted_aggregation(weights; name="Weighted (Custom)")

One of possible aggregation options. Performs weighted aggregation, i.e. applies metric to each class and reports the weighted mean.
By default, uses support of each class as the weight, but allows passing custom weights.
`weighted_aggregation(weights; name="Weighted (Custom)")` returns an aggregation function with fixed weights, useful for passing to [`classification_report`](@ref).
"""
function weighted_aggregation(func, TP, FN, FP, TN; weights=TP .+ FN)
    return sum(weights .* func.(TP, FN, FP, TN) ./ sum(weights))
end
function weighted_aggregation(weights; name="Weighted (Custom)") 
    custom_weighted_aggregation = (func, TP, FN, FP, TN) -> weighted_aggregation(func, TP, FN, FP, TN; weights=weights)
    @eval get_print_name(::$(typeof(custom_weighted_aggregation))) = name
    return custom_weighted_aggregation
end

"""
    get_print_name(x)

Returns a "pretty" name to be used in the classification report table. 
"""
get_print_name(::typeof(no_aggregation)) = "No aggregation"
get_print_name(::typeof(micro_aggregation)) = "Micro"
get_print_name(::typeof(macro_aggregation)) = "Macro"
get_print_name(::typeof(weighted_aggregation)) = "Weighted"
function pretty_name(m)
    return uppercasefirst(replace(string(m), r"(\d+)_(\d+)" => s"\1.\2", "_" => " "))
end
get_print_name(x) = pretty_name(x)

"""
    default_aggregation()

Returns aggregation used by default by all metrics. The default is [`weighted_aggregation`](@ref). Can be changed with [`set_default_aggregation!`](@ref).
"""
default_aggregation() = weighted_aggregation
"""
    set_default_aggregation!(aggregation)

Changes aggregation used by default by all metrics.
"""
set_default_aggregation!(aggregation) = @eval default_aggregation() = $aggregation

"""
    apply_metric(metric, TP, FN, FP, TN; aggregation=default_aggregation(), kws...)
    apply_metric(metric, pr::PredictionResults; aggregation=default_aggregation(), kws...)
    apply_metric(metric, confusion_matrix::ConfusionMatrix; aggregation=default_aggregation(), kws...)
    apply_metric(metric, predicted, classes; aggregation=default_aggregation() label_set=nothing, sort_labels=false, kws...)

Applies `metric` defined as a function of `TP`, `FN`, `FP`, `TN` with a given aggregation strategy.
It is assumed that the metric is defined for a single class, and `apply_metric` should be used for multiclass setting.
`kws` keywords can be used to pass additional parameters to the metric, e.g. β for the Fβ-score 

Note: all metrics defined with [`@metric`](@ref) macro are automatically extended, so they can be called in multiclass setting without calling this function explicitly.
"""
function apply_metric(
    metric, TP, FN, FP, TN; aggregation=default_aggregation(), kws...
)
    return aggregation(@fix(metric(_, _, _, _; kws...)), TP, FN, FP, TN)
end
function apply_metric(
    metric, pr::PredictionResults; aggregation=default_aggregation(), kws...
)
    return apply_metric(metric, pr.TP, pr.FN, pr.FP, pr.TN; aggregation=aggregation, kws...)
end
function apply_metric(
    metric,
    confusion_matrix::ConfusionMatrix;
    aggregation=default_aggregation(), 
    kws...
)
    return apply_metric(
        metric, prediction_results(confusion_matrix); aggregation=aggregation, kws...
    )
end
function apply_metric(
    metric,
    predicted,
    classes;
    aggregation=default_aggregation(),
    label_set=nothing,
    sort_labels=false, 
    kws...
)
    return apply_metric(
        metric,
        prediction_results(predicted, classes; label_set=label_set, sort_labels=sort_labels);
        aggregation=aggregation,
        kws...
    )
end

function define_metric_functions(func::Symbol; name=nothing)
        expr =  quote
                Base.@__doc__ function $(func)(
                    TP::T, FN::T, FP::T, TN::T; aggregation=ClassificationMetrics.default_aggregation(), kws...
                ) where {T<:AbstractArray}
                    return ClassificationMetrics.apply_metric(
                        $(func), TP, FN, FP, TN; aggregation=aggregation, kws...
                    )
                end
                function $(func)(
                    pr::ClassificationMetrics.PredictionResults; aggregation=ClassificationMetrics.default_aggregation(), kws...
                )
                    return ClassificationMetrics.apply_metric($(func), pr; aggregation=aggregation, kws...)
                end
                function $(func)(
                    cm::ClassificationMetrics.ConfusionMatrix; aggregation=ClassificationMetrics.default_aggregation(), kws...
                )
                    return ClassificationMetrics.apply_metric($(func), cm; aggregation=aggregation, kws...)
                end
                function $(func)(
                    predicted,
                    classes;
                    aggregation=ClassificationMetrics.default_aggregation(),
                    label_set=nothing,
                    sort_labels=false, 
                    kws...
                )
                    return ClassificationMetrics.apply_metric(
                        $(func),
                        predicted,
                        classes;
                        aggregation=aggregation,
                        label_set=label_set,
                        sort_labels=sort_labels,
                        kws...
                    )
                end
            end
        if !isnothing(name)
            expr = quote
                $expr
                ClassificationMetrics.get_print_name(::typeof($(func))) = $name
            end
        end
        return expr
end
function define_metric_functions(func::Expr; name=nothing)
    if Meta.isexpr(func, :(=)) && Meta.isexpr(func.args[1], :call) || Meta.isexpr(func, :function) && Meta.isexpr(func.args[1], :call)
        return Expr(:block, func, define_metric_functions(func.args[1].args[1]; name=name))
    end

end
function define_metric_functions((name, func)::Tuple{<:AbstractString, T}) where T
    return define_metric_functions(func; name=name)
end

foldnames(arr) = foldl(arr[2:end], init=Any[arr[1]]) do acc, x
    if acc[end] isa AbstractString
        acc[end] = (acc[end], x)
    else
        push!(acc, x)
    end
    return acc
end


"""
    @metric ["Metric print name"] metric_function(TP, FN, FP, TN) = ...
    @metric ["Metric print name"] function metric_function(TP, FN, FP, TN) 
        ... 
    end
    @metric ["Metric 1 print name"] metric1_function ["Metric 2 print name"] metric2_function ...

A macro to automatically define aggregation calls for a metric defined for a single class.
The metric should have signature `metric(TP, FN, FP, TN)` where `TP`, `FN`, `FP` and `TN` are all scalars. 

It is also possible to optionally define a print name for a metric to be used for printing classification report.

"""
macro metric(funcs...)
    exprs = (
        define_metric_functions(func) for func in foldnames(funcs)
    )
    return esc(Expr(:block, exprs...))
end

safe_div(a, b) = b == zero(b) ? zero(b) : a / b

"""
    binary_accuracy(TP, FN, FP, TN) = safe_div(TP + TN, TP + FP + TN + FN)
"""
binary_accuracy(TP, FN, FP, TN) = safe_div(TP + TN, TP + FP + TN + FN)
"""
    precision(TP, FN, FP, TN) = safe_div(TP, TP + FP)
"""
precision(TP, FN, FP, TN) = safe_div(TP, TP + FP)
"""
    recall(TP, FN, FP, TN) = safe_div(TP, TP + FN)
    sensitivity(TP, FN, FP, TN) = safe_div(TP, TP + FN)
    true_positive_rate(TP, FN, FP, TN) = safe_div(TP, TP + FN)
"""
recall(TP, FN, FP, TN) = safe_div(TP, TP + FN)
@doc (@doc recall)
const sensitivity = recall
@doc (@doc recall)
const true_positive_rate = recall

"""
    fall_out(TP, FN, FP, TN) = safe_div(FP, FP + TN)
    false_positive_rate(TP, FN, FP, TN) = safe_div(FP, FP + TN)
"""
fall_out(TP, FN, FP, TN) = safe_div(FP, FP + TN)
@doc (@doc fall_out)
const false_positive_rate = fall_out
"""
    miss_rate(TP, FN, FP, TN) = safe_div(FN, TP + FN)
    false_negative_rate(TP, FN, FP, TN) = safe_div(FN, TP + FN)
"""
miss_rate(TP, FN, FP, TN) = safe_div(FN, TP + FN)
@doc (@doc miss_rate)
const false_negative_rate = miss_rate
"""
    specificity(TP, FN, FP, TN) = safe_div(TN, FP + TN)
"""
specificity(TP, FN, FP, TN) = safe_div(TN, FP + TN)
"""
    jaccard(TP, FN, FP, TN) = safe_div(TP, TP + FN + FP)
    IoU(TP, FN, FP, TN) = safe_div(TP, TP + FN + FP)
"""
jaccard(TP, FN, FP, TN) = safe_div(TP, TP + FN + FP)
@doc (@doc jaccard)
const IoU = jaccard
"""
    support(TP, FN, FP, TN) = TP + FN
"""
support(TP, FN, FP, TN) = TP + FN
"""
    binary_accuracy(TP, FN, FP, TN) = safe_div(TP + TN, TP + FP + TN + FN)
"""
true_false_ratio(TP, FN, FP, TN) = safe_div(TP + FN, TP + FP + TN + FN)
"""
    Fβ_score(TP, FN, FP, TN; β=1) = safe_div((1 + β^2)TP, (1 + β^2)TP + β^2 * FN + FP)
"""
function Fβ_score(TP, FN, FP, TN; β=1)
    β2 = β^2
    safe_div((1 + β2)TP, (1 + β2)TP + β2 * FN + FP)
end
@generated Fβ_score(β::Real) = quote
    β = eval(β)
    rounded_β = isinteger(β) ? β : round(β; digits=2)
    name = Symbol(replace("F$(rounded_β)_score", "." => "_"))
    eval(:($name(args...; kwargs...) = Fβ_score(args...; kwargs..., β=$β)))
end
"""
    F1_score(TP, FN, FP, TN) = safe_div(2TP, 2TP + FN + FP)
"""
F1_score(args...; kwargs...) = Fβ_score(args...; kwargs..., β=1)

@metric binary_accuracy precision recall sensitivity fall_out miss_rate specificity "Jaccard index" jaccard support true_false_ratio Fβ_score

