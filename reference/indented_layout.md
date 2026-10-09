# Generate G6 Indented layout configuration

A tree layout that places each level one indent further than its parent,
with siblings stacked, so the drawing grows in height rather than width.
Like G6's other tree layouts, it expects a forest; for any graph, see
[`spanning_tree_layout()`](https://cynkra.github.io/g6R/reference/spanning_tree_layout.md).

## Usage

``` r
indented_layout(
  direction = c("LR", "RL", "H"),
  indent = 20,
  getWidth = NULL,
  getHeight = NULL,
  getSide = NULL,
  dropCap = NULL,
  ...
)
```

## Arguments

- direction:

  "LR" (children to the right), "RL" or "H" (both sides).

- indent:

  Indent of a level relative to its parent (px).

- getWidth, getHeight, getSide:

  Optional JS callbacks, see
  [`compact_box_layout()`](https://cynkra.github.io/g6R/reference/compact_box_layout.md).

- dropCap:

  Whether the first child sits on the parent's row.

- ...:

  Additional parameters passed to the layout. See
  <https://g6.antv.antgroup.com/en/manual/layout/indented-layout>.

## Value

A list containing the layout configuration.

## Examples

``` r
indented_layout(indent = 40)
#> $type
#> [1] "indented"
#> 
#> $direction
#> [1] "LR"
#> 
#> $indent
#> [1] 40
#> 
```
