# Generate G6 AntV circular layout configuration

This function creates a configuration list for G6 AntV circular layout
with all available options as parameters.

## Usage

``` r
circular_layout(
  angleRatio = 1,
  center = NULL,
  clockwise = TRUE,
  divisions = 1,
  nodeSize = 10,
  nodeSpacing = 10,
  ordering = NULL,
  radius = NULL,
  startAngle = 0,
  endAngle = 2 * pi,
  startRadius = NULL,
  endRadius = NULL,
  width = NULL,
  height = NULL,
  ...
)
```

## Arguments

- angleRatio:

  How many `2*PI` are there between the first node and the last node.

- center:

  Center of layout as vector `c(x, y)` or `c(x, y, z)`.

- clockwise:

  Is it arranged clockwise?

- divisions:

  Number of segments that nodes are placed on the ring.

- nodeSize:

  Node size (diameter) for collision detection.

- nodeSpacing:

  Minimum distance between rings.

- ordering:

  Basis for sorting nodes ("topology", "topology-directed", or
  "degree").

- radius:

  Radius of the circle (overrides startRadius and endRadius).

- startAngle:

  Starting angle of the layout.

- endAngle:

  End angle of the layout.

- startRadius:

  Starting radius of the spiral layout.

- endRadius:

  End radius of the spiral layout.

- width:

  Width of layout.

- height:

  Height of layout.

- ...:

  Additional parameters to pass to the layout. See
  <https://g6.antv.antgroup.com/en/manual/layout/circular-layout>.

## Value

A list containing the configuration for G6 AntV circular layout.

## Examples

``` r
circular_config <- circular_layout(
  radius = 200,
  startAngle = 0,
  endAngle = pi,
  clockwise = FALSE
)
```
