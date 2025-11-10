# Center graph

This function pans the graph to the center of the viewport

## Usage

``` r
g6_fit_center(graph, animation = NULL)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

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
<https://g6.antv.antgroup.com/en/api/viewport#graphfitcenteranimation>
for more details.

## See also

[`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md)
