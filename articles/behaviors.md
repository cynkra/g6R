# Behaviors

## Introduction

Behaviors are actions that can be applied to the graph, such as zooming,
panning, or selecting nodes. They can be added to the graph using the
[`g6_behaviors()`](https://cynkra.github.io/g6R/reference/g6_behaviors.md)
function. There are 2 ways to add behaviors to the graph. Either calling
behaviors name as a string, or passing behaviors functions. The latter
is more convenient to have more control over the specific options:

``` r
# Defaults
g6() |>
g6_behaviors("drag-canvas", "zoom-canvas")

# Fine tune parameters
g6() |>
  g6_behaviors(
    drag_canvas(
      key = "drag-canvas", 
      enable = TRUE,
      animation = NULL, 
      direction = c("both", "x", "y"),
      range = Inf,
      sensitivity = 10, 
      trigger = NULL,
      onFinish = NULL,
      ... # extra options
    ),
    create_edge(
      key = "create-edge",
      trigger = "drag",
      enable = FALSE, 
      onCreate = NULL,
      onFinish = NULL,
      style = NULL,
      notify = FALSE
    )
  )
```

## Brush Select

Enables rectangular brush selection for selecting multiple elements at
once. By default, the selection is made by clicking on shift and draging
the mouse over the canvas.

``` r
nodes <- data.frame(id = letters[1:5])

g6(nodes) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        )
      )
    )
  ) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(" brush-select ")
```

------------------------------------------------------------------------

## Click Select

Allows selection of elements through mouse clicks. You can also select
multiple elements by clicking on them while holding the shift key and
enabling the option `multiple = TRUE`.

``` r
nodes <- data.frame(id = letters[1:5])

g6(nodes) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        )
      )
    )
  ) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(" click-select ")
```

------------------------------------------------------------------------

## Drag Canvas

Allows dragging the entire canvas to pan the view. May be incompatible
with other behaviors such as `create-edge` depending on the trigger key.

``` r
nodes <- data.frame(id = letters[1:5])

g6(nodes) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        )
      )
    )
  ) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(" drag-canvas ")
```

------------------------------------------------------------------------

## Drag Element

Enables dragging individual elements to reposition them. May be
incompatible with other behaviors such as `create-edge` depending on the
trigger key.

``` r
nodes <- data.frame(id = letters[1:5])

g6(nodes) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        )
      )
    )
  ) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(" drag-element ")
```

------------------------------------------------------------------------

## Focus Element

Provides focusing capabilities to highlight specific elements. Click on
a given element and see the canvas focusing on it.

``` r
nodes <- data.frame(id = letters[1:5])

g6(nodes) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        )
      )
    )
  ) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(" focus-element ")
```

------------------------------------------------------------------------

## Hover Activate

Activates interactive features when hovering over elements.

``` r
nodes <- data.frame(id = letters[1:5])

g6(nodes) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        )
      )
    )
  ) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(" hover-activate ")
```

------------------------------------------------------------------------

## Lasso Select

Enables free-form lasso selection for selecting multiple elements. By
default, the selection is made by clicking on shift and draging the
mouse over the canvas.

``` r
nodes <- data.frame(id = letters[1:5])

g6(nodes) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        )
      )
    )
  ) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(" lasso-select ")
```

------------------------------------------------------------------------

## Scroll Canvas

Enables scrolling to navigate through large graphs.

``` r
nodes <- data.frame(id = letters[1:5])

g6(nodes) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        )
      )
    )
  ) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(" scroll-canvas ")
```

------------------------------------------------------------------------

## Zoom Canvas

Provides zooming functionality for the canvas view.

``` r
nodes <- data.frame(id = letters[1:5])

g6(nodes) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        )
      )
    )
  ) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(" zoom-canvas ")
```

------------------------------------------------------------------------

## Auto adapt label

Automatically adapts label positioning to avoid overlaps and improve
readability. This adjusts the label position based on the node’s size
and position, ensuring that labels are not overlapping with other
elements. It works well with `zoom-canvas` and `scroll-canvas`
behaviors.

``` r
g6(nodes) |>
  g6_options(
    animation = FALSE,
    node = nodes_options
  ) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(
    "auto-adapt-label",
    "zoom-canvas",
    "scroll-canvas"
  )
```

## Fix element size

Maintains fixed element sizes during transformations such as zooming or
panning. This is useful for ensuring that elements remain visually
consistent regardless of the zoom level or canvas position.

``` r
g6(nodes) |>
  g6_options(
    animation = FALSE,
    node = nodes_options
  ) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(
    "fix-element-size",
    "zoom-canvas",
    "scroll-canvas"
  )
```

## Optimize viewport transform

Optimizes viewport transformations for better performance. This works
well if the graph has many nodes and edges and if the hardware has
limited resources. Edges are hidden when zooming in and out.

``` r
g6(jsonUrl = "https://assets.antv.antgroup.com/g6/5000.json") |>
  g6_options(
    animation = FALSE,
    node = nodes_options
  ) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(
    "optimize-viewport-transform",
    "zoom-canvas",
    "scroll-canvas"
  )
```

## Create edge

It enables interactive creation of new edges between nodes. You can drag
from one node to another to create an edge and also change the trigger
if you want to press another key to start the edge creation. By default,
the `create-edge` behavior is disabled, so you need to enable it
explicitly. This is to avoid accidental edge creation when dragging
nodes or panning the canvas. In practice, you can use it it in
combination with the `contextmenu()` plugin which allows you to
right-click on a node to create an edge.

### Manual activation

``` r
g6(nodes) |>
  g6_options(
    animation = FALSE,
    node = nodes_options
  ) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(create_edge(enable = TRUE))
```

### With context menu

``` r
g6(nodes) |>
  g6_options(
    animation = FALSE,
    node = nodes_options
  ) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(create_edge()) |>
  g6_plugins(context_menu())
```

## Collapse and expand

This provides functionality to collapse and expand graph structures.
This works in a combo context when you double click (default) on the
enclosing combo.

``` r
nodes$combo <- rep(1, nrow(nodes))
g6(nodes, combos = data.frame(id = 1)) |>
  g6_options(
    animation = FALSE,
    node = nodes_options
  ) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors("collapse-expand")
```

## Drag element force

Combines element dragging with force simulation for dynamic positioning.
This requires animation to be enabled in
[`g6_options()`](https://cynkra.github.io/g6R/reference/g6_options.md).

``` r
nodes <- data.frame(id = letters[1:5])

g6(
  nodes,
  edges = data.frame(
    source = c("a", "b", "c", "d"),
    target = c("b", "c", "d", "e")
  )
) |>
  g6_options(
    nodes = nodes_options
  ) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(drag_element_force(fixed = TRUE))
```

## Dynamically interact with behaviors

### Add

TBD?

### Update

To update behavior from the server of a Shiny app, you can use the
[`g6_update_behavior()`](https://cynkra.github.io/g6R/reference/g6_update_behavior.md)
function. This function allows you to modify the behaviors of an
existing G6 graph.
