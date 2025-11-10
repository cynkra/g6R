# Configure Optimize Viewport Transform Behavior

Creates a configuration object for the optimize-viewport-transform
behavior in G6. This behavior improves performance during viewport
transformations by temporarily hiding certain elements.

## Usage

``` r
optimize_viewport_transform(
  key = "optimize-viewport-transform",
  enable = TRUE,
  debounce = 200,
  shapes = JS("(type) => type === 'node'"),
  ...
)
```

## Arguments

- key:

  Unique identifier for the behavior (string, default:
  "optimize-viewport-transform").

- enable:

  Whether to enable this behavior (boolean or JS function, default:
  TRUE).

- debounce:

  How long after the operation ends to restore the visibility of all
  elements in milliseconds (number, default: 200).

- shapes:

  Function to specify which graphical elements should remain visible
  during canvas operations (JS function, default: returns TRUE for
  nodes).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/behavior/optimize-viewport-transform>.

## Value

A list with the configuration settings for the
optimize-viewport-transform behavior.

## Examples

``` r
# Basic configuration
config <- optimize_viewport_transform()

# Custom configuration
config <- optimize_viewport_transform(
  key = "my-optimize-transform",
  debounce = 500,
  shapes = JS("(type) => type === 'node' || type === 'edge'")
)

# With conditional enabling
config <- optimize_viewport_transform(
  enable = JS("(event) => event.getCurrentTransform().zoom < 0.5")
)
```
