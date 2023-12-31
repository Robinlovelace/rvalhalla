% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sources_to_targets.R
\name{sources_to_targets}
\alias{sources_to_targets}
\title{Get matrix of travel times & distances from Valhalla API}
\usage{
sources_to_targets(
  from,
  to,
  costing = "pedestrian",
  directions_options = list(units = "km"),
  url = "http://localhost:8002",
  ...
)
}
\arguments{
\item{from}{a data frame or matrix of source locations with longitude and latitude columns.}

\item{to}{a data frame or matrix of target locations with longitude and latitude columns.}

\item{costing}{A string specifying the costing model to use for route optimization. Default is "auto".}

\item{directions_options}{A named list.
By default this is list(units = "km") specifying the units to use.}

\item{url}{A string specifying the URL of the Valhalla API. Default is "http://localhost:8002/route".}

\item{...}{Additional parameters to pass to the Valhalla API.}
}
\value{
A tibble of distances & times, with source and destination indices.
}
\description{
Get matrix of travel times & distances from Valhalla API
}
\examples{
if (FALSE) {
andorra_la_vella = c(1.5218, 42.5075)
pas_de_la_casa = c(1.7333, 42.5425)
# Another popular location in andorra:
encamp = c(1.5763, 42.5343)
from = rbind(andorra_la_vella, encamp)
to = rbind(pas_de_la_casa)
sources_to_targets(from, to)
}
}
