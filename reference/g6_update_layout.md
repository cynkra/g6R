# Execute layout for a g6 graph via proxy

This function order the execution of the layout of the current graph. It
can also update layout options before running it.

## Usage

``` r
g6_update_layout(graph, ...)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

- ...:

  Any option to pass to the layout. If so, the layout is updated before
  running it.

## Value

The g6_proxy object (invisibly), allowing for method chaining.

## Details

This function can only be used with a g6_proxy object within a Shiny
application. It will not work with regular g6 objects outside of Shiny.

## See also

[`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md)
