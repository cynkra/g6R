# Resize the canvas of a g6 graph via proxy

This function changes the size of the canvas of an existing g6 graph
instance using a proxy object. This allows updating the graph dimensions
without completely re-rendering it.

## Usage

``` r
g6_canvas_resize(graph, width, height)
```

## Arguments

- graph:

  A g6_proxy object created with
  [`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md).

- width:

  Numeric value specifying the new width of the canvas in pixels.

- height:

  Numeric value specifying the new height of the canvas in pixels.

## Value

The g6_proxy object (invisibly), allowing for method chaining.

## Details

This function can only be used with a g6_proxy object within a Shiny
application. It will not work with regular g6 objects outside of Shiny.

See
<https://g6.antv.antgroup.com/en/api/canvas#graphsetsizewidth-height>
for more details.

## See also

[`g6_proxy`](https://cynkra.github.io/g6R/reference/g6_proxy.md)
