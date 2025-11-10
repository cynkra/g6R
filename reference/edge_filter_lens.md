# Configure Edge Filter Lens Plugin

Creates a configuration object for the edge-filter-lens plugin in G6.
This plugin creates a lens that filters and displays edges within a
specific area.

## Usage

``` r
edge_filter_lens(
  key = "edge-filter-lens",
  trigger = c("pointermove", "click", "drag"),
  r = 60,
  maxR = NULL,
  minR = 0,
  scaleRBy = "wheel",
  nodeType = c("both", "source", "target", "either"),
  filter = NULL,
  style = NULL,
  nodeStyle = list(label = FALSE),
  edgeStyle = list(label = TRUE),
  preventDefault = TRUE,
  ...
)
```

## Arguments

- key:

  Unique identifier for the plugin (string, default: NULL).

- trigger:

  Method to move the lens: "pointermove", "click", or "drag" (string,
  default: "pointermove").

- r:

  Radius of the lens (number, default: 60).

- maxR:

  Maximum radius of the lens (number, default: NULL - half of the
  smaller canvas dimension).

- minR:

  Minimum radius of the lens (number, default: 0).

- scaleRBy:

  Method to scale the lens radius (string, default: "wheel").

- nodeType:

  Edge display condition: "both", "source", "target", or "either"
  (string, default: "both").

- filter:

  Filter out elements that are never displayed in the lens (JS function,
  default: NULL).

- style:

  Style of the lens (list, default: NULL).

- nodeStyle:

  Style of nodes in the lens (list or JS function, default: list(label =
  FALSE)).

- edgeStyle:

  Style of edges in the lens (list or JS function, default: list(label =
  TRUE)).

- preventDefault:

  Whether to prevent default events (boolean, default: TRUE).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/plugin/edge-filter-lens>.

## Value

A list with the configuration settings for the edge-filter-lens plugin.

## Examples

``` r
# Basic configuration
config <- edge_filter_lens()

# Custom configuration
config <- edge_filter_lens(
  key = "my-edge-lens",
  trigger = "drag",
  r = 100,
  nodeType = "either",
  style = list(
    fill = "rgba(200, 200, 200, 0.3)",
    stroke = "#999",
    lineWidth = 2
  ),
  filter = JS("(id, type) => {
    // Only display edges connected to specific nodes
    if (type === 'edge') {
      const edge = graph.getEdgeData(id);
      return edge.source === 'node1' || edge.target === 'node1';
    }
    return true;
  }")
)
```
