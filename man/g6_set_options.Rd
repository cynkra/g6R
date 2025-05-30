% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/proxy.R
\name{g6_set_options}
\alias{g6_set_options}
\title{Set options for a g6 graph via proxy}
\usage{
g6_set_options(graph, ...)
}
\arguments{
\item{graph}{A g6_proxy object created with \code{\link{g6_proxy}}.}

\item{...}{Named arguments representing the options to update and their new values.
These can include any valid g6 graph options such as fitView, animate, modes, etc.}
}
\value{
The g6_proxy object (invisibly), allowing for method chaining.
}
\description{
This function allows updating various configuration options of an existing g6 graph
instance using a proxy object within a Shiny application.
}
\details{
This function can only be used with a g6_proxy object within a Shiny application.
It will not work with regular g6 objects outside of Shiny.

The function allows updating various graph options dynamically without having to
re-render the entire graph. This is useful for changing behavior, appearance,
or interaction modes in response to user input.
}
\seealso{
\code{\link{g6_proxy}}
}
