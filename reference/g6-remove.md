# Remove nodes/edge/combos from a g6 graph via proxy

This function removes one or more nodes/edges/combos from an existing g6
graph instance using a proxy object. This allows updating the graph
without completely re-rendering it.

## Usage

``` r
g6_remove_nodes(graph, ids)

g6_remove_edges(graph, ids)

g6_remove_combos(graph, ids)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

- ids:

  Character vector or list containing the IDs of the nodes/edges/combos
  to be removed. If a single ID is provided, it will be converted to a
  list internally. You can't mix nodes, edges and combos ids, elements
  have to be of the same type.

## Value

The g6_proxy object (invisibly), allowing for method chaining.

## Details

This function can only be used with a g6_proxy object within a Shiny
application. It will not work with regular g6 objects outside of Shiny.

See <https://g6.antv.antgroup.com/en/api/data#graphremovenodedata>,
<https://g6.antv.antgroup.com/en/api/data#graphremoveedgedata> and
<https://g6.antv.antgroup.com/en/api/data#graphremovecombodata> for more
details.

## Note

When a node is removed, its connected edges are also removed.

## See also

[`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md)

## Examples

``` r
if (interactive()) {
  library(shiny)
  library(g6R)
  library(bslib)

  # Static data defined globally
  nodes <- data.frame(id = 1:3)
  edges <- data.frame(source = c(1, 2), target = c(2, 3))

  ui <- page_fluid(
    title = "Remove Nodes Dynamically",
    g6_output("graph"),
    actionButton("remove_node", "Remove Last Node")
  )

  server <- function(input, output, session) {
    output$graph <- render_g6({
      g6(nodes = nodes, edges = edges) |> g6_layout()
    })

    # Track the next node id and current node ids
    current_ids <- reactiveVal(nodes$id)

    observeEvent(input$remove_node, {
      ids <- current_ids()
      if (length(ids) > 0) {
        remove_id <- tail(ids, 1)
        g6_remove_nodes(g6_proxy("graph"), remove_id)
        current_ids(ids[-length(ids)])
      }
    })
  }

  shinyApp(ui, server)

}
```
