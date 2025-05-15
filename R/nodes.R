g6_node <- function(
  id,
  combo = NULL,
  type = c("circle"),
  data = list(),
  style = list(),
  states = NULL,
  ...
) {
  dropNulls(
    list(
      id = id,
      combo = combo,
      type = match.arg(type),
      data = data,
      style = style,
      states = states,
      ...
    )
  )
}

g6_edge <- function(
  source,
  target,
  id = NULL,
  type = "line",
  data = list(),
  style = list(),
  states = NULL,
  ...
) {
}


g6_combo <- function(
  id,
  combo = NULL,
  type = "circle",
  data = list(),
  style = list(),
  states = NULL,
  ...
) {
}
