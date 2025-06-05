library(shiny)
library(bslib)
library(g6R)

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

edges <- list(
  list(source = "node1", target = "node2")
)
combos <- list(
  list(
    id = "combo1",
    type = "rect",
    data = list(label = "Combo A")
  )
)

ui <- page_fluid(
  g6Output("graph"),
  verbatimTextOutput("selected_elements"),
  div(
    class = "d-flex align-items-center",
    actionButton("remove_node", "Remove node 1"),
    actionButton("remove_edge", "Remove edge"),
    actionButton("remove_combo", "Remove combo 1")
  ),
  div(
    class = "d-flex align-items-center",
    actionButton("add_node", "Add node and connect"),
    actionButton("update_node", "Update node 1 and node 2"),
    actionButton("update_edge", "Update edge 1"),
    actionButton("update_combo", "Update combo 1")
  ),
  div(
    class = "d-flex align-items-center",
    actionButton("canvas_resize", "Resize canvas"),
    actionButton("focus", "Focus node 1"),
    actionButton("show", "Show node 1"),
    actionButton("hide", "Hide node 1")
  ),
  div(
    class = "d-flex align-items-center",
    actionButton("expand", "Expand combo 1"),
    actionButton("collapse", "Collapse combo 1"),
    actionButton("set_options", "Set options")
  ),
  div(
    class = "d-flex align-items-center",
    actionButton("update_plugin", "Update minimap"),
    actionButton("update_behavior", "Disable zoom canvas")
  ),
  div(
    class = "d-flex align-items-center",
    actionButton("set_nodes", "Set nodes state")
  )
)

server <- function(input, output, session) {
  output$graph <- renderG6({
    g6(
      nodes,
      edges,
      combos
    ) |>
      g6_options(
        edge = edge_options(
          style = list(
            endArrow = TRUE
          )
        )
      ) |>
      g6_layout(d3_force_layout()) |>
      g6_behaviors(
        zoom_canvas(),
        drag_element(dropEffect = "link"),
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
      ) |>
      g6_plugins(
        minimap(),
        fullscreen(),
        #tooltips()
        toolbar(),
        context_menu()
      )
  })

  observeEvent(input$set_nodes, {
    g6_proxy("graph") |>
      g6_set_nodes(list(node1 = "selected", node2 = "disabled"))
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
      g6_update_nodes(
        list(
          list(
            id = "node1",
            type = "star"
          ),
          list(id = "node2", states = list("selected"))
        )
      )
  })

  observeEvent(input$update_edge, {
    g6_proxy("graph") |>
      g6_update_edges(list(list(
        id = "node1-node2",
        style = list(stroke = "#1783F", lineWidth = 2)
      )))
  })

  observeEvent(input$update_combo, {
    g6_proxy("graph") |>
      g6_update_combos(list(list(id = "combo1", type = "circle")))
  })

  observeEvent(input$canvas_resize, {
    g6_proxy("graph") |>
      g6_canvas_resize(1000, 1000)
  })

  observeEvent(input$focus, {
    g6_proxy("graph") |>
      g6_focus_elements("node1", animation = list(duration = 2000))
  })

  observeEvent(input$show, {
    g6_proxy("graph") |>
      g6_show_elements("node1")
  })

  observeEvent(input$hide, {
    g6_proxy("graph") |>
      g6_hide_elements("node1")
  })

  observeEvent(input$expand, {
    g6_proxy("graph") |>
      g6_expand_combo("combo1")
  })

  observeEvent(input$collapse, {
    g6_proxy("graph") |>
      g6_collapse_combo("combo1")
  })

  observeEvent(input$set_options, {
    g6_proxy("graph") |>
      g6_set_options(
        list(
          node = list(
            style = list(
              fill = '#91d5ff',
              stroke = '#40a9ff',
              lineWidth = 1,
              radius = 10
            )
          ),
          edge = list(
            style = list(
              stroke = '#91d5ff',
              lineWidth = 2,
              endArrow = TRUE
            )
          )
        )
      )
  })

  observeEvent(input$update_plugin, {
    g6_proxy("graph") |>
      g6_update_plugin(
        key = "minimap",
        position = "right-top"
      )
  })

  observeEvent(input$update_behavior, {
    g6_proxy("graph") |>
      g6_update_behavior(
        key = "zoom-canvas",
        enable = FALSE
      )
  })

  observeEvent(
    {
      req(input[["graph-initialized"]])
      input[["graph-state"]]
    },
    {
      g6_proxy("graph") |> g6_get_nodes(c("node1", "node2"))
    }
  )

  output$selected_elements <- renderPrint({
    list(
      node = input[["graph-selected_node"]],
      edge = input[["graph-selected_edge"]],
      combo = input[["graph-selected_combo"]],
      node2_combo = input[["graph-node2-state"]]$combo
    )
  })
}

shinyApp(ui, server)
