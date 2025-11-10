# Configure Global Options for G6 Graph

Sets up the global configuration options for a G6 graph including node,
edge and combo styles, layout, canvas, animation, and interactive
behavior settings.

## Usage

``` r
g6_options(
  graph,
  node = NULL,
  edge = NULL,
  combo = NULL,
  autoFit = NULL,
  canvas = NULL,
  animation = TRUE,
  autoResize = FALSE,
  background = NULL,
  cursor = valid_cursors,
  devicePixelRatio = NULL,
  renderer = NULL,
  padding = NULL,
  rotation = 0,
  x = NULL,
  y = NULL,
  zoom = 1,
  zoomRange = c(0.01, 10),
  theme = "light",
  ...
)
```

## Arguments

- graph:

  g6 graph instance.

- node:

  Node configuration. Controls the default appearance and behavior of
  nodes. Created with
  [`node_options()`](https://cynkra.github.io/g6R/reference/node_options.md).
  Default: NULL.

- edge:

  Edge configuration. Controls the default appearance and behavior of
  edges. Created with
  [`edge_options()`](https://cynkra.github.io/g6R/reference/edge_options.md).
  Default: NULL.

- combo:

  Combo configuration. Controls the default appearance and behavior of
  combo nodes. Created with
  [`combo_options()`](https://cynkra.github.io/g6R/reference/combo_options.md).
  Default: NULL.

- autoFit:

  Automatically fit the graph content to the canvas. Created with
  [`auto_fit_config()`](https://cynkra.github.io/g6R/reference/auto_fit_config.md).
  Default: NULL.

- canvas:

  Canvas configuration for the graph rendering surface. Created with
  [`canvas_config()`](https://cynkra.github.io/g6R/reference/canvas_config.md).
  Default: NULL.

- animation:

  Global animation configuration for graph transitions. Created with
  [`animation_config()`](https://cynkra.github.io/g6R/reference/animation_config.md).
  Default: TRUE.

- autoResize:

  Whether the graph should automatically resize when the window size
  changes. Default: FALSE.

- background:

  Background color of the graph. If not specified, the background will
  be transparent. Default: NULL.

- cursor:

  Default mouse cursor style when hovering over the graph. Options
  include: "default", "pointer", "move", etc. Default: "default".

- devicePixelRatio:

  Device pixel ratio for rendering on high-DPI displays. If NULL, the
  browser's default device pixel ratio will be used. Default: NULL.

- renderer:

  Rendering engine to use. Options: "canvas", "svg", "webgl", or
  "webgpu". Default: NULL (G6 will choose the appropriate renderer).

- padding:

  Padding around the graph content in pixels. Can be a single number for
  equal padding on all sides or a vector of four numbers
  `[top, right, bottom, left]`. Default: NULL.

- rotation:

  Rotation angle of the entire graph in degrees. Default: 0.

- x:

  X-coordinate of the graph's center relative to the container. Default:
  NULL (will use container center).

- y:

  Y-coordinate of the graph's center relative to the container. Default:
  NULL (will use container center).

- zoom:

  Initial zoom level of the graph. 1 represents 100% (original size).
  Default: 1.

- zoomRange:

  Minimum and maximum allowed zoom levels, specified as a vector with
  two elements: c(min_zoom, max_zoom). Default: c(0.01, 10).

- theme:

  Color theme for the graph. Either `light` or `dark` or a list
  representing a custom theme: see
  <https://g6.antv.antgroup.com/en/manual/theme/custom-theme>.

- ...:

  Other configuration parameters.

## Value

A list containing all specified G6 graph configuration options.

## Details

The `g6_options` function provides a comprehensive configuration
interface for G6 graphs. It allows you to control all aspects of graph
rendering and behavior, from styling of individual elements to global
visualization settings.

## Examples

``` r
# Basic usage with defaults
opts <- g6_options(g6())

# Customize node and edge styles
opts <- g6_options(
  g6(),
  node = node_options(
    type = "circle",
    style = node_style_options(
      fill = "#1783FF",
      stroke = "#0066CC"
    )
  ),
  edge = edge_options(
    type = "cubic",
    style = edge_style_options(
      stroke = "#999999",
      lineWidth = 1.5
    )
  )
)

# Configure graph with dark theme, auto-resize, and custom background
opts <- g6_options(
  g6(),
  theme = "dark",
  autoResize = TRUE,
  background = "#222222",
  padding = 20,
  zoom = 0.8,
  zoomRange = c(0.5, 2)
)

# Configure with custom animations
opts <- g6_options(
  g6(),
  animation = animation_config(
    duration = 500,
    easing = "easeCubic"
  ),
  autoFit = auto_fit_config(duration = 300, easing = "ease-out")
)
```
