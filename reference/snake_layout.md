# Generate G6 Snake layout configuration

Lays a chain out in rows that turn back on themselves. It only applies
to a single path (one source, one sink, every other node with one input
and one output); any other graph is left as it is.

## Usage

``` r
snake_layout(cols = NULL, rowGap = NULL, colGap = NULL, clockwise = NULL, ...)
```

## Arguments

- cols:

  Nodes per row.

- rowGap, colGap:

  Gaps between rows and columns (px).

- clockwise:

  Whether the first row runs left to right.

- ...:

  Additional parameters passed to the layout. See
  <https://g6.antv.antgroup.com/en/manual/layout/snake>.

## Value

A list containing the layout configuration.

## Examples

``` r
snake_layout(cols = 4)
#> $type
#> [1] "snake"
#> 
#> $cols
#> [1] 4
#> 
```
