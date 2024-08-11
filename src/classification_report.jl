
"""
$(TYPEDEF)

Aggregation subset to be used in [`classification_report`](@ref).

---

$(FIELDS)

"""
struct AggregationSubset{T1, T2, T3}
    "Aggregation function"
    aggregation::T1
    "Predicate that defines which subset to aggregate"
    predicate::T2
    "Name to be displayed in the classification report"
    name::T3
end

"""
    aggregate_subset(aggregation_function; 
        predicate=const_func(true), 
        name=get_print_name(aggregation_function))

Create [`AggregationSubset`](@ref) to be used in [`classification_report`](@ref). 
"""
aggregate_subset(aggregation_function; 
    predicate=const_func(true), 
    name=get_print_name(aggregation_function)) = AggregationSubset(aggregation_function, predicate, name)

"""
    classification_report(predicted, actual; label_set=nothing, sort_labels=true, kws...)
    classification_report(cf::ConfusionMatrix; kws...)
    classification_report(prediction_results::PredictionResults; kws...)

Print classification report. 

# Keywords
- `metrics=[precision, recall, F1_score]`: metrics to compute
- `show_per_class=true`: show results per each class or only the aggregated results
- `aggregations=[micro_aggregation, macro_aggregation, weighted_aggregation]`: aggregations 
to be used. If the aggregation function is passed, it will be applied to all classes. 
Alternatively, it is possible to aggregate only a subset of classes by passing [`AggregationSubset`](@ref) created with [`aggregate_subset`](@ref).
- `io::IO | String | HTML = stdout`: io to print out. Refer to `PrettyTables` for more information.
- `include_support=true`: print support column or not
- `default_format=val->@sprintf("%.4f", val)`: string format for the values
- `backend=Val(:text)`: the backend used to generate table. 
Can be Val(:text), Val(:html), Val(:latex), Val(:markdown). Refer to `PrettyTables` for more information.
- `optional_kws = DEFAULT_PARAMETERS[backend]: optional keywords to pass to `pretty_table`
"""
function classification_report(
    predicted, actual; label_set=nothing, sort_labels=true, kws...
)
    return classification_report(
        prediction_results(predicted, actual; label_set=label_set, sort_labels=sort_labels);
        kws...,
    )
end

function classification_report(cf::ConfusionMatrix; kws...)
    return classification_report(prediction_results(cf); kws...)
end

DEFAULT_PARAMETERS = Dict(
    Val(:text) => Dict(:crop => :none),
    Val(:latex) => Dict(),
    Val(:markdown) => Dict(),
    Val(:html) => Dict())

function classification_report(
    prediction_results::PredictionResults;
    metrics=[precision, recall, F1_score],
    show_per_class=true,
    aggregations=[micro_aggregation, macro_aggregation, weighted_aggregation],
    io=stdout,
    include_support=true,
    default_format=val -> @sprintf("%.4f", val),
    backend=Val(:text),
    optional_kws=DEFAULT_PARAMETERS[backend],
)
    names = get_print_name.(metrics)
    if include_support
        names = push!(names, "Support")
    end

    get_aggregation_subset(x::AggregationSubset) = x
    get_aggregation_subset(x) = aggregate_subset(x)
    aggregations = get_aggregation_subset.(aggregations)
    aggregation_funcs = getfield.(aggregations, :aggregation)
    full_labels = getfield.(aggregations, :name)
    predicates = getfield.(aggregations, :predicate)

    support = get_support(prediction_results)

    get_predicate(x::Tuple) = last(x)
    get_predicate(_) = const_func(true)

    all_inds = [p.(prediction_results.label_set) for p in predicates]

    support_col = [sum(support[inds]) for inds in all_inds]

    full_results = [
        map(
            (inds, agg) -> metric(prediction_results[inds]; aggregation=agg),
            all_inds,
            aggregation_funcs,
        ) for metric in metrics
    ]

    if show_per_class
        full_labels = vcat(prediction_results.label_set, full_labels)
        support_col = vcat(support, support_col)
        full_results =
            vcat.(
                map(m -> m(prediction_results; aggregation=no_aggregation), metrics),
                full_results,
            )
    end
    table = reduce(hcat, full_results)
    if include_support
        table = hcat(table, support_col)
    end
    if haskey(optional_kws, :hlines) && backend ≠ Val(:markdown)
        optional_kws[:hlines] = [0, 1, size(table, 1) + 1 - length(aggregations), size(table, 1) + 1]
    end
    pretty = pretty_table(
        io,
        table;
        header=names,
        row_labels=full_labels,
        formatters=(v, i, j) -> if (j == size(table, 2) && include_support)
            round(Integer, v)
        else
            default_format(v)
        end,
        backend=backend,
        optional_kws...,
    )
    return pretty, table
end
