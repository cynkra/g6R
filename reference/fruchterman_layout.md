# Generate G6 Fruchterman layout configuration

This function creates a configuration list for G6 Fruchterman layout
with all available options as parameters.

## Usage

``` r
fruchterman_layout(height = NULL, width = NULL, gravity = 10, speed = 5, ...)
```

## Arguments

- height:

  Numeric. Layout height. Defaults to container height.

- width:

  Numeric. Layout width. Defaults to container width.

- gravity:

  Numeric. Central force attracting nodes to the center. Larger values
  make the layout more compact. Defaults to 10.

- speed:

  Numeric. Node movement speed per iteration. Higher values may cause
  oscillation. Defaults to 5.

- ...:

  Additional parameters to pass to the layout. See
  <https://g6.antv.antgroup.com/en/manual/layout/fruchterman-layout>.

## Value

A list containing the configuration for G6 fruchterman layout.

## Examples

``` r
if (interactive()) {
  g6(lesmis$nodes, lesmis$edges) |>
   g6_layout(fruchterman_layout(
     gravity = 5,
     speed = 5
   )) |>
   g6_behaviors(
     "zoom-canvas",
     drag_element()
   )
}
```
