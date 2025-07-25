% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/options.R
\name{node_style_options}
\alias{node_style_options}
\title{Create Node Style Options for G6 Graphs}
\usage{
node_style_options(
  collapsed = FALSE,
  cursor = "default",
  fill = "#1783FF",
  fillOpacity = 1,
  increasedLineWidthForHitTesting = 0,
  lineCap = c("butt", "round", "square"),
  lineDash = NULL,
  lineDashOffset = NULL,
  lineJoin = c("miter", "round", "bevel"),
  lineWidth = 1,
  opacity = 1,
  shadowBlur = NULL,
  shadowColor = NULL,
  shadowOffsetX = NULL,
  shadowOffsetY = NULL,
  shadowType = c("outer", "inner"),
  size = 32,
  stroke = "#000",
  strokeOpacity = 1,
  transform = NULL,
  transformOrigin = NULL,
  visibility = c("visible", "hidden"),
  x = NULL,
  y = NULL,
  z = NULL,
  zIndex = NULL,
  ...
)
}
\arguments{
\item{collapsed}{Whether the current node/group is collapsed. Default: FALSE.}

\item{cursor}{Node mouse hover cursor style. Common values include "default",
"pointer", "move", etc. Default: "default".}

\item{fill}{Node fill color. Can be any valid CSS color value. Default: "#1783FF".}

\item{fillOpacity}{Node fill color opacity. Value between 0 and 1. Default: 1.}

\item{increasedLineWidthForHitTesting}{When lineWidth is small, this value increases
the interactive area to make "thin lines" easier to interact with. Default: 0.}

\item{lineCap}{Node stroke end style. Options: "round", "square", "butt". Default: "butt".}

\item{lineDash}{Node stroke dash style. Vector of numbers specifying dash pattern.}

\item{lineDashOffset}{Node stroke dash offset. Default: NULL.}

\item{lineJoin}{Node stroke join style. Options: "round", "bevel", "miter". Default: "miter".}

\item{lineWidth}{Node stroke width. Default: 1.}

\item{opacity}{Node overall opacity. Value between 0 and 1. Default: 1.}

\item{shadowBlur}{Node shadow blur amount. Default: NULL.}

\item{shadowColor}{Node shadow color. Default: NULL.}

\item{shadowOffsetX}{Node shadow offset in the x-axis direction. Default: NULL.}

\item{shadowOffsetY}{Node shadow offset in the y-axis direction. Default: NULL.}

\item{shadowType}{Node shadow type. Options: "inner", "outer". Default: "outer".}

\item{size}{Node size. Can be a single number for equal width/height or a vector
of two numbers \code{[width, height]}. Default: 32.}

\item{stroke}{Node stroke (border) color. Default: "#000".}

\item{strokeOpacity}{Node stroke color opacity. Value between 0 and 1. Default: 1.}

\item{transform}{CSS transform attribute to rotate, scale, skew, or translate the node.
Default: NULL.}

\item{transformOrigin}{Rotation and scaling center point. Default: NULL.}

\item{visibility}{Whether the node is visible. Options: "visible", "hidden". Default: "visible".}

\item{x}{Node x coordinate. Default: 0.}

\item{y}{Node y coordinate. Default: 0.}

\item{z}{Node z coordinate (for 3D). Default: 0.}

\item{zIndex}{Node rendering level (for layering). Default: 0.}

\item{...}{Other parameters.}
}
\value{
A list containing node style options that can be passed to \code{\link[=node_options]{node_options()}}.
}
\description{
Configures the styling options for nodes in a G6 graph. These settings control
the appearance and interaction behavior of nodes. Used in \link{node_options}.
}
\details{
Node style options allow fine-grained control over how nodes are rendered and
behave in a G6 graph. This includes colors, sizes, borders, shadows, visibility,
positioning, and interaction states.
}
\examples{
# Basic node style with blue fill and red border
styles <- node_style_options(
  fill = "#1783FF",
  stroke = "#FF0000",
  lineWidth = 2
)

# Create a node with shadow effects
styles <- node_style_options(
  fill = "#FFFFFF",
  stroke = "#333333",
  lineWidth = 1,
  shadowBlur = 10,
  shadowColor = "rgba(0,0,0,0.3)",
  shadowOffsetX = 5,
  shadowOffsetY = 5
)

# Custom sized node with dashed border
styles <- node_style_options(
  size = c(100, 50),
  fill = "#E8F7FF",
  stroke = "#1783FF",
  lineDash = c(5, 5),
  opacity = 0.8
)
}
