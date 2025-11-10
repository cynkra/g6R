library(shiny)
library(bslib)
library(g6R)

nodes <- data.frame(id = 1:100)

# Set a seed for reproducibility
set.seed(123)

# Define the number of edges to create (e.g., 200 random connections)
num_edges <- 50

# Generate random edges
edges <- data.frame(
  source = sample(nodes$id, num_edges, replace = TRUE),
  target = sample(nodes$id, num_edges, replace = TRUE)
)

edges$id <- paste0(edges$source, edges$target)
duplicated_id <- which(duplicated(edges$id) == TRUE)
if (length(duplicated_id)) {
  edges <- edges[-duplicated_id, ]
}

ui <- page_fluid(
  actionButton("add_hull", "Add hull"),
  verbatimTextOutput("state"),
  g6Output("graph", height = "100vh"),
)

server <- function(input, output, session) {
  output$graph <- renderG6({
    g6(nodes, edges) |>
      g6_options(
        autoFit = "view",
        node = list(
          style = list(
            labelBackground = TRUE,
            labelBackgroundFill = '#FFB6C1',
            labelBackgroundRadius = 4,
            labelFontFamily = 'Arial',
            labelPadding = c(0, 4),
            labelText = JS(
              "(d) => {
                return d.id
              }"
            )
          )
        )
      ) |>
      g6_layout() |>
      g6_behaviors(
        "zoom-canvas",
        drag_element_force(),
        click_select(multiple = TRUE),
        brush_select(),
        create_edge()
      ) |>
      g6_plugins(
        "minimap",
        context_menu()
      )
  })

  observeEvent(input$add_hull, {
    g6_proxy("graph") |>
      g6_add_plugin(
        hull(
          members = sample(nodes$id, 10),
          fill = "#F08F56",
          stroke = "#F08F56",
          labelText = "hull-a",
          labelPlacement = "top",
          labelBackground = TRUE,
          labelPadding = 5
        )
      )
  })

  observeEvent(req(input[["graph-initialized"]]), {
    print("Graph initialized")
  })

  observeEvent(req(input[["graph-state"]]), {
    print("Graph changed")
  })

  output$state <- renderPrint({
    list(
      node = input[["graph-selected_node"]],
      edge = input[["graph-selected_edge"]],
      combo = input[["graph-selected_combo"]]
    )
  })
}

shinyApp(ui, server)
