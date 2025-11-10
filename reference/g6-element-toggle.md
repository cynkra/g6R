# Hide/show elements in a g6 graph

This function hides/shows specified elements (nodes, edges, or combos)
in a g6 graph. Hidden elements are removed from view but remain in the
graph data structure.

## Usage

``` r
g6_hide_elements(graph, ids, animation = NULL)

g6_hide_nodes(graph, ids, animation = NULL)

g6_hide_edges(graph, ids, animation = NULL)

g6_hide_combos(graph, ids, animation = NULL)

g6_show_elements(graph, ids, animation = NULL)

g6_show_nodes(graph, ids, animation = NULL)

g6_show_edges(graph, ids, animation = NULL)

g6_show_combos(graph, ids, animation = NULL)
```

## Arguments

- graph:

  A g6 graph object or a g6_proxy object for Shiny applications.

- ids:

  Character vector specifying the IDs of elements to hide/show. Can
  include node IDs, edge IDs, or combo IDs.

- animation:

  Boolean to toggle animation.

## Value

The modified g6 graph or g6_proxy object, allowing for method chaining.

## Details

When elements are hidden, they are removed from the visual display but
still exist in the underlying data structure. This means they can be
shown again later using `g6_show_elements` without having to recreate
them.

Hidden elements will not participate in layout calculations, which may
cause other elements to reposition. When elements are shown again, the
graph may recalculate layout positions, which can cause other elements
to reposition.

## See also

`g6_show_elements`
