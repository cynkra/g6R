# Coerce to a list of g6_port objects (g6_ports)

Coerce to a list of g6_port objects (g6_ports)

## Usage

``` r
as_g6_ports(x, ...)

# S3 method for class 'g6_ports'
as_g6_ports(x, ...)

# S3 method for class 'list'
as_g6_ports(x, ...)
```

## Arguments

- x:

  An object to coerce.

- ...:

  Additional arguments (unused).

## Value

An object of class `g6_ports`.

## Examples

``` r
as_g6_ports(list(
  list(key = "input-1", type = "input", placement = "left"),
  list(key = "output-1", type = "output", placement = "right")
))
#> [[1]]
#> $key
#> [1] "input-1"
#> 
#> $type
#> [1] "input"
#> 
#> $arity
#> [1] 1
#> 
#> $visibility
#> [1] "visible"
#> 
#> $label
#> [1] "input-1"
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
#> 
#> [[2]]
#> $key
#> [1] "output-1"
#> 
#> $type
#> [1] "output"
#> 
#> $arity
#> [1] 1
#> 
#> $visibility
#> [1] "visible"
#> 
#> $label
#> [1] "output-1"
#> 
#> $fill
#> [1] "#FF4D4F"
#> 
#> $placement
#> [1] "right"
#> 
#> $r
#> [1] 4
#> 
#> attr(,"class")
#> [1] "g6_port"
#> 
#> attr(,"class")
#> [1] "g6_ports"
as_g6_ports(g6_ports(
  g6_port("input-1", type = "input"),
  g6_port("output-1", type = "output")
))
#> [[1]]
#> $key
#> [1] "input-1"
#> 
#> $type
#> [1] "input"
#> 
#> $arity
#> [1] 1
#> 
#> $visibility
#> [1] "visible"
#> 
#> $label
#> [1] "input-1"
#> 
#> $r
#> [1] 4
#> 
#> attr(,"class")
#> [1] "g6_port"
#> 
#> [[2]]
#> $key
#> [1] "output-1"
#> 
#> $type
#> [1] "output"
#> 
#> $arity
#> [1] 1
#> 
#> $visibility
#> [1] "visible"
#> 
#> $label
#> [1] "output-1"
#> 
#> $r
#> [1] 4
#> 
#> attr(,"class")
#> [1] "g6_port"
#> 
#> attr(,"class")
#> [1] "g6_ports"
```
