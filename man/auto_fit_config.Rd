% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/options.R
\name{auto_fit_config}
\alias{auto_fit_config}
\title{Create Auto-Fit Configuration for G6 Graphs}
\usage{
auto_fit_config(
  type = c("view", "center"),
  when = c("overflow", "always"),
  direction = c("x", "y", "both"),
  duration = 1000,
  easing = c("ease-in-out", "ease", "ease-in", "ease-out", "linear", "cubic-bezier",
    "step-start", "step-end")
)
}
\arguments{
\item{type}{The auto-fit mode to use. Options:
\itemize{
\item \code{"view"}: Scale and translate the graph to fit all elements within the view (default)
\item \code{"center"}: Only translate the graph to center elements without scaling
}}

\item{when}{When the auto-fit should be triggered. Options:
\itemize{
\item \code{"overflow"}: Trigger auto-fit only when elements overflow the canvas (default)
\item \code{"always"}: Always perform auto-fit when the graph data changes
}}

\item{direction}{The direction for auto-fit adjustment. Options:
\itemize{
\item \code{"x"}: Adjust only along the x-axis
\item \code{"y"}: Adjust only along the y-axis
\item \code{"both"}: Adjust in both x and y directions (default)
}}

\item{duration}{The duration of the auto-fit animation in milliseconds (default: 1000)}

\item{easing}{The animation easing function to use. Options:
\itemize{
\item \code{"ease-in-out"}: Slow at the beginning and end of the animation (default)
\item \code{"ease"}: Standard easing
\item \code{"ease-in"}: Slow at the beginning
\item \code{"ease-out"}: Slow at the end
\item \code{"linear"}: Constant speed throughout
\item \code{"cubic-bezier"}: Custom cubic-bezier curve
\item \code{"step-start"}: Jump immediately to the end state
\item \code{"step-end"}: Jump at the end to the end state
}}
}
\value{
A list containing the auto-fit configuration that can be passed to \code{\link[=g6_options]{g6_options()}}.
}
\description{
Configures the auto-fit behavior for a G6 graph. Auto-fit automatically adjusts
the view to fit all elements or centers them within the canvas.
}
\details{
The auto-fit feature helps ensure that graph elements remain visible within the canvas.
It can be configured to either fit all elements to view or center them, and can be
triggered under different conditions.
}
\examples{
# Basic auto-fit configuration with default settings
config <- auto_fit_config()

# Auto-fit with only centering (no scaling)
config <- auto_fit_config(type = "center")

# Auto-fit that always triggers when graph data changes
config <- auto_fit_config(when = "always")

# Auto-fit only in the x direction
config <- auto_fit_config(direction = "x")

# Auto-fit with a fast animation
config <- auto_fit_config(duration = 300, easing = "ease-out")
}
