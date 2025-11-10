# Configure Lasso Select Behavior

Creates a configuration object for the lasso-select behavior in G6. This
behavior allows selecting elements by drawing a lasso around them.

## Usage

``` r
lasso_select(
  key = "lasso-select",
  animation = FALSE,
  enable = TRUE,
  enableElements = "node",
  immediately = FALSE,
  mode = c("default", "union", "intersect", "diff"),
  onSelect = NULL,
  state = "selected",
  style = NULL,
  trigger = c("shift"),
  outputId = NULL,
  ...
)
```

## Arguments

- key:

  Unique identifier for the behavior (string, default: "lasso-select").

- animation:

  Whether to enable animation (boolean, default: FALSE).

- enable:

  Whether to enable lasso selection (boolean or JS function, default:
  TRUE).

- enableElements:

  Types of elements that can be selected (character vector, default:
  c("node", "combo", "edge")).

- immediately:

  Whether to select immediately, only effective when selection mode is
  default (boolean, default: FALSE).

- mode:

  Selection mode: "union", "intersect", "diff", or "default" (string,
  default: "default").

- onSelect:

  Callback for selected element state (JS function, default: NULL).

- state:

  State to switch to when selected (string, default: "selected").

- style:

  Style of the lasso during selection (list, default: NULL).

- trigger:

  Press this shortcut key along with mouse click to select (character
  vector, default: c("shift")).

- outputId:

  Manually pass the Shiny output ID. This is useful when the graph is
  initialised outside the shiny render function and the ID cannot be
  automatically inferred. This allows to set input values from the
  callback function with the right namespace and graph ID. You must
  typically pass `session$ns("graphid")` to ensure this also works in
  modules.

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/behavior/lasso-select>.

## Value

A list with the configuration settings for the lasso-select behavior.

## Examples

``` r
# Basic configuration
config <- lasso_select()

# Custom configuration
config <- lasso_select(
  key = "my-lasso-select",
  animation = TRUE,
  enableElements = c("node", "combo"),
  mode = "union",
  state = "highlight",
  trigger = c("control"),
  style = list(
    stroke = "#1890FF",
    lineWidth = 2,
    fillOpacity = 0.1
  )
)
```
