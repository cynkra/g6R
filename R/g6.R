#' G6 htmlwidget instance
#'
#' Creates an htmlwidget on top of G6.
#'
#' @import htmlwidgets
#'
#' @export
g6 <- function(
  nodes = NULL,
  edges = NULL,
  combos = NULL,
  options = g6_options(),
  behaviors = g6_behaviors(),
  plugins = g6_plugins(),
  width = NULL,
  height = NULL,
  elementId = NULL
) {
  # forward options using x
  x <- c(
    data = list(
      nodes = nodes,
      edges = edges,
      combos = combos
    ),
    behaviors = behaviors,
    plugins = plugins,
    options,
    width = width,
    height = height
  )

  # create widget
  htmlwidgets::createWidget(
    name = "g6",
    x,
    width = width,
    height = height,
    package = "shinyG6",
    elementId = elementId
  )
}

#' Shiny bindings for g6
#'
#' Output and render functions for using g6 within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a g6
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name g6-shiny
#'
#' @export
g6Output <- function(outputId, width = "100%", height = "400px") {
  htmlwidgets::shinyWidgetOutput(
    outputId,
    "g6",
    width,
    height,
    package = "shinyG6"
  )
}

#' @rdname g6-shiny
#' @export
renderG6 <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) {
    expr <- substitute(expr)
  } # force quoted
  htmlwidgets::shinyRenderWidget(expr, g6Output, env, quoted = TRUE)
}
