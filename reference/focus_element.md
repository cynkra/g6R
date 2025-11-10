# Configure Focus Element Behavior

Creates a configuration object for the focus-element behavior in G6.
This behavior allows focusing on specific elements by automatically
adjusting the viewport.

## Usage

``` r
focus_element(
  key = "focus-element",
  animation = list(duration = 500, easing = "ease-in"),
  enable = TRUE,
  ...
)
```

## Arguments

- key:

  Unique identifier for the behavior, used for subsequent operations
  (string, default: "focus-element").

- animation:

  Focus animation settings (list, default: list with duration 500ms and
  easing "ease-in").

- enable:

  Whether to enable the focus feature (boolean or JS function, default:
  TRUE).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/behavior/focus-element>.

## Value

A list with the configuration settings for the focus-element behavior.

## Examples

``` r
# Basic configuration
config <- focus_element()

# Custom configuration
config <- focus_element(
  key = "my-focus-behavior",
  animation = list(duration = 1000, easing = "ease-out"),
  enable = JS("(event) => event.targetType === 'node'")
)
```
