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
  nodes <- style_from_df(nodes_df, node_style_options)

  # TODO: find better solution
  names <- igraph::V(graph)$name
  V(graph)$name <- V(graph)$id
  edges_df <- igraph::as_data_frame(graph, what = "edges")
  names(edges_df)[1:2] <- c("source", "target")
  edges <- style_from_df(edges_df, edge_style_options)
  V(graph)$name <- names

  g6(
    nodes = nodes,
    edges = edges,
    combos = combos,
    width = width,
    height = height,
    elementId = elementId
  )
}

style_from_df <- function(df, style_fn) {
  style_args <- names(formals(style_fn))
  style_args <- style_args[style_args != "..."]

  items <- unname(split(df, seq(nrow(df))))
  items <- lapply(items, function(row) {
    item <- as.list(row)
    style_inputs <- item[names(item) %in% style_args]
    style <- do.call(style_fn, style_inputs)
    item$style <- style
    return(item)
  })
  items
}
