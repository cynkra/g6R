# Generate G6 AntV Dagre layout configuration

This function creates a configuration list for G6 AntV Dagre layout with
all available options as parameters. The Dagre layout is designed for
directed graphs, creating hierarchical layouts with nodes arranged in
layers.

## Usage

``` r
dagre_layout(
  rankdir = c("TB", "BT", "LR", "RL"),
  align = c("UL", "UR", "DL", "DR"),
  nodesep = 50,
  ranksep = 100,
  ranker = c("network-simplex", "tight-tree", "longest-path"),
  nodeSize = NULL,
  controlPoints = FALSE,
  ...
)
```

## Arguments

- rankdir:

  Layout direction: "TB" (top to bottom), "BT" (bottom to top), "LR"
  (left to right), or "RL" (right to left).

- align:

  Node alignment: "UL" (upper left), "UR" (upper right), "DL" (down
  left), or "DR" (down right).

- nodesep:

  Node spacing (px). When rankdir is "TB" or "BT", it's the horizontal
  spacing of nodes; when rankdir is "LR" or "RL", it's the vertical
  spacing of nodes.

- ranksep:

  Interlayer spacing (px). When rankdir is "TB" or "BT", it's the
  spacing between adjacent layers in the vertical direction; when
  rankdir is "LR" or "RL", it represents the spacing between adjacent
  layers in the horizontal direction.

- ranker:

  The algorithm for assigning a level to each node: "network-simplex"
  (the network simplex algorithm), "tight-tree" (the compact tree
  algorithm), or "longest-path" (the longest path algorithm).

- nodeSize:

  G6 custom attribute to specify the node size uniformly or for each
  node. Can be a single number (same width/height), an array
  `[width, height]`, or a function that returns either.

- controlPoints:

  Whether to keep the control points of the edge.

- ...:

  Additional parameters to pass to the layout. See
  <https://g6.antv.antgroup.com/en/manual/layout/dagre-layout>.

## Value

A list containing the configuration for G6 AntV Dagre layout.

## Examples

``` r
# Basic dagre layout
dagre_config <- dagre_layout()

# Custom dagre layout with horizontal flow
dagre_config <- dagre_layout(
  rankdir = "LR",
  nodesep = 80,
  ranksep = 150,
  ranker = "tight-tree"
)

# Custom dagre layout with specific node size
dagre_config <- dagre_layout(
  nodeSize = 40,
  controlPoints = TRUE
)
```
