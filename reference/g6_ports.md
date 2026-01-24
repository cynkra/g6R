# Create a List of G6 Ports

Create a List of G6 Ports

## Usage

``` r
g6_ports(...)
```

## Arguments

- ...:

  One or more g6_port objects.

## Value

An S3 object of class 'g6_ports'.

## Examples

``` r
g6_ports(
  g6_port("input-1", type = "input", placement = "left"),
  g6_port("output-1", type = "output", placement = "right")
)
#> [[1]]
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
#> $label
#> [1] "output-1"
#> 
#> $arity
#> [1] 1
#> 
#> $showGuides
#> [1] FALSE
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
```
