
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


"""
    unlabeled_confusion_matrix(predicted, actual, label_set)

Returns a `n × n` confusion matrix, where `n` is the length of the `label_set`. 
Function [`confusion_matrix`](@ref) creates a [`ConfusionMatrix`](@ref) object that holds both the matrix and the label set.
"""
function unlabeled_confusion_matrix(predicted, actual, label_set)
    m = length(label_set)
    reverse_index = Dict(x => i for (i, x) in enumerate(label_set))
    cm = zeros(Int64, m, m)
    for (p, a) in zip(predicted, actual)
        cm[reverse_index[a], reverse_index[p]] += 1
    end
    return cm
end

"""

    confusion_matrix(predicted, actual[, label_set]; sort_labels=false)
    confusion_matrix(predicted::OneHotLike, actual::OneHotLike, label_set)

Returns a [`ConfusionMatrix`](@ref) object that holds both the matrix and ladel set. `predicted` and `actual` can be provided as vectors of labels 
or in the one-hot encoded form. Optionally, `label_set` can be provided explicitly.
"""
function confusion_matrix end

function confusion_matrix(predicted::OneHotLike, actual::OneHotLike, label_set)
    return ConfusionMatrix(label_set, predicted * transpose(actual))
end
function confusion_matrix(predicted, actual; sort_labels=false)
    return confusion_matrix(
        predicted, actual, get_label_set(predicted, actual); sort_labels=sort_labels
    )
end
function confusion_matrix(predicted, actual, label_set; sort_labels=false)
    if sort_labels
        label_set = sort(label_set)
    end
    return ConfusionMatrix(label_set, unlabeled_confusion_matrix(predicted, actual, label_set))
end

function show(io::IO, cm::ConfusionMatrix)
    return pretty_table(
        io,
        cm.matrix;
        header=cm.label_set,
        row_labels=cm.label_set,
        alignment=:c,
        row_label_column_title="Actual ↓",
        highlighters=(
            Highlighter((_, i, j) -> i == j; foreground=:green),
            Highlighter((_, i, j) -> i ≠ j; foreground=:red),
        ),
        hlines=0:(length(cm.label_set) + 1),
        vlines=0:(length(cm.label_set) + 1),
        crop=:none,
    )
end
