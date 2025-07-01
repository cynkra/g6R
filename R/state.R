#' Get state of g6 instance
#'
#' These functions query the current state of a g6 instance in a Shiny app to
#' extract information about nodes, edges, and combos.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @export
#' @note Only works from the server of a Shiny app.
#' @rdname g6-state
#' @return A list containing the state of the g6 instance,
#' which includes nodes, edges, and combos.
g6_state <- function(graph) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "g6_state functions only work with g6_proxy object."
    )
  }
  if (nchar(graph$session$ns("")) > 0) {
    graph$id <- strsplit(graph$id, graph$session$ns(""))[[1]][2]
  }
  graph$session$input[[sprintf("%s-state", graph$id)]]
}

#' Get nodes state of g6 instance
#'
#' @export
#' @rdname g6-state
#' @return A list of nodes in the g6 instance.
g6_nodes <- function(graph) {
  state <- g6_state(graph)
  if (is.null(state)) {
    return(NULL)
  }
  state$nodes
}

#' Get nodes ids of g6 instance
#'
#' @export
#' @rdname g6-state
#' @return A vector of node ids in the g6 instance.
g6_nodes_ids <- function(graph) {
  nodes <- g6_nodes(graph)
  if (is.null(nodes)) {
    return(NULL)
  }
  sapply(nodes, `[[`, "id")
}

#' Get edges state of g6 instance
#'
#' @export
#' @rdname g6-state
#' @return A list of edges in the g6 instance.
g6_edges <- function(graph) {
  state <- g6_state(graph)
  if (is.null(state)) {
    return(NULL)
  }
  state$edges
}

#' Get edges ids of g6 instance
#'
#' @export
#' @rdname g6-state
#' @return A vector of edge ids in the g6 instance.
g6_edges_ids <- function(graph) {
  edges <- g6_edges(graph)
  if (is.null(edges)) {
    return(NULL)
  }
  sapply(edges, `[[`, "id")
}

#' Get combos state of g6 instance
#'
#' @export
#' @rdname g6-state
#' @return A list of combos in the g6 instance.
g6_combos <- function(graph) {
  state <- g6_state(graph)
  if (is.null(state)) {
    return(NULL)
  }
  state$combos
}

#' Get combo ids of g6 instance
#'
#' @export
#' @rdname g6-state
#' @return A vector of combo ids in the g6 instance.
g6_combos_ids <- function(graph) {
  combos <- g6_combos(graph)
  if (is.null(combos)) {
    return(NULL)
  }
  sapply(combos, `[[`, "id")
}
