library(shiny)
library(bslib)
library(g6R)

nodes <- data.frame(
  id = 1:5,
  combo = c("stack2", "stack2", "stack2", "stack1", "stack1")
)

# TBD add ports

# Set a seed for reproducibility
set.seed(123)

# Define the number of edges to create (e.g., 200 random connections)
num_edges <- 2

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

combos <- data.frame(
  id = paste0("stack", c(1, 2))
)

ui <- page_fluid(
  input_dark_mode(),
  actionButton("add_hull", "Add hull"),
  g6Output("graph", height = "100vh")
)

server <- function(input, output, session) {
  output$graph <- renderG6({
    g6(nodes, edges, combos) |>
      g6_options(
        combo = list(
          animation = FALSE,
          type = "circle-combo-with-extra-button",
          style = list(
            labelText = JS(
              "(d) => {
              return d.id
            }"
            )
          )
        ),
        edge = list(
          type = "fly-marker-cubic",
          zIndex = 100,
          style = list(
            endArrow = TRUE,
            targetPort = "port-1",
            lineDash = c(5, 5)
          )
        ),
        node = list(
          type = "html",
          style = list(
            port = TRUE,
            ports = list(
              list(key = "port-1", placement = c(0, 0.5))
            ),
            labelBackground = TRUE,
            labelBackgroundFill = '#FFB6C1',
            labelBackgroundRadius = 4,
            labelFontFamily = 'Arial',
            labelPadding = c(0, 4),
            labelText = JS(
              "(d) => {
              return d.id
            }"
            ),
            innerHTML = JS(
              '(d) => {
          return `
                <div style="width: 13rem; user-select: none;" class="card bslib-card bslib-mb-spacing html-fill-item html-fill-container" data-bslib-card-init data-require-bs-caller="card()" data-require-bs-version="5">
  <div class="card-body bslib-gap-spacing html-fill-item html-fill-container" style="margin-top:auto;margin-bottom:auto;flex:1 1 auto; user-select: none; width = 13rem">
    <div class="form-group shiny-input-container" data-require-bs-version="5" data-require-bs-caller="input_switch()">
      <div class="bslib-input-switch form-switch form-check">
        <input id="${d.id}" class="form-check-input" type="checkbox" role="switch"/>
        <label class="form-check-label" for="${d.id}">
          <span>Add to dashboard</span>
        </label>
      </div>
    </div>
  </div>
  <script data-bslib-card-init>bslib.Card.initializeAllCards();</script>
</div>
          `
            }'
            )
          )
        )
      ) |>
      g6_layout(
        antv_dagre_layout(
          ranksep = 500,
          nodesep = 100,
          sortByCombo = TRUE,
          controlPoints = TRUE
        )
      ) |>
      g6_behaviors(
        "zoom-canvas",
        drag_element(),
        click_select(multiple = TRUE),
        brush_select(),
        "collapse-expand"
      ) |>
      g6_plugins(
        "minimap",
        "tooltip",
        "fullscreen"
      )
  })

  observeEvent(input$add_hull, {
    g6_proxy("graph") |>
      g6_add_plugin(
        hull(
          members = sample(nodes$id, 5),
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
