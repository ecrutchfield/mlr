% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/BenchmarkResult_operators.R
\name{getBMRTuneResults}
\alias{getBMRTuneResults}
\title{Extract the tuning results from a benchmark result.}
\usage{
getBMRTuneResults(bmr, task.ids = NULL, learner.ids = NULL, as.df = FALSE)
}
\arguments{
\item{bmr}{[\code{\link{BenchmarkResult}}]\cr
Benchmark result.}

\item{task.ids}{[\code{character(1)}]\cr
Restrict result to certain tasks.
Default is all.}

\item{learner.ids}{[\code{character(1)}]\cr
Restrict result to certain learners.
Default is all.}

\item{as.df}{[\code{character(1)}]\cr
Return one data.frame as result - or a list of lists of objects?.
Default is \code{FALSE}}
}
\value{
[\code{list} | \code{data.frame}]. See above.
}
\description{
Returns a nested list of \code{\link{TuneResult}}s. The first level of nesting is by data set, the second by learner, the third for the benchmark resampling iterations. If \code{as.df} is \code{TRUE}, a data frame with the \dQuote{task.id}, \dQuote{learner.id}, the resample iteration, the parameter values and the performances is returned.
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
  \code{\link{plotBMRBoxplots}},
  \code{\link{plotBMRRanksAsBarChart}},
  \code{\link{plotBMRSummary}},
  \code{\link{plotCritDifferences}}
}

