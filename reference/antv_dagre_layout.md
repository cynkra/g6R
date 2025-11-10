# Generate G6 AntV Dagre layout configuration

This function creates a configuration list for G6 AntV Dagre layout with
all available options as parameters.

## Usage

``` r
antv_dagre_layout(
  rankdir = c("TB", "BT", "LR", "RL"),
  align = c("UL", "UR", "DL", "DR"),
  nodesep = 50,
  nodesepFunc = NULL,
  ranksep = 100,
  ranksepFunc = NULL,
  ranker = c("network-simplex", "tight-tree", "longest-path"),
  nodeSize = NULL,
  controlPoints = FALSE,
  begin = NULL,
  sortByCombo = FALSE,
  edgeLabelSpace = TRUE,
  nodeOrder = NULL,
  radial = FALSE,
  focusNode = NULL,
  preset = NULL,
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

  Node spacing (px). When rankdir is "TB" or "BT", it's the horizontal.
  spacing of nodes; when rankdir is "LR" or "RL", it's the vertical
  spacing of nodes.

- nodesepFunc:

  Function to customize node spacing for different nodes, in the form of
  function(node) that returns a number. Has higher priority than
  nodesep.

- ranksep:

  Layer spacing (px). When rankdir is "TB" or "BT", it's the vertical
  spacing between adjacent layers; when rankdir is "LR" or "RL", it's
  the horizontal spacing.

- ranksepFunc:

  Function to customize layer spacing, in the form of function(node)
  that returns a number. Has higher priority than ranksep.

- ranker:

  Algorithm for assigning ranks to nodes: "network-simplex",
  "tight-tree", or "longest-path".

- nodeSize:

  Node size for collision detection. Can be a single number (same
  width/height), an array `[width, height]`, or a function that returns
  either.

- controlPoints:

  Whether to retain edge control points.

- begin:

  Alignment position of the upper left corner of the layout. Can be
  `[x, y]` or `[x, y, z]`.

- sortByCombo:

  Whether to sort nodes on the same layer by parentId to prevent combo
  overlap.

- edgeLabelSpace:

  Whether to leave space for edge labels.

- nodeOrder:

  Reference array of node order on the same layer, containing node id
  values.

- radial:

  Whether to perform a radial layout based on dagre.

- focusNode:

  Focused node (only used when radial=TRUE). Can be a node ID or node
  object.

- preset:

  Node positions to reference during layout calculation.

- ...:

  Additional parameters to pass to the layout.

## Value

A list containing the configuration for G6 AntV Dagre layout.

## Examples

``` r
# Basic dagre layout
dagre_config <- antv_dagre_layout()

# Horizontal layout with custom spacing
dagre_config <- antv_dagre_layout(
  rankdir = "LR",
  align = "UL",
  nodesep = 80,
  ranksep = 150
)

# Radial layout with focus node
dagre_config <- antv_dagre_layout(
  radial = TRUE,
  focusNode = "node1",
  ranker = "tight-tree"
)
```
