# Update a behavior in a g6 graph via proxy

This function allows updating the configuration of an existing behavior
in a g6 graph instance using a proxy object within a Shiny application.

## Usage

``` r
g6_update_behavior(graph, key, ...)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

- key:

  Character string identifying the behavior to update.

- ...:

  Named arguments representing the behavior configuration options to
  update and their new values.

## Value

The g6_proxy object (invisibly), allowing for method chaining.

## Details

This function can only be used with a g6_proxy object within a Shiny
application. It will not work with regular g6 objects outside of Shiny.

Behaviors in G6 define how the graph responds to user interactions like
dragging, zooming, clicking, etc. This function allows dynamically
updating the configuration of these behaviors without having to
reinitialize the graph.

## See also

[`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md)
