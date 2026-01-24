# Extract ports from a g6 graph state via proxy

These helpers extract ports from the graph state stored in Shiny input,
accessed via a g6_proxy object. Ports are grouped by node and can be
filtered by type.

## Usage

``` r
g6_get_ports(graph)

g6_get_input_ports(graph)

g6_get_output_ports(graph)
```

## Arguments

- graph:

  A g6_proxy object.

## Value

A named list of ports for each node, optionally filtered by type.
