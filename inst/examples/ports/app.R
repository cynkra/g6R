library(shiny)
library(g6R)

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
                r = 4,
                isBillboard = TRUE
              ),
              g6_port(
                key = "output-1",
                type = "output",
                placement = "right",
                label = "port 2",
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
      )
      # edges = g6_edges(
      #   g6_edge(
      #     source = 1,
      #     target = 2,
      #     style = list(sourcePort = "output-1", targetPort = "input-2")
      #   )
      # )
    ) |>
      g6_layout() |>
      g6_options(animation = FALSE) |>
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
      )
  )

  output$clicked_port <- renderPrint({
    input[["dag-selected_port"]]
  })
}

shinyApp(ui, server)
