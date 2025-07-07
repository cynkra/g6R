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
#' @export
g6_proxy <- function(id, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    stop(
      "g6_proxy must be called from the server function of a Shiny app."
    )
  }

  structure(
    list(id = id, session = session),
    class = "g6_proxy"
  )
}

#' @keywords internal
g6_data <- function(graph, el, action, type) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_add_* with g6 object. Only within shiny and using g6_proxy."
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

#' @keywords internal
g6_set <- function(graph, el, type) {
  g6_data(graph, el, action = "set", type = type)
}

#' @keywords internal
g6_get <- function(graph, el, type) {
  g6_data(graph, el, action = "get", type = type)
}

#' Get the state of nodes/edges/combos in a g6 graph via proxy
#'
#' This function gets the state of one or more nodes/edges/combos to an existing g6 graph instance
#' using a proxy object.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param nodes,edges,combos A string or character vector.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' If a node with the same ID already exists, it will not be added again.
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphgetnodedata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}
#' @rdname g6-get
#' @export
#' @examples
#'  if (interactive()) {
#'    library(shiny)
#'    library(bslib)
#'
#'     ui <- page_fluid(
#'       verbatimTextOutput("res"),
#'       g6Output("graph")
#'     )
#'
#'     server <- function(input, output, session) {
#'       output$graph <- renderG6({
#'         g6(
#'           nodes = data.frame(id = c("node1", "node2"))
#'         ) |>
#'           g6_options(animation = FALSE) |>
#'           g6_layout() |>
#'           g6_behaviors(click_select())
#'       })
#'
#'       # Send query to JS
#'       observeEvent(req(input[["graph-initialized"]]), {
#'         g6_proxy("graph") |> g6_get_nodes(c("node1", "node2"))
#'       })
#'
#'       # Recover query result inside input[["<GRAPH_ID>-<ELEMENT_ID>-state"]]
#'       output$res <- renderPrint({
#'         list(
#'           node1_state = input[["graph-node1-state"]],
#'           node2_state = input[["graph-node2-state"]]
#'         )
#'       })
#'     }
#'     shinyApp(ui, server)
#'  }
g6_get_nodes <- function(graph, nodes) {
  g6_get(graph, nodes, type = "Node")
}

#' @rdname g6-get
#' @export
g6_get_edges <- function(graph, edges) {
  g6_get(graph, edges, type = "Edge")
}

#' @rdname g6-get
#' @export
g6_get_combos <- function(graph, combos) {
  g6_get(graph, combos, type = "Combo")
}

#' Set the state of nodes/edges/combos in a g6 graph via proxy
#'
#' This function sets the state of one or more nodes/edges/combos to an existing g6 graph instance
#' using a proxy object. This allows updating the graph without completely
#' re-rendering it. Valid states are "selected", "active", "inactive", "disabled", or "highlight".
#'
#' \link{g6_set_data} allows to set all graph data at once (nodes, edges and combos).
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param nodes A key value pair list with the node id and its state.
#' @param edges A key value pair list with the edge id and its state.
#' @param combos A key value pair list with the combo id and its state.
#' @param data A nested list containing all nodes, edges and combo data.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' If a node with the same ID already exists, it will not be added again.
#' See \url{https://g6.antv.antgroup.com/en/api/element#graphsetelementstateid-state-options} for more details.
#'
#' @seealso \code{\link{g6_proxy}}
#' @rdname g6-set
#' @export
g6_set_nodes <- function(graph, nodes) {
  g6_set(graph, nodes, type = "Node")
}

#' @rdname g6-set
#' @export
g6_set_edges <- function(graph, edges) {
  g6_set(graph, edges, type = "Edge")
}

#' @rdname g6-set
#' @export
g6_set_combos <- function(graph, combos) {
  g6_set(graph, combos, type = "Combo")
}

#' @rdname g6-set
#' @export
g6_set_data <- function(graph, data) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_add_* with g6 object. Only within shiny and using g6_proxy."
    )
  }

  graph$session$sendCustomMessage(
    sprintf("%s_g6-data", graph$id),
    list(data = data, action = "set", type = "Data")
  )
  graph
}

#' Add nodes/edges/combos to a g6 graph via proxy
#'
#' This function adds one or more nodes/edges/combos to an existing g6 graph instance
#' using a proxy object. This allows updating the graph without completely
#' re-rendering it.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param nodes,edges,combos A data frame or list specifying the elements to be added.
#'   Elements structure must be compliant with specifications listed at
#' \url{https://g6.antv.antgroup.com/manual/element/overview}
#' @param data A nested list possibly containing nodes, edges and combo data.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' If a node with the same ID already exists, it will not be added again.
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphaddnodedata},
#' \url{https://g6.antv.antgroup.com/en/api/data#graphaddedgedata} and
#' \url{https://g6.antv.antgroup.com/en/api/data#graphaddcombodata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}, \code{\link{g6_remove_nodes}}
#' @rdname g6-add
#' @export
g6_add_nodes <- function(graph, nodes) {
  g6_add(graph, nodes, type = "Node")
}

#' @rdname g6-add
#' @export
g6_add_edges <- function(graph, edges) {
  g6_add(graph, edges, type = "Edge")
}

#' @rdname g6-add
#' @export
g6_add_combos <- function(graph, combos) {
  g6_add(graph, combos, type = "Combo")
}

#' @rdname g6-add
#' @export
g6_add_data <- function(graph, data) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_update_* with g6 object. Only within shiny and using g6_proxy."
    )
  }

  graph$session$sendCustomMessage(
    sprintf("%s_g6-data", graph$id),
    list(data = data, action = "add", type = "Data")
  )
  graph
}

#' Remove nodes/edge/combos from a g6 graph via proxy
#'
#' This function removes one or more nodes/edges/combos from an existing g6 graph instance
#' using a proxy object. This allows updating the graph without completely
#' re-rendering it.
#'
#' @note When a node is removed, its connected edges are also removed.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param ids Character vector or list containing the IDs of the nodes/edges/combos to be removed.
#' If a single ID is provided, it will be converted to a list internally. You can't mix
#' nodes, edges and combos ids, elements have to be of the same type.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphremovenodedata},
#' \url{https://g6.antv.antgroup.com/en/api/data#graphremoveedgedata} and
#' \url{https://g6.antv.antgroup.com/en/api/data#graphremovecombodata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}
#' @rdname g6-remove
#' @export
g6_remove_nodes <- function(graph, ids) {
  g6_remove(graph, ids, type = "Node")
}

#' @rdname g6-remove
#' @export
g6_remove_edges <- function(graph, ids) {
  g6_remove(graph, ids, type = "Edge")
}

#' @rdname g6-remove
#' @export
g6_remove_combos <- function(graph, ids) {
  g6_remove(graph, ids, type = "Combo")
}

#' Update nodes/edges/combos to a g6 graph via proxy
#'
#' This function updates one or more nodes/edges/combos to an existing g6 graph instance
#' using a proxy object. This allows updating the graph without completely
#' re-rendering it.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param nodes,edges,combos A data frame or list specifying
#' the nodes/edges/combos to be updated. All elements have to be of the same type,
#' you can't mix nodes with edges.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' See \url{https://g6.antv.antgroup.com/en/api/data#graphupdatenodedata},
#' \url{https://g6.antv.antgroup.com/en/api/data#graphupdateedgedata} and
#' \url{https://g6.antv.antgroup.com/en/api/data#graphupdatecombodata} for more details.
#'
#' @seealso \code{\link{g6_proxy}}, \code{\link{g6_remove_nodes}}
#' @rdname g6-update
#' @export
g6_update_nodes <- function(graph, nodes) {
  g6_update(graph, nodes, type = "Node")
}

#' @rdname g6-update
#' @export
g6_update_edges <- function(graph, edges) {
  g6_update(graph, edges, type = "Edge")
}

#' @rdname g6-update
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
      "Can't use g6_canvas_resize with g6 object. Only within shiny and using g6_proxy."
    )
  }

  graph$session$sendCustomMessage(
    sprintf("%s_g6-canvas-resize", graph$id),
    list(width = width, height = height)
  )
  graph
}

#' Center graph
#'
#' This function pans the graph to the center of the viewport
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
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
#' See \url{https://g6.antv.antgroup.com/en/api/viewport#graphfitcenteranimation} for more details.
#'
#' @seealso \code{\link{g6_proxy}}
#' @export
g6_fit_center <- function(graph, animation = NULL) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_fit_center with g6 object. Only within shiny and using g6_proxy."
    )
  }

  if (!is.null(animation)) {
    stopifnot(is.list(animation))
  }

  if (is.null(animation)) {
    animation <- list()
  }

  graph$session$sendCustomMessage(
    sprintf("%s_g6-fit-center", graph$id),
    animation
  )
  graph
}

#' @keywords internal
g6_element_action <- function(graph, ids, animation = NULL, action) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_*_element with g6 object. Only within shiny and using g6_proxy."
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

#' Hide/show elements in a g6 graph
#'
#' This function hides/shows specified elements (nodes, edges, or combos) in a g6 graph.
#' Hidden elements are removed from view but remain in the graph data structure.
#'
#' @param graph A g6 graph object or a g6_proxy object for Shiny applications.
#' @param ids Character vector specifying the IDs of elements to hide/show.
#'   Can include node IDs, edge IDs, or combo IDs.
#' @param animation Boolean to toggle animation.
#'
#' @return The modified g6 graph or g6_proxy object, allowing for method chaining.
#'
#' @details
#' When elements are hidden, they are removed from the visual display but still exist
#' in the underlying data structure. This means they can be shown again later using
#' \code{\link{g6_show_elements}} without having to recreate them.
#'
#' Hidden elements will not participate in layout calculations, which may cause other
#' elements to reposition. When elements are shown again, the graph
#' may recalculate layout positions, which can cause other elements to reposition.
#'
#' @seealso
#' \code{\link{g6_show_elements}}
#' @rdname g6-element-toggle
#' @export
g6_hide_elements <- function(graph, ids, animation = NULL) {
  g6_element_action(graph, ids, animation, action = "hide")
}

#' @rdname g6-element-toggle
#' @export
g6_show_elements <- function(graph, ids, animation = NULL) {
  g6_element_action(graph, ids, animation, action = "show")
}

#' @keywords internal
g6_combo_action <- function(graph, id, options = NULL, action) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_*_combo with g6 object. Use only within shiny and using g6_proxy."
    )
  }

  graph$session$sendCustomMessage(
    sprintf("%s_g6-combo-action", graph$id),
    list(id = id, options = options, action = action)
  )
  graph
}

#' Collapse or expand a combo element in a g6 graph
#'
#' This function collapses/expands a specified combo (a group of nodes) in a g6 graph,
#' hiding its member nodes and edges while maintaining the combo itself visible.
#' This is useful for simplifying complex graphs with multiple hierarchical groups.
#'
#' @param graph A g6 graph object or a g6_proxy object for Shiny applications.
#' @param id Character string specifying the ID of the combo to collapse/expand.
#' @param options List containing optional configuration parameters for the collapse/expand action:
#'   \itemize{
#'     \item \code{animate}: Logical value indicating whether to animate the collapsing process. Default is \code{TRUE}.
#'     \item \code{align}: Logical value to ensure the position of expanded/collapsed nodes remains unchanged.
#'   }
#'
#' @return The modified g6 graph or g6_proxy object, allowing for method chaining.
#'
#' @details
#' When a combo is collapsed, its member nodes and edges are hidden from view
#' while the combo itself remains visible, typically shown as a single node.
#' This helps to reduce visual complexity in large graphs with hierarchical groupings.
#'
#' @rdname g6-combo-action
#' @references \url{https://g6.antv.antgroup.com/en/api/element#graphcollapseelementid-options},
#' \url{https://g6.antv.antgroup.com/en/api/element#graphexpandelementid-options}
#' @export
g6_collapse_combo <- function(graph, id, options = NULL) {
  g6_combo_action(graph, id, options, action = "collapse")
}

#' @rdname g6-combo-action
#' @export
g6_expand_combo <- function(graph, id, options = NULL) {
  g6_combo_action(graph, id, options, action = "expand")
}

#' Set options for a g6 graph via proxy
#'
#' This function allows updating various configuration options of an existing g6 graph
#' instance using a proxy object within a Shiny application.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param ... Named arguments representing the options to update and their new values.
#'   These can include any valid g6 graph options such as fitView, animate, modes, etc.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' The function allows updating various graph options dynamically without having to
#' re-render the entire graph. This is useful for changing behavior, appearance,
#' or interaction modes in response to user input.
#'
#' @seealso \code{\link{g6_proxy}}
#' @export
g6_set_options <- function(graph, ...) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_*_combo with g6 object. Use only within shiny and using g6_proxy."
    )
  }
  # TBD: support JS wrapped options
  graph$session$sendCustomMessage(
    sprintf("%s_g6-set-options", graph$id),
    list(...)
  )
  graph
}

#' Update a plugin in a g6 graph via proxy
#'
#' This function allows updating the configuration of an existing plugin in a g6 graph
#' instance using a proxy object within a Shiny application.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param key Character string identifying the plugin to update.
#' @param ... Named arguments representing the plugin configuration options to update
#'   and their new values.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' The function allows dynamically updating the configuration of an existing plugin
#' without having to reinitialize it. This is useful for changing plugin behavior
#' or appearance in response to user interactions.
#'
#' @seealso \code{\link{g6_proxy}}, \code{\link{g6_add_plugin}}
#' @export
g6_update_plugin <- function(graph, key, ...) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_update_plugin with g6 object. Use only within shiny and using g6_proxy."
    )
  }
  opts <- list(key = key, ...)
  graph$session$sendCustomMessage(
    sprintf("%s_g6-update-plugin", graph$id),
    # Mark any element of options wrapped by htmlwidgets::JS
    # so it can be evaluated on the JS side.
    list(opts = opts, evals = JSEvals(opts))
  )
  graph
}

#' Add a plugin to a g6 graph via proxy
#'
#' This function adds one or more plugins to an existing g6 graph instance
#' using a proxy object within a Shiny application.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param ... Named arguments where each name is a plugin type and each value is a
#'   list of configuration options for that plugin.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' G6 plugins extend the functionality of the graph visualization with features like
#' minimaps, toolbar controls, contextual menus, and more. This function allows adding
#' these plugins dynamically after the graph has been initialized.
#'
#' @seealso \code{\link{g6_proxy}}, \code{\link{g6_update_plugin}}
#' @export
g6_add_plugin <- function(graph, ...) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_add_plugin with g6 object. Use only within shiny and using g6_proxy."
    )
  }
  # TBD: support JS wrapped options
  graph$session$sendCustomMessage(
    sprintf("%s_g6-add-plugin", graph$id),
    list(...)
  )
  graph
}

#' Update a behavior in a g6 graph via proxy
#'
#' This function allows updating the configuration of an existing behavior in a g6 graph
#' instance using a proxy object within a Shiny application.
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param key Character string identifying the behavior to update.
#' @param ... Named arguments representing the behavior configuration options to update
#'   and their new values.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#'
#' @details
#' This function can only be used with a g6_proxy object within a Shiny application.
#' It will not work with regular g6 objects outside of Shiny.
#'
#' Behaviors in G6 define how the graph responds to user interactions like dragging,
#' zooming, clicking, etc. This function allows dynamically updating the configuration
#' of these behaviors without having to reinitialize the graph.
#'
#' @seealso \code{\link{g6_proxy}}
#' @export
g6_update_behavior <- function(graph, key, ...) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_update_behavior with g6 object. Use only within shiny and using g6_proxy."
    )
  }
  opts <- list(key = key, ...)
  graph$session$sendCustomMessage(
    sprintf("%s_g6-update-behavior", graph$id),
    # Mark any element of options wrapped by htmlwidgets::JS
    # so it can be evaluated on the JS side.
    list(opts = opts, evals = JSEvals(opts))
  )
  graph
}

#' Set the theme for a g6 graph via proxy
#'
#' This function sets the theme for an existing g6 graph instance
#'
#' @param graph A g6_proxy object created with \code{\link{g6_proxy}}.
#' @param theme A character string representing the theme to apply to the graph.
#' There are 2 internal predefined themes: `light` and `dark`.
#' Alternatively, you can pass a custom theme object that conforms to the G6 theme specifications,
#' according to the documentation at \url{https://g6.antv.antgroup.com/en/manual/theme/custom-theme}.
#'
#' @return The g6_proxy object (invisibly), allowing for method chaining.
#' @seealso [g6_proxy()]
#' @export
g6_set_theme <- function(graph, theme) {
  if (!any(class(graph) %in% "g6_proxy")) {
    stop(
      "Can't use g6_set_theme with g6 object. Use only within shiny and using g6_proxy."
    )
  }
  graph$session$sendCustomMessage(
    sprintf("%s_g6-set-theme", graph$id),
    list(theme = theme)
  )
  graph
}
