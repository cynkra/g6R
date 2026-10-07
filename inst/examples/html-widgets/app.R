# A small pipeline drawn as HTML nodes, each hosting live Shiny UI: sliders
# that filter the quakes data, and htmlwidgets (leaflet, DT, plotly, echarts)
# that show the result. Links connect the nodes' ports.
#
# Each node's content is ordinary Shiny UI, given to the node itself as
# g6_node(ui = ). The card header is the drag handle, so dragging a slider or
# panning the map does not move the node. The button adds and removes a node
# at runtime through the proxy.
library(shiny)
library(bslib)
library(g6R)
library(leaflet)
library(DT)
library(plotly)
library(echarts4r)

blocks <- list(
  source = list(
    title = "Earthquakes", size = c(280, 160), inputs = FALSE,
    body = sliderInput("mag", "Minimum magnitude", 4, 6.4, 4.5, 0.1)
  ),
  depth = list(
    title = "Depth filter", size = c(280, 160),
    body = sliderInput("depth", "Depth (km)", 40, 680, c(40, 680), 10)
  ),
  map = list(
    title = "Map", size = c(380, 300), outputs = FALSE,
    body = leafletOutput("map", height = "100%")
  ),
  table = list(
    title = "Table", size = c(380, 300), outputs = FALSE,
    body = DTOutput("table")
  ),
  scatter = list(
    title = "Magnitude vs depth", size = c(380, 300), outputs = FALSE,
    body = plotlyOutput("scatter", height = "100%")
  ),
  stations = list(
    title = "Stations reporting", size = c(380, 300), outputs = FALSE,
    body = echarts4rOutput("stations", height = "100%")
  )
)

links <- list(
  c("source", "depth"), c("depth", "map"), c("depth", "table"),
  c("depth", "scatter"), c("depth", "stations")
)

node_card <- function(b) {
  card(
    card_header(b$title, `data-g6-drag-handle` = NA),
    card_body(b$body, padding = 8),
    height = "100%",
    class = "m-0"
  )
}

node <- function(id, b) {
  ports <- c(
    if (!isFALSE(b$inputs)) {
      list(g6_input_port(key = paste0(id, "-in"), placement = "left"))
    },
    if (!isFALSE(b$outputs)) {
      list(g6_output_port(
        key = paste0(id, "-out"), placement = "right", arity = Inf
      ))
    }
  )
  g6_node(
    id = id,
    style = list(size = b$size),
    ports = do.call(g6_ports, ports),
    ui = node_card(b)
  )
}

histogram <- list(
  title = "Magnitude histogram", size = c(380, 300), outputs = FALSE,
  body = plotOutput("hist", height = "100%")
)

ui <- page_fluid(
  actionButton("toggle", "Add histogram", class = "my-2"),
  g6Output("graph", height = "760px")
)

server <- function(input, output, session) {

  quakes_sel <- reactive({
    req(input$mag, input$depth)
    subset(
      quakes,
      mag >= input$mag & depth >= input$depth[1] & depth <= input$depth[2]
    )
  })

  output$map <- renderLeaflet({
    leaflet(quakes_sel()) |>
      addTiles() |>
      addCircleMarkers(
        ~long, ~lat,
        radius = ~ (mag - 3.5) * 3, stroke = FALSE, fillOpacity = 0.6,
        popup = ~ sprintf("Magnitude %.1f, depth %d km", mag, depth)
      )
  })

  output$table <- renderDT(
    datatable(
      quakes_sel(),
      rownames = FALSE,
      options = list(dom = "t", paging = FALSE, scrollY = "180px"),
      class = "compact"
    )
  )

  output$scatter <- renderPlotly(
    plot_ly(
      quakes_sel(), x = ~depth, y = ~mag, type = "scatter", mode = "markers",
      marker = list(size = 5, opacity = 0.6)
    ) |>
      layout(margin = list(l = 40, r = 10, t = 10, b = 40)) |>
      config(displayModeBar = FALSE)
  )

  output$stations <- renderEcharts4r(
    quakes_sel() |>
      e_charts() |>
      e_histogram(stations, name = "Quakes", breaks = 20) |>
      e_legend(show = FALSE) |>
      e_grid(left = 40, right = 10, top = 10, bottom = 30)
  )

  output$hist <- renderPlot({
    par(mar = c(4, 4, 0.5, 0.5))
    hist(quakes_sel()$mag, main = NULL, xlab = "Magnitude", col = "#93c5fd",
         border = "white")
  })

  shown <- reactiveVal(FALSE)
  observeEvent(input$toggle, {
    proxy <- g6_proxy("graph")
    if (shown()) {
      g6_remove_nodes(proxy, "hist")
      updateActionButton(inputId = "toggle", label = "Add histogram")
    } else {
      g6_add_nodes(proxy, node("hist", histogram))
      g6_add_edges(
        proxy,
        g6_edge(
          "depth", "hist",
          style = list(sourcePort = "depth-out", targetPort = "hist-in")
        )
      )
      updateActionButton(inputId = "toggle", label = "Remove histogram")
    }
    shown(!shown())
  })

  output$graph <- renderG6({
    g6(
      nodes = do.call(g6_nodes, Map(node, names(blocks), blocks)),
      edges = do.call(
        g6_edges,
        lapply(links, function(l) {
          g6_edge(
            l[1], l[2],
            style = list(
              sourcePort = paste0(l[1], "-out"),
              targetPort = paste0(l[2], "-in")
            )
          )
        })
      )
    ) |>
      g6_options(animation = FALSE) |>
      g6_layout(
        antv_dagre_layout(rankdir = "LR", nodesep = 40, ranksep = 100)
      ) |>
      g6_behaviors(
        "zoom-canvas",
        # only from empty canvas, so it never competes with node or port drags
        drag_canvas(enable = JS("(e) => e.targetType === 'canvas'")),
        drag_element(),
        create_edge(enable = JS("(e) => e.targetType === 'node'"))
      )
  })
}

shinyApp(ui, server)
