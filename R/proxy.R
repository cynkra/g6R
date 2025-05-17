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

g6_data <- function(graph, el, action, type) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_add_* with g6 object. Only within shiny and using g6_proxy"
    )
  }
  if (action != "remove") {
    if (inherits(el, "data.frame")) {
      el <- lapply(seq_len(nrow(el)), \(i) {
        setNames(as.list(el[i, ]), colnames(el))
      })
    }
  } else {
    if (!is.null(el)) {
      if (length(el) == 1) {
        el <- list(el)
      }
    }
  }

  graph$session$sendCustomMessage(
    sprintf("%s_g6-data", graph$id),
    list(el = el, action = action, type = type)
  )
  graph
}

#' @keywords internal
g6_add <- function(graph, el, type) {
  g6_data(graph, el, action = "add", type = type)
}

#' @keywords internal
g6_remove <- function(graph, el, type) {
  g6_data(graph, el, action = "remove", type = type)
}

#' @keywords internal
g6_update <- function(graph, el, type) {
  g6_data(graph, el, action = "update", type = type)
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
  g6_add(graph, nodes, type = "Node")
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
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphaddedgedata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}, \code{\link{g6_remove_edges}}
#' @export
g6_add_edges <- function(graph, edges) {
  g6_add(graph, edges, type = "Edge")
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
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphaddcombodata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}, \code{\link{g6_remove_combos}}
#' @export
g6_add_combos <- function(graph, combos) {
  g6_add(graph, combos, type = "Combo")
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
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphremovenodedata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}
#' @export
g6_remove_nodes <- function(graph, ids) {
  g6_remove(graph, ids, type = "Node")
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
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphremoveedgedata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}
#' @export
g6_remove_edges <- function(graph, ids) {
  g6_remove(graph, ids, type = "Edge")
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
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphremovecombodata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}
#' @export
g6_remove_combos <- function(graph, ids) {
  g6_remove(graph, ids, type = "Combo")
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
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphupdatenodedata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}, \code{\link{g6_remove_nodes}}
#' @export
g6_update_nodes <- function(graph, nodes) {
  g6_update(graph, nodes, type = "Node")
}

#' Update edges to a g6 graph via proxy
#'
#' This function updates one or more edges to an existing g6 graph instance
#' using a proxy object. This allows updating the graph without completely
#' re-rendering it.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param edges A data frame or list specifying the edges to be updated.
#'   If a data frame is provided, each row will be converted to a edge.
#'   Each edge should have at least an 'id' field, and may include other attributes
#'   such as 'label', 'style', 'x', 'y', etc. based on G6 edge specifications.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphupdateedgedata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}, \code{\link{g6_remove_nodes}}
#' @export
g6_update_edges <- function(graph, edges) {
  g6_update(graph, edges, type = "Edge")
}

#' Update combos to a g6 graph via proxy
#'
#' This function updates one or more combos to an existing g6 graph instance
#' using a proxy object. This allows updating the graph without completely
#' re-rendering it.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param combos A data frame or list specifying the combos to be updated.
#'   If a data frame is provided, each row will be converted to a combo.
#'   Each combo should have at least an 'id' field, and may include other attributes
#'   such as 'label', 'style', 'x', 'y', etc. based on G6 combo specifications.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphupdatecombodata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}, \code{\link{g6_remove_nodes}}
#' @export
g6_update_combos <- function(graph, combos) {
  g6_update(graph, combos, type = "Combo")
}

#' Resize the canvas of a g6 graph via proxy
#'
#' This function changes the size of the canvas of an existing g6 graph instance
#' using a proxy object. This allows updating the graph dimensions without completely
#' re-rendering it.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param width Numeric value specifying the new width of the canvas in pixels.
#' @param height Numeric value specifying the new height of the canvas in pixels.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' See \url{https://g6.antv.antgroup.com/en/api/canvas#graphsetsizewidth-height} for more details.
#'
#' @seealso \code{\link{g6_proxy}}
#' @export
g6_canvas_resize <- function(graph, width, height) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_canvas_resize with g6 object. Only within shiny and using g6_proxy"
    )
  }

  graph$session$sendCustomMessage(
    sprintf("%s_g6-canvas-resize", graph$id),
    list(width = width, height = height)
  )
  graph
}

#' @keywords internal
g6_element_action <- function(graph, ids, animation = NULL, action) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_focus_element with g6 object. Only within shiny and using g6_proxy"
    )
  }

  graph$session$sendCustomMessage(
    sprintf("%s_g6-element-action", graph$id),
    list(ids = ids, animation = animation, action = action)
  )
  graph
}

#' Focus on specific elements in a g6 graph via proxy
#'
#' This function focuses on one or more elements (nodes/edges) in an existing g6 graph instance
#' using a proxy object. It highlights the specified elements and can optionally
#' animate the view to focus on them.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param ids Character vector containing the IDs of the elements (nodes/edges) to focus on.
#' @param animation Optional list containing animation configuration parameters for the focus action.
#'   Common parameters include:
#'   \itemize{
#'     \item \code{duration}: Duration of the animation in milliseconds.
#'     \item \code{easing}: Animation easing function name (e.g., "ease-in", "ease-out").
#'   }
#'   If NULL, no animation will be applied.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' See \url{https://g6.antv.antgroup.com/en/api/element#graphfocuselementid-animation} for more details.
#'
#' @seealso \code{\link{g6_proxy}}
#' @export
g6_focus_elements <- function(graph, ids, animation = NULL) {
  g6_element_action(graph, ids, animation, action = "focus")
}

g6_hide_elements <- function(graph, ids, animation = NULL) {
  g6_element_action(graph, ids, animation, action = "hide")
}

g6_show_elements <- function(graph, ids, animation = NULL) {
  g6_element_action(graph, ids, animation, action = "show")
}
