#' @title Plot a benchmark summary.
#'
#' @description
#' Creates a scatter plots, where each line refers to a task.
#' On that line the aggregated scores for all learners are plotted, for that task.
#' You can use a rank transformation or just use ggplot2's \code{}
#'
#' @template arg_bmr
#' @template arg_measure
#' @param trafo [\code{character(1)}]\cr
#'   Currently either \dQuote{none} or \dQuote{rank}, the latter performing a rank transformation
#'   (with average handling of ties) of the scores per task.
#'   NB: You can add always addd \code{\link{scale_x_log10}} to the result to put scores on a log scale.
#'   Default is \dQuote{none}.
#' @template arg_order_tsks
#' @param pointsize [\code{numeric(1)}]\cr
#'   Point size for ggplot2 \code{\link[ggplot2]{geom_point}} for data points.
#'   Default is 4.
#' @param jitter [\code{numeric(1)}]\cr
#'   Small vertical jitter to deal with overplotting in case of equal scores.
#'   Default is 0.05.
#' @template ret_gg2
#' @family benchmark
#' @family plot
#' @export
#' @examples
#' # see benchmark
plotBMRSummary = function(bmr, measure = NULL, trafo = "none", order.tsks = NULL, pointsize = 4L, jitter = 0.05) {
  assertClass(bmr, "BenchmarkResult")
  measure = checkBMRMeasure(measure, bmr)
  assertChoice(trafo, c("none", "rank"))
  meas.name = measureAggrName(measure)
  assertNumber(pointsize, lower = 0)
  assertNumber(jitter, lower = 0)

  df = getBMRAggrPerformances(bmr, as.df = TRUE)


  xlab.string = meas.name

  # trafo to ranks manually here
  if (trafo == "rank") {
    df = ddply(df, "task.id", function(d) {
      d[, meas.name] = rank(d[, meas.name], ties.method = "average")
      return(d)
    })
    xlab.string = paste("rank of", xlab.string)
  }

  df = orderBMRTasks(bmr, df, order.tsks)

  p = ggplot(df, aes_string(x = meas.name, y = "task.id", col = "learner.id"))
  p = p + geom_point(size = pointsize, position = position_jitter(width = 0, height = jitter))
  # we dont need y label, the task names speak for themselves
  p = p + ylab("")
  p = p + xlab(xlab.string)
  return(p)
}

