library(shiny)
library(g6R)

options(
  "g6R.mode" = "dev"
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
          type = "custom-circle-node",
          style = list(
            labelText = "Node 1",
            ports = g6_ports(
              g6_port(
                key = "input-1",
                type = "input",
                placement = "left",
                fill = "#52C41A",
                label = "port 1",
                r = 4
                #showGuides = FALSE,
              ),
              g6_port(
                key = "output-1",
                type = "output",
                placement = "right",
                label = "port 2",
                fill = "#FF4D4F",
                r = 4
              ),
              g6_port(
                key = "input-12",
                type = "input",
                placement = "top",
                label = "port 3",
                fill = "#FF4D4F",
                r = 4,
                isBillboard = TRUE
              )
            )
          )
        ),
        g6_node(
          id = 2,
          type = "custom-circle-node",
          style = list(
            labelText = "Node 2",
            ports = g6_ports(
              g6_port(
                key = "input-2",
                type = "input",
                placement = "left",
                fill = "#52C41A",
                r = 4
              ),
              g6_port(
                key = "output-2",
                type = "output",
                placement = "right",
                fill = "#FF4D4F",
                r = 4
              )
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
        edge = list(style = list(endArrow = TRUE))
      ) |>
      g6_behaviors(
        click_select(multiple = TRUE),
        drag_element(
          enable = JS(
            "(e) => {
          return !e.shiftKey && !e.altKey;
        }"
          )
        ),
        drag_canvas(
          enable = JS(
            "(e) => {
          return e.targetType === 'canvas' && !e.shiftKey && !e.altKey;
        }"
          )
        ),
        zoom_canvas(),
        create_edge(
          enable = JS(
            "(e) => {
        return e.shiftKey}"
          )
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
      g6_add_nodes(g6_node(
        id = new_id,
        type = "custom-circle-node",
        style = list(
          x = pos$x + 50, # avoids overlapping with the guide.
          y = pos$y,
          labelText = paste("Node", new_id),
          ports = g6_ports(
            g6_port(
              key = sprintf("input-%s", new_id),
              type = "input",
              placement = "left",
              fill = "#52C41A",
              r = 4
            ),
            g6_port(
              key = sprintf("output-%s", new_id),
              type = "output",
              placement = "right",
              fill = "#FF4D4F",
              r = 4
            )
          )
        )
      )) |>
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
