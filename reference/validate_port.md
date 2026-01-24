# Validate a single G6 port

Validate a single G6 port

## Usage

``` r
validate_port(x, ...)

# S3 method for class 'g6_port'
validate_port(x, ...)
```

## Arguments

- x:

  An object of class 'g6_port'.

- ...:

  Generic consistency.

## Value

The validated port (invisibly).

## Examples

``` r
validate_port(g6_port("input-1", type = "input"))
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
