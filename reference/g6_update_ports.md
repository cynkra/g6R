# Update ports for one or more nodes in a g6 graph via proxy

This function sends a message to the client to update (add, remove, or
modify) ports for one or more nodes. The actual update is handled on the
JS side.

## Usage

``` r
g6_update_ports(graph, ids, ops)
```

## Arguments

- graph:

  A g6_proxy object.

- ids:

  Character vector of node IDs to update.

- ops:

  A named list of operations for each node. Each entry can contain:

  - `add`: a list of port objects to add.

  - `remove`: a character vector of port keys to remove

  - `update`: a list of port objects (with key) to update

## Value

The g6_proxy object.

## Details

Removing a port that is currently used by an edge removes the edge as
well. Conversely, removing an edge does not remove the ports it was
using.

## Examples

``` r
if (interactive()) {
  library(shiny)
  library(g6R)

  ui <- fluidPage(
    g6_output("graph", height = "500px"),
    actionButton("update_ports", "Update Ports")
  )

  server <- function(input, output, session) {
    output$graph <- render_g6({
      g6(
        nodes = g6_nodes(
          g6_node(
            id = "A",
            ports = g6_ports(
              g6_input_port(key = "in1", label = "in1", placement = "left"),
              g6_output_port(key = "out1", label = "out1", placement = "right"),
              g6_output_port(key = "out2", label = "out2", placement = c(1, 0.7))
            ),
            style = list(x = 100, y = 200, labelText = "Node A")
          ),
          g6_node(
            id = "B",
            ports = g6_ports(
              g6_input_port(key = "in2", label = "in2", placement = "left"),
              g6_output_port(key = "out3", label = "out3", placement = "right"),
              g6_output_port(key = "out4", label = "out4", placement = c(1, 0.3))
            ),
            style = list(x = 300, y = 200, labelText = "Node B")
          )
        ),
        edges = g6_edges(
          g6_edge(source = "A", target = "B", style = list(sourcePort = "out1", targetPort = "in2"))
        )
      ) |> g6_behaviors(click_select(), drag_element(), drag_canvas())
    })

    observeEvent(input$update_ports, {
      g6_update_ports(
        g6_proxy("graph"),
        c("A", "B"),
        list(
          A = list(remove = c("out1", "out2")),
          B = list(
            add = list(g6_port(key = "new", label = "new", placement = "top")),
            update = list(g6_port(key = "in2", label = "Updated label"))
          )
        )
      )
    })
  }

  shinyApp(ui, server)
}
```
