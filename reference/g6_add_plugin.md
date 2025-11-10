# Add a plugin to a g6 graph via proxy

This function adds one or more plugins to an existing g6 graph instance
using a proxy object within a Shiny application.

## Usage

``` r
g6_add_plugin(graph, ...)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

- ...:

  Named arguments where each name is a plugin type and each value is a
  list of configuration options for that plugin.

## Value

The g6_proxy object (invisibly), allowing for method chaining.

## Details

This function can only be used with a g6_proxy object within a Shiny
application. It will not work with regular g6 objects outside of Shiny.

G6 plugins extend the functionality of the graph visualization with
features like minimaps, toolbar controls, contextual menus, and more.
This function allows adding these plugins dynamically after the graph
has been initialized.

## See also

[`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md),
[`g6_update_plugin`](https://cynkra.github.io/g6R/reference/g6_update_plugin.md)
