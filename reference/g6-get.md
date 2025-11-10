# Get the state of nodes/edges/combos in a g6 graph via proxy

This function gets the state of one or more nodes/edges/combos to an
existing g6 graph instance using a proxy object.

## Usage

``` r
g6_get_nodes(graph, nodes)

g6_get_edges(graph, edges)

g6_get_combos(graph, combos)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

- nodes, edges, combos:

  A string or character vector with the IDs of the nodes/edges/combos.

## Value

The g6_proxy object (invisibly), allowing for method chaining.

## Details

This function can only be used with a g6_proxy object within a Shiny
application. It will not work with regular g6 objects outside of Shiny.

If a node with the same ID already exists, it will not be added again.
See <https://g6.antv.antgroup.com/en/api/data#graphgetnodedata> for more
details.

## See also

[`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md)

## Examples

``` r
 if (interactive()) {
   library(shiny)
   library(bslib)

    ui <- page_fluid(
      verbatimTextOutput("res"),
      g6Output("graph")
    )

    server <- function(input, output, session) {
      output$graph <- renderG6({
        g6(
          nodes = data.frame(id = c("node1", "node2"))
        ) |>
          g6_options(animation = FALSE) |>
          g6_layout() |>
          g6_behaviors(click_select())
      })

      # Send query to JS
      observeEvent(req(input[["graph-initialized"]]), {
        g6_proxy("graph") |> g6_get_nodes(c("node1", "node2"))
      })

      # Recover query result inside input[["<GRAPH_ID>-<ELEMENT_ID>-state"]]
      output$res <- renderPrint({
        list(
          node1_state = input[["graph-node1-state"]],
          node2_state = input[["graph-node2-state"]]
        )
      })
    }
    shinyApp(ui, server)
 }
```
