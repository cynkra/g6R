# Configure Drag Canvas Behavior

Creates a configuration object for the drag-canvas behavior in G6. This
allows users to drag the canvas to pan the view.

## Usage

``` r
drag_canvas(
  key = "drag-canvas",
  enable = NULL,
  animation = NULL,
  direction = c("both", "x", "y"),
  range = NULL,
  sensitivity = 10,
  trigger = NULL,
  onFinish = NULL,
  ...
)
```

## Arguments

- key:

  Behavior unique identifier. Useful to modify this behavior from JS
  side.

- enable:

  Whether to enable this behavior (boolean or function, default:
  function that enables dragging only on canvas).

- animation:

  Drag animation configuration for keyboard movement (list, default:
  NULL).

- direction:

  Allowed drag direction: "x", "y", or "both" (string, default: "both").

- range:

  Draggable viewport range in viewport size units (number or numeric
  vector, default: Inf).

- sensitivity:

  Distance to trigger a single keyboard movement (number, default: 10).

- trigger:

  Keyboard keys to trigger dragging (list, default: NULL).

- onFinish:

  Callback function when dragging is completed (function, default:
  NULL).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/behavior/drag-canvas>.

## Value

A list with the configuration settings for the drag-canvas behavior.

## Examples

``` r
# Basic configuration
config <- drag_canvas()

# Custom configuration
config <- drag_canvas(
  enable = TRUE,
  direction = "x",
  range = c(-100, 100),
  sensitivity = 5,
  trigger = list(
   up = "ArrowUp",
   down = "ArrowDown",
   left = "ArrowLeft",
   right = "ArrowRight"
  )
)
```
