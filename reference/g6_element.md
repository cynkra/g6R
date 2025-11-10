# G6 Graph Elements

Constructors and validators for G6 node, edge, and combo elements.

## Usage

``` r
g6_node(
  id,
  type = NULL,
  data = NULL,
  style = NULL,
  states = NULL,
  combo = NULL,
  children = NULL
)

g6_edge(
  source,
  target,
  id = paste(source, target, sep = "-"),
  type = NULL,
  data = NULL,
  style = NULL,
  states = NULL
)

g6_combo(
  id,
  type = NULL,
  data = NULL,
  style = NULL,
  states = NULL,
  combo = NULL
)

is_g6_node(x)

is_g6_edge(x)

is_g6_combo(x)

validate_element(x, ...)

# S3 method for class 'g6_element'
validate_element(x, ...)

# S3 method for class 'g6_node'
validate_element(x, ...)

# S3 method for class 'g6_edge'
validate_element(x, ...)

# S3 method for class 'g6_combo'
validate_element(x, ...)

as_g6_node(x, ...)

# S3 method for class 'g6_node'
as_g6_node(x, ...)

# S3 method for class 'list'
as_g6_node(x, ...)

as_g6_edge(x, ...)

# S3 method for class 'g6_edge'
as_g6_edge(x, ...)

# S3 method for class 'list'
as_g6_edge(x, ...)

as_g6_combo(x, ...)

# S3 method for class 'g6_combo'
as_g6_combo(x, ...)

# S3 method for class 'list'
as_g6_combo(x, ...)
```

## Arguments

- id:

  Character. Unique identifier for the node or combo (required). For
  edges, this is optional (id is constructed as source-target if not
  provided).

- type:

  Character. Element type (optional).

- data:

  List. Custom data for the element (optional).

- style:

  List. Element style (optional).

- states:

  Character vector. Initial states for the element (optional).

- combo:

  Character or NULL. Combo ID or parent combo ID (optional).

- children:

  Character vector. Child node IDs (optional, nodes only).

- source:

  Character. Source node ID (required, edges only).

- target:

  Character. Target node ID (required, edges only).

- x:

  An object of class `g6_element`, `g6_node`, `g6_edge`, or `g6_combo`.

- ...:

  Additional arguments (unused). the checks on source and target.

## Value

An S3 object of class `g6_node`, `g6_edge`, or `g6_combo` (and
`g6_element`).

## Examples

``` r
# Create a node
node <- g6_node(
  id = "n1",
  type = "rect",
  data = list(label = "Node 1"),
  style = list(color = "red"),
  states = list("selected"),
  combo = NULL,
  children = c("n2", "n3")
)

# Create an edge
edge <- g6_edge(
  source = "n1",
  target = "n2",
  type = "line",
  style = list(width = 2)
)

# Create a combo
combo <- g6_combo(
  id = "combo1",
  type = "rect",
  data = list(label = "Combo 1"),
  style = list(border = "dashed"),
  states = list("active"),
  combo = NULL
)

# Validate a node explicitly
validate_element(node)
#> $id
#> [1] "n1"
#> 
#> $type
#> [1] "rect"
#> 
#> $data
#> $data$label
#> [1] "Node 1"
#> 
#> 
#> $style
#> $style$color
#> [1] "red"
#> 
#> 
#> $states
#> $states[[1]]
#> [1] "selected"
#> 
#> 
#> $children
#> [1] "n2" "n3"
#> 
#> attr(,"class")
#> [1] "g6_node"    "g6_element"
```
