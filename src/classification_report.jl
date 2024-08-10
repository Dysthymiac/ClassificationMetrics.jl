
function classification_report(
    predicted, actual; label_set=nothing, sort_labels=true, kws...
)
    return classification_report(
        prediction_results(predicted, actual; label_set=label_set, sort_labels=sort_labels);
        kws...,
    )
end

function classification_report(
    cf::ConfusionMatrix; kws...
)
    return classification_report(
        prediction_results(cf);
        kws...,
    )
end



function classification_report(
    prediction_results::PredictionResults;
    metrics=[precision, recall, F1_score],
    show_per_class=true,
    aggregations=[micro_aggregation, macro_aggregation, weighted_aggregation],
    io=stdout,
    include_support=true,
    default_format=val->@sprintf("%.4f", v),
    backend=Val(:text),
    optional_kws = backend == Val(:latex) ? Dict() : Dict(:crop => :none)
)
    
    names = pretty_name.(metrics)
    if include_support
        names = push!(names, "Support")
    end

    get_aggregation(x::Tuple) = first(x)
    get_aggregation(x) = x
    aggregation_funcs = get_aggregation.(aggregations)
    full_labels = get_print_name.(aggregation_funcs)

    support = get_support(prediction_results)

    get_predicate(x::Tuple) = last(x)
    get_predicate(_) = const_func(true)
    
    all_inds = [
        get_predicate(ag).(prediction_results.label_set) for ag in aggregations
    ]

    support_col = [sum(support[inds]) for inds in all_inds]

    full_results = [
        map(
            (inds, agg) -> metric(prediction_results[inds]; aggregate=agg),
            all_inds, aggregation_funcs
        ) for metric in metrics
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
    
    pretty = pretty_table(
        io,
        table;
        header=names,
        row_labels=full_labels,
        hlines=[0, 1, size(table, 1) + 1 - length(aggregations), size(table, 1) + 1],
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
