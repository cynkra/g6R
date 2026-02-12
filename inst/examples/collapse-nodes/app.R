library(shiny)
library(g6R)

options(
  "g6R.mode" = "dev",
  # In theory this is automatically set whenever a g6_node has some children ...
  "g6R.directed_graph" = TRUE
)

ui <- fluidPage(
  g6_output("dag"),
  verbatimTextOutput("clicked_port"),
  verbatimTextOutput("removed_node")
)

server <- function(input, output, session) {
  output$dag <- render_g6(
    g6(
      nodes = g6_nodes(
        g6_node(
          id = 1,
          type = "custom-rect-node",
          style = list(
            src = "https://gw.alipayobjects.com/mdn/rms_6ae20b/afts/img/A*N4ZMS7gHsUIAAAAAAAAAAABkARQnAQ",
            labelText = "Node 1"
          ),
          ports = g6_ports(
            g6_input_port(
              key = "input-1",
              placement = "top",
              label = "port 1 (visible)"
              # visibility = "visible" is default
            ),
            g6_output_port(
              key = "output-1",
              placement = "bottom",
              label = "port 2 (hover)"
            ),
            g6_input_port(
              key = "input-12",
              placement = "top",
              label = "port 3 (hidden)",
              visibility = "hidden"
            )
          ),
          children = c(2),
          collapse = g6_collapse_options(
            collapsed = TRUE,
            stroke = "#67ba1eff",
            iconStroke = "#d82fa0ff",
            placement = "left-top",
            lineWidth = 1.4,
            iconLineWidth = 1,
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
              placement = "top",
              arity = Inf
            )
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
        )
      )
    ) |>
      g6_layout() |>
      g6_options(
        animation = FALSE,
        node = list(
          style = list(
            #fill = "#CED4D9",
            #fillOpacity = 0
          )
        ),
        renderer = JS("() => new SVGRenderer()"),
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
        create_edge(enable = TRUE)
      ) |>
      # Allow to dynamically remove an edge or node
      g6_plugins(
        context_menu(
          enable = JS("(e) => true"),
          getItems = JS(
            "(e) => {
              if (e.targetType === 'edge') {
                return [{ name: 'Remove edge', value: 'remove_edge' }];
              } else if (e.targetType === 'node') {
                return [{ name: 'Remove node', value: 'remove_node' }];
              }
              return [];
            }"
          ),
          onClick = JS(
            "(value, target, current) => {
              const graph = HTMLWidgets
                .find(`#${target.closest('.g6').id}`)
                .getWidget();
              if (current.id === undefined) return;
              if (value === 'remove_edge') {
              console.log(target);
              Shiny.setInputValue(target.closest('.g6').id + '-removed_edge', 
                  {id: current.id}, 
                  {priority: 'event'});
              } else if (value === 'remove_node') {
                // Send node ID to Shiny before removing
                Shiny.setInputValue(target.closest('.g6').id + '-removed_node', 
                  {id: current.id}, 
                  {priority: 'event'});
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

  output$removed_node <- renderPrint({
    input[["dag-removed_node"]]
  })

  proxy <- g6_proxy("dag")

  # Add a new node when a port is clicked from the guide
  # at the mouse position (close to the guide)
  observeEvent(input[["dag-selected_port"]], {
    new_id <- as.character(round(as.numeric(Sys.time())))
    pos <- input[["dag-mouse_position"]]
    parent_id <- as.character(input[["dag-selected_port"]][["node"]])

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
          source = parent_id,
          target = new_id,
          style = list(
            sourcePort = input[["dag-selected_port"]][["port"]],
            targetPort = sprintf("input-%s", new_id),
            endArrow = TRUE
          )
        )
      )
  })

  observeEvent(input[["dag-removed_edge"]], {
    proxy |>
      g6_remove_edges(input[["dag-removed_edge"]]$id)
  })

  # Handle node removal - update parent's children list
  observeEvent(input[["dag-removed_node"]], {
    proxy |>
      g6_remove_nodes(input[["dag-removed_node"]]$id)
  })
}

shinyApp(ui, server)
