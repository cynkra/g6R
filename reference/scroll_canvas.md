# Configure Scroll Canvas Behavior

Creates a configuration object for the scroll-canvas behavior in G6.
This behavior allows scrolling the canvas with mouse wheel or keyboard.

## Usage

``` r
scroll_canvas(
  key = "scroll-canvas",
  enable = TRUE,
  direction = NULL,
  range = 1,
  sensitivity = 1,
  trigger = NULL,
  onFinish = NULL,
  preventDefault = TRUE,
  ...
)
```

## Arguments

- key:

  Unique identifier for the behavior (string, default: "scroll-canvas").

- enable:

  Whether to enable this behavior (boolean or JS function, default:
  TRUE).

- direction:

  Allowed scrolling direction: "x", "y", or NULL for no limit (string or
  NULL, default: NULL).

- range:

  Scrollable viewport range in viewport size units (numeric or numeric
  vector, default: 1).

- sensitivity:

  Scrolling sensitivity, the larger the value, the faster the scrolling
  (numeric, default: 1).

- trigger:

  Keyboard shortcuts to trigger scrolling (list, default: NULL).

- onFinish:

  Callback function when scrolling is finished (JS function, default:
  NULL).

- preventDefault:

  Whether to prevent the browser's default event (boolean, default:
  TRUE).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/behavior/scroll-canvas>.

## Value

A list with the configuration settings for the scroll-canvas behavior.

## Examples

``` r
# Basic configuration
config <- scroll_canvas()

# Custom configuration
config <- scroll_canvas(
  key = "my-scroll-behavior",
  direction = "x",
  range = c(-2, 2),
  sensitivity = 1.5,
  preventDefault = FALSE
)

# With keyboard triggers and callback
config <- scroll_canvas(
  enable = JS("(event) => !event.altKey"),
  trigger = list(
    up = "w",
    down = "s",
    left = "a",
    right = "d"
  ),
  onFinish = JS("() => { console.log('Scrolling finished'); }")
)
```
