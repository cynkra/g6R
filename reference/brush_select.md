# Configure Brush Selection Interaction

Creates a configuration object for brush selection interaction in graph
visualizations. This function configures how elements are selected when
using a brush selection tool.

## Usage

``` r
brush_select(
  key = "brush-select",
  animation = FALSE,
  enable = JS("(e) => {\n      return true;\n    }"),
  enableElements = "node",
  immediately = FALSE,
  mode = c("default", "union", "intersect", "diff"),
  onSelect = NULL,
  state = c("selected", "active", "inactive", "disabled", "highlight"),
  style = NULL,
  trigger = "shift",
  outputId = NULL,
  ...
)
```

## Arguments

- key:

  Behavior unique identifier. Useful to modify this behavior from JS
  side.

- animation:

  Whether to enable animation (boolean, default: FALSE).

- enable:

  Whether to enable brush select functionality (boolean or function,
  default: TRUE).

- enableElements:

  Types of elements that can be selected (character vector, default:
  "node"). Can be `c("node", "edge", "combo")`.

- immediately:

  Whether to select immediately in default mode (boolean, default:
  FALSE).

- mode:

  Selection mode: "union", "intersect", "diff", or "default" (string,
  default: "default").

- onSelect:

  Callback for selected element state (JS function).

- state:

  State to switch to when selected (string, default: "selected").

- style:

  Style specification for the selection box (list). See
  <https://g6.antv.antgroup.com/en/manual/behavior/brush-select#style>.

- trigger:

  Shortcut keys for selection (character vector).

- outputId:

  Manually pass the Shiny output ID. This is useful when the graph is
  initialised outside the shiny render function and the ID cannot be
  automatically inferred. This allows to set input values from the
  callback function with the right namespace and graph ID. You must
  typically pass `session$ns("graphid")` to ensure this also works in
  modules.

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/behavior/brush-select>.

## Value

A list with the configuration settings for the brush select behavior.

## Examples

``` r
# Basic configuration
config <- brush_select()

# Custom configuration
config <- brush_select(
  animation = TRUE,
  enableElements = c("node", "edge"),
  mode = "union",
  state = "highlight",
  style = list(
    fill = "rgba(0, 0, 255, 0.1)",
    stroke = "blue",
    lineWidth = 2
  ),
  trigger = c("Shift")
)
```
