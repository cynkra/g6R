# Create a g6_data object

Create compatible data structure for
[`g6_add_data()`](https://cynkra.github.io/g6R/reference/g6-add.md),
[`g6_set_data()`](https://cynkra.github.io/g6R/reference/g6-set.md) or
simply [`g6()`](https://cynkra.github.io/g6R/reference/g6.md).

## Usage

``` r
g6_data(nodes = NULL, edges = NULL, combos = NULL)

is_g6_data(x)

as_g6_data(x, ...)

# S3 method for class 'g6_data'
as_g6_data(x, ...)

# S3 method for class 'list'
as_g6_data(x, ...)
```

## Arguments

- nodes:

  Nodes data.

- edges:

  Edges data.

- combos:

  Combo data.

- x:

  A list with elements `nodes`, `edges`, and/or `combos`.

- ...:

  Additional arguments (unused).
