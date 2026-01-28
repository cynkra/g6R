#' Check if an object is a g6_port
#'
#' @param x An object to check.
#' @return Logical indicating if \code{x} is of class \code{g6_port}.
#' @examples
#' p <- g6_port("input-1", type = "input")
#' is_g6_port(p)
#' is_g6_port(list(key = "input-1", type = "input"))
#' is_g6_port(as_g6_port(list(key = "input-1", type = "input")))
#' @export
#' @rdname is_g6_port
is_g6_port <- function(x) {
  inherits(x, "g6_port")
}

#' @export
#' @rdname is_g6_port
#' @examples
#' is_g6_ports(g6_ports(
#'   g6_port("input-1", type = "input"),
#'   g6_port("output-1", type = "output")
#' ))
is_g6_ports <- function(x) {
  inherits(x, "g6_ports")
}

#' Create a G6 Port
#'
#' @param key Character. Unique identifier for the port (required).
#' @param label Character. Label text for the port (optional).
#' @param type Character. Either "input" or "output" (required).
#' @param arity Numeric. Maximum number of
#' connections this port can accept (default: 1).
#' Use 0, Inf, or any non-negative integer.
#' @param visibility Character. Controls port visibility behavior:
#' \itemize{
#'   \item \code{"visible"}: Ports are always shown (default).
#'   \item \code{"hover"}: Ports appear only when hovering over the node.
#'   \item \code{"hidden"}: Ports are never visible.
#' }
#' @param ... Additional port style parameters. See
#' \url{https://g6.antv.antgroup.com/en/manual/element/node/base-node#portstyleprops}.
#' @return An S3 object of class 'g6_port'.
#' @examples
#' g6_port("input-1", label = "port 1", type = "input", arity = 2, placement = "left")
#' g6_port("output-1", label = "port 2", type = "output", placement = "right")
#' g6_port("input-2", type = "input", visibility = "hover")
#' @export
g6_port <- function(
  key,
  label = NULL,
  type = c("input", "output"),
  arity = 1,
  visibility = c("visible", "hover", "hidden"),
  ...
) {
  type <- match.arg(type)
  visibility <- match.arg(visibility)
  port <- structure(
    c(
      list(
        key = key,
        type = type,
        arity = arity,
        visibility = visibility
      ),
      if (!is.null(label)) list(label = label),
      list(...)
    ),
    class = "g6_port"
  )
  validate_port(port)
}

#' Create a single-connection input port
#' @export
#' @param fill Character. Color of the port
#' (default: "#52C41A" for input ports,
#' "#FF4D4F" for output ports).
#' @rdname g6_port
#' @note To create an (input/output) port with multiple connections,
#' simply set the arity to \code{Inf} or any positive integer.
g6_input_port <- function(
  key,
  label = NULL,
  arity = 1,
  visibility = c("visible", "hover", "hidden"),
  fill = "#52C41A",
  ...
) {
  visibility <- match.arg(visibility)
  g6_port(
    key = key,
    label = label,
    type = "input",
    arity = arity,
    visibility = visibility,
    fill = fill,
    ...
  )
}

#' Create an output port (single connection by default)
#' @export
#' @rdname g6_port
g6_output_port <- function(
  key,
  label = NULL,
  arity = 1,
  visibility = c("visible", "hover", "hidden"),
  fill = "#FF4D4F",
  ...
) {
  visibility <- match.arg(visibility)
  g6_port(
    key = key,
    label = label,
    type = "output",
    arity = arity,
    visibility = visibility,
    fill = fill,
    ...
  )
}

#' Validate a single G6 port
#'
#' @param x An object of class 'g6_port'.
#' @param ... Generic consistency.
#' @return The validated port (invisibly).
#' @examples
#' validate_port(g6_port("input-1", type = "input"))
#' @export
validate_port <- function(x, ...) {
  UseMethod("validate_port")
}

#' @rdname validate_port
#' @export
validate_port.g6_port <- function(x, ...) {
  if (
    !is.character(x$key) ||
      length(x$key) != 1 ||
      is.na(x$key) ||
      x$key == ""
  ) {
    stop("'key' must be a non-empty character string.")
  }

  # Avoid issues with JSON conversion of Inf
  if (is.infinite(x$arity) || identical(x$arity, "Infinity")) {
    x$arity <- "Infinity"
  } else {
    if (
      !is.numeric(x$arity) ||
        length(x$arity) != 1 ||
        is.na(x$arity) ||
        x$arity < 0
    ) {
      stop(
        "'arity' must be a single non-negative number (0, Inf, or positive integer)."
      )
    }
  }

  # Ensure ports are displayed: doc says
  # If set to undefined, the port is treated as a point,
  # not displayed on canvas. Default is set to 4.
  if (is.null(x[["r"]])) {
    x[["r"]] <- 4
  } else {
    if (
      !is.numeric(x[["r"]]) ||
        length(x[["r"]]) != 1 ||
        is.na(x[["r"]]) ||
        x[["r"]] <= 0
    ) {
      stop("'r' (radius) must be a single positive number.")
    }
  }

  # Ensure ports are on the node border (avoids 0.5/0.5)
  placement <- x$placement
  if (is.numeric(placement) && length(placement) == 2) {
    # Must be on an edge: at least one value is exactly 0 or 1
    if (!any(placement == 0 | placement == 1)) {
      stop(
        "Invalid port placement: when placement is a numeric vector, at least one value must be 0 or 1 (i.e., on the node edge). ",
        "You supplied: c(",
        paste(placement, collapse = ", "),
        ")"
      )
    }
  }
  x
}

#' Create a List of G6 Ports
#'
#' @param ... One or more g6_port objects.
#' @return An S3 object of class 'g6_ports'.
#' @examples
#' g6_ports(
#'   g6_port("input-1", type = "input", placement = "left"),
#'   g6_port("output-1", type = "output", placement = "right")
#' )
#' @export
g6_ports <- function(...) {
  ports <- list(...)
  validate_ports(ports)
  structure(ports, class = "g6_ports")
}

#' Validate a list of G6 ports
#'
#' @param x A list of g6_port objects.
#' @param ... Generic consistency.
#' @return The validated list (invisibly).
#' @examples
#' validate_ports(list(
#'   g6_port("input-1", type = "input"),
#'   g6_port("output-1", type = "output")
#' ))
#' @export
validate_ports <- function(x, ...) {
  UseMethod("validate_ports")
}

#' @rdname validate_ports
#' @export
validate_ports.list <- function(x, ...) {
  if (length(x) == 0) {
    stop("No ports provided.")
  }
  if (!all(lgl_ply(x, is_g6_port))) {
    stop("All elements must be of class 'g6_port'.")
  }
  keys <- vapply(x, function(p) p$key, character(1))
  if (anyDuplicated(keys)) {
    stop(
      "All port 'key' values must be unique. Duplicates: ",
      paste(unique(keys[duplicated(keys)]), collapse = ", ")
    )
  }
  invisible(x)
}

#' @rdname validate_ports
#' @export
validate_ports.g6_ports <- function(x, ...) {
  validate_ports.list(x, ...)
}

#' Coerce to a g6_port object
#'
#' @param x An object to coerce.
#' @param ... Additional arguments (unused).
#' @return An object of class \code{g6_port}.
#' @examples
#' as_g6_port(list(key = "input-1", type = "input", placement = "left"))
#' as_g6_port(g6_port("input-1", type = "input"))
#' @export
as_g6_port <- function(x, ...) {
  UseMethod("as_g6_port")
}

#' @rdname as_g6_port
#' @export
as_g6_port.g6_port <- function(x, ...) {
  x
}

#' @rdname as_g6_port
#' @export
as_g6_port.list <- function(x, ...) {
  port_ctor <- g6_port
  if (length(x[["type"]])) {
    port_ctor <- switch(
      x[["type"]],
      "input" = g6_input_port,
      "output" = g6_output_port
    )
    x[["type"]] <- NULL
  }
  do.call(port_ctor, x)
}

#' Coerce to a list of g6_port objects (g6_ports)
#'
#' @param x An object to coerce.
#' @param ... Additional arguments (unused).
#' @return An object of class \code{g6_ports}.
#' @examples
#' as_g6_ports(list(
#'   list(key = "input-1", type = "input", placement = "left"),
#'   list(key = "output-1", type = "output", placement = "right")
#' ))
#' as_g6_ports(g6_ports(
#'   g6_port("input-1", type = "input"),
#'   g6_port("output-1", type = "output")
#' ))
#' @export
as_g6_ports <- function(x, ...) {
  UseMethod("as_g6_ports")
}

#' @rdname as_g6_ports
#' @export
as_g6_ports.g6_ports <- function(x, ...) {
  x
}

#' @rdname as_g6_ports
#' @export
as_g6_ports.list <- function(x, ...) {
  ports <- lapply(x, as_g6_port)
  do.call(g6_ports, ports)
}

extract_port_field <- function(nodes, field) {
  unlist(
    lapply(nodes, function(node) {
      ports <- node$style$ports
      if (is.null(ports) || length(ports) == 0) {
        return(NULL)
      }
      vapply(ports, function(port) port[[field]], character(1))
    }),
    use.names = FALSE
  )
}

#' Validate that all edges connect input/output ports
#'
#' @param nodes List of g6_node objects.
#' @param edges List of g6_edge objects.
#' @return Invisibly TRUE if all edges are valid, otherwise stops with an error.
#' @export
validate_edges_ports <- function(edges, nodes) {
  keys <- extract_port_field(nodes, "key")
  types <- extract_port_field(nodes, "type")
  port_types <- setNames(types, keys)

  if (length(port_types) == 0) {
    return(invisible(TRUE))
  }

  source_ports <- vapply(
    edges,
    function(e) e$style$sourcePort,
    character(1)
  )
  target_ports <- vapply(
    edges,
    function(e) e$style$targetPort,
    character(1)
  )

  if (length(source_ports) == 0 || length(target_ports) == 0) {
    return(invisible(TRUE))
  }

  type1 <- port_types[source_ports]
  type2 <- port_types[target_ports]

  if (anyNA(type1) || anyNA(type2)) {
    stop("Edge refers to unknown port key.")
  }

  same_type <- type1 == type2
  if (any(same_type)) {
    idx <- which(same_type)[1]
    stop(
      sprintf(
        "Invalid edge: cannot connect two '%s' ports ('%s' <-> '%s').",
        type1[idx],
        source_ports[idx],
        target_ports[idx]
      )
    )
  }

  invisible(TRUE)
}
