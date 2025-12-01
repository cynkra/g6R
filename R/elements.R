#' G6 Graph Elements
#'
#' Constructors and validators for G6 node, edge, and combo elements.
#'
#' @param id Character. Unique identifier for the node or combo (required).
#' For edges, this is optional (id is constructed as source-target if not provided).
#' @param type Character. Element type (optional).
#' @param data List. Custom data for the element (optional).
#' @param style List. Element style (optional).
#' @param states Character vector. Initial states for the element (optional).
#' @param combo Character or NULL. Combo ID or parent combo ID (optional).
#' @param children Character vector. Child node IDs (optional, nodes only).
#' @param source Character. Source node ID (required, edges only).
#' @param target Character. Target node ID (required, edges only).
#' @param ... Additional arguments (unused).
#' the checks on source and target.
#'
#' @return An S3 object of class \code{g6_node}, \code{g6_edge}, or \code{g6_combo} (and \code{g6_element}).
#' @examples
#' # Create a node
#' node <- g6_node(
#'   id = "n1",
#'   type = "rect",
#'   data = list(label = "Node 1"),
#'   style = list(color = "red"),
#'   states = list("selected"),
#'   combo = NULL,
#'   children = c("n2", "n3")
#' )
#'
#' # Create an edge
#' edge <- g6_edge(
#'   source = "n1",
#'   target = "n2",
#'   type = "line",
#'   style = list(width = 2)
#' )
#'
#' # Create a combo
#' combo <- g6_combo(
#'   id = "combo1",
#'   type = "rect",
#'   data = list(label = "Combo 1"),
#'   style = list(border = "dashed"),
#'   states = list("active"),
#'   combo = NULL
#' )
#'
#' # Validate a node explicitly
#' validate_element(node)
#' @rdname g6_element
#' @export
g6_node <- function(
  id,
  type = NULL,
  data = NULL,
  style = NULL,
  states = NULL,
  combo = NULL,
  children = NULL
) {
  node <- dropNulls(list(
    id = id,
    type = type,
    data = data,
    style = style,
    states = states,
    combo = combo,
    children = children
  ))
  node <- structure(node, class = c("g6_node", "g6_element"))
  validate_element(node)
}

#' @rdname g6_element
#' @export
g6_edge <- function(
  source,
  target,
  id = paste(source, target, sep = "-"),
  type = NULL,
  data = NULL,
  style = NULL,
  states = NULL
) {
  edge <- dropNulls(list(
    source = source,
    target = target,
    id = id,
    type = type,
    data = data,
    style = style,
    states = states
  ))
  edge <- structure(edge, class = c("g6_edge", "g6_element"))
  validate_element(edge)
}

#' @keywords internal
#' @note To manage updating an edge
#' since source and target are not mandatory in that case.
g6_edge_update <- function(id, ...) {
  edge <- dropNulls(list(id = id, ...))
  edge <- structure(edge, class = c("g6_edge", "g6_element"), update = TRUE)
  validate_element(edge) # update validation
}

#' @rdname g6_element
#' @export
g6_combo <- function(
  id,
  type = NULL,
  data = NULL,
  style = NULL,
  states = NULL,
  combo = NULL
) {
  combo <- dropNulls(list(
    id = id,
    type = type,
    data = data,
    style = style,
    states = states,
    combo = combo
  ))
  combo <- structure(combo, class = c("g6_combo", "g6_element"))
  validate_element(combo)
}

#' Check if an object is a G6 element
#'
#' @rdname is_g6_element
#' @param x An object of class \code{g6_node}, \code{g6_edge}, or \code{g6_combo}.
#' @return Logical indicating if \code{x} is of the specified class.
#' @export
is_g6_node <- function(x) {
  inherits(x, "g6_node")
}

#' @rdname is_g6_element
#' @export
is_g6_edge <- function(x) {
  inherits(x, "g6_edge")
}

#' @rdname is_g6_element
#' @export
is_g6_combo <- function(x) {
  inherits(x, "g6_combo")
}

#' @rdname g6_element
#' @param x An object of class \code{g6_element},
#' \code{g6_node}, \code{g6_edge}, or \code{g6_combo}.
#' @export
validate_element <- function(x, ...) {
  UseMethod("validate_element")
}

#' @rdname g6_element
#' @export
validate_element.g6_element <- function(x, ...) {
  # id: character, length 1, non-empty
  if (
    !is.null(x$id) &&
      (length(x$id) != 1 || is.na(x$id) || x$id == "")
  ) {
    stop("'id' must be a non-empty character string if provided.")
  }
  # type: character, length 1
  if (!is.null(x$type) && (!is.character(x$type) || length(x$type) != 1)) {
    stop("'type' must be a character string if provided.")
  }
  # data: list
  if (!is.null(x$data) && !is.list(x$data)) {
    stop("'data' must be a list if provided.")
  }
  # style: list
  if (!is.null(x$style) && !is.list(x$style)) {
    stop("'style' must be a list if provided.")
  }

  is_unnamed_list <- function(x) {
    is.list(x) && (is.null(names(x)) || all(names(x) == ""))
  }

  # states: unnamed list
  if (!is.null(x$states) && !is_unnamed_list(x$states)) {
    stop("'states' must be an unnamed list if provided.")
  }
  x
}

#' @rdname g6_element
#' @export
validate_element.g6_node <- function(x, ...) {
  # Node-specific validation
  if (is.null(x$id)) {
    stop("Node 'id' is required.")
  }
  if (
    !is.null(x$combo) &&
      !(length(x$combo) == 1 || is.null(x$combo))
  ) {
    stop("Node 'combo' must be a character string or NULL.")
  }
  if (!is.null(x$children) && !is.character(x$children)) {
    stop("Node 'children' must be a character vector if provided.")
  }
  NextMethod()
}

#' @rdname g6_element
#' @export
validate_element.g6_edge <- function(x, ...) {
  # Skip source/target validation if updating
  if (isTRUE(attr(x, "update"))) {
    attributes(x)$update <- NULL
    return(NextMethod())
  }

  if (
    is.null(x$source) ||
      length(x$source) != 1 ||
      is.na(x$source) ||
      x$source == ""
  ) {
    stop("Edge 'source' is required and must be a non-empty character string.")
  }
  if (
    is.null(x$target) ||
      length(x$target) != 1 ||
      is.na(x$target) ||
      x$target == ""
  ) {
    stop("Edge 'target' is required and must be a non-empty character string.")
  }
  if (!is.null(x$id) && (!is.character(x$id) || length(x$id) != 1)) {
    stop("Edge 'id' must be a character string if provided.")
  }
  NextMethod()
}

#' @rdname g6_element
#' @export
validate_element.g6_combo <- function(x, ...) {
  # Combo-specific validation
  if (is.null(x$id)) {
    stop("Combo 'id' is required.")
  }
  if (
    !is.null(x$combo) &&
      !(length(x$combo) == 1 || is.null(x$combo))
  ) {
    stop("Combo 'combo' must be a character string or NULL.")
  }
  NextMethod()
}

#' Create and validate lists of G6 elements
#'
#' Constructors for lists of G6 node, edge, and combo elements.
#' Each function accepts multiple validated elements and returns a
#' list with the appropriate class.
#' All elements are validated on construction.
#'
#' @param ... One or more \code{g6_node}, \code{g6_edge}, or \code{g6_combo} objects.
#' @return An object of class \code{g6_nodes}, \code{g6_edges}, or \code{g6_combos}.
#' @examples
#' nodes <- g6_nodes(
#'   g6_node(id = "n1"),
#'   g6_node(id = "n2")
#' )
#' edges <- g6_edges(
#'   g6_edge(source = "n1", target = "n2")
#' )
#' combos <- g6_combos(
#'   g6_combo(id = "c1")
#' )
#' @rdname g6_elements
#' @export
g6_nodes <- function(...) {
  nodes <- structure(list(...), class = "g6_nodes")
  validate_elements(nodes)
}

#' @rdname g6_elements
#' @export
g6_edges <- function(...) {
  edges <- structure(list(...), class = "g6_edges")
  validate_elements(edges)
}

#' @rdname g6_elements
#' @export
g6_combos <- function(...) {
  combos <- structure(list(...), class = "g6_combos")
  validate_elements(combos)
}

#' Check if an object is a list of G6 elements
#'
#' @param x An object of class \code{g6_nodes}, \code{g6_edges}, or \code{g6_combos}.
#' @rdname is_g6_elements
#' @export
is_g6_nodes <- function(x) {
  inherits(x, "g6_nodes")
}

#' @rdname is_g6_elements
#' @export
is_g6_edges <- function(x) {
  inherits(x, "g6_edges")
}

#' @rdname is_g6_elements
#' @export
is_g6_combos <- function(x) {
  inherits(x, "g6_combos")
}

#' Validate a list of G6 elements
#'
#' S3 generic for validating lists of G6 elements.
#'
#' @param x An object of class \code{g6_nodes}, \code{g6_edges}, or \code{g6_combos}.
#' @param ... Additional arguments (unused).
#' @return Invisibly returns the validated object.
#' @rdname g6_elements
#' @export
validate_elements <- function(x, ...) {
  stopifnot(length(x) > 0)
  UseMethod("validate_elements")
}

#' @rdname g6_elements
#' @export
validate_elements.g6_nodes <- function(x, ...) {
  if (!all(lgl_ply(x, is_g6_node))) {
    stop("All elements must be of class 'g6_node'.")
  }
  x
}

#' @rdname g6_elements
#' @export
validate_elements.g6_edges <- function(x, ...) {
  if (!all(lgl_ply(x, is_g6_edge))) {
    stop("All elements must be of class 'g6_edge'.")
  }
  x
}

#' @rdname g6_elements
#' @export
validate_elements.g6_combos <- function(x, ...) {
  if (!all(lgl_ply(x, is_g6_combo))) {
    stop("All elements must be of class 'g6_combo'.")
  }
  x
}

#' Coerce to a g6 element object
#' @export
#' @param x An object to be coerced. List or g6 element are supported.
#' @param ... Additional arguments (unused).
#' @rdname as_g6_element
#' @return An element of class \code{g6_node}, \code{g6_edge}, or \code{g6_combo}.
as_g6_node <- function(x, ...) {
  UseMethod("as_g6_node")
}

#' @export
#' @rdname as_g6_element
as_g6_node.g6_node <- function(x, ...) {
  x
}

#' @export
#' @rdname as_g6_element
as_g6_node.list <- function(x, ...) {
  if ("combo" %in% names(x)) {
    # Drop nulls except for combo field
    node <- dropNulls(x, except = "combo")
    node <- structure(node, class = c("g6_node", "g6_element"))
    validate_element(node)
    return(node)
  }
  
  # Default behavior
  do.call(g6_node, x)
}

#' Coerce to a list of g6_elements objects
#' @export
#' @param x An object to be coerced. Data frame, list
#' or g6 element are supported.
#' @param ... Additional arguments (unused).
#' @rdname as_g6_elements
#' @return An object of class \code{g6_nodes}, \code{g6_edges}, or \code{g6_combos}.
as_g6_nodes <- function(x, ...) {
  UseMethod("as_g6_nodes")
}

#' @export
#' @rdname g6_elements
as_g6_nodes.g6_nodes <- function(x, ...) {
  x
}

#' @export
#' @rdname g6_elements
as_g6_nodes.data.frame <- function(x, ...) {
  lst <- unname(split(x, seq(nrow(x))))
  lst <- lapply(lst, as.list)
  as_g6_nodes(lst)
}

#' @export
#' @rdname g6_elements
as_g6_nodes.list <- function(x, ...) {
  nodes <- lapply(x, as_g6_node)
  structure(nodes, class = "g6_nodes")
}

#' @export
#' @rdname as_g6_element
as_g6_edge <- function(x, ...) {
  UseMethod("as_g6_edge")
}

#' @export
#' @rdname as_g6_element
as_g6_edge.g6_edge <- function(x, ...) {
  x
}

#' @export
#' @rdname as_g6_element
as_g6_edge.list <- function(x, ...) {
  if (!is.null(x$id) && is.null(x$source) && is.null(x$target)) {
    do.call(g6_edge_update, x)
  } else {
    do.call(g6_edge, x)
  }
}

#' @export
#' @rdname as_g6_elements
as_g6_edges <- function(x, ...) {
  UseMethod("as_g6_edges")
}

#' @export
#' @rdname as_g6_elements
as_g6_edges.g6_edges <- function(x, ...) {
  x
}

#' @export
#' @rdname as_g6_elements
as_g6_edges.data.frame <- function(x, ...) {
  lst <- unname(split(x, seq(nrow(x))))
  lst <- lapply(lst, as.list)
  as_g6_edges(lst)
}

#' @export
#' @rdname as_g6_elements
as_g6_edges.list <- function(x, ...) {
  edges <- lapply(x, as_g6_edge)
  structure(edges, class = "g6_edges")
}

#' @export
#' @rdname as_g6_element
as_g6_combo <- function(x, ...) {
  UseMethod("as_g6_combo")
}

#' @export
#' @rdname as_g6_element
as_g6_combo.g6_combo <- function(x, ...) {
  x
}

#' @export
#' @rdname as_g6_element
as_g6_combo.list <- function(x, ...) {
  if ("combo" %in% names(x)) {
    # Drop nulls except for combo field
    combo <- dropNulls(x, except = "combo")
    combo <- structure(combo, class = c("g6_combo", "g6_element"))
    validate_element(combo)
    return(combo)
  }
  do.call(g6_combo, x)
}

#' @export
#' @rdname as_g6_elements
as_g6_combos <- function(x, ...) {
  UseMethod("as_g6_combos")
}

#' @export
#' @rdname as_g6_elements
as_g6_combos.g6_combos <- function(x, ...) {
  x
}

#' @export
#' @rdname as_g6_elements
as_g6_combos.data.frame <- function(x, ...) {
  lst <- unname(split(x, seq(nrow(x))))
  lst <- lapply(lst, as.list)
  as_g6_combos(lst)
}

#' @export
#' @rdname as_g6_elements
as_g6_combos.list <- function(x, ...) {
  combos <- lapply(x, as_g6_combo)
  structure(combos, class = "g6_combos")
}

#' Create a g6_data object
#'
#' Create compatible data structure for [g6_add_data()], [g6_set_data()] or
#' simply [g6()].
#'
#' @param nodes Nodes data.
#' @param edges Edges data.
#' @param combos Combo data.
#' @param x A list with elements \code{nodes}, \code{edges}, and/or \code{combos}.
#' @param ... Additional arguments (unused).
#'
#' @export
#' @rdname g6_data
#' @return An object of class \code{g6_data}.
g6_data <- function(nodes = NULL, edges = NULL, combos = NULL) {
  dat <- list()

  if (!is.null(nodes)) {
    dat[["nodes"]] <- as_g6_nodes(nodes)
  }
  if (!is.null(edges)) {
    dat[["edges"]] <- as_g6_edges(edges)
  }
  if (!is.null(combos)) {
    dat[["combos"]] <- as_g6_combos(combos)
  }

  structure(dat, class = "g6_data")
}

#' Check if an object is a g6_data object
#'
#' @param x An object to check.
#' @return Logical indicating if \code{x} is of class \code{g6_data}.
#' @export
#' @rdname is_g6_data
is_g6_data <- function(x) {
  inherits(x, "g6_data")
}

#' Coerce to a g6_data object
#'
#' @export
#' @rdname g6_data
as_g6_data <- function(x, ...) {
  UseMethod("as_g6_data")
}

#' @export
#' @rdname g6_data
as_g6_data.g6_data <- function(x, ...) {
  x
}

#' @export
#' @rdname g6_data
as_g6_data.list <- function(x, ...) {
  g6_data(
    nodes = x$nodes,
    edges = x$edges,
    combos = x$combos
  )
}

#' @keywords internal
flatten_g6_elements <- function(el, max_depth = 2) {
  depth <- 1
  while (
    length(el) == 1 &&
      is.list(el[[1]]) &&
      is.null(names(el[[1]]))
  ) {
    el <- el[[1]]
    depth <- depth + 1
    if (depth > max_depth) {
      stop(
        "Input is too deeply nested. Please provide a 
        list of elements, not a list of lists of lists."
      )
    }
  }
  el
}

#' @keywords internal
as_g6_elements <- function(..., coerc_func) {
  el <- list(...)
  # If user passed a single data frame, use it directly
  if (length(el) == 1 && inherits(el[[1]], "data.frame")) {
    return(coerc_func(el[[1]]))
  }
  el <- flatten_g6_elements(el)
  coerc_func(el)
}
