# Configure Zoom Canvas Behavior

Creates a configuration object for the zoom-canvas behavior in G6. This
behavior allows zooming the canvas with mouse wheel or keyboard
shortcuts.

## Usage

``` r
zoom_canvas(
  key = "zoom-canvas",
  animation = list(duration = 200),
  enable = TRUE,
  origin = NULL,
  onFinish = NULL,
  preventDefault = TRUE,
  sensitivity = 1,
  trigger = NULL,
  ...
)
```

## Arguments

- key:

  Unique identifier for the behavior (string, default: "zoom-canvas").

- animation:

  Zoom animation effect settings (list, default: list with duration
  200ms).

- enable:

  Whether to enable this behavior (boolean or JS function, default:
  TRUE).

- origin:

  Zoom center point in viewport coordinates (list with x, y values,
  default: NULL).

- onFinish:

  Callback function when zooming is finished (JS function, default:
  NULL).

- preventDefault:

  Whether to prevent the browser's default event (boolean, default:
  TRUE).

- sensitivity:

  Zoom sensitivity, the larger the value, the faster the zoom (numeric,
  default: 1).

- trigger:

  How to trigger zooming, supports mouse wheel and keyboard shortcuts
  (list, default: NULL).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/behavior/zoom-canvas>.

## Value

A list with the configuration settings for the zoom-canvas behavior.

## Examples

``` r
# Basic configuration
config <- zoom_canvas()

# Custom configuration
config <- zoom_canvas(
  key = "my-zoom-behavior",
  animation = list(duration = 300, easing = "ease-in-out"),
  origin = list(x = 0, y = 0),
  sensitivity = 1.5,
  preventDefault = FALSE
)

# With keyboard triggers and callback
config <- zoom_canvas(
  enable = JS("(event) => !event.altKey"),
  trigger = list(
    zoomIn = "+",
    zoomOut = "-",
    reset = "0"
  ),
  onFinish = JS("() => { console.log('Zooming finished'); }")
)
```
