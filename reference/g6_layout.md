# Set the layout algorithm for a g6 graph

This function configures the layout algorithm used to position nodes in
a g6 graph.

## Usage

``` r
g6_layout(graph, layout = d3_force_layout())
```

## Arguments

- graph:

  A g6 graph object created with
  [`g6()`](https://cynkra.github.io/g6R/reference/g6.md).

- layout:

  An existing layout function like
  [circular_layout](https://cynkra.github.io/g6R/reference/circular_layout.md)
  or a string like `circular-layout`. At minimum, this can be a list
  that should contain a `type` element specifying the layout algorithm.
  Additional parameters depend on the layout type chosen, for instance
  `list(type = "force")`.

## Value

The modified g6 graph object with the specified layout, allowing for
method chaining.

## Details

G6 provides several layout algorithms, each suitable for different graph
structures:

- **force**: Force-directed layout using physical simulation of forces.

- **random**: Random layout placing nodes randomly.

- **circular**: Arranges nodes on a circle.

- **radial**: Radial layout with nodes arranged outward from a central
  node.

- **grid**: Arranges nodes in a grid pattern.

- **concentric**: Concentric circles with important nodes in the center.

- **dagre**: Hierarchical layout for directed acyclic graphs.

- **fruchterman**: Force-directed layout based on the
  Fruchterman-Reingold algorithm.

- **mds**: Multidimensional scaling layout.

- **comboForce**: Force-directed layout specially designed for combo
  graphs.

Each layout algorithm has specific configuration options. See the G6
documentation for detailed information on each layout and its
parameters: <https://g6.antv.antgroup.com/en/manual/layout/overview>.

## See also

[`g6()`](https://cynkra.github.io/g6R/reference/g6.md)
