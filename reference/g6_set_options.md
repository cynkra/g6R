# Set options for a g6 graph via proxy

This function allows updating various configuration options of an
existing g6 graph instance using a proxy object within a Shiny
application.

## Usage

``` r
g6_set_options(graph, ...)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

- ...:

  Named arguments representing the options to update and their new
  values. These can include any valid g6 graph options such as fitView,
  animate, modes, etc.

## Value

The g6_proxy object (invisibly), allowing for method chaining.

## Details

This function can only be used with a g6_proxy object within a Shiny
application. It will not work with regular g6 objects outside of Shiny.

The function allows updating various graph options dynamically without
having to re-render the entire graph. This is useful for changing
behavior, appearance, or interaction modes in response to user input.

## See also

[`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md)
