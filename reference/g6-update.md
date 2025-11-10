# Update nodes/edges/combos to a g6 graph via proxy

This function updates one or more nodes/edges/combos to an existing g6
graph instance using a proxy object. This allows updating the graph
without completely re-rendering it.

## Usage

``` r
g6_update_nodes(graph, ...)

g6_update_edges(graph, ...)

g6_update_combos(graph, ...)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

- ...:

  Nodes or edges or combos. You can pass a list of nodes/edges/combos, a
  dataframe or leverage the g6_nodes(), g6_edges() or g6_combos()
  helpers or pass individual elements like g6_node(), g6_edge() or
  g6_combo(). Elements structure must be compliant with specifications
  listed at <https://g6.antv.antgroup.com/manual/element/overview>.

## Value

The g6_proxy object (invisibly), allowing for method chaining.

## Details

This function can only be used with a g6_proxy object within a Shiny
application. It will not work with regular g6 objects outside of Shiny.

See <https://g6.antv.antgroup.com/en/api/data#graphupdatenodedata>,
<https://g6.antv.antgroup.com/en/api/data#graphupdateedgedata> and
<https://g6.antv.antgroup.com/en/api/data#graphupdatecombodata> for more
details.

## See also

[`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md),
[`g6_remove_nodes`](https://cynkra.github.io/g6R/reference/g6-remove.md)
