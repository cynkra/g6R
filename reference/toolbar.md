# Configure Toolbar Plugin

Creates a configuration object for the toolbar plugin in G6. This plugin
adds a customizable toolbar with items for graph operations.

## Usage

``` r
toolbar(
  getItems = NULL,
  key = "toolbar",
  className = NULL,
  position = c("top-left", "top", "top-right", "right", "bottom-right", "bottom",
    "bottom-left", "left"),
  style = NULL,
  onClick = NULL,
  ...
)
```

## Arguments

- getItems:

  Function that returns the list of toolbar items (JS function,
  required).

- key:

  Unique identifier for the plugin (string, default: NULL).

- className:

  Additional CSS class name for the toolbar DOM element (string,
  default: NULL).

- position:

  Toolbar position relative to the canvas (string, default: "top-left").

- style:

  Custom style for the toolbar DOM element (list or JS object, default:
  NULL).

- onClick:

  Callback function after a toolbar item is clicked (JS function,
  default: NULL).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/plugin/toolbar>.

## Value

A list with the configuration settings for the toolbar plugin.

## Examples

``` r
# Basic toolbar with zoom controls
config <- toolbar(
  position = "top-right",
  getItems = JS("() => [
    { id: 'zoom-in', value: 'zoom-in' },
    { id: 'zoom-out', value: 'zoom-out' },
    { id: 'undo', value: 'undo' },
    { id: 'redo', value: 'redo' },
    { id: 'auto-fit', value: 'fit' }
  ]"),
  onClick = JS("(value) => {
    // redo, undo need to be used with the history plugin
    const history = graph.getPluginInstance('history');
    switch (value) {
      case 'zoom-in':
        graph.zoomTo(1.1);
        break;
      case 'zoom-out':
        graph.zoomTo(0.9);
        break;
      case 'undo':
        history?.undo();
        break;
      case 'redo':
        history?.redo();
        break;
      case 'fit':
        graph.fitView();
        break;
      default:
        break;
    }
  }")
)
```
