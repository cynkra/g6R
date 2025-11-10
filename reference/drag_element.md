# Configure Drag Element Behavior

Creates a configuration object for the drag-element behavior in G6. This
allows users to drag nodes and combos in the graph.

## Usage

``` r
drag_element(
  key = "drag-element",
  enable = TRUE,
  animation = TRUE,
  state = "selected",
  dropEffect = c("move", "link", "none"),
  hideEdge = c("none", "out", "in", "both", "all"),
  shadow = FALSE,
  cursor = NULL,
  ...
)
```

## Arguments

- key:

  Unique identifier for the behavior, used for subsequent operations
  (string, default: NULL)

- enable:

  Whether to enable the drag function (boolean or function, default:
  function that enables dragging for nodes and combos).

- animation:

  Whether to enable drag animation (boolean, default: TRUE).

- state:

  Identifier for the selected state of nodes (string, default:
  "selected").

- dropEffect:

  Defines the operation effect after dragging ends: "link", "move", or
  "none" (string, default: "move").

- hideEdge:

  Controls the display state of edges during dragging: "none", "out",
  "in", "both", or "all" (string, default: "none").

- shadow:

  Whether to enable ghost nodes (boolean, default: FALSE).

- cursor:

  Customize the mouse style during dragging (list, default: NULL).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/behavior/drag-element>.

## Value

A list with the configuration settings for the drag-element behavior.

## Examples

``` r
# Basic configuration
config <- drag_element()

# Custom configuration
config <- drag_element(
  key = "my-drag-behavior",
  animation = FALSE,
  dropEffect = "link",
  hideEdge = "both",
  shadow = TRUE,
  cursor = list(
    default = "default",
    grab = "grab",
    grabbing = "grabbing"
  ),
  enable = JS(
   "(e) => {
     return e.targetType === 'node' || e.targetType === 'combo';
   }"
  )
)
```
