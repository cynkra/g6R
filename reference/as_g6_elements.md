# Coerce to a list of g6_elements objects

Coerce to a list of g6_elements objects

## Usage

``` r
as_g6_nodes(x, ...)

as_g6_edges(x, ...)

# S3 method for class 'g6_edges'
as_g6_edges(x, ...)

# S3 method for class 'data.frame'
as_g6_edges(x, ...)

# S3 method for class 'list'
as_g6_edges(x, ...)

as_g6_combos(x, ...)

# S3 method for class 'g6_combos'
as_g6_combos(x, ...)

# S3 method for class 'data.frame'
as_g6_combos(x, ...)

# S3 method for class 'list'
as_g6_combos(x, ...)
```

## Arguments

- x:

  An object to be coerced. Data frame, list or g6 element are supported.

- ...:

  Additional arguments (unused).

## Value

An object of class `g6_nodes`, `g6_edges`, or `g6_combos`.
