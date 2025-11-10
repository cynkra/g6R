# Create and validate lists of G6 elements

Constructors for lists of G6 node, edge, and combo elements. Each
function accepts multiple validated elements and returns a list with the
appropriate class. All elements are validated on construction.

S3 generic for validating lists of G6 elements.

## Usage

``` r
g6_nodes(...)

g6_edges(...)

g6_combos(...)

is_g6_nodes(x)

is_g6_edges(x)

is_g6_combos(x)

validate_elements(x, ...)

# S3 method for class 'g6_nodes'
validate_elements(x, ...)

# S3 method for class 'g6_edges'
validate_elements(x, ...)

# S3 method for class 'g6_combos'
validate_elements(x, ...)

as_g6_nodes(x, ...)

# S3 method for class 'g6_nodes'
as_g6_nodes(x, ...)

# S3 method for class 'data.frame'
as_g6_nodes(x, ...)

# S3 method for class 'list'
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

- ...:

  Additional arguments (unused).

- x:

  An object of class `g6_nodes`, `g6_edges`, or `g6_combos`.

## Value

An object of class `g6_nodes`, `g6_edges`, or `g6_combos`.

Invisibly returns the validated object.

## Examples

``` r
nodes <- g6_nodes(
  g6_node(id = "n1"),
  g6_node(id = "n2")
)
edges <- g6_edges(
  g6_edge(source = "n1", target = "n2")
)
combos <- g6_combos(
  g6_combo(id = "c1")
)
```
