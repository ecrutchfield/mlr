% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotBMRSummary.R
\name{plotBMRSummary}
\alias{plotBMRSummary}
\title{Plot a benchmark summary.}
\usage{
plotBMRSummary(bmr, measure = NULL, trafo = "none", order.tsks = NULL,
  pointsize = 4L, jitter = 0.05)
}
\arguments{
\item{bmr}{[\code{\link{BenchmarkResult}}]\cr
Benchmark result.}

\item{measure}{[\code{\link{Measure}}]\cr
Performance measure.
Default is the default measure for the task, see here \code{\link{getDefaultMeasure}}.}

\item{trafo}{[\code{character(1)}]\cr
Currently either \dQuote{none} or \dQuote{rank}, the latter performing a rank transformation
(with average handling of ties) of the scores per task.
NB: You can add always addd \code{\link{scale_x_log10}} to the result to put scores on a log scale.
Default is \dQuote{none}.}

\item{order.tsks}{[\code{character(n.tasks)}] \cr 
Character vector with \code{task.ids} in new order.}

\item{pointsize}{[\code{numeric(1)}]\cr
Point size for ggplot2 \code{\link[ggplot2]{geom_point}} for data points.
Default is 4.}

\item{jitter}{[\code{numeric(1)}]\cr
Small vertical jitter to deal with overplotting in case of equal scores.
Default is 0.05.}
}
\value{
ggplot2 plot object.
}
\description{
Creates a scatter plots, where each line refers to a task.
On that line the aggregated scores for all learners are plotted, for that task.
You can use a rank transformation or just use ggplot2's \code{}
}
\examples{
# see benchmark
}
\seealso{
Other benchmark: \code{\link{BenchmarkResult}},
  \code{\link{benchmark}},
  \code{\link{convertBMRToRankMatrix}},
  \code{\link{friedmanPostHocTestBMR}},
  \code{\link{friedmanTestBMR}},
  \code{\link{generateCritDifferencesData}},
  \code{\link{getBMRAggrPerformances}},
  \code{\link{getBMRFeatSelResults}},
  \code{\link{getBMRFilteredFeatures}},
  \code{\link{getBMRLearnerIds}},
  \code{\link{getBMRLearners}},
  \code{\link{getBMRMeasureIds}},
  \code{\link{getBMRMeasures}}, \code{\link{getBMRModels}},
  \code{\link{getBMRPerformances}},
  \code{\link{getBMRPredictions}},
  \code{\link{getBMRTaskIds}},
  \code{\link{getBMRTuneResults}},
  \code{\link{plotBMRBoxplots}},
  \code{\link{plotBMRRanksAsBarChart}},
  \code{\link{plotCritDifferences}}

Other plot: \code{\link{plotBMRBoxplots}},
  \code{\link{plotBMRRanksAsBarChart}},
  \code{\link{plotCalibration}},
  \code{\link{plotCritDifferences}},
  \code{\link{plotFilterValuesGGVIS}},
  \code{\link{plotFilterValues}},
  \code{\link{plotLearningCurveGGVIS}},
  \code{\link{plotLearningCurve}},
  \code{\link{plotPartialPredictionGGVIS}},
  \code{\link{plotPartialPrediction}},
  \code{\link{plotROCCurves}},
  \code{\link{plotROCRCurvesGGVIS}},
  \code{\link{plotROCRCurves}},
  \code{\link{plotThreshVsPerfGGVIS}},
  \code{\link{plotThreshVsPerf}}
}

