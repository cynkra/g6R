# Collapse or expand a combo element in a g6 graph

This function collapses/expands a specified combo (a group of nodes) in
a g6 graph, hiding its member nodes and edges while maintaining the
combo itself visible. This is useful for simplifying complex graphs with
multiple hierarchical groups.

## Usage

``` r
g6_collapse_combo(graph, id, options = NULL)

g6_expand_combo(graph, id, options = NULL)
```

## Arguments

- graph:

  A g6 graph object or a g6_proxy object for Shiny applications.

- id:

  Character string specifying the ID of the combo to collapse/expand.

- options:

  List containing optional configuration parameters for the
  collapse/expand action:

  - `animate`: Logical value indicating whether to animate the
    collapsing process. Default is `TRUE`.

  - `align`: Logical value to ensure the position of expanded/collapsed
    nodes remains unchanged.

## Value

The modified g6 graph or g6_proxy object, allowing for method chaining.

## Details

When a combo is collapsed, its member nodes and edges are hidden from
view while the combo itself remains visible, typically shown as a single
node. This helps to reduce visual complexity in large graphs with
hierarchical groupings.

## References

<https://g6.antv.antgroup.com/en/api/element#graphcollapseelementid-options>,
<https://g6.antv.antgroup.com/en/api/element#graphexpandelementid-options>
