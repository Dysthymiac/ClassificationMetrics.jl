
"""
$(TYPEDEF)

Holds TP, FP, TN, and FN values for further metric calculation. Use [`prediction_results`](@ref) to create.

---

$(FIELDS)

"""
struct PredictionResults{T1,T2}
    "Class labels"
    label_set::T1
    "True positives"
    TP::T2
    "False negatives"
    FN::T2
    "False positives"
    FP::T2
    "True negatives"
    TN::T2
end

"""
    prediction_results(predicted, actual; label_set=nothing, sort_labels=false)
    prediction_results(cm::ConfusionMatrix)

Calculate `TP`, `FN`, `FN` and `TN` and return a [`PredictionResults`](@ref) object. 
Supports indexing and `vcat`.

"""
function prediction_results(cm::ConfusionMatrix)
    return PredictionResults(cm.label_set, unlabeled_prediction_results(cm.matrix)...)
end
function prediction_results(predicted, actual; label_set=nothing, sort_labels=false)
    return prediction_results(
        confusion_matrix(
            predicted,
            actual,
            @something(label_set, get_label_set(predicted, actual));
            sort_labels=sort_labels,
        ),
    )
end

"""
    unlabeled_prediction_results(confusion_matrix)

Calculate and return `TP`, `FN`, `FN` and `TN`.
"""
function unlabeled_prediction_results(confusion_matrix)
    TP = diag(confusion_matrix)
    FN = vec(sum(confusion_matrix; dims=2)) .- TP
    FP = vec(sum(confusion_matrix; dims=1)) .- TP
    TN = sum(confusion_matrix) .- TP .- FN .- FP
    return TP, FN, FP, TN
end

"""
    get_support(pr::PredictionResults)

Calculate support for each class.
"""
get_support(pr::PredictionResults) = round.(Integer, pr.TP .+ pr.FN)

function Base.getindex(pr::PredictionResults, I)
    return PredictionResults(pr.label_set[I], pr.TP[I], pr.FN[I], pr.FP[I], pr.TN[I])
end
function Base.vcat(pr1::PredictionResults, pr2::PredictionResults)
    return PredictionResults(
        vcat(pr1.label_set, pr2.label_set),
        vcat(pr1.TP, pr2.TP),
        vcat(pr1.FN, pr2.FN),
        vcat(pr1.FP, pr2.FP),
        vcat(pr1.TN, pr2.TN),
    )
end
Base.vcat(pr1::PredictionResults, prs::PredictionResults...) = reduce(vcat, prs; init=pr1)
Base.length(pr::PredictionResults) = length(pr.label_set)

function show(io::IO, pr::PredictionResults)
    return pretty_table(
        io,
        hcat(pr.TP, pr.FN, pr.FP, pr.TN);
        header=["TP", "FN", "FP", "TN"],
        row_labels=pr.label_set,
        alignment=:r,
        hlines=0:(length(pr.label_set) + 1),
        vlines=0:5,
        crop=:none,
    )
end

"""
    rename_labels(pr::PredictionResults, new_labels)
    rename_labels(pr::ConfusionMatrix, new_labels)

A convenience function to batch rename class labels.
"""
rename_labels(pr::PredictionResults, new_labels) = PredictionResults(new_labels, pr.results)
rename_labels(cm::ConfusionMatrix, new_labels) = ConfusionMatrix(new_labels, cm.matrix)
