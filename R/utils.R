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
JS <- function(...) {
  x <- c(...)
  if (is.null(x)) return()
  if (!is.character(x))
    stop("The arguments for JS() must be a character vector")
  x <- paste(x, collapse = "\n")
  structure(x, class = unique(c("JS_EVAL", oldClass(x))))
}

#' @keywords internal
is_js <- function(x) {
  inherits(x, "JS_EVAL")
}
