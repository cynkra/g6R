# Create Canvas Configuration for G6 Graphs

Configures the canvas settings for a G6 graph. The canvas is the
rendering surface where the graph is drawn.

## Usage

``` r
canvas_config(
  container = NULL,
  devicePixelRatio = NULL,
  width = NULL,
  height = NULL,
  cursor = NULL,
  background = NULL,
  renderer = NULL,
  enableMultiLayer = NULL
)
```

## Arguments

- container:

  The container element for the canvas. Can be a CSS selector string or
  an HTML element reference.

- devicePixelRatio:

  The device pixel ratio to use for rendering. Higher values provide
  sharper rendering on high-DPI displays but may impact performance. If
  not specified, the device's pixel ratio will be used.

- width:

  The width of the canvas in pixels.

- height:

  The height of the canvas in pixels.

- cursor:

  The CSS cursor style to use when hovering over the canvas. Common
  values include "default", "pointer", "move", etc.

- background:

  The background color of the canvas. Can be any valid CSS color value
  (hex, rgb, rgba, named colors).

- renderer:

  A function that returns a renderer for different layers. The function
  takes a layer parameter which can be 'background', 'main', 'label', or
  'transient'.

- enableMultiLayer:

  Whether to enable multi-layer rendering. This is a non-dynamic
  parameter and is only effective during initialization. Multi-layer
  rendering can improve performance for complex graphs by separating
  elements into different rendering layers.

## Value

A list containing the canvas configuration that can be passed to
[`g6_options()`](https://cynkra.github.io/g6R/reference/g6_options.md).

## Details

Canvas configuration controls how the graph is rendered, including its
size, scaling, background, and rendering layer settings. This function
provides a structured way to configure all canvas-related options.

Note that many of these settings (container, width, height,
devicePixelRatio, background, cursor) can also be set directly in the
main graph configuration, which will be automatically converted to
canvas configuration items.

## Examples

``` r
# Basic canvas configuration
config <- canvas_config(
  container = "#graph-container",
  width = 800,
  height = 600
)

# Canvas with multi-layer rendering enabled
config <- canvas_config(
  container = "#graph-container",
  width = 1000,
  height = 700,
  enableMultiLayer = TRUE,
  cursor = "grab"
)
```
