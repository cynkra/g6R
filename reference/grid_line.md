# Configure Grid Line Plugin

Creates a configuration object for the grid-line plugin in G6. This
plugin adds a background grid to the graph canvas.

## Usage

``` r
grid_line(
  key = "grid-line",
  border = TRUE,
  borderLineWidth = 1,
  borderStroke = "#eee",
  borderStyle = "solid",
  follow = FALSE,
  lineWidth = 1,
  size = 20,
  stroke = "#eee",
  ...
)
```

## Arguments

- key:

  Unique identifier for the plugin (string, default: NULL).

- border:

  Whether to display the border (boolean, default: TRUE).

- borderLineWidth:

  Border line width (number, default: 1).

- borderStroke:

  Border color (string, default: "#eee").

- borderStyle:

  Border style (string, default: "solid").

- follow:

  Whether the grid follows canvas movements (boolean or list, default:
  FALSE).

- lineWidth:

  Grid line width (number or string, default: 1).

- size:

  Grid unit size in pixels (number, default: 20).

- stroke:

  Grid line color (string, default: "#eee").

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/plugin/grid-line>.

## Value

A list with the configuration settings for the grid-line plugin.

## Examples

``` r
# Basic configuration
config <- grid_line()

# Custom configuration
config <- grid_line(
  key = "my-grid",
  border = TRUE,
  borderLineWidth = 2,
  borderStroke = "#ccc",
  borderStyle = "dashed",
  follow = list(
    translate = TRUE,
    zoom = FALSE
  ),
  lineWidth = 0.5,
  size = 30,
  stroke = "#e0e0e0"
)
```
