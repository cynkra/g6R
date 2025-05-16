library(shiny)
library(bslib)
library(shinyG6)

nodes <- list(
  list(id = "node1"),
  list(id = "node2")
)

edges <- list(list(source = "node1", target = "node2"))

ui <- page_fluid(
  g6Output("graph")
)

server <- function(input, output, session) {
  output$graph <- renderG6({
    g6(nodes, edges, options = list(theme = "dark"))
  })

  observe({
    print(input[["graph-selected_node"]])
    print(input[["graph-selected_edge"]])
  })
}

shinyApp(ui, server)
