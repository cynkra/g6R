# Does a layout configuration carry a JS() value anywhere? A configuration
# built entirely from plain R values is JSON-serialisable, so it survives a
# save / restore round-trip; one holding a JS() callback does not.
has_js_value <- function(x) {
  if (is_js(x)) {
    return(TRUE)
  }
  if (is.list(x)) {
    return(any(vapply(x, has_js_value, logical(1))))
  }
  FALSE
}
