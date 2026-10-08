# Content of HTML nodes, given as `g6_node(ui = )`.
#
# A node's `ui` is rendered to HTML here, in R, and travels to the browser
# apart from the node data: its markup in a map keyed by node id, its HTML
# dependencies with the widget (or the proxy message). The browser builds each
# node's content once from that markup and keeps it for the node's lifetime,
# so the node data itself, which g6 copies around on every update, stays small.
extract_node_ui <- function(nodes) {
  none <- list(nodes = nodes, html = NULL, deps = NULL)

  if (!length(nodes) || is.data.frame(nodes)) {
    return(none)
  }

  html <- list()
  deps <- list()

  for (i in seq_along(nodes)) {
    ui <- nodes[[i]][["ui"]]
    if (is.null(ui)) {
      next
    }
    rendered <- htmltools::renderTags(ui)
    html[[as.character(nodes[[i]][["id"]])]] <- as.character(rendered$html)
    deps <- c(deps, rendered$dependencies)
    nodes[[i]][["ui"]] <- NULL
  }

  if (!length(html)) {
    return(none)
  }

  list(
    nodes = nodes,
    html = html,
    deps = htmltools::resolveDependencies(deps)
  )
}
