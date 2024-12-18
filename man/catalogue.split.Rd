% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/catalogue.R
\name{catalogue.split}
\alias{catalogue.split}
\title{Splits a catalogue table, as produced by \code{\link{catalogue.compile}}, in multiple tables with a set number of rows each}
\usage{
catalogue.split(catalogue, max_rows = 60)
}
\arguments{
\item{catalogue}{a catalogue table}

\item{max_rows}{the maximum number of rows to be included in each _slice_}
}
\value{
a list of catalogue tables each of which is a subset of the original one and consists of _max_rows_ rows at maximum.
THe  _union_ of these subset tables will result in the original table.
}
\description{
Splits a catalogue table, as produced by \code{\link{catalogue.compile}}, in multiple tables with a set number of rows each
}
