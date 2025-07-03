library(shiny)
library(bslib)
library(g6R)

themes <- list(
  "light" = list(
    theme = 'light',
    node = list(
      style = list(
        size = 4
      ),
      palette = list(
        type = 'group',
        field = 'cluster'
      )
    ),
    plugins = list(
      list(
        type = 'background',
        background = '#fff'
      )
    )
  ),
  "dark" = list(
    theme = 'dark',
    node = list(
      style = list(
        size = 4
      ),
      palette = list(
        type = 'group',
        field = 'cluster'
      )
    ),
    plugins = list(
      list(
        type = 'background',
        background = '#000'
      )
    )
  ),
  "blue" = list(
    theme = 'light',
    node = list(
      style = list(
        size = 4
      ),
      palette = list(
        type = 'group',
        field = 'cluster',
        color = "blues",
        invert = TRUE
      )
    ),
    plugins = list(
      list(
        type = 'background',
        background = '#f3faff'
      )
    )
  ),
  "yellow" = list(
    theme = 'light',
    node = list(
      style = list(
        size = 4
      ),
      palette = list(
        type = 'group',
        field = 'cluster',
        color = c(
          '#ffe7ba',
          '#ffd591',
          '#ffc069',
          '#ffa940',
          '#fa8c16',
          '#d46b08',
          '#ad4e00',
          '#873800',
          '#612500'
        )
      )
    ),
    plugins = list(
      list(
        type = 'background',
        background = '#fcf9f1'
      )
    )
  )
)

ui <- page_fluid(
  selectInput(
    "theme",
    "Theme",
    choices = c("light", "dark", "blue", "yellow"),
    selected = "default"
  ),
  g6Output("graph", height = "100vh")
)

server <- function(input, output, session) {
  output$graph <- renderG6({
    g6(
      jsonUrl = "https://assets.antv.antgroup.com/g6/20000.json"
    ) |>
      g6_options(
        animation = FALSE,
        autoFit = "view",
        padding = 20,
        node = list(
          style = list(size = 4),
          palette = list(
            type = "group",
            field = "cluster"
          )
        )
      ) |>
      g6_behaviors(
        "zoom-canvas",
        "drag-canvas",
        "optimize-viewport-transform"
      )
  })

  observeEvent(input$theme, {
    g6_proxy("graph") |>
      g6_set_theme(themes[[input$theme]])
  })

  observeEvent(input[["graph-initialized"]], {
    showNotification(
      "Graph initialized",
      type = "message"
    )
  })

  observeEvent(input[["graph-state"]], {
    showNotification(
      "Graph state updated",
      type = "message"
    )
  })
}

shinyApp(ui, server)
