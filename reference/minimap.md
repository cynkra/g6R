# Configure Minimap Plugin

Creates a configuration object for the minimap plugin in G6. This plugin
adds a minimap/thumbnail view of the entire graph.

## Usage

``` r
minimap(
  key = "minimap",
  className = NULL,
  container = NULL,
  containerStyle = NULL,
  delay = 128,
  filter = NULL,
  maskStyle = NULL,
  padding = 10,
  position = "right-bottom",
  renderer = NULL,
  shape = "key",
  size = c(240, 160),
  ...
)
```

## Arguments

- key:

  Unique identifier for the plugin (string, default: NULL).

- className:

  Class name of the thumbnail canvas (string, default: NULL).

- container:

  Container to which the thumbnail is mounted (HTML element or string,
  default: NULL).

- containerStyle:

  Style of the thumbnail container (list or JS object, default: NULL).

- delay:

  Delay update time in milliseconds for performance optimization
  (number, default: 128).

- filter:

  Function to filter elements to display in minimap (JS function,
  default: NULL).

- maskStyle:

  Style of the mask (list or JS object, default: NULL).

- padding:

  Padding around the minimap (number or numeric vector, default: 10).

- position:

  Position of the thumbnail relative to the canvas (string or numeric
  vector, default: "right-bottom").

- renderer:

  Custom renderer (JS object, default: NULL).

- shape:

  Method for generating element thumbnails (string or JS function,
  default: "key").

- size:

  Width and height of the minimap `[width, height]` (numeric vector,
  default: c(240, 160)).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/plugin/minimap>.

## Value

A list with the configuration settings for the minimap plugin.

## Examples

``` r
# Basic configuration
config <- minimap()

# Custom configuration
config <- minimap(
  key = "my-minimap",
  position = "left-top",
  size = c(200, 150),
  padding = 15,
  containerStyle = list(
    border = "1px solid #ddd",
    borderRadius = "4px",
    boxShadow = "0 0 8px rgba(0,0,0,0.1)"
  ),
  maskStyle = list(
    stroke = "#1890ff",
    strokeWidth = 2,
    fill = "rgba(24, 144, 255, 0.1)"
  )
)

# With custom filtering function
config <- minimap(
  filter = JS("(id, elementType) => {
    // Only show nodes and important edges in the minimap
    if (elementType === 'node') return true;
    if (elementType === 'edge') {
      // Assuming edges have an 'important' attribute
      const edge = graph.findById(id);
      return edge.getModel().important === true;
    }
    return false;
  }")
)
```
