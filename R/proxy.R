#' Create a proxy object to modify an existing g6 graph instance
#'
#' This function creates a proxy object that can be used to update an existing g6 graph
#' instance after it has been rendered in the UI. The proxy allows for server-side
#' modifications of the graph without completely re-rendering it.
#'
#' @param id Character string matching the ID of the g6 graph instance to be modified.
#' @param session The Shiny session object within which the graph exists.
#'   By default, this uses the current reactive domain.
#'
#' @return A proxy object of class "g6_proxy" that can be used with g6 proxy methods
#'   such as `g6_add_nodes()`, `g6_remove_nodes()`, etc.
#'
#' @details
#' This function must be called from within a Shiny server function. The returned
#' proxy object contains a reference to the session and the ID of the graph to be
#' modified.
#'
#' @export
g6_proxy <- function(id, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    stop(
      "g6_proxy must be called from the server function of a Shiny app"
    )
  }

  structure(
    list(id = id, session = session),
    class = "g6_proxy"
  )
}

#' Add nodes to a g6 graph via proxy
#'
#' This function adds one or more nodes to an existing g6 graph instance
#' using a proxy object. This allows updating the graph without completely
#' re-rendering it.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param nodes A data frame or list specifying the nodes to be added.
#'   If a data frame is provided, each row will be converted to a node.
#'   Each node should have at least an 'id' field, and may include other attributes
#'   such as 'label', 'style', 'x', 'y', etc. based on G6 node specifications.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' If a node with the same ID already exists, it will not be added again.
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphaddnodedata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}, \code{\link{g6_remove_nodes}}
#' @export
g6_add_nodes <- function(graph, nodes) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_add_nodes with g6 object. Only within shiny & using g6_proxy"
    )
  }

  if (inherits(nodes, "data.frame")) {
    nodes <- lapply(seq_len(nrow(nodes)), \(i) {
      setNames(as.list(nodes[i, ]), colnames(nodes))
    })
  }

  graph$session$sendCustomMessage(sprintf("%s_g6-add-nodes", graph$id), nodes)
  graph
}

#' Add edges to a g6 graph via proxy
#'
#' This function adds one or more edges to an existing g6 graph instance
#' using a proxy object. This allows updating the graph without completely
#' re-rendering it.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param edges A data frame or list specifying the edges to be added.
#'   If a data frame is provided, each row will be converted to an edge.
#'   Each edge should have at least an 'id' field, and may include other attributes
#'   such as 'label', 'style', 'x', 'y', etc. based on G6 edge specifications.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' If a node with the same ID already exists, it will not be added again.
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphaddnodedata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}, \code{\link{g6_remove_edges}}
#' @export
g6_add_edges <- function(graph, edges) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_add_edges with g6 object. Only within shiny & using g6_proxy"
    )
  }

  if (inherits(edges, "data.frame")) {
    edges <- lapply(seq_len(nrow(edges)), \(i) {
      setNames(as.list(edges[i, ]), colnames(edges))
    })
  }

  graph$session$sendCustomMessage(sprintf("%s_g6-add-edges", graph$id), edges)
  graph
}

#' Add combos to a g6 graph via proxy
#'
#' This function adds one or more combos to an existing g6 graph instance
#' using a proxy object. This allows updating the graph without completely
#' re-rendering it.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param combos A data frame or list specifying the combos to be added.
#'   If a data frame is provided, each row will be converted to an combo.
#'   Each combo should have at least an 'id' field, and may include other attributes
#'   such as 'label', 'style', 'x', 'y', etc. based on G6 combo specifications.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' If a node with the same ID already exists, it will not be added again.
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphaddnodedata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}, \code{\link{g6_remove_combos}}
#' @export
g6_add_combos <- function(graph, combos) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_add_combos with g6 object. Only within shiny & using g6_proxy"
    )
  }

  if (inherits(combos, "data.frame")) {
    combos <- lapply(seq_len(nrow(combos)), \(i) {
      setNames(as.list(combos[i, ]), colnames(combos))
    })
  }

  graph$session$sendCustomMessage(sprintf("%s_g6-add-combos", graph$id), combos)
  graph
}

#' Remove nodes from a g6 graph via proxy
#'
#' This function removes one or more nodes from an existing g6 graph instance
#' using a proxy object. This allows updating the graph without completely
#' re-rendering it. When a node is removed, its connected edges are also removed.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param ids Character vector or list containing the IDs of the nodes to be removed.
#'   If a single ID is provided, it will be converted to a list internally.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' Under the hood, this function uses the G6 removeNode method, which
#' removes the specified node and all its related edges from the graph.
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphremovenodedata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}
#' @export
g6_remove_nodes <- function(graph, ids) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_remove_nodes with g6 object. Only within shiny & using g6_proxy"
    )
  }

  if (!is.null(ids)) {
    if (length(ids) == 1) {
      ids <- list(ids)
    }
  }

  graph$session$sendCustomMessage(sprintf("%s_g6-remove-nodes", graph$id), ids)
  graph
}

#' Remove edges from a g6 graph via proxy
#'
#' This function removes one or more edges from an existing g6 graph instance
#' using a proxy object. This allows updating the graph without completely
#' re-rendering it. When a edge is removed, its connected edges are also removed.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param ids Character vector or list containing the IDs of the edges to be removed.
#'   If a single ID is provided, it will be converted to a list internally.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' Under the hood, this function uses the G6 removeNode method, which
#' removes the specified node and all its related edges from the graph.
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphremoveedgedata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}
#' @export
g6_remove_edges <- function(graph, ids) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_remove_edges with g6 object. Only within shiny & using g6_proxy"
    )
  }

  if (!is.null(ids)) {
    if (length(ids) == 1) {
      ids <- list(ids)
    }
  }

  graph$session$sendCustomMessage(sprintf("%s_g6-remove-edges", graph$id), ids)
  graph
}

#' Remove combos from a g6 graph via proxy
#'
#' This function removes one or more combos from an existing g6 graph instance
#' using a proxy object. This allows updating the graph without completely
#' re-rendering it. When a combo is removed, its connected combos are also removed.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param ids Character vector or list containing the IDs of the combos to be removed.
#'   If a single ID is provided, it will be converted to a list internally.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' Under the hood, this function uses the G6 removeNode method, which
#' removes the specified node and all its related combos from the graph.
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphremovecombodata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}
#' @export
g6_remove_combos <- function(graph, ids) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_remove_combos with g6 object. Only within shiny & using g6_proxy"
    )
  }

  if (!is.null(ids)) {
    if (length(ids) == 1) {
      ids <- list(ids)
    }
  }

  graph$session$sendCustomMessage(sprintf("%s_g6-remove-combos", graph$id), ids)
  graph
}

#' Update nodes to a g6 graph via proxy
#'
#' This function updates one or more nodes to an existing g6 graph instance
#' using a proxy object. This allows updating the graph without completely
#' re-rendering it.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param nodes A data frame or list specifying the nodes to be updated.
#'   If a data frame is provided, each row will be converted to a node.
#'   Each node should have at least an 'id' field, and may include other attributes
#'   such as 'label', 'style', 'x', 'y', etc. based on G6 node specifications.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' If a node with the same ID already exists, it will not be added again.
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphaddnodedata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}, \code{\link{g6_remove_nodes}}
#' @export
g6_update_nodes <- function(graph, nodes) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_add_nodes with g6 object. Only within shiny & using g6_proxy"
    )
  }

  if (inherits(nodes, "data.frame")) {
    nodes <- lapply(seq_len(nrow(nodes)), \(i) {
      setNames(as.list(nodes[i, ]), colnames(nodes))
    })
  }

  graph$session$sendCustomMessage(
    sprintf("%s_g6-update-nodes", graph$id),
    nodes
  )
  graph
}
