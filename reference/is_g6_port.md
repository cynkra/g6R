# Check if an object is a g6_port

Check if an object is a g6_port

## Usage

``` r
is_g6_port(x)

is_g6_ports(x)
```

## Arguments

- x:

  An object to check.

## Value

Logical indicating if `x` is of class `g6_port`.

## Examples

``` r
p <- g6_port("input-1", type = "input")
is_g6_port(p)
#> [1] TRUE
is_g6_port(list(key = "input-1", type = "input"))
#> [1] FALSE
is_g6_port(as_g6_port(list(key = "input-1", type = "input")))
#> [1] TRUE
is_g6_ports(g6_ports(
  g6_port("input-1", type = "input"),
  g6_port("output-1", type = "output")
))
#> [1] TRUE
```
