# Generate G6 Force layout configuration

G6's own force-directed layout, as opposed to
[`d3_force_layout()`](https://cynkra.github.io/g6R/reference/d3_force_layout.md).

## Usage

``` r
force_layout(
  linkDistance = NULL,
  nodeStrength = NULL,
  edgeStrength = NULL,
  preventOverlap = NULL,
  gravity = NULL,
  ...
)
```

## Arguments

- linkDistance:

  Ideal edge length (px).

- nodeStrength:

  Node repulsion strength.

- edgeStrength:

  Edge attraction strength.

- preventOverlap:

  Whether nodes are kept from overlapping.

- gravity:

  Strength of the pull towards the centre.

- ...:

  Additional parameters passed to the layout. See
  <https://g6.antv.antgroup.com/en/manual/layout/force-layout>.

## Value

A list containing the layout configuration.

## Examples

``` r
force_layout(linkDistance = 100, preventOverlap = TRUE)
#> $type
#> [1] "force"
#> 
#> $linkDistance
#> [1] 100
#> 
#> $preventOverlap
#> [1] TRUE
#> 
```
