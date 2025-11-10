# Add nodes/edges/combos to a g6 graph via proxy

This function adds one or more nodes/edges/combos to an existing g6
graph instance using a proxy object. This allows updating the graph
without completely re-rendering it.

## Usage

``` r
g6_add_nodes(graph, ...)

g6_add_edges(graph, ...)

g6_add_combos(graph, ...)

g6_add_data(graph, data)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

- ...:

  Nodes or edges or combos. You can pass a list of nodes/edges/combos, a
  dataframe or leverage the g6_nodes(), g6_edges() or g6_combos()
  helpers or pass individual elements like g6_node(), g6_edge() or
  g6_combo(). Elements structure must be compliant with specifications
  listed at <https://g6.antv.antgroup.com/manual/element/overview>.

- data:

  A nested list possibly containing nodes, edges and combo data. Can
  also be created with the
  [`g6_data`](https://cynkra.github.io/g6R/reference/g6_data.md) helper.

## Value

The g6_proxy object (invisibly), allowing for method chaining.

## Details

This function can only be used with a g6_proxy object within a Shiny
application. It will not work with regular g6 objects outside of Shiny.

If a node with the same ID already exists, it will not be added again.
See <https://g6.antv.antgroup.com/en/api/data#graphaddnodedata>,
<https://g6.antv.antgroup.com/en/api/data#graphaddedgedata> and
<https://g6.antv.antgroup.com/en/api/data#graphaddcombodata> for more
details.

## See also

[`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md),
[`g6_remove_nodes`](https://cynkra.github.io/g6R/reference/g6-remove.md)

## Examples

``` r
if (interactive()) {
  library(shiny)
  library(bslib)
  library(g6R)
  ui <- page_fluid(
    titlePanel("g6_proxy Add Nodes/Data Examples"),
    layout_sidebar(
      sidebar = sidebar(
        actionButton("old1", "Old: list(list(id = 'n1'), list(id = 'n2'))"),
        actionButton("old2", "Old: list(id = 'n3'), list(id = 'n4')"),
        actionButton("old3", "Old: g6_nodes(g6_node(id = 'n5'), g6_node(id = 'n6'))"),
        actionButton("new1", "New: g6_node(id = 'n7'), g6_node(id = 'n8')"),
        actionButton("new2", "New: data.frame(id = c('n9', 'n10'))"),
        actionButton("add_data", "Add Data (nodes/edges/combos)"),
        verbatimTextOutput("graph_data")
      ),
      g6Output("graph")
    )
  )
  server <- function(input, output, session) {
    output$graph <- renderG6({
      g6() |>
        g6_layout()
    })
    proxy <- g6_proxy("graph")
    observeEvent(input$old1, {
      g6_add_nodes(proxy, list(list(id = "n1"), list(id = "n2")))
    })
    observeEvent(input$old2, {
      g6_add_nodes(proxy, list(id = "n3"), list(id = "n4"))
    })
    observeEvent(input$old3, {
      g6_add_nodes(proxy, g6_nodes(g6_node(id = "n5"), g6_node(id = "n6")))
    })
    observeEvent(input$new1, {
      g6_add_nodes(proxy, g6_node(id = "n7"), g6_node(id = "n8"))
    })
    observeEvent(input$new2, {
      g6_add_nodes(proxy, data.frame(id = c("n9", "n10")))
    })
    observeEvent(input$add_data, {
      g6_add_data(
        proxy,
        list(
          nodes = list(list(id = "n11"), list(id = "n12")),
          edges = list(list(source = "n11", target = "n12", id = "e1")),
          combos = list(list(id = "combo1"))
        )
      )
    })
    output$graph_data <- renderPrint({
      "See graph updates in the visualization above."
    })
  }
  shinyApp(ui, server)
}
```
