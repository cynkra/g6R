library(shiny)
library(bslib)
library(shinyG6)

ui <- page_fluid(
  g6Output("graph")
)

server <- function(input, output, session) {
  output$graph <- renderG6({
    g6("plop")
  })

  observe({
    print(input[["graph-selected_node"]])
    print(input[["graph-selected_edge"]])
  })
}

shinyApp(ui, server)
