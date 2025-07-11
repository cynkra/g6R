% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/layouts.R
\name{circular_layout}
\alias{circular_layout}
\title{Generate G6 AntV circular layout configuration}
\usage{
circular_layout(
  angleRatio = 1,
  center = NULL,
  clockwise = TRUE,
  divisions = 1,
  nodeSize = 10,
  nodeSpacing = 10,
  ordering = NULL,
  radius = NULL,
  startAngle = 0,
  endAngle = 2 * pi,
  startRadius = NULL,
  endRadius = NULL,
  width = NULL,
  height = NULL,
  ...
)
}
\arguments{
\item{angleRatio}{How many \code{2*PI} are there between the first node and the last node.}

\item{center}{Center of layout as vector \code{c(x, y)} or \code{c(x, y, z)}.}

\item{clockwise}{Is it arranged clockwise?}

\item{divisions}{Number of segments that nodes are placed on the ring.}

\item{nodeSize}{Node size (diameter) for collision detection.}

\item{nodeSpacing}{Minimum distance between rings.}

\item{ordering}{Basis for sorting nodes ("topology", "topology-directed", or "degree").}

\item{radius}{Radius of the circle (overrides startRadius and endRadius).}

\item{startAngle}{Starting angle of the layout.}

\item{endAngle}{End angle of the layout.}

\item{startRadius}{Starting radius of the spiral layout.}

\item{endRadius}{End radius of the spiral layout.}

\item{width}{Width of layout.}

\item{height}{Height of layout.}

\item{...}{Additional parameters to pass to the layout.
See \url{https://g6.antv.antgroup.com/en/manual/layout/circular-layout}.}
}
\value{
A list containing the configuration for G6 AntV circular layout.
}
\description{
This function creates a configuration list for G6 AntV circular layout
with all available options as parameters.
}
\examples{
circular_config <- circular_layout(
  radius = 200,
  startAngle = 0,
  endAngle = pi,
  clockwise = FALSE
)
}
