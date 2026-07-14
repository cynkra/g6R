library(shiny)
library(g6R)

options(
  "g6R.mode" = "dev",
  "g6R.layout_on_data_change" = TRUE
)

ui <- fluidPage(
  g6_output("dag"),
  verbatimTextOutput("clicked_port")
)

server <- function(input, output, session) {
  output$dag <- render_g6(
    g6(
      nodes = g6_nodes(
        g6_node(
          id = 1,
          type = "custom-image-node",
          style = list(
            src = "https://gw.alipayobjects.com/mdn/rms_6ae20b/afts/img/A*N4ZMS7gHsUIAAAAAAAAAAABkARQnAQ",
            labelText = "Node 1"
          ),
          ports = g6_ports(
            g6_input_port(
              key = "input-1",
              placement = c(0, 1),
              label = "port 1 (visible)"
              # visibility = "visible" is default
            ),
            g6_output_port(
              key = "output-1",
              placement = "right",
              label = "port 2 (hover)",
              visibility = "hover"
            ),
            g6_input_port(
              key = "input-12",
              placement = "top",
              label = "port 3 (hidden)",
              visibility = "hidden"
            )
          )
        ),
        g6_node(
          id = 2,
          type = "custom-circle-node",
          style = list(
            labelText = "Node 2"
          ),
          ports = g6_ports(
            g6_input_port(
              key = "input-2",
              placement = "left"
            ),
            g6_output_port(
              key = "output-2",
              placement = "right",
              arity = Inf
            )
          )
        ),
        # Nodes 3 and 4 reproduce the blockr.dag styling: a bottom label with a
        # background, and an output port placed at the label surface via
        # placement = "label-bottom". The input port stays at the node top.
        g6_node(
          id = 3,
          type = "custom-image-node",
          style = list(
            src = "https://gw.alipayobjects.com/mdn/rms_6ae20b/afts/img/A*N4ZMS7gHsUIAAAAAAAAAAABkARQnAQ",
            labelText = "Dataset",
            labelFill = "#6b7280",
            labelBackground = TRUE,
            labelBackgroundFill = "#f3f4f6",
            labelBackgroundStroke = "#e5e7eb",
            labelBackgroundRadius = 4,
            labelPlacement = "bottom",
            labelOffsetY = 8,
            labelBackgroundLineWidth = 1,
            labelBackgroundOpacity = 1,
            labelPadding = c(1, 6, 1, 6),
            labelFontSize = 11,
            labelFontFamily = "Open Sans, system-ui, sans-serif"
          ),
          ports = g6_ports(
            g6_input_port(key = "input-3", placement = "top"),
            g6_output_port(key = "output-3", placement = "label-bottom")
          )
        ),
        g6_node(
          id = 4,
          type = "custom-image-node",
          style = list(
            src = "https://gw.alipayobjects.com/mdn/rms_6ae20b/afts/img/A*N4ZMS7gHsUIAAAAAAAAAAABkARQnAQ",
            labelText = "Scatter",
            labelFill = "#6b7280",
            labelBackground = TRUE,
            labelBackgroundFill = "#f3f4f6",
            labelBackgroundStroke = "#e5e7eb",
            labelBackgroundRadius = 4,
            labelPlacement = "bottom",
            labelOffsetY = 8,
            labelBackgroundLineWidth = 1,
            labelBackgroundOpacity = 1,
            labelPadding = c(1, 6, 1, 6),
            labelFontSize = 11,
            labelFontFamily = "Open Sans, system-ui, sans-serif"
          ),
          ports = g6_ports(
            g6_input_port(key = "input-4", placement = "top"),
            g6_output_port(key = "output-4", placement = "label-bottom")
          )
        )
      ),
      edges = g6_edges(
        g6_edge(
          source = 1,
          target = 2,
          style = list(
            sourcePort = "output-1",
            targetPort = "input-2",
            endArrow = TRUE,
            startArrow = FALSE,
            endArrowType = "vee"
          )
        ),
        # Connects the label-bottom output of node 3 to the top input of node 4.
        g6_edge(
          source = 3,
          target = 4,
          style = list(
            sourcePort = "output-3",
            targetPort = "input-4",
            endArrow = TRUE,
            endArrowType = "vee"
          )
        )
      )
    ) |>
      g6_layout() |>
      g6_options(
        animation = FALSE,
        edge = list(style = list(endArrow = TRUE))
      ) |>
      g6_behaviors(
        click_select(multiple = TRUE),
        drag_element(),
        drag_canvas(
          enable = JS(
            "(e) => {
          return e.targetType === 'canvas' && !e.shiftKey && !e.altKey;
        }"
          )
        ),
        zoom_canvas(),
        create_edge(
          enable = JS("(e) => true"),
          onFinish = NULL
        )
      ) |>
      # Allow to dynamically remove an edge
      g6_plugins(
        context_menu(
          enable = JS("(e) => e.targetType === 'edge'"),
          getItems = JS(
            "() => {
              return [
                { name: 'Remove edge', value: 'remove_edge' }
              ];
            }"
          ),
          onClick = JS(
            "(value, target, current) => {
              const graph = HTMLWidgets
                .find(`#${target.closest('.g6').id}`)
                .getWidget();
              console.log(current.id);
              if (current.id === undefined) return;
              if (value === 'remove_edge') {
                graph.removeEdgeData([current.id]);
                graph.draw();
              }
            }
          "
          )
        )
      )
  )

  output$clicked_port <- renderPrint({
    input[["dag-selected_port"]]
  })

  proxy <- g6_proxy("dag")

  # Add a new node when a port is clicked from the guide
  # at the mouse position (close to the guide)
  observeEvent(input[["dag-selected_port"]], {
    new_id <- round(as.numeric(Sys.time()))
    pos <- input[["dag-mouse_position"]]

    proxy |>
      g6_add_nodes(
        g6_node(
          id = new_id,
          type = "custom-circle-node",
          style = list(
            x = pos$x + 50, # avoids overlapping with the guide.
            y = pos$y,
            labelText = paste("Node", new_id)
          ),
          ports = g6_ports(
            g6_input_port(
              key = sprintf("input-%s", new_id),
              placement = "left"
            ),
            g6_output_port(
              key = sprintf("output-%s", new_id),
              placement = "right",
              arity = Inf
            )
          )
        )
      ) |>
      g6_add_edges(
        g6_edge(
          source = input[["dag-selected_port"]][["node"]],
          target = new_id,
          style = list(
            sourcePort = input[["dag-selected_port"]][["port"]],
            targetPort = sprintf("input-%s", new_id),
            endArrow = TRUE
          )
        )
      )
  })
}

shinyApp(ui, server)
