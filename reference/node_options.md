# Create Node Options Configuration for G6 Graphs

Configures the general options for nodes in a G6 graph. These settings
control the type, style, state, palette, and animation of nodes.

## Usage

``` r
node_options(
  type = c("circle", "rect", "ellipse", "diamond", "triangle", "star", "image",
    "modelRect"),
  style = node_style_options(),
  state = NULL,
  palette = NULL,
  animation = NULL
)
```

## Arguments

- type:

  Node type. Can be a built-in node type name or a custom node name.
  Built-in types include "circle", "rect", "ellipse", "diamond",
  "triangle", etc. Default: "circle".

- style:

  Node style configuration. Controls the appearance of nodes including
  color, size, border, etc. Can be created with
  [`node_style_options()`](https://cynkra.github.io/g6R/reference/node_style_options.md).
  Default: NULL.

- state:

  Defines the style of the node in different states, such as hover,
  selected, disabled, etc. Should be a list mapping state names to style
  configurations. Default: NULL.

- palette:

  Defines the color palette of the node, used to map colors based on
  different data. Default: NULL.

- animation:

  Defines the animation effect of the node. Can be created with
  [`animation_config()`](https://cynkra.github.io/g6R/reference/animation_config.md).
  Default: NULL.

## Value

A list containing node options configuration that can be passed to
[`g6_options()`](https://cynkra.github.io/g6R/reference/g6_options.md).

## Details

Node options allow defining how nodes appear and behave in a G6 graph.
This includes selecting node types, setting styles, configuring
state-based appearances, defining color palettes, and specifying
animation effects.

## Examples

``` r
# Basic node options with default circle type
options <- node_options()

# Rectangle node with custom style
options <- node_options(
  type = "rect",
  style = node_style_options(
    fill = "#E8F7FF",
    stroke = "#1783FF",
    lineWidth = 2
  )
)
```
