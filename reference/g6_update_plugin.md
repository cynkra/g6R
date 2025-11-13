# Update a plugin in a g6 graph via proxy

This function allows updating the configuration of an existing plugin in
a g6 graph instance using a proxy object within a Shiny application.

## Usage

``` r
g6_update_plugin(graph, key, ...)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

- key:

  Character string identifying the plugin to update.

- ...:

  Named arguments representing the plugin configuration options to
  update and their new values.

## Value

The g6_proxy object (invisibly), allowing for method chaining.

## Details

This function can only be used with a g6_proxy object within a Shiny
application. It will not work with regular g6 objects outside of Shiny.

The function allows dynamically updating the configuration of an
existing plugin without having to reinitialize it. This is useful for
changing plugin behavior or appearance in response to user interactions.

## See also

[`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md),
[`g6_add_plugin`](https://cynkra.github.io/g6R/reference/g6_add_plugin.md)

## Examples

``` r
if (interactive()) {
  library(shiny)
  library(g6R)
  library(bslib)

  color_to_hex <- function(col) {
    rgb <- col2rgb(col)
    sprintf("#%02X%02X%02X", rgb[1], rgb[2], rgb[3])
  }

  nodes <- data.frame(id = c("node1", "node2", "node3"))
  edges <- data.frame(source = "node1", target = "node2")

  ui <- page_fluid(
    g6_output("graph"),
    actionButton("add_hull", "Add Hull Plugin"),
    selectInput(
      "hull_color",
      "Hull Color",
      choices = c("red", "blue", "green", "orange", "purple"),
      selected = "red"
    )
  )

  server <- function(input, output, session) {
    output$graph <- render_g6({
      g6(nodes = nodes, edges = edges) |>
        g6_layout() |>
        g6_options(animation = FALSE)
    })

    observeEvent(input$add_hull, {
      g6_add_plugin(
        g6_proxy("graph"),
        hull(
          members = c("node1", "node2", "node3"),
          fill = color_to_hex(input$hull_color),
          fillOpacity = 0.2
        )
      )
    })

    observeEvent(input$hull_color, {
      # Only update if hull plugin exists
      g6_update_plugin(
        g6_proxy("graph"),
        key = "hull",
        fill = color_to_hex(input$hull_color),
        stroke = color_to_hex(input$hull_color)
      )
    })
  }

  shinyApp(ui, server)
}
```
