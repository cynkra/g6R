% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plugins.R
\name{hull}
\alias{hull}
\title{Configure Hull Plugin}
\usage{
hull(
  members,
  key = "hull",
  concavity = Inf,
  corner = c("rounded", "smooth", "sharp"),
  padding = 10,
  label = TRUE,
  labelText = NULL,
  labelPlacement = c("bottom", "left", "right", "top", "center"),
  labelBackground = FALSE,
  labelPadding = 0,
  labelCloseToPath = TRUE,
  labelAutoRotate = TRUE,
  labelOffsetX = 0,
  labelOffsetY = 0,
  labelMaxWidth = 0,
  ...
)
}
\arguments{
\item{members}{Elements within the hull, including nodes and edges (character vector, required).}

\item{key}{Unique identifier for the plugin (string, default: NULL).}

\item{concavity}{Concavity parameter, larger values create less concave hulls (number, default: Infinity).}

\item{corner}{Corner type: "rounded", "smooth", or "sharp" (string, default: "rounded").}

\item{padding}{Padding around the elements (number, default: 10).}

\item{label}{Whether to display the label (boolean, default: TRUE).}

\item{labelText}{Label text content. Default to NULL.}

\item{labelPlacement}{Label position: "left", "right", "top", "bottom", or "center" (string, default: "bottom").}

\item{labelBackground}{Whether to display the background (boolean, default: FALSE).}

\item{labelPadding}{Label padding (number or numeric vector, default: 0).}

\item{labelCloseToPath}{Whether the label is close to the hull (boolean, default: TRUE).}

\item{labelAutoRotate}{Whether the label rotates with the hull, effective only when
closeToPath is true (boolean, default: TRUE).}

\item{labelOffsetX}{X-axis offset (number, default: 0).}

\item{labelOffsetY}{Y-axis offset (number, default: 0).}

\item{labelMaxWidth}{Maximum width of the text, exceeding will be ellipsized (number, default: 0).}

\item{...}{Other options.
See \url{https://g6.antv.antgroup.com/en/manual/plugin/hull}.}
}
\value{
A list with the configuration settings for the hull plugin.
}
\description{
Creates a configuration object for the hull plugin in G6.
This plugin creates a hull (convex or concave) that surrounds specified graph elements.
}
\examples{
# Basic configuration
config <- hull(members = c("node1", "node2", "node3"))

# Custom configuration for a cluster
config <- hull(
  key = "cluster-hull",
  members = c("node1", "node2", "node3", "node4"),
  concavity = 0.8,
  corner = "smooth",
  padding = 15,
  label = TRUE,
  labelPlacement = "top",
  labelBackground = TRUE,
  labelPadding = c(4, 8),
  labelMaxWidth = 100
)
}
