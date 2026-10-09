# Generate G6 Fishbone layout configuration

A cause-and-effect (Ishikawa) layout. It reads tree-shaped data: nodes
carrying `children`, as G6's `treeToGraphData()` builds them.

## Usage

``` r
fishbone_layout(
  direction = c("RL", "LR"),
  hGap = NULL,
  vGap = NULL,
  getRibSep = NULL,
  nodeSize = NULL,
  ...
)
```

## Arguments

- direction:

  "RL" (head on the right) or "LR".

- hGap, vGap:

  Horizontal and vertical gaps (px).

- getRibSep:

  Optional JS callback giving the gap between ribs.

- nodeSize:

  Node size, a number or a vector of width and height.

- ...:

  Additional parameters passed to the layout. See
  <https://g6.antv.antgroup.com/en/manual/layout/fishbone>.

## Value

A list containing the layout configuration.

## Examples

``` r
fishbone_layout(hGap = 40)
#> $type
#> [1] "fishbone"
#> 
#> $direction
#> [1] "RL"
#> 
#> $hGap
#> [1] 40
#> 
```
