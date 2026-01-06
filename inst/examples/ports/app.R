library(shiny)
library(g6R)

ui <- fluidPage(
  g6_output("dag")
)

server <- function(input, output, session) {
  output$dag <- render_g6(
    g6(
      nodes = list(
        list(
          id = 1,
          type = "custom-circle-node",
          style = list(
            labelText = "Node 1",
            ports = list(
              list(
                key = "input-1",
                placement = "left",
                fill = "#52C41A",
                r = 4,
                isBillboard = TRUE
              ),
              list(
                key = "output-1",
                placement = "right",
                fill = "#FF4D4F",
                r = 4,
                isBillboard = TRUE
              )
            )
          )
        ),
        list(
          id = 2,
          type = "custom-circle-node",
          style = list(
            labelText = "Node 2",
            ports = list(
              list(
                key = "input-2",
                placement = "left",
                fill = "#52C41A",
                r = 4
              ),
              list(
                key = "output-2",
                placement = "right",
                fill = "#FF4D4F",
                r = 4
              )
            )
          )
        )
      ) #,
      #edges = list(
      #  list(
      #    source = 1,
      #    target = 2,
      #    style = list(sourcePort = "output-1", targetPort = "input-2")
      #  )
      #)
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
}

shinyApp(ui, server)
