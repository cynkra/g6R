#' @keywords internal
dropNulls <- function(x) {
  x[!vapply(x, is.null, FUN.VALUE = logical(1))]
}

#' Marks as string to be processed as a JS function
#'
#' Useful for htmlwidgets
#'
#' @param ... Any valid JS element.
#'
#' @export
#' @return A character vector with class "JS_EVAL" that can be used in htmlwidgets
#' to mark is as a JavaScript function.
JS <- function(...) {
  x <- c(...)
  if (is.null(x)) {
    return()
  }
  if (!is.character(x)) {
    stop("The arguments for JS() must be a character vector")
  }
  x <- paste(x, collapse = "\n")
  structure(x, class = unique(c("JS_EVAL", oldClass(x))))
}

#' @keywords internal
is_js <- function(x) {
  inherits(x, "JS_EVAL")
}

#' @keywords internal
validate_component <- function(x, mode) {
  valid_choices <- switch(
    mode,
    "layout" = valid_layouts,
    "behavior" = valid_behaviors,
    "plugin" = valid_plugins
  )

  # Allow to pass behavior as text
  if (!is.list(x)) {
    # Call with default values
    if (x %in% names(valid_choices)) {
      x <- valid_choices[[x]]()
    } else {
      stop(sprintf(
        "'%s' is not a valid %s. Valid choices are: %s.",
        x,
        mode,
        paste(names(valid_choices), collapse = ", ")
      ))
    }
  } else {
    if (is.null(x[["type"]]) || !(x[["type"]] %in% names(valid_choices))) {
      stop(sprintf(
        "'%s' is not a valid %s. Valid choices are: %s.",
        if (is.null(x[["type"]])) "unknown" else x[["type"]],
        mode,
        paste(names(valid_choices), collapse = ", ")
      ))
    }
  }
  x
}
