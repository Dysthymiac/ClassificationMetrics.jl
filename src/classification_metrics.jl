
using Statistics, OneHotArrays, LinearAlgebra, PrettyTables, Printf

using DocStringExtensions
import OneHotArrays: onehotbatch, OneHotLike
import Base: show, getindex, vcat


"""
$(TYPEDEF)

Confusion matrix struct that holds the matrix and label names.

---

$(FIELDS)

"""
struct ConfusionMatrix{T1,T2}
    "Class labels"
    label_set::T1
    "Confusion matrix"
    matrix::T2
end

function create_confusion_matrix(predicted, actual, label_set)
    m = length(label_set)
    reverse_index = Dict(x => i for (i, x) in enumerate(label_set))
    cm = zeros(Int64, m, m)
    for (p, a) in zip(predicted, actual)
        cm[reverse_index[p], reverse_index[a]] += 1
    end
    return cm
end

"""

    confusion_matrix(predicted, actual[, label_set=nothing]; sort_labels=false)
    confusion_matrix(predicted::OneHotLike, actual::OneHotLike, label_set)

Compute confusion matrix. Predicted and actual can be provided as vectors of labels 
or in the one-hot encoded form. Optionally, label set can be provided explicitly.
"""
function confusion_matrix end

function confusion_matrix(predicted::OneHotLike, actual::OneHotLike, label_set)
    return ConfusionMatrix(label_set, predicted * transpose(actual))
end
function confusion_matrix(predicted, actual, ::Nothing=nothing; sort_labels=false)
    return confusion_matrix(
        predicted, actual, get_label_set(predicted, actual); sort_labels=sort_labels
    )
end
function confusion_matrix(predicted, actual, label_set; sort_labels=false)
    if sort_labels
        label_set = sort(label_set)
    end
    return ConfusionMatrix(label_set, create_confusion_matrix(predicted, actual, label_set))
end


"""
$(TYPEDEF)

Holds TP, FP, TN, and FN values for further metric calculation.

---

$(FIELDS)

"""
struct PredictionResults{T1,T2}
    "Class labels"
    label_set::T1
    "A ``4 \\times n`` matrix with rows corresponding to TP, FN, FP and TN."
    results::T2
end

rename_labels(pr::PredictionResults, new_labels) = PredictionResults(new_labels, pr.results)

function prediction_results(cm::ConfusionMatrix)
    return PredictionResults(cm.label_set, prediction_results(cm.matrix))
end
function prediction_results(predicted, actual; label_set=nothing, sort_labels=false)
    return prediction_results(
        confusion_matrix(predicted, actual, label_set; sort_labels=sort_labels)
    )
end
function show(io::IO, cm::PredictionResults)
    return pretty_table(
        io,
        cm.results;
        header=["TP", "FN", "FP", "TN"],
        row_labels=cm.label_set,
        alignment=:r,
        # row_label_column_title="Predictions ↓",
        hlines=0:(length(cm.label_set) + 1),
        vlines=0:5,
        crop=:none,
    )
end

function show(io::IO, cm::ConfusionMatrix)
    return pretty_table(
        io,
        cm.matrix;
        header=cm.label_set,
        row_labels=cm.label_set,
        alignment=:c,
        row_label_column_title="Predictions ↓",
        highlighters=(
            Highlighter((_, i, j) -> i == j; foreground=:green),
            Highlighter((_, i, j) -> i ≠ j; foreground=:red),
        ),
        hlines=0:(length(cm.label_set) + 1),
        vlines=0:(length(cm.label_set) + 1),
        crop=:none,
    )
end

get_label_set(x) = unique(x)
get_label_set(x...) = ∪(get_label_set.(x)...)

onehot_prepare(args...; label_set) = map(x -> onehotbatch(x, label_set), args)

function prediction_results(confusion_matrix)
    TP = diag(confusion_matrix)
    FN = vec(sum(confusion_matrix; dims=1)) .- TP
    FP = vec(sum(confusion_matrix; dims=2)) .- TP
    TN = sum(confusion_matrix) .- TP .- FN .- FP
    return hcat(TP, FN, FP, TN)
end

function Base.getindex(pr::PredictionResults, I)
    let res = pr.results[I, :]
        PredictionResults(pr.label_set[I], ndims(res) == 1 ? transpose(res) : res)
    end
end
function Base.vcat(pr1::PredictionResults, pr2::PredictionResults)
    return PredictionResults(
        vcat(pr1.label_set, pr2.label_set), vcat(pr1.results, pr2.results)
    )
end
Base.vcat(pr1::PredictionResults, prs::PredictionResults...) = reduce(vcat, prs; init=pr1)

get_TP(pr::PredictionResults) = @view pr.results[:, 1]
get_FN(pr::PredictionResults) = @view pr.results[:, 2]
get_FP(pr::PredictionResults) = @view pr.results[:, 3]
get_TN(pr::PredictionResults) = @view pr.results[:, 4]
get_support(pr::PredictionResults) = round.(Integer, sum(@view(pr.results[:, 1:2]); dims=2))

nonzero_mean(vals) = mean(vals[abs.(vals) .> eps()])

no_aggregation(func, vals...) = func.(vals...)
micro_aggregation(func, vals...) = nonzero_mean(func.(vals...))
macro_aggregation(func, vals...) = func(sum.(vals)...)
function weighted_aggregation(func, vals...; weights=nothing)
    let weights = @something weights vals[1] .+ vals[2]
        sum(weights .* func.(vals...) ./ sum(weights))
    end
end

default_aggregation = weighted_aggregation

function apply_metric(
    TP, FN, FP, TN; aggregate=default_aggregation, metric=accuracy, kws...
)
    return aggregate(@fix(metric(_...; kws...)), TP, FN, FP, TN)
end
function apply_metric(
    pr::PredictionResults; aggregate=default_aggregation, metric=accuracy, kws...
)
    return apply_metric(eachcol(pr.results)...; aggregate=aggregate, metric=metric, kws...)
end
function apply_metric(
    confusion_matrix::ConfusionMatrix;
    aggregate=default_aggregation,
    metric=accuracy,
    kws...,
)
    return apply_metric(
        prediction_results(confusion_matrix); aggregate=aggregate, metric=metric, kws...
    )
end
function apply_metric(
    predicted,
    classes;
    aggregate=default_aggregation,
    metric=accuracy,
    label_set=nothing,
    sort_labels=false,
    kws...,
)
    return apply_metric(
        confusion_matrix(predicted, classes, label_set; sort_labels=sort_labels);
        aggregate=aggregate,
        metric=metric,
        kws...,
    )
end

macro metric(funcs...)
    exprs = (
        esc(
            quote
                function $(func)(
                    TP::T, FN::T, FP::T, TN::T; aggregate=default_aggregation, kws...
                ) where {T<:AbstractArray}
                    return apply_metric(
                        TP, FN, FP, TN; aggregate=aggregate, metric=$(func), kws...
                    )
                end
                function $(func)(
                    pr::PredictionResults; aggregate=default_aggregation, kws...
                )
                    return apply_metric(pr; aggregate=aggregate, metric=$(func), kws...)
                end
                function $(func)(
                    cm::ConfusionMatrix; aggregate=default_aggregation, kws...
                )
                    return apply_metric(cm; aggregate=aggregate, metric=$(func), kws...)
                end
                function $(func)(
                    predicted,
                    classes;
                    aggregate=default_aggregation,
                    label_set=nothing,
                    sort_labels=false,
                    kws...,
                )
                    return apply_metric(
                        predicted,
                        classes;
                        aggregate=aggregate,
                        metric=$(func),
                        label_set=label_set,
                        sort_labels=sort_labels,
                        kws...,
                    )
                end
            end,
        ) for func in funcs
    )
    return Expr(:block, exprs...)
end

safe_div(a, b) = b == zero(b) ? zero(b) : a / b

binary_accuracy(TP, FN, FP, TN) = safe_div(TP + TN, TP + FP + TN + FN)
precision(TP, FN, FP, TN) = safe_div(TP, TP + FP)
recall(TP, FN, FP, TN) = safe_div(TP, TP + FN)
fall_out(TP, FN, FP, TN) = safe_div(FP, FP + TN)
miss_rate(TP, FN, FP, TN) = safe_div(FN, TP + FN)
specificity(TP, FN, FP, TN) = safe_div(TN, FP + TN)
jaccard(TP, FN, FP, TN) = safe_div(TP, TP + FN + FP)
IoU(args...; kwargs...) = jaccard(args...; kwargs...)
support(TP, FN, FP, TN) = TP + FN
true_false_ratio(TP, FN, FP, TN) = safe_div(TP + FN, TP + FP + TN + FN)
Fβ_score(TP, FN, FP, TN; β=1) =
    let β² = β^2
        safe_div((1 + β²)TP, (1 + β²)TP + β² * FN + FP)
    end
@generated Fβ_score(β::Real) = quote
    β = eval(β)
    rounded_β = isinteger(β) ? β : round(β; digits=2)
    name = Symbol(replace("F$(rounded_β)_score", "." => "_"))
    eval(:($name(args...; kwargs...) = Fβ_score(args...; kwargs..., β=$β)))
end
F1_score(args...; kwargs...) = Fβ_score(args...; kwargs..., β=1)

sensitivity(args...; kwargs...) = recall(args...; kwargs...)
true_positive_rate(args...; kwargs...) = recall(args...; kwargs...)
false_positive_rate(args...; kwargs...) = fall_out(args...; kwargs...)
false_negative_rate(args...; kwargs...) = miss_rate(args...; kwargs...)

@metric binary_accuracy precision recall fall_out specificity 
@metric Fβ_score miss_rate jaccard support true_false_ratio

accuracy(predicted, actual) = mean(predicted .== actual)

function all_aggregation()
    return [
        AggregationSet("Micro", micro_aggregation),
        AggregationSet("Macro", macro_aggregation),
        AggregationSet("Weighted", weighted_aggregation),
    ]
end

struct AggregationSet{T1,T2,T3}
    name::T1
    predicate::T2
    aggregation::T3
end

function AggregationSet(name, aggregation=default_aggregation; predicate=always(true))
    return AggregationSet(name, predicate, aggregation)
end

function classification_report(
    predicted, actual; label_set=nothing, sort_labels=true, kws...
)
    return classification_report(
        prediction_results(predicted, actual; label_set=label_set, sort_labels=sort_labels);
        kws...,
    )
end

function classification_report(
    prediction_results::PredictionResults;
    metrics=[precision, recall, F₁_score],
    show_per_class=true,
    aggregation_sets=all_aggregation(),
    io=stdout,
    include_support=true,
    backend=Val(:text),
)
    function pretty_name(m)
        return uppercasefirst(replace(string(m), r"(\d+)_(\d+)" => s"\1.\2", "_" => " "))
    end
    names = pretty_name.(metrics)
    if include_support
        names = push!(names, "Support")
    end

    full_labels = [ag.name for ag in aggregation_sets]

    support = get_support(prediction_results)

    all_inds = [
        findall(ag.predicate.(prediction_results.label_set)) for ag in aggregation_sets
    ]

    support_col = [sum(support[inds]) for inds in all_inds]

    agg_types = [ag.aggregation for ag in aggregation_sets]

    full_results = [
        map(
            ((inds, agg),) -> m(prediction_results[inds]; aggregate=agg),
            zip(all_inds, agg_types),
        ) for m in metrics
    ]

    if show_per_class
        full_labels = vcat(prediction_results.label_set, full_labels)
        support_col = vcat(support, support_col)
        full_results =
            vcat.(
                map(m -> m(prediction_results; aggregate=no_aggregation), metrics),
                full_results,
            )
    end
    table = reduce(hcat, full_results)
    if include_support
        table = hcat(table, support_col)
    end
    optional_kws = backend == Val(:latex) ? Dict() : Dict(:crop => :none)
    pretty = pretty_table(
        io,
        table;
        header=names,
        row_labels=full_labels,
        hlines=[0, 1, size(table, 1) + 1 - length(aggregation_sets), size(table, 1) + 1],
        formatters=(v, i, j) -> if (j == size(table, 2) && include_support)
            round(Integer, v)
        else
            @sprintf("%.4f", v)
        end,
        backend=backend,
        optional_kws...,
    )
    return pretty, table
end
