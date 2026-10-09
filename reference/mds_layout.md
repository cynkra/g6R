# Generate G6 MDS layout configuration

Multidimensional scaling: places nodes so that drawn distances follow
graph distances.

## Usage

``` r
mds_layout(linkDistance = NULL, center = NULL, ...)
```

## Arguments

- linkDistance:

  Ideal edge length (px).

- center:

  Centre of the layout, a vector of x and y.

- ...:

  Additional parameters passed to the layout. See
  <https://g6.antv.antgroup.com/en/manual/layout/mds-layout>.

## Value

A list containing the layout configuration.

## Examples

``` r
mds_layout(linkDistance = 80)
#> $type
#> [1] "mds"
#> 
#> $linkDistance
#> [1] 80
#> 
```
