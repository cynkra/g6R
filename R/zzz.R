shiny::registerInputHandler("g6R.brush_select", function(data, ...) {
  if (!length(data)) return(NULL)
  data <- unlist(data)
  attr(data, "eventType") <- "brush_select"
  data
}, force = TRUE)