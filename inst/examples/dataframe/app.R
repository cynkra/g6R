library(shiny)
library(bslib)
library(g6R)

nodes <- data.frame(
  id = as.character(1:100),
  label = as.character(1:100)
)

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
  g6Output("graph", height = "100vh")
)

server <- function(input, output, session) {
  output$graph <- renderG6({
    g6(nodes, edges) |>
      g6_options(
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
      g6_layout(
        #layout = list(
        #  type = "force-atlas2",
        #  preventOverlap = TRUE,
        #  r = 20,
        #  center = c(250, 250)
        #),
        layout = list(
          type = "d3-force",
          link = list(
            distance = 100,
            strength = 2
          ),
          collide = list(radius = 40)
        )
      ) |>
      g6_behaviors(
        "zoom-canvas",
        drag_element_force(fixed = TRUE),
        click_select(
          #multiple = TRUE,
          onClick = JS(
            "(e) => {
            console.log(e);
          }"
          )
        ),
        brush_select(
          onSelect = JS(
            "(states) => {
            return console.log(states);
          }"
          )
        )
      ) |>
      g6_plugins(
        "minimap",
        "tooltip"
      )
  })

  observeEvent(TRUE, {
    browser()
    g6_proxy("graph") |>
      g6_add_plugin(
        hull(
          members = sample(nodes$id, 10),
          labelText = "hull-a",
          labelPlacement = "top",
          labelBackground = TRUE,
          labelPadding = 5
        )
      )
  })

  observe({
    print(input[["graph-selected_node"]])
    print(input[["graph-selected_edge"]])
  })
}

shinyApp(ui, server)
