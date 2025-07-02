#' Create a G6 Graph Visualization
#'
#' @description
#' Creates an interactive graph visualization using the G6 graph visualization library.
#' This function is the main entry point for creating G6 graph visualizations in R.
#'
#' @details
#' The `g6` function creates a G6 graph as an htmlwidget that can be used in R Markdown,
#' Shiny applications, or rendered to HTML. It takes graph data in the form of nodes, edges,
#' and optional combo groupings, along with various configuration options for customizing
#' the appearance and behavior of the graph.
#'
#' \subsection{Nodes}{
#' The `nodes` parameter should be a data frame or list of nodes with at least an `id` field
#' for each node. Additional fields can include:
#' \itemize{
#'   \item \code{id} (required): Unique identifier for the node. Must be a character.
#'   \item \code{type}: Node type (e.g., "circle", "rect", "diamond").
#'   \item \code{data}: Custom data associated with the node.
#'   \item \code{style}: List of style attributes (color, size, etc.).
#'   \item \code{states}: String. Initial states for the node, such as selected, active, hover, etc.
#'   \item \code{combo}: ID of the combo this node belongs to.
#' }}
#'
#' \subsection{Edges}{
#' The `edges` parameter should be a data frame or list of edges with at least `source` and
#' `target` fields identifying the connected nodes. Additional fields can include:
#' \itemize{
#'   \item \code{source} (required): ID of the source node. Must be a character.
#'   \item \code{target} (required): ID of the target node. Must be a character.
#'   \item \code{id}: Unique identifier for the edge.
#'   \item \code{type}: Edge type (e.g., "line", "cubic", "arc").
#'   \item \code{data}: Custom data associated with the edge.
#'   \item \code{style}: List of style attributes (color, width, etc.).
#'   \item \code{states}: String. Initial states for the edge.
#' }}
#'
#'
#' \subsection{Combos}{
#' The `combos` parameter is used for grouping nodes and can be a data frame or list with
#' combo definitions. Fields include:
#' \itemize{
#'   \item \code{id} (required): Unique identifier for the combo. Must be a character.
#'   \item \code{type}: String: Combo type. It can be the type of built-in Combo, or the custom Combo.
#'   \item \code{data}: Custom data associated with the combo.
#'   \item \code{style}: List of style attributes.
#'   \item \code{states}: String. Initial states for the combo.
#'   \item \code{combo}: String. Parent combo ID. If there is no parent combo, it is null.
#' }}
#'
#' Nodes are assigned to combos by setting their `combo` field to the ID of the combo.
#'
#' @param nodes A data frame or list of nodes in the graph. Each node should have at least
#'   an "id" field. See 'Data Structure' section for more details.
#'   Default: NULL.
#'
#' @param edges A data frame or list of edges in the graph. Each edge should have "source"
#'   and "target" fields identifying the connected nodes. See 'Data Structure' section
#'   for more details.
#'   Default: NULL.
#'
#' @param combos A data frame or list of combo groups in the graph. Each combo should have
#'   at least an "id" field. Nodes can be assigned to combos using their "combo" field.
#'   See 'Data Structure' section for more details.
#'   Default: NULL.
#'
#' @param jsonUrl An url pointing to a valid JSON containing the graph data in G6 format.
#' See \url{https://assets.antv.antgroup.com/g6/20000.json} for
#' an example. Can't be used at the same time as `nodes`, `edges`, and `combos`.
#' @param iconsUrl A URL pointing to a JavaScript file containing custom icons. Default provides
#' reasonable set of icons from
#' \url{https://at.alicdn.com/t/project/2678727/caef142c-804a-4a2f-a914-ae82666a31ee.html?spm=a313x.7781069.1998910419.35}.
#'
#' @param width Width of the graph container in pixels or as a valid CSS unit.
#'   Default: NULL (automatic sizing).
#'
#' @param height Height of the graph container in pixels or as a valid CSS unit.
#'   Default: NULL (automatic sizing).
#'
#' @param elementId A unique ID for the graph HTML element.
#'   Default: NULL (automatically generated).
#'
#' @return An htmlwidget object that can be printed, included in R Markdown documents,
#' or used in Shiny applications. This widget contains the graph data and configuration
#' necessary to render the G6 graph visualization.
#'
#' @examples
#' # Create a simple graph with two nodes and one edge
#' nodes <- data.frame(
#'   id = c("node1", "node2")
#' )
#'
#' edges <- data.frame(
#'   source = "node1",
#'   target = "node2"
#' )
#'
#' g6(nodes = nodes, edges = edges)
#' @export
g6 <- function(
  nodes = NULL,
  edges = NULL,
  combos = NULL,
  jsonUrl = NULL,
  iconsUrl = "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js",
  width = "100%",
  height = NULL,
  elementId = NULL
) {
  stopifnot(!is.null(iconsUrl))
  if (
    !is.null(jsonUrl) &&
      (!is.null(nodes) || !is.null(edges) || !is.null(combos))
  ) {
    stop(
      "Can't use jsonUrl` argument at the same time as `nodes`, `edges`, and `combos`."
    )
  }

  dat <- NULL
  if (is.null(jsonUrl)) {
    # Convert data frames to lists of records
    if (inherits(nodes, "data.frame")) {
      nodes <- unname(split(nodes, seq(nrow(nodes))))
      nodes <- lapply(nodes, function(node) as.list(node))
    }
    if (inherits(edges, "data.frame")) {
      edges <- unname(split(edges, seq(nrow(edges))))
      edges <- lapply(edges, function(edge) as.list(edge))
    }
    if (inherits(combos, "data.frame")) {
      combos <- unname(split(combos, seq(nrow(combos))))
      combos <- lapply(combos, function(combo) as.list(combo))
    }

    dat <- dropNulls(
      list(
        nodes = nodes,
        edges = edges,
        combos = combos
      )
    )
  }

  # Build properly named list of parameters to pass to widget
  x <- list(
    data = dat,
    jsonUrl = jsonUrl,
    iconsUrl = iconsUrl
  )

  # In case we need it ...
  hookFunc <- function(widget) {
    # TBD
  }

  # create widget
  htmlwidgets::createWidget(
    name = "g6",
    x,
    width = width,
    height = height,
    package = "g6R",
    elementId = elementId,
    preRenderHook = NULL
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
#' @return `g6Output` and `g6_output`
#' return a Shiny output function that can be used in the UI part of a Shiny app.
#' `renderG6` and `render_g6` return a
#' Shiny render function that can be used in the server part of a Shiny app to
#' render a `g6` element.
#'
#' @export
g6Output <- function(outputId, width = "100%", height = "400px") {
  htmlwidgets::shinyWidgetOutput(
    outputId,
    "g6",
    width,
    height,
    package = "g6R"
  )
}

#' Alias to \link{g6Output}
#' @export
#' @rdname g6-shiny
g6_output <- g6Output

#' @rdname g6-shiny
#' @export
renderG6 <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) {
    expr <- substitute(expr)
  } # force quoted
  htmlwidgets::shinyRenderWidget(expr, g6Output, env, quoted = TRUE)
}

#' Alias to \link{renderG6}
#' @export
#' @rdname g6-shiny
render_g6 <- renderG6
