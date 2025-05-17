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
  div(
    class = "d-flex align-items-center",
    actionButton("remove_node", "Remove node 1"),
    actionButton("remove_edge", "Remove edge"),
    actionButton("remove_combo", "Remove combo 1")
  ),
  div(
    class = "d-flex align-items-center",
    actionButton("add_node", "Add node and connect"),
    actionButton("update_node", "Update node 1")
  )
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
        brush_select(immediately = TRUE),
        collapse_expand(),
        drag_canvas(
          trigger = list(
            up = c("ArrowUp"),
            down = c("ArrowDown"),
            left = c("ArrowLeft"),
            right = c("ArrowRight")
          ),
          animation = list(duration = 100)
        )
      ),
      plugins = g6_plugins(
        minimap()
      )
    )
  })

  observeEvent(input$remove_node, {
    g6_proxy("graph") |>
      g6_remove_nodes("node1")
  })

  observeEvent(input$remove_edge, {
    g6_proxy("graph") |>
      g6_remove_edges("node1-node2")
  })

  observeEvent(input$remove_combo, {
    g6_proxy("graph") |>
      g6_remove_combos("combo1")
  })

  observeEvent(input$add_node, {
    g6_proxy("graph") |>
      g6_add_combos(
        data.frame(
          id = "combo2"
        )
      ) |>
      g6_add_nodes(
        data.frame(
          id = c("node3", "node4"),
          combo = c("combo2", "combo2")
        )
      ) |>
      g6_add_edges(
        data.frame(
          source = "node3",
          target = "node4"
        )
      )
  })

  observeEvent(input$update_node, {
    g6_proxy("graph") |>
      g6_update_nodes(list(list(id = "node1", type = "star")))
  })

  observe({
    print(input[["graph-selected_node"]])
    print(input[["graph-selected_edge"]])
  })
}

shinyApp(ui, server)
