# Focus on specific elements in a g6 graph via proxy

This function focuses on one or more elements (nodes/edges) in an
existing g6 graph instance using a proxy object. It highlights the
specified elements and can optionally animate the view to focus on them.

## Usage

``` r
g6_focus_elements(graph, ids, animation = NULL)

g6_focus_nodes(graph, ids, animation = NULL)

g6_focus_edges(graph, ids, animation = NULL)

g6_focus_combos(graph, ids, animation = NULL)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

- ids:

  Character vector containing the IDs of the elements
  (nodes/edges/combos) to focus on.

- animation:

  Optional list containing animation configuration parameters for the
  focus action. Common parameters include:

  - `duration`: Duration of the animation in milliseconds.

  - `easing`: Animation easing function name (e.g., "ease-in",
    "ease-out").

  If NULL, no animation will be applied.

## Value

The g6_proxy object (invisibly), allowing for method chaining.

## Details

This function can only be used with a g6_proxy object within a Shiny
application. It will not work with regular g6 objects outside of Shiny.

See
<https://g6.antv.antgroup.com/en/api/element#graphfocuselementid-animation>
for more details.

## See also

[`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md)
