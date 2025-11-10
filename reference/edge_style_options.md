# Create Edge Style Options for G6 Graphs

Configures the styling options for edges in a G6 graph. These settings
control the appearance and interaction behavior of edges.

## Usage

``` r
edge_style_options(
  class = NULL,
  cursor = valid_cursors,
  fill = NULL,
  fillRule = c("nonzero", "evenodd"),
  filter = NULL,
  increasedLineWidthForHitTesting = NULL,
  isBillboard = TRUE,
  lineDash = 0,
  lineDashOffset = 0,
  lineWidth = 1,
  opacity = 1,
  pointerEvents = NULL,
  shadowBlur = NULL,
  shadowColor = NULL,
  shadowOffsetX = NULL,
  shadowOffsetY = NULL,
  shadowType = NULL,
  sourcePort = NULL,
  stroke = "#000",
  strokeOpacity = 1,
  targetPort = NULL,
  transform = NULL,
  transformOrigin = NULL,
  visibility = c("visible", "hidden"),
  zIndex = -10000,
  ...
)
```

## Arguments

- class:

  Edge class name for custom styling with CSS. Default: NULL.

- cursor:

  Edge mouse hover cursor style. Common values include "default",
  "pointer", "move", etc. Default: "default".

- fill:

  Edge area fill color (for edges with area, like loops). Default: NULL.

- fillRule:

  Edge internal fill rule. Options: "nonzero", "evenodd". Default: NULL.

- filter:

  Edge shadow filter effect. Default: NULL.

- increasedLineWidthForHitTesting:

  When the edge width is too small, this value increases the interaction
  area to make edges easier to interact with. Default: NULL.

- isBillboard:

  Effective in 3D scenes, always facing the screen so the line width is
  not affected by perspective projection. Default: TRUE.

- lineDash:

  Edge dashed line style. Numeric vector specifying dash pattern.
  Default: 0.

- lineDashOffset:

  Edge dashed line offset. Default: 0.

- lineWidth:

  Edge width in pixels. Default: 1.

- opacity:

  Overall opacity of the edge. Value between 0 and 1. Default: 1.

- pointerEvents:

  Whether the edge responds to pointer events. Default: NULL.

- shadowBlur:

  Edge shadow blur effect amount. Default: NULL.

- shadowColor:

  Edge shadow color. Default: NULL.

- shadowOffsetX:

  Edge shadow X-axis offset. Default: NULL.

- shadowOffsetY:

  Edge shadow Y-axis offset. Default: NULL.

- shadowType:

  Edge shadow type. Options: "inner", "outer", "both". Default: NULL.

- sourcePort:

  Source port of the edge connection. Default: NULL.

- stroke:

  Edge color. Default: "#000".

- strokeOpacity:

  Edge color opacity. Value between 0 and 1. Default: 1.

- targetPort:

  Target port of the edge connection. Default: NULL.

- transform:

  CSS transform attribute to rotate, scale, skew, or translate the edge.
  Default: NULL.

- transformOrigin:

  Rotation and scaling center point. Default: NULL.

- visibility:

  Whether the edge is visible. Options: "visible", "hidden". Default:
  "visible".

- zIndex:

  Edge rendering level (for layering). Default: 1.

- ...:

  Extra parameters.

## Value

A list containing edge style options that can be passed to
[`edge_options()`](https://cynkra.github.io/g6R/reference/edge_options.md).

## Details

Edge style options allow fine-grained control over how edges are
rendered and behave in a G6 graph. This includes colors, widths, line
styles, shadows, visibility, and interaction properties.
