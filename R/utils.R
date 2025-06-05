#' @keywords internal
dropNulls <- function(x) {
  x[!vapply(x, is.null, FUN.VALUE = logical(1))]
}

g6_globals <- new.env()

#' @keywords internal
get_ids <- function() {
  get0("ids", envir = g6_globals, inherits = FALSE)
}

#' @keywords internal
add_id_to_globals <- function(id) {
  assign(
    "ids",
    c(get_ids(), id),
    envir = g6_globals,
    inherits = FALSE
  )
  invisible()
}

#' @keywords internal
df_to_list <- function(df) {
  df <- unname(split(df, seq(nrow(df))))
  lapply(df, function(row) {
    el <- as.list(row)
    el$id <- as.character(el$id)
    add_id_to_globals(el$id)
    el
  })
}

#' @keywords internal
convert_id_to_chr <- function(lst) {
  lapply(lst, function(el) {
    if (!is.character(el[["id"]])) {
      el[["id"]] <- as.character(el[["id"]])
    }
    add_id_to_globals(el$id)
    el
  })
}

#' @keywords internal
ensure_unique_ids <- function(ids) {
  duplicated <- any(duplicated(ids))
  if (duplicated) {
    stop("Some nodes, edges or combos ids are duplicated.")
  }
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
