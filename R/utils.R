dropNulls <- function(x) {
  x[!vapply(x, is.null, FUN.VALUE = logical(1))]
}

is_js <- function(x) {
  inherits(x, "JS_EVAL")
}
