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
reset_ids <- function() {
  assign("ids", NULL, envir = g6_globals)
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
process_g6_data <- function(dat, type) {
  if (!is.null(dat)) {
    attr(dat, "type") <- type
    if (inherits(dat, "data.frame")) {
      dat <- df_to_list(dat)
    } else {
      dat <- convert_id_to_chr(dat)
    }
  }
}

#' @keywords internal
df_to_list <- function(df) {
  lst <- unname(split(df, seq(nrow(df))))
  lapply(lst, function(row) {
    el <- as.list(row)
    if (attr(df, "type") == "edge") {
      el$id <- paste(el$source, el$target, sep = "-")
    } else {
      el$id <- as.character(el$id)
    }
    add_id_to_globals(el$id)
    el
  })
}

#' @keywords internal
convert_id_to_chr <- function(lst) {
  if (attr(lst, "type") == "edge") {
    lapply(lst, function(el) {
      if (is.null(el[["id"]])) {
        el[["id"]] <- paste(el[["source"]], el[["target"]], sep = "-")
      } else {
        if (!is.character(el[["id"]])) {
          el[["id"]] <- as.character(el[["id"]])
        }
      }
      add_id_to_globals(el[["id"]])
      el
    })
  } else {
    lapply(lst, function(el) {
      if (!is.character(el[["id"]])) {
        el[["id"]] <- as.character(el[["id"]])
      }
      add_id_to_globals(el[["id"]])
      el
    })
  }
}

#' @keywords internal
ensure_unique_ids <- function(ids) {
  duplicated <- which(duplicated(ids))
  if (length(duplicated)) {
    reset_ids()
    stop(
      sprintf(
        "issue in %s. Some nodes, edges or combos ids are duplicated: '%s'.",
        deparse(sys.call(which = -2)),
        paste(ids[duplicated], collapse = ", ")
      )
    )
  }
}

#' @keywords internal
check_if_in_graph <- function(el, graph) {
  all_ids <- c(g6_nodes_ids(graph), g6_edges_ids(graph), g6_combos_ids(graph))
  res <- which(!(el %in% all_ids))
  if (length(res)) {
    stop(
      sprintf(
        "issue in %s, target element(s) with id(s) '%s' not in the graph.",
        deparse(sys.call(which = -2)),
        paste(el[res], collapse = ", ")
      )
    )
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
