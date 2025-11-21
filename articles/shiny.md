# Shiny

## Introduction

[g6R](https://github.com/cynkra/g6R) can be easily integrated into Shiny
applications using the
[`g6_output()`](https://cynkra.github.io/g6R/reference/g6-shiny.md) and
[`render_g6()`](https://cynkra.github.io/g6R/reference/g6-shiny.md)
functions:

``` r
library(shiny)
library(g6R)
library(bslib)

nodes <- data.frame(id = 1:5)
edges <- data.frame(
  source = c(1, 2, 3, 4),
  target = c(2, 3, 4, 5)
)
    

ui <- page_fluid(
  title = "g6R Shiny Example",
  g6_output("graph")
)

server <- function(input, output, session) {
  output$graph <- render_g6({
    g6(
      nodes = nodes, 
      edges = edges
    ) |> 
      g6_layout()
  })
}

shinyApp(ui, server)
```

## Leverage proxy functions

In Shiny applications, you can use [g6R](https://github.com/cynkra/g6R)
**proxy** functions to dynamically update the graph without
**re-rendering** it entirely. This allows for a more responsive user
experience. For example, you can add nodes or edges, update plugins and
behaviors.

### Example: Adding nodes dynamically

#### What you should not do

Why is the below example wrong? Looking at it carefully, we introduce a
reactive dependency between `nodes()` and the
[`render_g6()`](https://cynkra.github.io/g6R/reference/g6-shiny.md)
expression. When the button is clicked, `nodes()` is updated, which
causes the entire graph to be re-rendered. This is inefficient and
negates the benefits of using proxy functions.

``` r
# Bad example of adding node the graph
library(shiny)
library(g6R)
library(bslib)

ui <- page_fluid(
  title = "Add Nodes Dynamically",
  g6_output("graph"),
  actionButton("add_node", "Add Node")
)

server <- function(input, output, session) {
  nodes <- reactiveVal(data.frame(id = 1:3))
  edges <- data.frame(source = c(1, 2), target = c(2, 3))

  proxy <- g6_proxy("graph")

  output$graph <- render_g6({
    g6(nodes = nodes(), edges = edges) |> g6_layout()
  })

  observeEvent(input$add_node, {
    new_id <- max(nodes()$id) + 1
    g6_add_nodes(proxy, data.frame(id = new_id))
    nodes(rbind(nodes(), data.frame(id = new_id)))
  })
}

shinyApp(ui, server)
```

#### The proper way

A corrected version would be:

``` r
library(shiny)
library(g6R)
library(bslib)

# Static data defined globally
nodes <- data.frame(id = 1:3)
edges <- data.frame(source = c(1, 2), target = c(2, 3))

ui <- page_fluid(
  title = "Add Nodes Dynamically",
  g6_output("graph"),
  actionButton("add_node", "Add Node")
)

server <- function(input, output, session) {
  output$graph <- render_g6({
    g6(nodes = nodes, edges = edges) |> g6_layout()
  })

  next_id <- reactiveVal(max(nodes$id) + 1)

  observeEvent(input$add_node, {
    g6_add_nodes(g6_proxy("graph"), data.frame(id = next_id()))
    next_id(next_id() + 1)
  })
}

shinyApp(ui, server)
```

[`g6_add_nodes()`](https://cynkra.github.io/g6R/reference/g6-add.md)
accepts many different syntax, even though the recommended way is to use
a data frame or
[`g6_node()`](https://cynkra.github.io/g6R/reference/g6_element.md)
objects to avoid confusions. Besides,
[`g6_node()`](https://cynkra.github.io/g6R/reference/g6_element.md)
offers data validation out of the box. Here are some examples that all
work:

``` r
g6_add_nodes(g6_proxy("graph"), data.frame(id = next_id()))

g6_add_nodes(
  g6_proxy("graph"), 
  g6_node(id = next_id())
)

g6_add_nodes(
  g6_proxy("graph"), 
  g6_nodes(
    g6_node(id = next_id())
  )
)

g6_add_nodes(
  g6_proxy("graph"), 
  list(
    list(id = next_id())
  )
)

g6_add_nodes(
  g6_proxy("graph"), 
  list(id = next_id())
)
```

### Example: remove and update nodes

To remove a node, you can use the
[`g6_remove_nodes()`](https://cynkra.github.io/g6R/reference/g6-remove.md)
proxy function:

``` r
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
```

[`g6_remove_nodes()`](https://cynkra.github.io/g6R/reference/g6-remove.md)
expects a vector of node IDs to remove from the graph.

Similarly, to update node properties, you can use the
[`g6_update_nodes()`](https://cynkra.github.io/g6R/reference/g6-update.md)
function. Here’s an example where we update the label of a node:

``` r
library(shiny)
library(g6R)
library(bslib)

# Static data defined globally
nodes <- data.frame(id = 1:3)
edges <- data.frame(source = c(1, 2), target = c(2, 3))

ui <- page_fluid(
  title = "Update Nodes Dynamically",
  g6_output("graph"),
  actionButton("update_node", "Update Node 1 Label")
)

server <- function(input, output, session) {
  output$graph <- render_g6({
    g6(nodes = nodes, edges = edges) |> g6_layout()
  })

  observeEvent(input$update_node, {
    # Update label for node 1
    g6_update_nodes(
      g6_proxy("graph"),
      g6_node(id = 1, style = list(labelText = "Node label updated"))
    )
  })
}

shinyApp(ui, server)
```

[`g6_update_nodes()`](https://cynkra.github.io/g6R/reference/g6-update.md)
expects one or more
[`g6_node()`](https://cynkra.github.io/g6R/reference/g6_element.md)
objects with updated properties, `id` being required to identify which
node to update. As you notice below, different syntax work but the
easiest one is to have any number of
[`g6_node()`](https://cynkra.github.io/g6R/reference/g6_element.md)
object:

``` r
# Recommanded way
g6_update_nodes(
  g6_proxy("graph"),
  g6_node(id = 1, style = list(labelText = "Node label updated"))
)

g6_update_nodes(
  g6_proxy("graph"),
  list(
    g6_node(id = 1, style = list(labelText = "Node label updated"))
  )
)

g6_update_nodes(
  g6_proxy("graph"),
  list(
    list(id = 1, style = list(labelText = "Node label updated"))
  )
)

g6_update_nodes(
  g6_proxy("graph"),
  data.frame(
    id = 1,
    style = I(list(labelText = "Node label updated"))
  )
)

g6_update_nodes(
  g6_proxy("graph"),
  g6_nodes(
    g6_node(id = 1, style = list(labelText = "Node label updated"))
  )
```

The more challenging part is likely to find which propertie to update.
For this you can look at the nodes
[vignette](https://cynkra.github.io/g6R/articles/nodes.html) where we
document the main options. To unleash the full power of G6, please look
at the original
[API](https://g6.antv.antgroup.com/en/manual/element/node/base-node).

### Example: change the state of nodes

You can also change the state of nodes using the
[`g6_set_nodes()`](https://cynkra.github.io/g6R/reference/g6-set.md).
Here’s an example:

``` r
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
```

The [`g6_set_nodes()`](https://cynkra.github.io/g6R/reference/g6-set.md)
function expects a named list where names are node IDs and values are
the states to set. Element states are defined
[here](https://g6.antv.antgroup.com/en/manual/element/state#what-is-element-state).

All these proxy functions are available for edges and combos as well.

## Available Shiny inputs

### Graph readiness

To perform actions on the graph, it is better to wait its full
initialisation. You can do so by observing the
`input[["<GRAPH_ID>-initialized"]]` input, which will be set to `TRUE`
once the graph is ready:

``` r
library(shiny)
library(g6R)
library(bslib)

nodes <- data.frame(id = 1:2)
edges <- data.frame(source = 1, target = 2)

ui <- page_fluid(
  g6_output("graph")
)

server <- function(input, output, session) {
  output$graph <- render_g6({
    g6(nodes = nodes, edges = edges) |> g6_layout()
  })

  observeEvent(input[["graph-initialized"]], {
    showNotification("Graph is ready!", type = "message")
  }, ignoreInit = TRUE)
}

shinyApp(ui, server)
```

As an example, this is what would happen if you try to add nodes before
the graph is initialized (nothing would happen):

``` r
library(shiny)
library(g6R)
library(bslib)

nodes <- data.frame(id = 1:3)
edges <- data.frame(source = c(1, 2), target = c(2, 3))

ui <- page_fluid(
  title = "Remove Node Before Graph Ready",
  g6_output("graph")
)

server <- function(input, output, session) {
  output$graph <- render_g6({
    g6(nodes = nodes, edges = edges) |> g6_layout()
  })

  g6_remove_nodes(g6_proxy("graph"), 1)
}

shinyApp(ui, server)
```

Now waiting for the graph to be ready before removing the node works as
expected:

``` r
library(shiny)
library(g6R)
library(bslib)

nodes <- data.frame(id = 1:3)
edges <- data.frame(source = c(1, 2), target = c(2, 3))

ui <- page_fluid(
  title = "Remove Node Before Graph Ready",
  g6_output("graph")
)

server <- function(input, output, session) {
  output$graph <- render_g6({
    g6(nodes = nodes, edges = edges) |> g6_layout()
  })

  observeEvent(input[["graph-initialized"]], {
    g6_remove_nodes(g6_proxy("graph"), 1)
  })
}

shinyApp(ui, server)
```

### Current element selection

How to know which element is selected? You can retrieve the currently
selected nodes, edges, and combos using the following pattern:
`input[["<GRAPH_ID>-selected_<ELEMENT_TYPE>"]]`, where `<ELEMENT_TYPE>`
can be `node`, `edge`, or `combo`. Here’s an example that demonstrates
how to capture selected elements in a graph:

``` r
library(shiny)
library(g6R)
library(bslib)

nodes <- data.frame(id = c("node1", "node2"))
edges <- data.frame(source = "node1", target = "node2")
combos <- data.frame(id = "combo1", type = "rect")

ui <- page_fluid(
  g6_output("graph"),
  verbatimTextOutput("selected_elements")
)

server <- function(input, output, session) {
  output$graph <- render_g6({
    g6(
      nodes = nodes,
      edges = edges,
      combos = combos
    ) |>
      g6_layout() |>
      g6_behaviors(
        click_select(multiple = TRUE),
        brush_select(
          enableElements = c("node", "edge", "combo"),
          immediately = TRUE
        )
      )
  })

  output$selected_elements <- renderPrint({
    list(
      selected_nodes = input[["graph-selected_node"]],
      selected_edges = input[["graph-selected_edge"]],
      selected_combos = input[["graph-selected_combo"]]
    )
  })
}

shinyApp(ui, server)
```

In this example, you can select elements and multiselect by pressing
shift key. The selected elements’ IDs are be displayed in the verbatim
text output. When you press shift and brush with the mouse, all elements
within the brush area are selected. Maintaining shift again while
clicking allows to unselect some elements.

### Graph state

In Shiny applications, you can retrieve the current state of the graph
using `input[["<GRAPH_ID>-state"]]`. This allows you to access
information about nodes, edges, and combos dynamically, also be able to
serialise and deserialise the graph state:

``` r
library(shiny)
library(g6R)
library(bslib)

nodes <- data.frame(id = 1:2)
edges <- data.frame(source = 1, target = 2)

ui <- page_fluid(
  g6_output("graph"),
  verbatimTextOutput("state")
)

server <- function(input, output, session) {
  output$graph <- render_g6({
    g6(nodes = nodes, edges = edges) |>
      g6_layout() |>
      # animation turned of for performance reasons
      g6_options(animation = FALSE)
  })

  output$state <- renderPrint({
    input[["graph-state"]]
  })
}

shinyApp(ui, server)
```

A clever usage of the state comes with
[`g6_set_data()`](https://cynkra.github.io/g6R/reference/g6-set.md)
proxy function, which allows you to reset the graph data to a previous
state. Below, we provide an example where we store the initial state of
the graph after the first render, then we provide buttons to remove all
nodes and edges, and reset the graph to its initial state. The state
storage is of course not optimal for larger data but you get the idea:

``` r
library(shiny)
library(g6R)
library(bslib)

nodes <- data.frame(id = 1:2)
edges <- data.frame(source = 1, target = 2)

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
```

Note that you can also add data to a graph using the
[`g6_add_data()`](https://cynkra.github.io/g6R/reference/g6-add.md)
proxy function, which appends nodes, edges, and combos to the existing
graph data.

If you’d need to get only a subset of the graph state, you can also
query nodes, edges or combos states. The pattern is
`input[["<GRAPH_ID>-<ELEMENT_ID>-state"]]`, where `<ELEMENT_ID>` is the
id of the node, edge or combo you want to query. Here’s an example
querying node states:

``` r
library(shiny)
library(g6R)
library(bslib)

nodes <- data.frame(id = 1:2)
edges <- data.frame(source = 1, target = 2)

ui <- page_fluid(
  g6_output("graph"),
  actionButton("query_state", "Query Node States"),
  verbatimTextOutput("node_info")
)

server <- function(input, output, session) {
  output$graph <- render_g6({
    g6(nodes = nodes, edges = edges) |>
      g6_layout()
  })

  # Query node states when button is clicked
  observeEvent(input$query_state, {
    g6_get_nodes(g6_proxy("graph"), c(1, 2))
  })

  # Display node states
  output$node_info <- renderPrint({
    list(
      node1_state = input[["graph-1-state"]],
      node2_state = input[["graph-2-state"]]
    )
  })
}

shinyApp(ui, server)
```

### Handle right click: context menu

If you enable the **context menu** behavior, you can recover the **right
clicked** element by `input[["<GRAPH_ID>-contextmenu"]]` which contains
the type and ID of right clicked element, except for the canvas where
only the `type` is returned. Here’s an example:

``` r
library(shiny)
library(g6R)
library(bslib)

nodes <- data.frame(id = c("node1", "node2"))
edges <- data.frame(source = "node1", target = "node2")

ui <- page_fluid(
  g6_output("graph"),
  verbatimTextOutput("contextmenu_info")
)

server <- function(input, output, session) {
  output$graph <- render_g6({
    g6(
      nodes = nodes,
      edges = edges
    ) |>
      g6_layout() |>
      g6_plugins(
        context_menu()
      )
  })

  output$contextmenu_info <- renderPrint({
    input[["graph-contextmenu"]]
  })
}

shinyApp(ui, server)
```

### Mouse position

#### Insert a node where the mouse is clicked

You can retrieve the mouse position on the graph using
`input[["<GRAPH_ID>-mouse_position"]]`. This input provides the `x` and
`y` coordinates of the mouse relative to the graph canvas. Here’s an
example that demonstrates how to insert a new node at the mouse click
position:

``` r
library(shiny)
library(g6R)
library(bslib)

nodes <- data.frame(id = 1)

ui <- page_fluid(
  g6_output("graph")
)

server <- function(input, output, session) {
  output$graph <- render_g6({
    g6(nodes = nodes) |> 
      g6_layout() |>
      g6_options(animation = FALSE)
  })

  next_id <- reactiveVal(2)

  observeEvent(input[["graph-mouse_position"]], {
    pos <- input[["graph-mouse_position"]]
    g6_proxy("graph") |>
    g6_add_nodes(
      g6_node(
        id = next_id(), 
        style = list(x = pos$x, y = pos$y)
      )
    )
    next_id(next_id() + 1)
  })
}

shinyApp(ui, server)
```

Be mindful of the canvas borders. Clicking outside the borders won’t do
anything.

#### Create a node at the drop edge position

We can lerevage the
[`create_edge()`](https://cynkra.github.io/g6R/reference/create_edge.md)
behavior to create an edge on drag from a node by maintaining the shift
key:

``` r
library(shiny)
library(g6R)
library(bslib)

nodes <- data.frame(id = 1)

ui <- page_fluid(
  g6_output("graph")
)

server <- function(input, output, session) {
  output$graph <- render_g6({
    g6(nodes = nodes) |>
      g6_layout() |>
      g6_behaviors(
        create_edge(
          enable = JS("
            (e) => { return e.shiftKey; }"
          ),
          onFinish = JS(
            "(edge) => {
              const graph = HTMLWidgets.find('#graph').getWidget();
              const targetType = graph.getElementType(edge.target);
              if (targetType !== 'node') {
                graph.removeEdgeData([edge.id]);
              } else {
                Shiny.setInputValue('added_edge', edge);
              }
            }"
          )
        )
      )
  })

  next_id <- reactiveVal(2)

  observeEvent(input$added_edge, {
    edge <- input$added_edge
    pos <- input[["graph-mouse_position"]]
    # Only add node if released on canvas
    if (edge$targetType == "canvas") {
      # Add new node at drop position
      g6_proxy("graph") |>
      g6_add_nodes(
        g6_node(
          id = next_id(), 
          style = list(x = pos$x, y = pos$y)
        )
      )
      # Connect source node to new node
      g6_proxy("graph") |>
      g6_add_edges(
        g6_edge(source = edge$source, target = next_id())
      )
      next_id(next_id() + 1)
    }
  })
}

shinyApp(ui, server)
```

### Modifying plugins and behaviors

#### Plugins

You can dynamically add or remove plugins using the `g6_add_plugins()`
and `g6_update_plugins()` proxy functions. It is mandatory to initialise
the plugin with a **key** that serves as ID to identify it for later
updates. By default, the **key** is set to the element type, however, if
you had to use multiple elements, you must pass unique keys. Here’s an
example:

``` r
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
```

#### Behaviors

You can also dynamically add or remove behaviors using the
`g6_add_behavior()` and
[`g6_update_behavior()`](https://cynkra.github.io/g6R/reference/g6_update_behavior.md)
proxy functions. Here’s an example:

``` r
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
```
