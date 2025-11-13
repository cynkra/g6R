# Set the state of nodes/edges/combos in a g6 graph via proxy

This function sets the state of one or more nodes/edges/combos to an
existing g6 graph instance using a proxy object. This allows updating
the graph without completely re-rendering it. Valid states are
"selected", "active", "inactive", "disabled", or "highlight".

## Usage

``` r
g6_set_nodes(graph, nodes)

g6_set_edges(graph, edges)

g6_set_combos(graph, combos)

g6_set_data(graph, data)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

- nodes:

  A key value pair list with the node id and its state.

- edges:

  A key value pair list with the edge id and its state.

- combos:

  A key value pair list with the combo id and its state.

- data:

  A nested list containing all nodes, edges and combo data.
  Alternatively you can use
  [`g6_data`](https://cynkra.github.io/g6R/reference/g6_data.md) to
  generate compatible data.

## Value

The g6_proxy object (invisibly), allowing for method chaining.

## Details

g6_set_data allows to set all graph data at once (nodes, edges and
combos).

This function can only be used with a g6_proxy object within a Shiny
application. It will not work with regular g6 objects outside of Shiny.

If a node with the same ID already exists, it will not be added again.
See
<https://g6.antv.antgroup.com/en/api/element#graphsetelementstateid-state-options>
for more details.

## See also

[`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md)

## Examples

``` r
if (interactive()) {
  # Example setting node states
  library(shiny)
  library(g6R)
  library(bslib)

  nodes <- data.frame(id = 1:2)
  edges <- data.frame(source = 1, target = 2)

  ui <- page_fluid(
    g6_output("graph"),
    actionButton("set_state", "Set Node States")
  )

  server <- function(input, output, session) {
    output$graph <- render_g6({
      g6(nodes = nodes, edges = edges) |> g6_layout()
    })

    observeEvent(input$set_state, {
      g6_set_nodes(
        g6_proxy("graph"),
        list(`1` = "selected", `2` = "disabled")
      )
    })
  }

  shinyApp(ui, server)

  # Replace data dynamically
  ui <- page_fluid(
    g6_output("graph"),
    actionButton("remove", "Remove All"),
    actionButton("reset", "Reset Graph"),
    verbatimTextOutput("state")
  )

  server <- function(input, output, session) {
    # Store initial state after first render
    initial_state <- reactiveVal(NULL)

    output$graph <- render_g6({
      g6(nodes = nodes, edges = edges) |>
        g6_layout() |>
        g6_options(animation = FALSE)
    })

    # Save initial state once available
    observe({
      state <- input[["graph-state"]]
      if (!is.null(state) && is.null(initial_state())) {
        initial_state(state)
      }
    })

    # Remove all nodes and edges
    observeEvent(input$remove, {
      g6_set_data(g6_proxy("graph"), list(nodes = list(), edges = list()))
    })

    # Reset graph to initial state
    observeEvent(input$reset, {
      state <- initial_state()
      if (!is.null(state)) {
        g6_set_data(g6_proxy("graph"), state)
      }
    })

    output$state <- renderPrint({
      input[["graph-state"]]
    })
  }

  shinyApp(ui, server)
}
```
