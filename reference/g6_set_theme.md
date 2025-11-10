# Set the theme for a g6 graph via proxy

This function sets the theme for an existing g6 graph instance

## Usage

``` r
g6_set_theme(graph, theme)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

- theme:

  A character string representing the theme to apply to the graph. There
  are 2 internal predefined themes: `light` and `dark`. Alternatively,
  you can pass a custom theme object that conforms to the G6 theme
  specifications, according to the documentation at
  <https://g6.antv.antgroup.com/en/manual/theme/custom-theme>.

## Value

The g6_proxy object (invisibly), allowing for method chaining.

## See also

[`g6_proxy()`](https://cynkra.github.io/g6R/reference/g6_proxy.md)
