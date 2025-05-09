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
}

shinyApp(ui, server)
