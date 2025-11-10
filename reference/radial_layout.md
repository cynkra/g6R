# Generate G6 Radial layout configuration

This function creates a configuration list for G6 Radial layout with all
available options as parameters.

## Usage

``` r
radial_layout(
  center = NULL,
  focusNode = NULL,
  height = NULL,
  width = NULL,
  nodeSize = NULL,
  nodeSpacing = 10,
  linkDistance = 50,
  unitRadius = 100,
  maxIteration = 1000,
  maxPreventOverlapIteration = 200,
  preventOverlap = FALSE,
  sortBy = NULL,
  sortStrength = 10,
  strictRadial = TRUE,
  ...
)
```

## Arguments

- center:

  Numeric vector of length 2. Center coordinates.

- focusNode:

  Character, list (Node), or NULL. Radiating center node. Defaults to
  NULL.

- height:

  Numeric. Canvas height.

- width:

  Numeric. Canvas width.

- nodeSize:

  Numeric. Node size (diameter).

- nodeSpacing:

  Numeric or function. Minimum node spacing (effective when preventing
  overlap). Defaults to 10.

- linkDistance:

  Numeric. Edge length. Defaults to 50.

- unitRadius:

  Numeric or NULL. Radius per circle. Defaults to 100.

- maxIteration:

  Numeric. Maximum number of iterations. Defaults to 1000.

- maxPreventOverlapIteration:

  Numeric. Max iterations for overlap prevention. Defaults to 200.

- preventOverlap:

  Logical. Whether to prevent node overlap. Defaults to FALSE.

- sortBy:

  Character. Field for sorting nodes in the same layer.

- sortStrength:

  Numeric. Sorting strength for nodes in the same layer. Defaults to 10.

- strictRadial:

  Logical. Strictly place nodes in the same layer on the same ring.
  Defaults to TRUE.

- ...:

  Additional parameters to pass to the layout. See
  <https://g6.antv.antgroup.com/en/manual/layout/radial-layout>.

## Value

A list containing the configuration for G6 radial layout.

## Examples

``` r
if (interactive()) {
  g6(jsonUrl = "https://assets.antv.antgroup.com/g6/radial.json") |>
    g6_layout(
      radial_layout(
        unitRadius = 100,
        linkDistance = 200
      )
    ) |>
    g6_behaviors(
      "zoom-canvas",
      drag_element()
    )
}
```
