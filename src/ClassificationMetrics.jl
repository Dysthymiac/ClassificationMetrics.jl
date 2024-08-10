module ClassificationMetrics

export get_label_set, confusion_matrix, prediction_results, rename_labels
export IoU,
    support,
    true_false_ratio,
    precision,
    recall,
    Fβ_score,
    F1_score,
    fall_out,
    specificity,
    sensitivity,
    true_positive_rate,
    false_positive_rate,
    false_negative_rate,
    miss_rate,
    jaccard
export classification_report, all_aggregation
export AggregationSet
export macro_aggregation, micro_aggregation, weighted_aggregation, no_aggregation


using Statistics, OneHotArrays, LinearAlgebra, PrettyTables, Printf

using DocStringExtensions
import OneHotArrays: onehotbatch, OneHotLike
import Base: show, getindex, vcat

include("common_utils.jl")
include("confusion_matrix.jl")
include("prediction_results.jl")
include("metrics.jl")
include("classification_report.jl")

end