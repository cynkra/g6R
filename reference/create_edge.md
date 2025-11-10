# Configure Create Edge Behavior

Creates a configuration object for the create-edge behavior in G6. This
allows users to create edges between nodes by clicking or dragging.

## Usage

``` r
create_edge(
  key = "create-edge",
  trigger = "drag",
  enable = FALSE,
  onCreate = NULL,
  onFinish = NULL,
  style = NULL,
  notify = FALSE,
  outputId = NULL,
  ...
)
```

## Arguments

- key:

  Behavior unique identifier. Useful to modify this behavior from JS
  side.

- trigger:

  The way to trigger edge creation: "click" or "drag" (string, default:
  "drag").

- enable:

  Whether to enable this behavior (boolean or function, default: FALSE).
  Our default implementation works in parallel with the
  [context_menu](https://cynkra.github.io/g6R/reference/context_menu.md)
  plugin which is responsible for activating the edge behavior when edge
  creation is selected.

- onCreate:

  Callback function for creating an edge, returns edge data (function,
  default: NULL).

- onFinish:

  Callback function for successfully creating an edge (function). By
  default, we provide an internal implementation that disables the edge
  mode when the edge creation is succesful so that it does not conflict
  with other drag behaviors.

- style:

  Style of the newly created edge (list, default: NULL).

- notify:

  Whether to show a feedback message in the ui.

- outputId:

  Manually pass the Shiny output ID. This is useful when the graph is
  initialised outside the shiny render function and the ID cannot be
  automatically inferred. This allows to set input values from the
  callback function with the right namespace and graph ID. You must
  typically pass `session$ns("graphid")` to ensure this also works in
  modules.

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/behavior/create-edge>.

## Value

A list with the configuration settings for the create-edge behavior.

## Note

create_edge,
[drag_element](https://cynkra.github.io/g6R/reference/drag_element.md)
and
[drag_element_force](https://cynkra.github.io/g6R/reference/drag_element_force.md)
are incompatible by default, as there triggers are the same. You can
change the trigger to workaround this.

## Examples

``` r
# Basic configuration
config <- create_edge()
```
