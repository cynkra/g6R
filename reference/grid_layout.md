# Generate G6 Grid layout configuration

Generate G6 Grid layout configuration

## Usage

``` r
grid_layout(
  rows = NULL,
  cols = NULL,
  sortBy = NULL,
  preventOverlap = NULL,
  condense = NULL,
  ...
)
```

## Arguments

- rows, cols:

  Number of rows and columns; derived from the node count when not
  given.

- sortBy:

  Node order: "id", "degree" or a JS comparator.

- preventOverlap:

  Whether nodes are kept from overlapping.

- condense:

  Whether the grid takes the least space it can.

- ...:

  Additional parameters passed to the layout. See
  <https://g6.antv.antgroup.com/en/manual/layout/grid-layout>.

## Value

A list containing the layout configuration.

## Examples

``` r
grid_layout(cols = 4)
#> $type
#> [1] "grid"
#> 
#> $cols
#> [1] 4
#> 
```
