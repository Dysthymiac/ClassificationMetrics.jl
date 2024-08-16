var documenterSearchIndex = {"docs":
[{"location":"metrics/","page":"Metrics","title":"Metrics","text":"CurrentModule = ClassificationMetrics\nDocTestSetup = quote\n    using ClassificationMetrics\nend","category":"page"},{"location":"metrics/#Metrics","page":"Metrics","title":"Metrics","text":"","category":"section"},{"location":"metrics/#Built-in-metrics","page":"Metrics","title":"Built-in metrics","text":"","category":"section"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"A large number of classic classification metrics is defined in the package:","category":"page"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"binary_accuracy\nprecision\nrecall\nsensitivity\nfall_out\nmiss_rate\nspecificity\njaccard\nsupport\ntrue_false_ratio\nFβ_score","category":"page"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"All metrics can be applied to four scalars TP, FN, FP and TN. ","category":"page"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"using ClassificationMetrics\n\nrecall(25, 0, 1, 1)","category":"page"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"If those arguments are not scalars but vectors, or ConfusionMatrix, PredictionResults, or predicted and actual labels, then the aggregation strategy will be used. ","category":"page"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"\nactual    = [0, 0, 0, 1, 1, 1, 2, 2, 2]\npredicted = [1, 0, 0, 0, 0, 1, 0, 2, 0]\n\nrecall(predicted, actual; aggregation=macro_aggregation)","category":"page"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"It is also possible to specify no_aggregation as the aggregation strategy to return values for each class. By default, it uses aggregation created by the default_aggregation function. The default can be changed by calling set_default_aggregation!:","category":"page"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"\nClassificationMetrics.set_default_aggregation!(no_aggregation)\n\nrecall(predicted, actual, sort_labels=true)","category":"page"},{"location":"metrics/#Aggregation","page":"Metrics","title":"Aggregation","text":"","category":"section"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"There are 4 standard aggregation strategies available:","category":"page"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"no_aggregation\nmicro_aggregation\nmacro_aggregation\nweighted_aggregation","category":"page"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"By default, weighted_aggregation uses class supports to calculate weights, but it is possible to pass custom class weights as an optional keyword argument. For convenience of passing the function as the argument, it is possible to call weighted_aggregation with 1 argument to create a function with custom weights:","category":"page"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"\n\nrecall(predicted, actual, sort_labels=true, aggregation=weighted_aggregation([2, 1, 1]))","category":"page"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"Custom aggregation can be used by defining your own function:","category":"page"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"using Statistics\n\nmicro_median_aggregation(func, TP, FN, FP, TN) = median(func.(TP, FN, FP, TN))\n\nrecall(predicted, actual, sort_labels=true, aggregation=micro_median_aggregation)","category":"page"},{"location":"metrics/#Custom-metrics","page":"Metrics","title":"Custom metrics","text":"","category":"section"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"Defining a custom metric is also made easy thanks to the @metric macro. In order to define a metric, one needs only to define a function that calculates it for scalar TP, FN, FP and TN, and the @metric macro will automatically define all other functions, allowing the metric to be called for ConfusionMatrix, PredictionResults, and predicted/actual labels. It also allows to optionally define a display name for a metric that will be used in the classification_report:","category":"page"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"\nusing ClassificationMetrics: safe_div\n\n# Option 1: define a function and then extend it in a separate macro call\n\ntrue_negative_rate(TP, FN, FP, TN) = 1 − false_positive_rate(TP, FN, FP, TN)\n\n@metric true_negative_rate\n\n# Option 2: use macro on the function definition\n\n@metric \"Bookmaker informedness\" informedness(TP, FN, FP, TN) = true_positive_rate(TP, FN, FP, TN) + true_negative_rate(TP, FN, FP, TN) − 1\n\nclassification_report(predicted, actual, sort_labels=true, metrics=[true_negative_rate, informedness])\nnothing # hide","category":"page"},{"location":"metrics/","page":"Metrics","title":"Metrics","text":"Note that a custom name can be assigned to the metric by passing a string before the function name. That name will be used in the classification_report.","category":"page"},{"location":"api/#Api-Reference","page":"API reference","title":"Api Reference","text":"","category":"section"},{"location":"api/","page":"API reference","title":"API reference","text":"Documentation for ClassificationMetrics.","category":"page"},{"location":"api/","page":"API reference","title":"API reference","text":"Modules = [ClassificationMetrics]","category":"page"},{"location":"api/#ClassificationMetrics.AggregationSubset","page":"API reference","title":"ClassificationMetrics.AggregationSubset","text":"struct AggregationSubset{T1, T2, T3}\n\nAggregation subset to be used in classification_report.\n\n\n\naggregation: Aggregation function\npredicate: Predicate that defines which subset to aggregate\nname: Name to be displayed in the classification report\n\n\n\n\n\n","category":"type"},{"location":"api/#ClassificationMetrics.ConfusionMatrix","page":"API reference","title":"ClassificationMetrics.ConfusionMatrix","text":"struct ConfusionMatrix{T1, T2}\n\nConfusion matrix struct that holds the matrix and label names.\n\n\n\nlabel_set: Class labels\nmatrix: Confusion matrix\n\n\n\n\n\n","category":"type"},{"location":"api/#ClassificationMetrics.PredictionResults","page":"API reference","title":"ClassificationMetrics.PredictionResults","text":"struct PredictionResults{T1, T2}\n\nHolds TP, FP, TN, and FN values for further metric calculation. Use prediction_results to create.\n\n\n\nlabel_set: Class labels\nTP: True positives\nFN: False negatives\nFP: False positives\nTN: True negatives\n\n\n\n\n\n","category":"type"},{"location":"api/#ClassificationMetrics.F1_score-Tuple","page":"API reference","title":"ClassificationMetrics.F1_score","text":"F1_score(TP, FN, FP, TN) = safe_div(2TP, 2TP + FN + FP)\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.Fβ_score-NTuple{4, Any}","page":"API reference","title":"ClassificationMetrics.Fβ_score","text":"Fβ_score(TP, FN, FP, TN; β=1) = safe_div((1 + β^2)TP, (1 + β^2)TP + β^2 * FN + FP)\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.IoU","page":"API reference","title":"ClassificationMetrics.IoU","text":"jaccard(TP, FN, FP, TN) = safe_div(TP, TP + FN + FP)\nIoU(TP, FN, FP, TN) = safe_div(TP, TP + FN + FP)\n\n\n\n\n\n","category":"function"},{"location":"api/#ClassificationMetrics.aggregate_subset-Tuple{Any}","page":"API reference","title":"ClassificationMetrics.aggregate_subset","text":"aggregate_subset(aggregation_function; \n    predicate=const_func(true), \n    name=get_print_name(aggregation_function))\n\nCreate AggregationSubset to be used in classification_report. \n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.apply_metric-NTuple{5, Any}","page":"API reference","title":"ClassificationMetrics.apply_metric","text":"apply_metric(metric, TP, FN, FP, TN; aggregation=default_aggregation(), kws...)\napply_metric(metric, pr::PredictionResults; aggregation=default_aggregation(), kws...)\napply_metric(metric, confusion_matrix::ConfusionMatrix; aggregation=default_aggregation(), kws...)\napply_metric(metric, predicted, classes; aggregation=default_aggregation() label_set=nothing, sort_labels=false, kws...)\n\nApplies metric defined as a function of TP, FN, FP, TN with a given aggregation strategy. It is assumed that the metric is defined for a single class, and apply_metric should be used for multiclass setting. kws keywords can be used to pass additional parameters to the metric, e.g. β for the Fβ-score \n\nNote: all metrics defined with @metric macro are automatically extended, so they can be called in multiclass setting without calling this function explicitly.\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.binary_accuracy-NTuple{4, Any}","page":"API reference","title":"ClassificationMetrics.binary_accuracy","text":"binary_accuracy(TP, FN, FP, TN) = safe_div(TP + TN, TP + FP + TN + FN)\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.classification_report-Tuple{Any, Any}","page":"API reference","title":"ClassificationMetrics.classification_report","text":"classification_report(predicted, actual; label_set=nothing, sort_labels=true, kws...)\nclassification_report(cf::ConfusionMatrix; kws...)\nclassification_report(prediction_results::PredictionResults; kws...)\n\nPrint classification report. \n\nKeywords\n\nmetrics=[precision, recall, F1_score]: metrics to compute\nshow_per_class=true: show results per each class or only the aggregated results\naggregations=[micro_aggregation, macro_aggregation, weighted_aggregation]: aggregations \n\nto be used. If the aggregation function is passed, it will be applied to all classes.  Alternatively, it is possible to aggregate only a subset of classes by passing AggregationSubset created with aggregate_subset.\n\nio::IO | String | HTML = stdout: io to print out. Refer to PrettyTables for more information.\ninclude_support=true: print support column or not\ndefault_format=val->@sprintf(\"%.4f\", val): string format for the values\nbackend=Val(:text): the backend used to generate table. \n\nCan be Val(:text), Val(:html), Val(:latex), Val(:markdown). Refer to PrettyTables for more information.\n\noptional_kws = DEFAULT_PARAMETERS[backend]: optional keywords to pass topretty_table`\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.confusion_matrix","page":"API reference","title":"ClassificationMetrics.confusion_matrix","text":"confusion_matrix(predicted, actual[, label_set]; sort_labels=false)\nconfusion_matrix(predicted::OneHotLike, actual::OneHotLike, label_set)\n\nReturns a ConfusionMatrix object that holds both the matrix and ladel set. predicted and actual can be provided as vectors of labels  or in the one-hot encoded form. Optionally, label_set can be provided explicitly.\n\n\n\n\n\n","category":"function"},{"location":"api/#ClassificationMetrics.default_aggregation-Tuple{}","page":"API reference","title":"ClassificationMetrics.default_aggregation","text":"default_aggregation()\n\nReturns aggregation used by default by all metrics. The default is weighted_aggregation. Can be changed with set_default_aggregation!.\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.fall_out-NTuple{4, Any}","page":"API reference","title":"ClassificationMetrics.fall_out","text":"fall_out(TP, FN, FP, TN) = safe_div(FP, FP + TN)\nfalse_positive_rate(TP, FN, FP, TN) = safe_div(FP, FP + TN)\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.false_negative_rate","page":"API reference","title":"ClassificationMetrics.false_negative_rate","text":"miss_rate(TP, FN, FP, TN) = safe_div(FN, TP + FN)\nfalse_negative_rate(TP, FN, FP, TN) = safe_div(FN, TP + FN)\n\n\n\n\n\n","category":"function"},{"location":"api/#ClassificationMetrics.false_positive_rate","page":"API reference","title":"ClassificationMetrics.false_positive_rate","text":"fall_out(TP, FN, FP, TN) = safe_div(FP, FP + TN)\nfalse_positive_rate(TP, FN, FP, TN) = safe_div(FP, FP + TN)\n\n\n\n\n\n","category":"function"},{"location":"api/#ClassificationMetrics.get_label_set-Tuple","page":"API reference","title":"ClassificationMetrics.get_label_set","text":"get_label_set(xs...)\n\nReturn all unique labels from one or several containers with labels.\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.get_print_name-Tuple{typeof(no_aggregation)}","page":"API reference","title":"ClassificationMetrics.get_print_name","text":"get_print_name(x)\n\nReturns a \"pretty\" name to be used in the classification report table. \n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.get_support-Tuple{ClassificationMetrics.PredictionResults}","page":"API reference","title":"ClassificationMetrics.get_support","text":"get_support(pr::PredictionResults)\n\nCalculate support for each class.\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.jaccard-NTuple{4, Any}","page":"API reference","title":"ClassificationMetrics.jaccard","text":"jaccard(TP, FN, FP, TN) = safe_div(TP, TP + FN + FP)\nIoU(TP, FN, FP, TN) = safe_div(TP, TP + FN + FP)\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.macro_aggregation-NTuple{5, Any}","page":"API reference","title":"ClassificationMetrics.macro_aggregation","text":"macro_aggregation(func, TP, FN, FP, TN)\n\nOne of possible aggregation options. Performs macro aggregation, i.e. sums values of all classes and applies the metric.\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.micro_aggregation-NTuple{5, Any}","page":"API reference","title":"ClassificationMetrics.micro_aggregation","text":"micro_aggregation(func, TP, FN, FP, TN)\n\nOne of possible aggregation options. Performs micro aggregation, i.e. applies metric to each class and reports the mean.\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.miss_rate-NTuple{4, Any}","page":"API reference","title":"ClassificationMetrics.miss_rate","text":"miss_rate(TP, FN, FP, TN) = safe_div(FN, TP + FN)\nfalse_negative_rate(TP, FN, FP, TN) = safe_div(FN, TP + FN)\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.no_aggregation-NTuple{5, Any}","page":"API reference","title":"ClassificationMetrics.no_aggregation","text":"no_aggregation(func, TP, FN, FP, TN)\n\nOne of possible aggregation options. Does not perform aggregation and instead returns metrics for each class.\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.precision-NTuple{4, Any}","page":"API reference","title":"ClassificationMetrics.precision","text":"precision(TP, FN, FP, TN) = safe_div(TP, TP + FP)\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.prediction_results-Tuple{ClassificationMetrics.ConfusionMatrix}","page":"API reference","title":"ClassificationMetrics.prediction_results","text":"prediction_results(predicted, actual; label_set=nothing, sort_labels=false)\nprediction_results(cm::ConfusionMatrix)\n\nCalculate TP, FN, FN and TN and return a PredictionResults object.  Supports indexing and vcat.\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.recall-NTuple{4, Any}","page":"API reference","title":"ClassificationMetrics.recall","text":"recall(TP, FN, FP, TN) = safe_div(TP, TP + FN)\nsensitivity(TP, FN, FP, TN) = safe_div(TP, TP + FN)\ntrue_positive_rate(TP, FN, FP, TN) = safe_div(TP, TP + FN)\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.rename_labels-Tuple{ClassificationMetrics.PredictionResults, Any}","page":"API reference","title":"ClassificationMetrics.rename_labels","text":"rename_labels(pr::PredictionResults, new_labels)\nrename_labels(pr::ConfusionMatrix, new_labels)\n\nA convenience function to batch rename class labels.\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.sensitivity","page":"API reference","title":"ClassificationMetrics.sensitivity","text":"recall(TP, FN, FP, TN) = safe_div(TP, TP + FN)\nsensitivity(TP, FN, FP, TN) = safe_div(TP, TP + FN)\ntrue_positive_rate(TP, FN, FP, TN) = safe_div(TP, TP + FN)\n\n\n\n\n\n","category":"function"},{"location":"api/#ClassificationMetrics.set_default_aggregation!-Tuple{Any}","page":"API reference","title":"ClassificationMetrics.set_default_aggregation!","text":"set_default_aggregation!(aggregation)\n\nChanges aggregation used by default by all metrics.\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.specificity-NTuple{4, Any}","page":"API reference","title":"ClassificationMetrics.specificity","text":"specificity(TP, FN, FP, TN) = safe_div(TN, FP + TN)\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.support-NTuple{4, Any}","page":"API reference","title":"ClassificationMetrics.support","text":"support(TP, FN, FP, TN) = TP + FN\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.true_false_ratio-NTuple{4, Any}","page":"API reference","title":"ClassificationMetrics.true_false_ratio","text":"binary_accuracy(TP, FN, FP, TN) = safe_div(TP + TN, TP + FP + TN + FN)\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.true_positive_rate","page":"API reference","title":"ClassificationMetrics.true_positive_rate","text":"recall(TP, FN, FP, TN) = safe_div(TP, TP + FN)\nsensitivity(TP, FN, FP, TN) = safe_div(TP, TP + FN)\ntrue_positive_rate(TP, FN, FP, TN) = safe_div(TP, TP + FN)\n\n\n\n\n\n","category":"function"},{"location":"api/#ClassificationMetrics.unlabeled_confusion_matrix-Tuple{Any, Any, Any}","page":"API reference","title":"ClassificationMetrics.unlabeled_confusion_matrix","text":"unlabeled_confusion_matrix(predicted, actual, label_set)\n\nReturns a n × n confusion matrix, where n is the length of the label_set.  Function confusion_matrix creates a ConfusionMatrix object that holds both the matrix and the label set.\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.unlabeled_prediction_results-Tuple{Any}","page":"API reference","title":"ClassificationMetrics.unlabeled_prediction_results","text":"unlabeled_prediction_results(confusion_matrix)\n\nCalculate and return TP, FN, FN and TN.\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.weighted_aggregation-NTuple{5, Any}","page":"API reference","title":"ClassificationMetrics.weighted_aggregation","text":"weighted_aggregation(func, TP, FN, FP, TN; weights=TP .+ FN)\nweighted_aggregation(weights; name=\"Weighted (Custom)\")\n\nOne of possible aggregation options. Performs weighted aggregation, i.e. applies metric to each class and reports the weighted mean. By default, uses support of each class as the weight, but allows passing custom weights. weighted_aggregation(weights; name=\"Weighted (Custom)\") returns an aggregation function with fixed weights, useful for passing to classification_report.\n\n\n\n\n\n","category":"method"},{"location":"api/#ClassificationMetrics.@metric-Tuple","page":"API reference","title":"ClassificationMetrics.@metric","text":"@metric [\"Metric print name\"] metric_function(TP, FN, FP, TN) = ...\n@metric [\"Metric print name\"] function metric_function(TP, FN, FP, TN) \n    ... \nend\n@metric [\"Metric 1 print name\"] metric1_function [\"Metric 2 print name\"] metric2_function ...\n\nA macro to automatically define aggregation calls for a metric defined for a single class. The metric should have signature metric(TP, FN, FP, TN) where TP, FN, FP and TN are all scalars. \n\nIt is also possible to optionally define a print name for a metric to be used for printing classification report.\n\n\n\n\n\n","category":"macro"},{"location":"confusion_matrix/","page":"Confusion matrix","title":"Confusion matrix","text":"CurrentModule = ClassificationMetrics\nDocTestSetup = quote\n    using ClassificationMetrics\nend","category":"page"},{"location":"confusion_matrix/#Confusion-matrix","page":"Confusion matrix","title":"Confusion matrix","text":"","category":"section"},{"location":"confusion_matrix/","page":"Confusion matrix","title":"Confusion matrix","text":"Confusion matrix can be created from predicted and actual labels using confusion_matrix:","category":"page"},{"location":"confusion_matrix/","page":"Confusion matrix","title":"Confusion matrix","text":"using ClassificationMetrics\n\nactual    = [0, 0, 0, 1, 1, 1, 2, 2, 2]\npredicted = [1, 2, 0, 0, 0, 1, 0, 2, 0]\n\nconfusion_matrix(predicted, actual, sort_labels=true)","category":"page"},{"location":"confusion_matrix/","page":"Confusion matrix","title":"Confusion matrix","text":"It is possible to provide full label set in case not all classes are present in the data. Optional argument sort_labels specifies whether the labels should be sorted or not.  The confusion matrix is stored in a convenience struct ConfusionMatrix that holds the matrix itself and the labels. It can be passed to prediction_results and classification_report to get further results or \"pretty printed\" in the terminal. ","category":"page"},{"location":"classification_report/","page":"Classification report","title":"Classification report","text":"CurrentModule = ClassificationMetrics\nDocTestSetup = quote\n    using ClassificationMetrics\nend","category":"page"},{"location":"classification_report/#Classification-report","page":"Classification report","title":"Classification report","text":"","category":"section"},{"location":"classification_report/","page":"Classification report","title":"Classification report","text":"Aggregate statistics for the multiclass classification can be conveniently calculated and summarized using the classification_report function. ","category":"page"},{"location":"classification_report/","page":"Classification report","title":"Classification report","text":"using Random\nusing ClassificationMetrics\nRandom.seed!(1)\n","category":"page"},{"location":"classification_report/","page":"Classification report","title":"Classification report","text":"classes = [:Class1, :Class2, :Class3]\n\npredicted = rand(classes, 100)\nactual = rand(classes, 100)\n\nclassification_report(predicted, actual, label_set=classes)\nnothing # hide","category":"page"},{"location":"classification_report/","page":"Classification report","title":"Classification report","text":"It is possible to specify custom metrics and custom aggregation subsets. If it is necessary, for example, to only aggregate specific classes, it can be accomplished with the aggregate_subset that can be passed along other aggregations:","category":"page"},{"location":"classification_report/","page":"Classification report","title":"Classification report","text":"using ClassificationMetrics:precision\n\nclassification_report(predicted, \n                        actual, \n                        label_set=classes,\n                        metrics=[precision, recall, F1_score, Fβ_score(2)],\n                        aggregations=[\n                            aggregate_subset(\n                                macro_aggregation, \n                                name=\"Classes 1 and 2\", \n                                predicate=∈([:Class1, :Class2])),\n                            aggregate_subset(\n                                macro_aggregation, \n                                name=\"Classes 2 and 3\", \n                                predicate=∈([:Class2, :Class3])),\n                            micro_aggregation,\n                            macro_aggregation,\n                            weighted_aggregation\n                        ])\nnothing # hide","category":"page"},{"location":"classification_report/","page":"Classification report","title":"Classification report","text":"The table is printed using PrettyTables and accepts keyword arguments defined in that package. For example, to print the table in the LaTeX or Markdown formats, one can specify the backend:","category":"page"},{"location":"classification_report/","page":"Classification report","title":"Classification report","text":"using Markdown\n\nmarkdown_table = classification_report(predicted, \n                        actual, \n                        label_set=classes,\n                        metrics=[precision, recall, F1_score, Fβ_score(2)],\n                        aggregations=[\n                            aggregate_subset(\n                                macro_aggregation, \n                                name=\"Classes 1 and 2\", \n                                predicate=∈([:Class1, :Class2])),\n                            aggregate_subset(\n                                macro_aggregation, \n                                name=\"Classes 2 and 3\", \n                                predicate=∈([:Class2, :Class3])),\n                            micro_aggregation,\n                            macro_aggregation,\n                            weighted_aggregation\n                        ],\n                        io=String,\n                        backend=Val(:markdown)) |> first\nMarkdown.parse(markdown_table) # hide","category":"page"},{"location":"classification_report/","page":"Classification report","title":"Classification report","text":"latex_table = classification_report(predicted, \n                        actual, \n                        label_set=classes,\n                        metrics=[precision, recall, F1_score, Fβ_score(2)],\n                        aggregations=[\n                            aggregate_subset(\n                                macro_aggregation, \n                                name=\"Classes 1 and 2\", \n                                predicate=∈([:Class1, :Class2])),\n                            aggregate_subset(\n                                macro_aggregation, \n                                name=\"Classes 2 and 3\", \n                                predicate=∈([:Class2, :Class3])),\n                            micro_aggregation,\n                            macro_aggregation,\n                            weighted_aggregation\n                        ],\n                        io=String,\n                        backend=Val(:latex)) |> first\n\nusing Latexify # hide\n\nlatex_string = Latexify.LaTeXString(latex_table) # hide\nrender(latex_string, MIME(\"image/svg\"), debug=false, documentclass=(\"standalone\"), name=\"table\",open=false) # hide\nlatex_table # hide\nnothing # hide","category":"page"},{"location":"classification_report/","page":"Classification report","title":"Classification report","text":"(Image: )","category":"page"},{"location":"prediction_results/","page":"Prediction results","title":"Prediction results","text":"CurrentModule = ClassificationMetrics\nDocTestSetup = quote\n    using ClassificationMetrics\nend","category":"page"},{"location":"prediction_results/#Prediction-results","page":"Prediction results","title":"Prediction results","text":"","category":"section"},{"location":"prediction_results/","page":"Prediction results","title":"Prediction results","text":"Prediction results refer to TP, FN, FP and TN values. They can be calculated using prediction_results:","category":"page"},{"location":"prediction_results/","page":"Prediction results","title":"Prediction results","text":"using ClassificationMetrics\n\nactual    = [0, 0, 0, 1, 1, 1, 2, 2, 2]\npredicted = [1, 2, 0, 0, 0, 1, 0, 2, 0]\n\nprediction_results(predicted, actual, sort_labels=true)","category":"page"},{"location":"prediction_results/","page":"Prediction results","title":"Prediction results","text":"It is possible to provide full label set in case not all classes are present in the data. Optional argument sort_labels specifies whether the labels should be sorted or not.  The results are stored in a convenience struct PredictionResults that holds TP, FN, FP and TN values and the labels. It can be passed to classification_report to get further results or \"pretty printed\" in the terminal. ","category":"page"},{"location":"prediction_results/","page":"Prediction results","title":"Prediction results","text":"It is also possible to index the results and concatenate them with vcat:","category":"page"},{"location":"prediction_results/","page":"Prediction results","title":"Prediction results","text":"using ClassificationMetrics\n\nactual    = [0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3]\npredicted = [1, 2, 0, 0, 0, 1, 0, 2, 0, 2, 0, 3]\n\nres = prediction_results(predicted, actual, sort_labels=true)\nres1 = res[1:2]\nres2 = res[4]\n\nvcat(res1, res2)","category":"page"},{"location":"prediction_results/","page":"Prediction results","title":"Prediction results","text":"The indexing uses the order of the labels stored in PredictionResults.","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = ClassificationMetrics","category":"page"},{"location":"#ClassificationMetrics.jl","page":"Home","title":"ClassificationMetrics.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Classification metrics calculation and reporting for Julia.","category":"page"},{"location":"","page":"Home","title":"Home","text":"A package for calculating classification metrics and generating classification reports.","category":"page"},{"location":"#Documentation-Outline","page":"Home","title":"Documentation Outline","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Pages=[\n    \"confusion_matrix.md\",\n    \"prediction_results.md\",\n    \"metrics.md\",\n    \"classification_report.md\",\n    \"api.md\",\n]\nDepth = 1","category":"page"}]
}
