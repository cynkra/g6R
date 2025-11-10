library(shiny)
library(bslib)
library(g6R)

nodes <- data.frame(id = as.character(1:10))

# Generate random edges
edges <- data.frame(
  source = c("2", "6", "7"),
  target = c("1", "3", "9")
)

ui <- page_fluid(
  actionButton("update", "Update plugin"),
  h6(
    class = "my-2",
    "Right click on an edge. Then, click on update and right click on an edge again."
  ),
  g6_output("graph")
)

server <- function(input, output, session) {
  output$graph <- render_g6({
    g6(nodes, edges) |>
      g6_options(animation = FALSE) |>
      g6_layout(d3_force_layout()) |>
      g6_plugins(
        context_menu()
      )
  })

  observeEvent(input$update, {
    g6_proxy("graph") |>
      g6_update_plugin(
        key = "contextmenu",
        getItems = JS(
          "() => {
        return [
          { name: 'plop', value: 'plop' }
        ];
      }"
        )
      )
  })
}

shinyApp(ui, server)
