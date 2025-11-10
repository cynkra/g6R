# Create Edge Options Configuration for G6 Graphs

Configures the general options for edges in a G6 graph. These settings
control the type, style, state, palette, and animation of edges.

## Usage

``` r
edge_options(
  type = c("line", "polyline", "arc", "quadratic", "cubic", "cubic-vertical",
    "cubic-horizontal", "loop"),
  style = edge_style_options(),
  state = NULL,
  palette = NULL,
  animation = NULL
)
```

## Arguments

- type:

  Edge type. Can be a built-in edge type name or a custom edge name.
  Built-in types include "line", "polyline", "arc", "quadratic",
  "cubic", "cubic-vertical", "cubic-horizontal", "loop", etc. Default:
  "line".

- style:

  Edge style configuration. Controls the appearance of edges including
  color, width, dash patterns, etc. Can be created with
  [`edge_style_options()`](https://cynkra.github.io/g6R/reference/edge_style_options.md).
  Default: NULL.

- state:

  Defines the style of the edge in different states, such as hover,
  selected, disabled, etc. Should be a list mapping state names to style
  configurations. Default: NULL.

- palette:

  Defines the color palette of the edge, used to map colors based on
  different data. Default: NULL.

- animation:

  Defines the animation effect of the edge. Can be created with
  [`animation_config()`](https://cynkra.github.io/g6R/reference/animation_config.md).
  Default: NULL.

## Value

A list containing edge options configuration that can be passed to
[`g6_options()`](https://cynkra.github.io/g6R/reference/g6_options.md).

## Details

Edge options allow defining how edges appear and behave in a G6 graph.
This includes selecting edge types, setting styles, configuring
state-based appearances, defining color palettes, and specifying
animation effects.

## Examples

``` r
# Basic edge options with default line type
options <- edge_options()

# Curved edge with custom style
options <- edge_options(
  type = "cubic",
  style = edge_style_options(
    stroke = "#1783FF",
    lineWidth = 2,
    endArrow = TRUE
  )
)
```
