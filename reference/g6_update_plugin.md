# Update a plugin in a g6 graph via proxy

This function allows updating the configuration of an existing plugin in
a g6 graph instance using a proxy object within a Shiny application.

## Usage

``` r
g6_update_plugin(graph, key, ...)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

- key:

  Character string identifying the plugin to update.

- ...:

  Named arguments representing the plugin configuration options to
  update and their new values.

## Value

The g6_proxy object (invisibly), allowing for method chaining.

## Details

This function can only be used with a g6_proxy object within a Shiny
application. It will not work with regular g6 objects outside of Shiny.

The function allows dynamically updating the configuration of an
existing plugin without having to reinitialize it. This is useful for
changing plugin behavior or appearance in response to user interactions.

## See also

[`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md),
[`g6_add_plugin`](https://cynkra.github.io/g6R/reference/g6_add_plugin.md)
