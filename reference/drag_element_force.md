# Configure Drag Element Force Behavior

Creates a configuration object for the drag-element-force behavior in
G6. This allows users to drag nodes and combos with force-directed
layout interactions.

## Usage

``` r
drag_element_force(
  key = "drag-element-force",
  fixed = FALSE,
  enable = NULL,
  state = "selected",
  hideEdge = c("none", "out", "in", "both", "all"),
  cursor = NULL,
  ...
)
```

## Arguments

- key:

  Unique identifier for the behavior, used for subsequent operations
  (string, default: "drag-element-force").

- fixed:

  Whether to keep the node position fixed after dragging ends (boolean,
  default: FALSE).

- enable:

  Whether to enable the drag function (boolean or JS function, default:
  JS function that enables dragging for nodes and combos).

- state:

  Identifier for the selected state of nodes (string, default:
  "selected").

- hideEdge:

  Controls the display state of edges during dragging: "none", "out",
  "in", "both", or "all" (string, default: "none").

- cursor:

  Customize the mouse style during dragging (list, default: NULL).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/behavior/drag-element-force>.

## Value

A list with the configuration settings for the drag-element-force
behavior.

## Examples

``` r
# Basic configuration
config <- drag_element_force()

# Custom configuration with JavaScript arrow function and custom key
config <- drag_element_force(
  key = "my-custom-drag-force",
  fixed = TRUE,
  enable = JS("(event) => { return event.targetType === 'node'; }"),
  hideEdge = "both",
  cursor = list(
    default = "default",
    grab = "grab",
    grabbing = "grabbing"
  )
)
```
