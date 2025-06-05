#' Create a G6 Graph from an igraph Object
#'
#' @description
#' Converts an `igraph` graph object into the format required by the `g6()` function
#' and creates an interactive G6 graph visualization. This is a convenience wrapper around
#' [g6()] that allows you to work directly with `igraph` objects.
#'
#' @details
#' This function extracts the node and edge data from an `igraph` object, converts them
#' into the appropriate format for G6, and passes them to [g6()]. Node styling is derived
#' from vertex attributes, and edge styling from edge attributes.
#'
#' If the graph is directed, edges will automatically be rendered with arrows.
#'
#' @inheritParams g6
#' @param graph An object of class [`igraph::igraph`] containing the graph to visualize.
#'
#' @return An htmlwidget object that can be rendered in R Markdown, Shiny apps, or the R console.
#'
#' @seealso [g6()] for more information about node, edge, and combo structure.
#'
#' @examples
#' if (require(igraph)) {
#'   g <- igraph::make_ring(5)
#'   g6_igraph(g)
#' }
#'
#' @export
g6_igraph <- function(
  graph,
  combos = NULL,
  width = "100%",
  height = NULL,
  elementId = NULL
) {
  if (!requireNamespace("igraph", quietly = TRUE)) {
    stop(
      "The package 'igraph' is required for this function to work. Please install it."
    )
  }
  igraph::V(graph)$id <- as.character(seq_len(igraph::vcount(graph)))

  nodes_df <- igraph::as_data_frame(graph, what = "vertices")
  nodes_df <- shape2type(nodes_df)
  nodes <- style_from_df(nodes_df, node_style_options)

  # TODO: find better solution
  names <- igraph::V(graph)$name %||% igraph::V(graph)$id
  igraph::V(graph)$name <- igraph::V(graph)$id
  edges_df <- igraph::as_data_frame(graph, what = "edges")
  names(edges_df)[1:2] <- c("source", "target")
  if (igraph::is_directed(graph)) {
    edges_df$endArrow <- TRUE
  }
  edges <- style_from_df(edges_df, edge_style_options)
  igraph::V(graph)$name <- names

  g6(
    nodes = nodes,
    edges = edges,
    combos = combos,
    width = width,
    height = height,
    elementId = elementId
  )
}

#' @keywords internal
style_from_df <- function(df, style_fn) {
  formal_args <- names(formals(style_fn))
  has_dots <- "..." %in% formal_args
  style_args <- setdiff(formal_args, "...")

  items <- unname(split(df, seq(nrow(df))))
  items <- lapply(items, function(row) {
    item <- as.list(row)

    style_inputs <- item[names(item) %in% style_args]
    extra_inputs <- item[!names(item) %in% style_args]

    if (has_dots) {
      style <- do.call(style_fn, c(style_inputs, extra_inputs))
    } else {
      style <- do.call(style_fn, style_inputs)
    }

    item$style <- style
    return(item)
  })

  items
}

#' @keywords internal
#' @note In igraph type is reserved for bipartite graphs, whereas in g6 it defines the
#' shape of the node
shape2type <- function(nodes_df) {
  if ("shape" %in% names(nodes_df)) {
    if (!"type" %in% names(nodes_df)) {
      nodes_df$type <- nodes_df$shape
    } else {
      nodes_df$type_igraph <- nodes_df$type
      nodes_df$type <- nodes_df$shape
    }
  }
  nodes_df
}
