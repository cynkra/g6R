# Generate G6 Mindmap layout configuration

A tree layout that spreads children to both sides of their parent. Like
G6's other tree layouts, it expects a forest; for any graph, see
[`spanning_tree_layout()`](https://cynkra.github.io/g6R/reference/spanning_tree_layout.md).

## Usage

``` r
mindmap_layout(
  direction = c("H", "LR", "RL"),
  getWidth = NULL,
  getHeight = NULL,
  getHGap = NULL,
  getVGap = NULL,
  getSide = NULL,
  ...
)
```

## Arguments

- direction:

  "H" (both sides), "LR" or "RL".

- getWidth, getHeight, getHGap, getVGap, getSide:

  Optional JS callbacks, see
  [`compact_box_layout()`](https://cynkra.github.io/g6R/reference/compact_box_layout.md).

- ...:

  Additional parameters passed to the layout. See
  <https://g6.antv.antgroup.com/en/manual/layout/mindmap-layout>.

## Value

A list containing the layout configuration.

## Examples

``` r
mindmap_layout()
#> $type
#> [1] "mindmap"
#> 
#> $direction
#> [1] "H"
#> 
```
