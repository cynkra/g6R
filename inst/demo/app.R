library(shiny)
library(bslib)
library(shinyG6)

nodes <- list(
  list(
    id = "node1",
    combo = "combo1",
    style = list(
      halo = FALSE, # Whether to display the node halo
      port = TRUE,
      ports = list(
        list(
          key = "top",
          placement = c(0.5, 1),
          fill = "#7E92B5"
        ),
        list(
          key = "right",
          placement = c(1, 0.5),
          fill = "#F4664A"
        ),
        list(
          key = "bottom",
          placement = c(0.5, 0),
          fill = "#FFBE3A"
        ),
        list(
          key = "left",
          placement = c(0, 0.5),
          fill = "#D580FF"
        )
      ),
      portR = 3,
      portLineWidth = 1,
      portStroke = "#fff"
    )
  ),
  list(
    id = "node2",
    style = list(
      x = 150,
      y = 50,
      badge = TRUE, # Whether to display the badge
      badges = list(
        list(
          text = "A",
          placement = "right-top"
        ),
        list(
          text = "Important",
          placement = "right"
        ),
        list(
          text = "Notice",
          placement = "right-bottom"
        )
      ),
      badgePalette = c("#7E92B5", "#F4664A", "#FFBE3A"), # Badge background color palette
      badgeFontSize = 7 # Badge font size
    ),
    combo = "combo1"
  )
)

edges <- list(list(source = "node1", target = "node2"))
combos <- list(
  list(
    id = "combo1",
    type = "rect",
    data = list(label = "Combo A")
  )
)

ui <- page_fluid(
  g6Output("graph"),
  actionButton("remove", "Remove nodes")
)

server <- function(input, output, session) {
  output$graph <- renderG6({
    g6(
      nodes,
      edges,
      combos,
      options = list(theme = "dark"),
      behaviors = g6_behaviors(
        zoom_canvas(),
        drag_element(),
        click_select(multiple = TRUE),
        brush_select(immediately = TRUE)
      ),
      plugins = g6_plugins(
        minimap()
      )
    )
  })
  observeEvent(input$remove, {
    g6_proxy("graph") |>
      g6_remove_nodes("node1")
  })

  observe({
    print(input[["graph-selected_node"]])
    print(input[["graph-selected_edge"]])
  })
}

shinyApp(ui, server)
