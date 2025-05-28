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

  nodes <- igraph::as_data_frame(graph, what = "vertices")

  edges <- as.data.frame(igraph::as_edgelist(graph, names = FALSE))
  names(edges)[1:2] <- c("source", "target")
  edges$source <- as.character(edges$source)
  edges$target <- as.character(edges$target)

  g6(
    nodes = nodes,
    edges = edges,
    combos = combos,
    width = width,
    height = height,
    elementId = elementId
  )
}
