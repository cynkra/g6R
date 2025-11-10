# Layouts

``` r
library(g6R)
#> 
#> Attaching package: 'g6R'
#> The following object is masked from 'package:graphics':
#> 
#>     legend
#> The following object is masked from 'package:utils':
#> 
#>     history
data(lesmis)
data(radial)
data(tree)
data(dag)
```

A graph layout is the algorithmic process of positioning nodes and edges
in a visual space to reveal the structure of a graph. The goal is to
enhance readability by minimizing edge crossings, evenly distributing
nodes, and highlighting key patterns or clusters. Different layout
strategies, like force-directed or hierarchical, serve various use cases
and aesthetic preferences.

G6 provides a variety of layout algorithms, allowing users to choose the
appropriate one based on their needs. The exhaustive list can be found
in the [docs of
G6](https://g6.antv.antgroup.com/en/manual/layout/overview). `g6R`
currently does not expose all of them but the most commonly used ones.

``` r
grep("_layout$", ls("package:g6R"), value = TRUE)
#>  [1] "antv_dagre_layout"     "circular_layout"       "combo_combined_layout"
#>  [4] "compact_box_layout"    "concentric_layout"     "d3_force_layout"      
#>  [7] "dagre_layout"          "dendrogram_layout"     "force_atlas2_layout"  
#> [10] "fruchterman_layout"    "g6_layout"             "radial_layout"
```

## Force directed layouts

G6 implements several force-directed layouts, which simulate physical
forces to position nodes. The
[`d3_force_layout()`](https://cynkra.github.io/g6R/reference/d3_force_layout.md)
function is a wrapper around the [D3 force layout
algorithm](https://cynkra.github.io/g6R/articles/g6.antv.antgroup.com/en/manual/layout/build-in/d3-force-layout)
and `force_atlas_layout()` is a wrapper around the [Force Atlas2 layout
algorithm](https://g6.antv.antgroup.com/en/manual/layout/build-in/force-atlas2-layout).
Both layouts are commonly used for visualizing networks where the later
is particularly suited for large networks.

The D3 force layout has quite sensible defaults.

``` r
g6(lesmis$nodes, lesmis$edges) |>
  g6_layout(d3_force_layout()) |>
  g6_options(autoFit = "view", autoResize = TRUE)
```

The Force Atlas2 layout might need some parameter tweaking to get the
best results.

``` r
g6(lesmis$nodes, lesmis$edges) |>
  g6_layout(force_atlas2_layout(preventOverlap = TRUE, kr = 20)) |>
  g6_options(autoFit = "view", autoResize = TRUE)
```

For more on
[`g6_options()`](https://cynkra.github.io/g6R/reference/g6_options.md),
see the [options
vignette](https://cynkra.github.io/g6R/articles/options.qmd).

The [Fruchterman
layout](https://g6.antv.antgroup.com/en/manual/layout/build-in/fruchterman-layout)
is another force-directed layout that is particularly useful for smaller
graphs. It positions nodes based on attractive and repulsive forces,
creating a balanced distribution.

``` r
g6(radial$nodes, radial$edges) |>
  g6_layout(fruchterman_layout()) |>
  g6_options(autoFit = "view", autoResize = TRUE)
```

## Circular layouts

Circular layouts arrange nodes in a circular pattern, which can be
useful for highlighting relationships in cyclic or radial structures. G6
provides several circular layout algorithms. Exposed in `g6R` are
[`circular_layout()`](https://cynkra.github.io/g6R/reference/circular_layout.md),
[`radial_layout()`](https://cynkra.github.io/g6R/reference/radial_layout.md),
and
[`concentric_layout()`](https://cynkra.github.io/g6R/reference/concentric_layout.md).

THe
[`circular_layout()`](https://cynkra.github.io/g6R/reference/circular_layout.md)
function arranges nodes in a circle. This has a very limited use case
but can be useful for small graphs.

``` r
g6(radial$nodes, radial$edges) |>
  g6_layout(circular_layout()) |>
  g6_options(autoFit = "view", autoResize = TRUE)
```

The
[`radial_layout()`](https://cynkra.github.io/g6R/reference/radial_layout.md)
function arranges nodes in a radial pattern, which is useful for
hierarchical structures. It positions nodes around a central node,
making it easier to visualize hierarchical relationships.

``` r
g6(radial$nodes, radial$edges) |>
  g6_layout(radial_layout()) |>
  g6_options(
    autoFit = "view",
    autoResize = TRUE,
    node = list(
      style = list(
        labelFill = '#fff',
        labelPlacement = "center",
        labelText = JS(
          "(d) => {
              return d.id
            }"
        )
      )
    )
  )
```

For more on node styles, see the [nodes
vignette](https://cynkra.github.io/g6R/articles/nodes.md).

The focus node can be set to any node in the graph. The `focusNode`
parameter is used to specify the central node around which the radial
layout is arranged.

``` r
g6(radial$nodes, radial$edges) |>
  g6_layout(radial_layout(focusNode = "22")) |>
  g6_options(
    autoFit = "view",
    autoResize = TRUE,
    node = list(
      style = list(
        labelFill = '#fff',
        labelPlacement = "center",
        labelText = JS(
          "(d) => {
              return d.id
            }"
        )
      )
    )
  )
```

The
[`concentric_layout()`](https://cynkra.github.io/g6R/reference/concentric_layout.md)
function arranges nodes in concentric circles, based on their degree or
other attributes. This layout is useful for visualizing the structure of
networks with varying node importance or connectivity. The `sortBy`
parameter can be used to sort nodes by degree, or any other existing
node attribute.

``` r
g6(lesmis$nodes, lesmis$edges) |>
  g6_layout(concentric_layout(sortBy = "degree", preventOverlap = TRUE)) |>
  g6_options(autoFit = "view", autoResize = TRUE)
```

## Tree layouts

The package also implements layouts for trees. The
[`dendrogram_layout()`](https://cynkra.github.io/g6R/reference/dendrogram_layout.md)
function is a wrapper around the [Dendrogram layout
algorithm](https://g6.antv.antgroup.com/en/manual/layout/build-in/dendrogram-layout).

``` r
g6(tree$nodes, tree$edges) |>
  g6_layout(dendrogram_layout(nodeSep = 36, rankSep = 250, direction = "LR")) |>
  g6_options(edge = list(type = "cubic-horizontal"), autoFit = "view")
```

More on edge styles can be found in the [edges
vignette](https://cynkra.github.io/g6R/articles/edges.md).

The direction of the dendrogram can be changed using the `direction`
parameter. The default is “LR” (left to right), but it can for example
also be set to “TB” (top to bottom).

``` r
g6(tree$nodes, tree$edges) |>
  g6_layout(dendrogram_layout(nodeSep = 36, rankSep = 250, direction = "TB")) |>
  g6_options(edge = list(type = "cubic-horizontal"), autoFit = "view")
```

The
[`compact_box_layout()`](https://cynkra.github.io/g6R/reference/compact_box_layout.md)
function is a wrapper around the [Compact Box layout
algorithm](https://g6.antv.antgroup.com/en/manual/layout/build-in/compact-box-layout).
It can be used to create compact visualizations of trees.

``` r
g6(tree$nodes, tree$edges) |>
  g6_layout(compact_box_layout(
    getHeight = JS(
      "function getHeight() {
          return 32;
        }"
    ),
    getWidth = JS(
      "function getWidth() {
          return 32;
        }"
    ),
    getVGap = JS(
      "function getVGap() {
          return 10;
        }"
    ),
    getHGap = JS(
      "function getHGap() {
          return 100;
        }"
    )
  )) |>
  g6_options(edge = list(type = "cubic-horizontal"), autoFit = "view")
```

## Manual layout

Sometimes, you might want to manually specify the positions of nodes in
a graph. The most straightforward way to do this is to add the
coordinates to the nodes data frame and use the
[`g6_options()`](https://cynkra.github.io/g6R/reference/g6_options.md)
function to set the node styles accordingly.

``` r
g6(lesmis$nodes, lesmis$edges) |>
  g6_options(
    autoFit = "view",
    autoResize = TRUE,
    node = list(
      style = list(
        x = JS("(d) => {return 500*d.x}"),
        y = JS("(d) => {return 500*d.y}")
      )
    )
  )
```
