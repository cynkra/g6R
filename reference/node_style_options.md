# Create Node Style Options for G6 Graphs

Configures the styling options for nodes in a G6 graph. These settings
control the appearance and interaction behavior of nodes. Used in
[node_options](https://cynkra.github.io/g6R/reference/node_options.md).

## Usage

``` r
node_style_options(
  collapsed = FALSE,
  cursor = "default",
  fill = "#1783FF",
  fillOpacity = 1,
  increasedLineWidthForHitTesting = 0,
  lineCap = c("butt", "round", "square"),
  lineDash = NULL,
  lineDashOffset = NULL,
  lineJoin = c("miter", "round", "bevel"),
  lineWidth = 1,
  opacity = 1,
  shadowBlur = NULL,
  shadowColor = NULL,
  shadowOffsetX = NULL,
  shadowOffsetY = NULL,
  shadowType = c("outer", "inner"),
  size = 32,
  stroke = "#000",
  strokeOpacity = 1,
  transform = NULL,
  transformOrigin = NULL,
  visibility = c("visible", "hidden"),
  x = NULL,
  y = NULL,
  z = NULL,
  zIndex = NULL,
  ...
)
```

## Arguments

- collapsed:

  Whether the current node/group is collapsed. Default: FALSE.

- cursor:

  Node mouse hover cursor style. Common values include "default",
  "pointer", "move", etc. Default: "default".

- fill:

  Node fill color. Can be any valid CSS color value. Default: "#1783FF".

- fillOpacity:

  Node fill color opacity. Value between 0 and 1. Default: 1.

- increasedLineWidthForHitTesting:

  When lineWidth is small, this value increases the interactive area to
  make "thin lines" easier to interact with. Default: 0.

- lineCap:

  Node stroke end style. Options: "round", "square", "butt". Default:
  "butt".

- lineDash:

  Node stroke dash style. Vector of numbers specifying dash pattern.

- lineDashOffset:

  Node stroke dash offset. Default: NULL.

- lineJoin:

  Node stroke join style. Options: "round", "bevel", "miter". Default:
  "miter".

- lineWidth:

  Node stroke width. Default: 1.

- opacity:

  Node overall opacity. Value between 0 and 1. Default: 1.

- shadowBlur:

  Node shadow blur amount. Default: NULL.

- shadowColor:

  Node shadow color. Default: NULL.

- shadowOffsetX:

  Node shadow offset in the x-axis direction. Default: NULL.

- shadowOffsetY:

  Node shadow offset in the y-axis direction. Default: NULL.

- shadowType:

  Node shadow type. Options: "inner", "outer". Default: "outer".

- size:

  Node size. Can be a single number for equal width/height or a vector
  of two numbers `[width, height]`. Default: 32.

- stroke:

  Node stroke (border) color. Default: "#000".

- strokeOpacity:

  Node stroke color opacity. Value between 0 and 1. Default: 1.

- transform:

  CSS transform attribute to rotate, scale, skew, or translate the node.
  Default: NULL.

- transformOrigin:

  Rotation and scaling center point. Default: NULL.

- visibility:

  Whether the node is visible. Options: "visible", "hidden". Default:
  "visible".

- x:

  Node x coordinate. Default: 0.

- y:

  Node y coordinate. Default: 0.

- z:

  Node z coordinate (for 3D). Default: 0.

- zIndex:

  Node rendering level (for layering). Default: 0.

- ...:

  Other parameters.

## Value

A list containing node style options that can be passed to
[`node_options()`](https://cynkra.github.io/g6R/reference/node_options.md).

## Details

Node style options allow fine-grained control over how nodes are
rendered and behave in a G6 graph. This includes colors, sizes, borders,
shadows, visibility, positioning, and interaction states.

## Examples

``` r
# Basic node style with blue fill and red border
styles <- node_style_options(
  fill = "#1783FF",
  stroke = "#FF0000",
  lineWidth = 2
)

# Create a node with shadow effects
styles <- node_style_options(
  fill = "#FFFFFF",
  stroke = "#333333",
  lineWidth = 1,
  shadowBlur = 10,
  shadowColor = "rgba(0,0,0,0.3)",
  shadowOffsetX = 5,
  shadowOffsetY = 5
)

# Custom sized node with dashed border
styles <- node_style_options(
  size = c(100, 50),
  fill = "#E8F7FF",
  stroke = "#1783FF",
  lineDash = c(5, 5),
  opacity = 0.8
)
```
