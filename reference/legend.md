# Configure Legend Plugin

Creates a configuration object for the legend plugin in G6. This plugin
adds a legend to the graph, allowing users to identify and interact with
different categories of elements.

## Usage

``` r
legend(
  key = "legend",
  trigger = c("hover", "click"),
  position = c("bottom", "top", "left", "right", "top-left", "top-right", "bottom-left",
    "bottom-right"),
  container = NULL,
  className = NULL,
  containerStyle = NULL,
  nodeField = NULL,
  edgeField = NULL,
  comboField = NULL,
  orientation = c("horizontal", "vertical"),
  layout = c("flex", "grid"),
  showTitle = FALSE,
  titleText = "",
  x = NULL,
  y = NULL,
  width = 240,
  height = 160,
  itemSpacing = 4,
  rowPadding = 10,
  colPadding = 10,
  itemMarkerSize = 16,
  itemLabelFontSize = 16,
  gridCol = NULL,
  gridRow = NULL,
  ...
)
```

## Arguments

- key:

  Unique identifier for the plugin (string, default: NULL).

- trigger:

  How legend items trigger highlighting: "hover" or "click" (string,
  default: "hover").

- position:

  Relative position of the legend on the canvas (string, default:
  "bottom").

- container:

  Container to which the legend is mounted (HTML element or string,
  default: NULL).

- className:

  Legend canvas class name (string, default: NULL).

- containerStyle:

  Style of the legend container (list or JS object, default: NULL).

- nodeField:

  Node classification identifier (string or JS function, default: NULL).

- edgeField:

  Edge classification identifier (string or JS function, default: NULL).

- comboField:

  Combo classification identifier (string or JS function, default:
  NULL).

- orientation:

  Layout direction: "horizontal" or "vertical" (string, default:
  "horizontal").

- layout:

  Layout method: "flex" or "grid" (string, default: "flex").

- showTitle:

  Whether to display the title (boolean, default: FALSE).

- titleText:

  Title content (string, default: "").

- x:

  Relative horizontal position (number, default: NULL).

- y:

  Relative vertical position (number, default: NULL).

- width:

  Width of the legend (number, default: 240).

- height:

  Height of the legend (number, default: 160).

- itemSpacing:

  Spacing between text and marker (number, default: 4).

- rowPadding:

  Spacing between rows (number, default: 10).

- colPadding:

  Spacing between columns (number, default: 10).

- itemMarkerSize:

  Size of the legend item marker (number, default: 16).

- itemLabelFontSize:

  Font size of the legend item text (number, default: 16).

- gridCol:

  Maximum number of columns for grid layout (number, default: NULL).

- gridRow:

  Maximum number of rows for grid layout (number, default: NULL).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/plugin/legend>.

## Value

A list with the configuration settings for the legend plugin.

## Examples

``` r
# Basic configuration for node categories
config <- legend(
  nodeField = "category"
)

# Advanced configuration
config <- legend(
  key = "my-legend",
  position = "top-right",
  nodeField = "type",
  edgeField = "relation",
  orientation = "vertical",
  layout = "grid",
  showTitle = TRUE,
  titleText = "Graph Elements",
  width = 300,
  height = 200,
  gridCol = 2,
  containerStyle = list(
    background = "#f9f9f9",
    border = "1px solid #ddd",
    borderRadius = "4px",
    padding = "8px"
  )
)

# Using a function for classification
config <- legend(
  nodeField = JS("(item) => {
    return item.data.importance > 0.5 ? 'Important' : 'Regular';
  }")
)
```
