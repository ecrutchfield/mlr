#' @title Generate threshold vs. performance(s) for 2-class classification.
#'
#' @description
#' Generates data on threshold vs. performance(s) for 2-class classification that can be used for plotting.
#'
#' @family generate_plot_data
#' @family thresh_vs_perf
#'
#' @template arg_plotroc_obj
#' @template arg_measures
#' @param gridsize [\code{integer(1)}]\cr
#'   Grid resolution for x-axis (threshold).
#'   Default is 100.
#' @param aggregate [\code{logical(1)}]\cr
#'   Whether to aggregate \code{\link{ResamplePrediction}}s or to plot the performance
#'   of each iteration separately.
#'   Default is \code{TRUE}.
#' @param task.id [\code{character(1)}]\cr
#'   Selected task in \code{\link{BenchmarkResult}} to do plots for, ignored otherwise.
#'   Default is first task.
#' @return [\code{ThreshVsPerfData}]. A named list containing the measured performance
#'   across the threshold grid, the measures, and whether the performance estimates were
#'   aggregated (only applicable for (list of) \code{\link{ResampleResult}}s).
#' @export
generateThreshVsPerfData = function(obj, measures, gridsize = 100L, aggregate = TRUE, task.id = NULL)
  UseMethod("generateThreshVsPerfData")
#' @export
generateThreshVsPerfData.Prediction = function(obj, measures, gridsize = 100L, aggregate = TRUE,
                                               task.id = NULL) {
  checkPrediction(obj, task.type = "classif", binary = TRUE, predict.type = "prob")
  generateThreshVsPerfData.list(namedList("prediction", obj), measures, gridsize, aggregate, task.id)
}
#' @export
generateThreshVsPerfData.ResampleResult = function(obj, measures, gridsize = 100L, aggregate = TRUE,
                                                   task.id = NULL) {
  obj = getRRPredictions(obj)
  checkPrediction(obj, task.type = "classif", binary = TRUE, predict.type = "prob")
  generateThreshVsPerfData.Prediction(obj, measures, gridsize, aggregate)
}
#' @export
generateThreshVsPerfData.BenchmarkResult = function(obj, measures, gridsize = 100L, aggregate = TRUE,
                                                    task.id = NULL) {
  tids = getBMRTaskIds(obj)
  if (is.null(task.id))
    task.id = tids[1L]
  else
    assertChoice(task.id, tids)
  obj = getBMRPredictions(obj, task.ids = task.id, as.df = FALSE)[[1L]]

  for (x in obj)
    checkPrediction(x, task.type = "classif", binary = TRUE, predict.type = "prob")
  generateThreshVsPerfData.list(obj, measures, gridsize, aggregate, task.id)
}
#' @export
generateThreshVsPerfData.list = function(obj, measures, gridsize = 100L, aggregate = TRUE, task.id = NULL) {
  assertList(obj, c("Prediction", "ResampleResult"), min.len = 1L)
  ## unwrap ResampleResult to Prediction and set default names
  if (inherits(obj[[1L]], "ResampleResult")) {
    if (is.null(names(obj)))
      names(obj) = extractSubList(obj, "learner.id")
    obj = extractSubList(obj, "pred", simplify = FALSE)
  }
  assertList(obj, names = "unique")
  td = extractSubList(obj, "task.desc", simplify = FALSE)[[1L]]
  measures = checkMeasures(measures, td)
  mids = replaceDupeMeasureNames(measures, "id")
  names(measures) = mids
  thseq = seq(0, 1, length.out = gridsize)
  grid = data.frame(threshold = thseq)
  obj = lapply(obj, function(x) {
    if (all(sapply(obj, function(x) inherits(x, "ResamplePrediction"))) & !aggregate) {
      do.call("rbind", lapply(thseq, function(threshold) {
        pp = setThreshold(x, threshold = threshold)
        t(sapply(unique(x$data$iter), function(i) {
          pp$data = pp$data[pp$data$iter == i, ]
          c(performance(pp, measures = measures), "iter" = i)
        }))
      }))
    } else {
      asMatrixRows(lapply(thseq, function(threshold) {
        pp = setThreshold(x, threshold = threshold)
        performance(pp, measures = measures)
      }), col.names = mids)
    }
  })
  out = plyr::ldply(obj, .id = "learner")
  makeS3Obj("ThreshVsPerfData",
            measures = measures,
            data = cbind(grid, out),
            aggregate = aggregate)
}

#' @title Plot threshold vs. performance(s) for 2-class classification using ggplot2.
#'
#' @description
#' Plots threshold vs. performance(s) data that has been generated with \code{\link{generateThreshVsPerfData}}.
#'
#' @family plot
#' @family thresh_vs_perf
#'
#' @param obj [\code{ThreshVsPerfData}]\cr
#'   Result of \code{\link{generateThreshVsPerfData}}.
#' @param facet [\code{character(1)}]\cr
#'   Selects \dQuote{measure} or \dQuote{learner} to be the facetting variable.
#'   The variable mapped to \code{facet} must have more than one unique value, otherwise it will
#'   be ignored. The variable not chosen is mapped to color if it has more than one unique value.
#'   The default is \dQuote{measure}.
#' @param mark.th [\code{numeric(1)}]\cr
#'   Mark given threshold with vertical line?
#'   Default is \code{NA} which means not to do it.
#' @param pretty.names [\code{logical(1)}]\cr
#'   Whether to use the \code{\link{Measure}} name instead of the id in the plot.
#'   Default is \code{TRUE}.
#' @template ret_gg2
#' @export
#' @examples
#' lrn = makeLearner("classif.rpart", predict.type = "prob")
#' mod = train(lrn, sonar.task)
#' pred = predict(mod, sonar.task)
#' pvs = generateThreshVsPerfData(pred, list(acc, setAggregation(acc, train.mean)))
#' plotThreshVsPerf(pvs)
plotThreshVsPerf = function(obj, facet = "measure", mark.th = NA_real_, pretty.names = TRUE) {
  assertClass(obj, classes = "ThreshVsPerfData")
  mappings = c("measure", "learner")
  assertChoice(facet, mappings)
  color = mappings[mappings != facet]

  if (pretty.names) {
    mnames = replaceDupeMeasureNames(obj$measures, "name")
    colnames(obj$data) = mapValues(colnames(obj$data),
                                   names(obj$measures),
                                   mnames)
  } else
    mnames = names(obj$measures)

  data = reshape2::melt(obj$data,
                        measure.vars = mnames,
                        variable.name = "measure", value.name = "performance",
                        id.vars = c("learner", "threshold"))
  nlearn = length(unique(data$learner))
  nmeas = length(unique(data$measure))

  if ((color == "learner" & nlearn == 1L) | (color == "measure" & nmeas == 1L))
    color = NULL
  if ((facet == "learner" & nlearn == 1L) | (facet == "measure" & nmeas == 1L))
    facet = NULL

  if (!is.null(color))
    plt = ggplot2::ggplot(data, aes_string(x = "threshold", y = "performance", color = color))
  else
    plt = ggplot2::ggplot(data, aes_string(x = "threshold", y = "performance"))
  plt = plt + ggplot2::geom_line()
  if (!is.na(mark.th))
    plt = plt + ggplot2::geom_vline(xintercept = mark.th)
  if (!is.null(facet))
    plt = plt + ggplot2::facet_wrap(as.formula(paste("~", facet)), scales = "free_y")
  else if (length(obj$measures) == 1L)
    plt = plt + ylab(obj$measures[[1]]$name)
  else
    plt = plt + ylab("performance")
  return(plt)
}
#' @title Plot threshold vs. performance(s) for 2-class classification using ggvis.
#'
#' @description
#' Plots threshold vs. performance(s) data that has been generated with \code{\link{generateThreshVsPerfData}}.
#'
#' @family plot
#' @family thresh_vs_perf
#'
#' @param obj [\code{ThreshVsPerfData}]\cr
#'   Result of \code{\link{generateThreshVsPerfData}}.
#' @param mark.th [\code{numeric(1)}]\cr
#'   Mark given threshold with vertical line?
#'   Default is \code{NA} which means not to do it.
#' @param interaction [\code{character(1)}]\cr
#'   Selects \dQuote{measure} or \dQuote{learner} to be used in a Shiny application
#'   making the \code{interaction} variable selectable via a drop-down menu.
#'   This variable must have more than one unique value, otherwise it will be ignored.
#'   The variable not chosen is mapped to color if it has more than one unique value.
#'   Note that if there are multiple learners and multiple measures interactivity is
#'   necessary as ggvis does not currently support facetting or subplots.
#'   The default is \dQuote{measure}.
#' @param pretty.names [\code{logical(1)}]\cr
#'   Whether to use the \code{\link{Measure}} name instead of the id in the plot.
#'   Default is \code{TRUE}.
#' @template ret_ggv
#' @export
#' @examples \dontrun{
#' lrn = makeLearner("classif.rpart", predict.type = "prob")
#' mod = train(lrn, sonar.task)
#' pred = predict(mod, sonar.task)
#' pvs = generateThreshVsPerfData(pred, list(tpr, fpr))
#' plotThreshVsPerfGGVIS(pvs)
#' }
plotThreshVsPerfGGVIS = function(obj, interaction = "measure", mark.th = NA_real_, pretty.names = TRUE) {
  assertClass(obj, classes = "ThreshVsPerfData")
  mappings = c("measure", "learner")
  assertChoice(interaction, mappings)
  assertFlag(pretty.names)
  color = mappings[mappings != interaction]

  if (pretty.names) {
    mnames = replaceDupeMeasureNames(obj$measures, "name")
    colnames(obj$data) = mapValues(colnames(obj$data),
                                   names(obj$measures),
                                   mnames)
  } else
    mnames = names(obj$measures)

  data = reshape2::melt(obj$data,
                        measure.vars = mnames,
                        variable.name = "measure", value.name = "performance",
                        id.vars = c("learner", "threshold"))
  nmeas = length(unique(data$measure))
  nlearn = length(unique(data$learner))

  if ((color == "learner" & nlearn == 1L) | (color == "measure" & nmeas == 1L))
    color = NULL
  if ((interaction == "learner" & nlearn == 1L) | (interaction == "measure" & nmeas == 1L))
    interaction = NULL

  create_plot = function(data, color, measures) {
    if (!is.null(color)) {
      plt = ggvis::ggvis(data, ggvis::prop("x", as.name("threshold")),
                         ggvis::prop("y", as.name("performance")),
                         ggvis::prop("stroke", as.name(color)))
    } else {
      plt = ggvis::ggvis(data, ggvis::prop("x", as.name("threshold")),
                         ggvis::prop("y", as.name("performance")))
    }
    plt = ggvis::layer_lines(plt)
    if (!is.na(mark.th) & is.null(interaction)) { ## cannot do vline with reactive data
      vline_data = data.frame(x2 = rep(mark.th, 2), y2 = c(min(data$perf), max(data$perf)),
                              measure = obj$measures[1])
      plt = ggvis::layer_paths(plt, ggvis::prop("x", as.name("x2")),
                               ggvis::prop("y", as.name("y2")),
                               ggvis::prop("stroke", "grey", scale = FALSE), data = vline_data)
    }
    plt = ggvis::add_axis(plt, "x", title = "threshold")
    if (length(measures) > 1L)
      plt = ggvis::add_axis(plt, "y", title = "performance")
    else
      plt = ggvis::add_axis(plt, "y", title = measures[[1]]$name)
    plt
  }

  if (!is.null(interaction)) {
    ui = shiny::shinyUI(
        shiny::pageWithSidebar(
            shiny::headerPanel("Threshold vs. Performance"),
            shiny::sidebarPanel(
                shiny::selectInput("interaction_select",
                                   paste("choose a", interaction),
                                   levels(data[[interaction]]))
            ),
            shiny::mainPanel(
                shiny::uiOutput("ggvis_ui"),
                ggvis::ggvisOutput("ggvis")
            )
        ))
    server = shiny::shinyServer(function(input, output) {
      data_sub = shiny::reactive(data[which(data[[interaction]] == input$interaction_select), ])
      plt = create_plot(data_sub, color, obj$measures)
      ggvis::bind_shiny(plt, "ggvis", "ggvis_ui")
    })
    shiny::shinyApp(ui, server)
  } else {
    create_plot(data, color, obj$measures)
  }
}

#' @title Plots a ROC curve using ggplot2
#'
#' @description
#' Plots a ROC curve from predictions.
#'
#' @family plot
#' @family thresh_vs_perf
#'
#' @template arg_plotroc_obj
#' @template arg_measures
#' @param diagonal [\code{logical(1)}]\cr
#'   Whether to plot a dashed diagonal line.
#'   Default is \code{TRUE}.
#' @param pretty.names [\code{logical(1)}]\cr
#'   Whether to use the \code{\link{Measure}} name instead of the id in the plot.
#'   Default is \code{TRUE}.
#' @template ret_ggv
#' @export
#' @examples
#' \donttest{
#' lrn = makeLearner("classif.rpart", predict.type = "prob")
#' fit = train(lrn, sonar.task)
#' pred = predict(fit, task = sonar.task)
#' roc = generateThreshVsPerfData(pred, list(fpr, tpr))
#' plotROCCurves(roc)
#'
#' r = bootstrapB632plus(lrn, sonar.task, iters = 3)
#' roc_r = generateThreshVsPerfData(r, list(fpr, tpr), aggregate = FALSE)
#' plotROCCurves(roc_r)
#'
#' r2 = crossval(lrn, sonar.task, iters = 3)
#' roc_l = generateThreshVsPerfData(list(boot = r, cv = r2), list(fpr, tpr), aggregate = FALSE)
#' plotROCCurves(roc_l)
#' }
plotROCCurves = function(obj, measures = obj$measures[1:2], diagonal = TRUE, pretty.names = TRUE) {
  assertClass(obj, "ThreshVsPerfData")
  assertList(measures, "Measure", len = 2)
  assertFlag(diagonal)
  assertFlag(pretty.names)

  if (is.null(names(measures)))
    names(measures) = extractSubList(measures, "id")

  if (pretty.names)
    mnames = replaceDupeMeasureNames(obj$measures, "name")
  else
    mnames = names(obj$measures)

  mlearn = length(unique(obj$data$learner)) > 1L
  resamp = "iter" %in% colnames(obj$data)

  if (!obj$aggregate & mlearn & resamp) {
    obj$data$int = interaction(obj$data$learner, obj$data$iter)
    p = ggplot(obj$data, aes_string(names(measures)[1], names(measures)[2], group = "int"))
    p = p + geom_path(alpha = .5)
  } else if (!obj$aggregate & !mlearn & resamp) {
    p = ggplot(obj$data, aes_string(names(measures)[1], names(measures)[2], group = "iter"))
    p = p + geom_path(alpha = .5)
  } else if (obj$aggregate & mlearn & !resamp) {
    p = ggplot(obj$data, aes_string(names(measures)[1], names(measures)[2]), group = "learner", color = "learner")
    p = p + geom_path(alpha = .5)
  } else {
    obj$data = obj$data[order(obj$data$threshold), ]
    p = ggplot(obj$data, aes_string(names(measures)[1], names(measures)[2]))
    p = p + geom_path()
  }

  p = p + labs(x = mnames[1], y = mnames[2])

  if (length(unique(obj$data$learner)) > 1L)
    p = p + facet_wrap(~ learner)

  if (diagonal & all(sapply(obj$data[, names(measures)], max) <= 1))
    p = p + geom_abline(aes(intercept = 0, slope = 1), linetype = "dashed", alpha = .5)
  p
}
