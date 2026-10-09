# Generate G6 Random layout configuration

Generate G6 Random layout configuration

## Usage

``` r
random_layout(width = NULL, height = NULL, ...)
```

## Arguments

- width, height:

  Size of the area nodes are placed in (px).

- ...:

  Additional parameters passed to the layout. See
  <https://g6.antv.antgroup.com/en/manual/layout/random-layout>.

## Value

A list containing the layout configuration.

## Examples

``` r
random_layout()
#> $type
#> [1] "random"
#> 
```
