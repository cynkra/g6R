# Generate a spanning tree layout configuration

Runs one of G6's tree layouts on any graph. G6's tree layouts take a
node's children from its successors and lay out every root from the same
origin. On a graph that is not a forest, a node with several parents
lands under one of them and leaves an empty slot under the others, and
separate roots are drawn on top of each other. This layout first keeps
one parent per node and hangs the roots side by side under a hidden
root. The other edges are still drawn; they just don't place anything.
On a forest it gives the base layout's arrangement, spaced by the drawn
nodes' sizes rather than the base layout's defaults. Cycles are broken
where found, so any graph lays out.

## Usage

``` r
spanning_tree_layout(
  base = c("indented", "compact-box", "dendrogram", "mindmap"),
  ...
)
```

## Arguments

- base:

  The tree layout to run: "indented", "compact-box", "dendrogram" or
  "mindmap".

- ...:

  Options of the base layout, e.g. `direction`, `indent`, `getHGap`,
  `getVGap` (see
  [`indented_layout()`](https://cynkra.github.io/g6R/reference/indented_layout.md),
  [`compact_box_layout()`](https://cynkra.github.io/g6R/reference/compact_box_layout.md),
  [`dendrogram_layout()`](https://cynkra.github.io/g6R/reference/dendrogram_layout.md)
  and
  [`mindmap_layout()`](https://cynkra.github.io/g6R/reference/mindmap_layout.md)).
  Node sizes default to the drawn nodes' sizes.

## Value

A list containing the layout configuration.

## Details

A node's parent is its `data$treeParent` when that names one of its
sources, otherwise the source of its first incoming edge.

## Examples

``` r
spanning_tree_layout("indented", indent = 40)
#> $type
#> [1] "spanning-tree"
#> 
#> $base
#> [1] "indented"
#> 
#> $indent
#> [1] 40
#> 
spanning_tree_layout("compact-box", direction = "TB")
#> $type
#> [1] "spanning-tree"
#> 
#> $base
#> [1] "compact-box"
#> 
#> $direction
#> [1] "TB"
#> 
```
