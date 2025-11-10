# Create a List of G6 Plugins

Combines multiple G6 plugins into a list that can be passed to a G6
graph configuration. G6 plugins extend the functionality of the base
graph visualization with additional features.

## Usage

``` r
g6_plugins(graph, ...)
```

## Arguments

- graph:

  G6 graph instance.

- ...:

  G6 plugin configuration objects created with plugin-specific functions

## Value

A list of G6 plugin configurations that can be passed to a G6 graph.

## Details

G6 plugins provide extended functionality beyond the core graph
visualization capabilities. Plugins are divided into several categories:

### Visual Style Enhancement

- **Grid Line (grid-line):** Displays grid reference lines on the canvas

- **Background (background):** Adds background images or colors to the
  canvas

- **Watermark (watermark):** Adds a watermark to the canvas to protect
  copyright

- **Hull (hull):** Creates an outline for a specified set of nodes

- **Bubble Sets (bubble-sets):** Creates smooth bubble-like element
  outlines

- **Snapline (snapline):** Displays alignment reference lines when
  dragging elements

### Navigation and Overview

- **Minimap (minimap):** Displays a thumbnail preview of the graph,
  supporting navigation

- **Fullscreen (fullscreen):** Supports full-screen display and exit for
  charts

- **Timebar (timebar):** Provides filtering and playback control for
  temporal data

### Interactive Controls

- **Toolbar (toolbar):** Provides a collection of common operation
  buttons

- **Context Menu (contextmenu):** Displays a menu of selectable
  operations on right-click

- **Tooltip (tooltip):** Displays detailed information about elements on
  hover

- **Legend (legend):** Displays categories and corresponding style
  descriptions of chart data

### Data Exploration

- **Fisheye (fisheye):** Provides a focus + context exploration
  experience

- **Edge Filter Lens (edge-filter-lens):** Filters and displays edges
  within a specified area

- **Edge Bundling (edge-bundling):** Bundles edges with similar paths
  together to reduce visual clutter

### Advanced Features

- **History (history):** Supports undo/redo operations

- **Camera Setting (camera-setting):** Configures camera parameters in a
  3D scene

## Note

You can also build your own plugins as described at
<https://g6.antv.antgroup.com/en/manual/plugin/custom-plugin>.

## Examples

``` r
# Create a configuration with multiple plugins
plugins <- g6_plugins(
  g6(),
  minimap(),
  grid_line(),
  tooltips(
    getContent = JS("(e, items) => {
      return `<div>${items[0].id}</div>`;
    }")
  )
)

# Add a context menu and toolbar
plugins <- g6_plugins(
  g6(),
  context_menu(
    key = "my-context-menu",
    className = "my-context-menu",
    trigger = "click",
    offset = c(10, 10),
    getItems = JS("(event) => {
      const type = event.itemType;
      const isNode = type === 'node';
      return [
        { key: 'delete', text: 'Delete' },
        { key: 'edit', text: 'Edit' },
        { key: 'details', text: 'View Details', disabled: !isNode }
      ];
    }"),
    onClick = JS("(value, target, current) => {
      if (value === 'delete') {
        // do stuff
    }")
  ),
  toolbar(
    position = "top-right",
    getItems = JS("() => [
      { id: 'zoom-in', value: 'zoom-in' },
      { id: 'zoom-out', value: 'zoom-out' },
      { id: 'fit', value: 'fit' }
    ]"),
    onClick = JS("(value) => {
      if (value === 'zoom-in') graph.zoomTo(1.1);
      else if (value === 'zoom-out') graph.zoomTo(0.9);
      else if (value === 'fit') graph.fitView();
    }")
  )
)
```
