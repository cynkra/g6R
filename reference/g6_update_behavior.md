# Update a behavior in a g6 graph via proxy

This function allows updating the configuration of an existing behavior
in a g6 graph instance using a proxy object within a Shiny application.

## Usage

``` r
g6_update_behavior(graph, key, ...)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

- key:

  Character string identifying the behavior to update.

- ...:

  Named arguments representing the behavior configuration options to
  update and their new values.

## Value

The g6_proxy object (invisibly), allowing for method chaining.

## Details

This function can only be used with a g6_proxy object within a Shiny
application. It will not work with regular g6 objects outside of Shiny.

Behaviors in G6 define how the graph responds to user interactions like
dragging, zooming, clicking, etc. This function allows dynamically
updating the configuration of these behaviors without having to
reinitialize the graph.

## See also

[`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md)

## Examples

``` r
if (interactive()) {
  library(shiny)
  library(g6R)
  library(bslib)

  nodes <- data.frame(id = c("node1", "node2", "node3"))
  edges <- data.frame(source = "node1", target = "node2")

  ui <- page_fluid(
    g6_output("graph"),
    checkboxInput("enable_click_select", "Enable Click Select", value = TRUE)
  )

  server <- function(input, output, session) {
    output$graph <- render_g6({
      g6(nodes = nodes, edges = edges) |>
        g6_layout() |>
        g6_options(animation = FALSE) |>
        g6_behaviors(
          click_select()
        )
    })

    observeEvent(input$enable_click_select, {
      g6_update_behavior(
        g6_proxy("graph"),
        key = "click-select",
        enable = input$enable_click_select
      )
    })
  }

  shinyApp(ui, server)
}
```
