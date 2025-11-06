library(shiny)
library(bslib)
library(g6R)

default_node_style <- list(
  fill = "#1783FF",
  labelBackgroundFill = "#a0cafa",
  badges = list()
)

nodes <- list(
  list(
    id = "1",
    combo = "combo1",
    style = default_node_style
  ),
  list(
    id = "2",
    combo = "combo1",
    style = list(
      fill = "#ee705c",
      labelBackgroundFill = "#FFB6C1",
      badges = list(
        list(
          text = sprintf("Eval errors: '%s'", 1),
          placement = "right-bottom",
          backgroundFill = "#85847e"
        ),
        list(
          text = sprintf("Data errors: '%s'", 1),
          placement = "right",
          backgroundFill = "#edb528"
        ),
        list(
          text = sprintf("State errors: '%s'", 1),
          placement = "right-top",
          backgroundFill = "#ee705c"
        )
      )
    )
  ),
  list(
    id = "3",
    combo = "combo1",
    style = default_node_style
  ),
  list(
    id = "4",
    combo = "combo2",
    style = default_node_style
  ),
  list(
    id = "5",
    combo = "combo2",
    style = default_node_style
  )
)

edges <- list(
  list(
    type = "fly-marker-cubic",
    source = "1",
    target = "2"
  ),
  list(
    source = "2",
    target = "3",
    type = "cubic",
    style = list(
      stroke = "#ee705c",
      badgeText = "ERROR",
      badgeBackgroundFill = "#ee705c",
      badgeBackground = TRUE
    ),
    states = list("inactive")
  ),
  list(
    type = "fly-marker-cubic",
    source = "4",
    target = "5"
  )
)

combos <- list(
  list(
    id = "combo1",
    type = "rect",
    data = list(label = "Combo A"),
    style = list(
      stroke = "orange",
      fill = "orange",
      fillOpacity = 0.2,
      shadowColor = "orange",
      collapsedFill = "orange",
      collapsedStroke = "orange",
      iconFill = "orange",
      labelPlacement = "top"
    )
  ),
  list(
    id = "combo2",
    data = list(label = "Combo B"),
    style = list(
      stroke = "lightblue",
      fill = "lightblue",
      fillOpacity = 0.2,
      shadowColor = "lightblue",
      collapsedFill = "lightblue",
      collapsedStroke = "lightblue",
      iconFill = "lightblue",
      labelPlacement = "top"
    )
  )
)

ui <- page_fluid(
  g6Output("graph", height = "100vh"),
)

server <- function(input, output, session) {
  output$graph <- renderG6({
    g6(
      nodes,
      edges,
      combos
    ) |>
      g6_options(
        animation = FALSE,
        node = list(
          style = list(
            labelBackground = TRUE,
            labelBackgroundRadius = 4,
            labelFontFamily = "Arial",
            labelPadding = c(0, 4),
            labelText = JS(
              "(d) => {
                return d.id
              }"
            )
          )
        ),
        combo = list(
          animation = FALSE,
          type = "circle-combo-with-extra-button",
          style = list(
            labelText = JS(
              "(d) => {
                return d.data.label
              }"
            )
          )
        ),
        edge = list(
          style = list(
            endArrow = TRUE,
            lineDash = c(5, 5),
            labelText = JS(
              "(d) => {
                return d.label
              }"
            )
          )
        )
      ) |>
      g6_layout(d3_force_layout()) |>
      g6_behaviors(
        "zoom-canvas",
        "drag-canvas",
        drag_element(dropEffect = "link"),
        click_select(multiple = TRUE),
        "brush-select"
      ) |>
      g6_plugins(
        toolbar(
          style = list(
            backgroundColor = "#f5f5f5",
            padding = "8px",
            boxShadow = "0 2px 8px rgba(0, 0, 0, 0.15)",
            borderRadius = "8px",
            border = "1px solid #e8e8e8",
            opacity = "0.9",
            marginTop = "12px",
            marginLeft = "12px"
          ),
          position = "left"
        ),
        context_menu()
      )
  })
}

shinyApp(ui, server)
