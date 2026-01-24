# Coerce to a g6_port object

Coerce to a g6_port object

## Usage

``` r
as_g6_port(x, ...)

# S3 method for class 'g6_port'
as_g6_port(x, ...)

# S3 method for class 'list'
as_g6_port(x, ...)
```

## Arguments

- x:

  An object to coerce.

- ...:

  Additional arguments (unused).

## Value

An object of class `g6_port`.

## Examples

``` r
as_g6_port(list(key = "input-1", type = "input", placement = "left"))
#> Warning: 'showGuides' is set to TRUE, but Shiny app is not running. Connection guides will not be displayed.
#> $key
#> [1] "input-1"
#> 
#> $type
#> [1] "input"
#> 
#> $label
#> [1] "input-1"
#> 
#> $arity
#> [1] 1
#> 
#> $showGuides
#> [1] FALSE
#> 
#> $fill
#> [1] "#52C41A"
#> 
#> $placement
#> [1] "left"
#> 
#> $r
#> [1] 4
#> 
#> attr(,"class")
#> [1] "g6_port"
as_g6_port(g6_port("input-1", type = "input"))
#> $key
#> [1] "input-1"
#> 
#> $type
#> [1] "input"
#> 
#> $label
#> [1] "input-1"
#> 
#> $arity
#> [1] 1
#> 
#> $showGuides
#> [1] FALSE
#> 
#> $r
#> [1] 4
#> 
#> attr(,"class")
#> [1] "g6_port"
```
