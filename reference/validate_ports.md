# Validate a list of G6 ports

Validate a list of G6 ports

## Usage

``` r
validate_ports(x, ...)

# S3 method for class 'list'
validate_ports(x, ...)

# S3 method for class 'g6_ports'
validate_ports(x, ...)
```

## Arguments

- x:

  A list of g6_port objects.

- ...:

  Generic consistency.

## Value

The validated list (invisibly).

## Examples

``` r
validate_ports(list(
  g6_port("input-1", type = "input"),
  g6_port("output-1", type = "output")
))
```
