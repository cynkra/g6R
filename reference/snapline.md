# Configure Snapline Plugin

Creates a configuration object for the snapline plugin in G6. This
plugin provides alignment guidelines when moving nodes.

## Usage

``` r
snapline(
  key = "snapline",
  tolerance = 5,
  offset = 20,
  autoSnap = TRUE,
  shape = "key",
  verticalLineStyle = list(stroke = "#1783FF"),
  horizontalLineStyle = list(stroke = "#1783FF"),
  filter = NULL,
  ...
)
```

## Arguments

- key:

  Unique identifier for the plugin (string, default: NULL).

- tolerance:

  The alignment accuracy in pixels (number, default: 5).

- offset:

  The extension distance of the snapline (number, default: 20).

- autoSnap:

  Whether to enable automatic snapping (boolean, default: TRUE).

- shape:

  Specifies which shape to use as reference: "key" or a function (string
  or JS function, default: "key").

- verticalLineStyle:

  Vertical snapline style (list or JS object, default: list(stroke =
  "#1783FF")).

- horizontalLineStyle:

  Horizontal snapline style (list or JS object, default: list(stroke =
  "#1783FF")).

- filter:

  Function to filter nodes that don't participate in alignment (JS
  function, default: NULL).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/plugin/snapline>.

## Value

A list with the configuration settings for the snapline plugin.

## Examples

``` r
# Basic configuration
config <- snapline()

# Custom configuration
config <- snapline(
  key = "my-snapline",
  tolerance = 8,
  offset = 30,
  verticalLineStyle = list(
    stroke = "#f00",
    strokeWidth = 1.5,
    lineDash = c(5, 2)
  ),
  horizontalLineStyle = list(
    stroke = "#00f",
    strokeWidth = 1.5,
    lineDash = c(5, 2)
  )
)

# With custom filter function
config <- snapline(
  filter = JS("(node) => {
    // Only allow regular nodes to participate in alignment
    // Exclude special nodes like 'start' or 'end'
    const model = node.getModel();
    return model.type !== 'start' && model.type !== 'end';
  }")
)
```
