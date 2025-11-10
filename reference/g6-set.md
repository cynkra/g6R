# Set the state of nodes/edges/combos in a g6 graph via proxy

This function sets the state of one or more nodes/edges/combos to an
existing g6 graph instance using a proxy object. This allows updating
the graph without completely re-rendering it. Valid states are
"selected", "active", "inactive", "disabled", or "highlight".

## Usage

``` r
g6_set_nodes(graph, nodes)

g6_set_edges(graph, edges)

g6_set_combos(graph, combos)

g6_set_data(graph, data)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

- nodes:

  A key value pair list with the node id and its state.

- edges:

  A key value pair list with the edge id and its state.

- combos:

  A key value pair list with the combo id and its state.

- data:

  A nested list containing all nodes, edges and combo data.
  Alternatively you can use
  [`g6_data`](https://cynkra.github.io/g6R/reference/g6_data.md) to
  generate compatible data.

## Value

The g6_proxy object (invisibly), allowing for method chaining.

## Details

g6_set_data allows to set all graph data at once (nodes, edges and
combos).

This function can only be used with a g6_proxy object within a Shiny
application. It will not work with regular g6 objects outside of Shiny.

If a node with the same ID already exists, it will not be added again.
See
<https://g6.antv.antgroup.com/en/api/element#graphsetelementstateid-state-options>
for more details.

## See also

[`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md)
