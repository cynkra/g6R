# Generate G6 AntV Concentric layout configuration

This function creates a configuration list for G6 AntV Concentric layout
with all available options as parameters. The Concentric layout places
nodes in concentric circles based on a centrality measure.

## Usage

``` r
concentric_layout(
  center = NULL,
  clockwise = FALSE,
  equidistant = FALSE,
  width = NULL,
  height = NULL,
  sortBy = "degree",
  maxLevelDiff = NULL,
  nodeSize = 30,
  nodeSpacing = 10,
  preventOverlap = FALSE,
  startAngle = 3/2 * pi,
  sweep = NULL,
  ...
)
```

## Arguments

- center:

  The center position of the circular layout `[x, y]` or `[x, y, z]`. By
  default, it's the center position of the current container.

- clockwise:

  Whether nodes are arranged in clockwise order.

- equidistant:

  Whether the distances between rings are equal.

- width:

  The width of the layout. By default, the container width is used.

- height:

  The height of the layout. By default, the container height is used.

- sortBy:

  Specify the sorting basis (node attribute name). The higher the value,
  the more central the node will be placed. If it is "degree", the
  degree of the node will be calculated. The higher the degree, the more
  central the node will be placed.

- maxLevelDiff:

  If the maximum attribute difference of nodes in the same layer is
  undefined, it will be set to maxValue / 4, where maxValue is the
  maximum attribute value of the sorting basis. For example, if sortBy
  is 'degree', then maxValue is the degree of the node with the largest
  degree among all nodes.

- nodeSize:

  Node size (diameter). Used to prevent collision detection when nodes
  overlap. Can be a number, a 2-element vector `[width, height]`, or a
  function that returns a number.

- nodeSpacing:

  Minimum distance between rings, used to adjust the radius. Can be a
  number, a vector of numbers, or a function that returns a number.

- preventOverlap:

  Whether to prevent node overlap. Must be coordinated with the nodeSize
  attribute or the data.size attribute in the node data. Only when
  data.size is set in the data or the nodeSize value that is the same as
  the current graph node size is configured in the layout, can node
  overlap collision detection be performed.

- startAngle:

  The arc at which to start layout of nodes (in radians)

- sweep:

  If the radian difference between the first and last nodes in the same
  layer is undefined, it will be set to
  `2 * Math.PI * (1 - 1 / |level.nodes|)`, where level.nodes is the
  number of nodes in each layer calculated by the algorithm, and
  \|level.nodes\| is the number of nodes in the layer.

- ...:

  Additional parameters to pass to the layout. See
  <https://g6.antv.antgroup.com/en/manual/layout/concentric-layout>.

## Value

A list containing the configuration for G6 AntV Concentric layout

## Examples

``` r
# Basic concentric layout
concentric_config <- concentric_layout()

# Custom concentric layout with degree-based sorting and overlap prevention
concentric_config <- concentric_layout(
  clockwise = TRUE,
  sortBy = "degree",
  preventOverlap = TRUE,
  nodeSize = 30,
  nodeSpacing = 20
)

# Custom concentric layout with specific center and dimensions
concentric_config <- concentric_layout(
  center = c(300, 300),
  width = 600,
  height = 600,
  equidistant = TRUE,
  startAngle = pi
)
```
