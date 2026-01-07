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
is_g6_port <- function(x) {
  inherits(x, "g6_port")
}

#' Create a G6 Port
#'
#' @param key Character. Unique identifier for the port (required).
#' @param type Character. Either "input" or "output" (required).
#' @param arity Numeric. Maximum number of
#' connections this port can accept (default: 1).
#' Use 0, Inf, or any non-negative integer.
#' @param showGuides Logical. Whether to show connection
#' guides when hovering over the port (default: TRUE).
#' @param ... Additional port style parameters. See
#' \url{https://g6.antv.antgroup.com/en/manual/element/node/base-node#portstyleprops}.
#' @return An S3 object of class 'g6_port'.
#' @examples
#' g6_port("input-1", type = "input", arity = 2, placement = "left")
#' g6_port("output-1", type = "output", placement = "right")
#' @export
g6_port <- function(
  key,
  type = c("input", "output"),
  arity = 1,
  showGuides = TRUE,
  ...
) {
  type <- match.arg(type)
  port <- structure(
    c(
      list(
        key = key,
        type = type,
        arity = arity,
        showGuides = showGuides
      ),
      list(...)
    ),
    class = "g6_port"
  )
  validate_port(port)
}

#' Validate a single G6 port
#'
#' @param x An object of class 'g6_port'.
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
    !is.character(x$key) || length(x$key) != 1 || is.na(x$key) || x$key == ""
  ) {
    stop("'key' must be a non-empty character string.")
  }
  if (!(x$type %in% c("input", "output"))) {
    stop("'type' must be either 'input' or 'output'.")
  }
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
  do.call(g6_port, x)
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
