# Generate G6 D3 Force layout configuration

This function creates a configuration list for G6 D3 Force layout with
all available options as parameters.

## Usage

``` r
d3_force_layout(
  link = list(distance = 100, strength = 2),
  collide = list(radius = 40),
  ...
)
```

## Arguments

- link:

  A list specifying force parameters for links (edges), with components:

  id

  :   Edge id generation function, format:
      `function(edge, index, edges) { return string }`. Default is
      `function(e) e.id`

  distance

  :   Ideal edge length that edges will tend toward. Can be a number or
      a function `function(edge, index, edges) { return number }`.
      Default is 30

  strength

  :   The strength of the force. Higher values make edge lengths closer
      to the ideal length. Can be a number or a function
      `function(edge, index, edges) { return number }`. Default is 1

  iterations

  :   Number of iterations of link force. Default is 1

- collide:

  A list specifying collision force parameters for nodes, with
  components:

  radius

  :   Collision radius. Nodes closer than this distance will experience
      a repulsive force. Can be a number or a function
      `function(node, index, nodes) { return number }`. Default is 10

  strength

  :   The strength of the repulsive force. Higher values produce more
      obvious repulsion. Default is 1

  iterations

  :   The number of iterations for collision detection. Default is 1

- ...:

  Additional parameters to pass to the layout. See
  <https://g6.antv.antgroup.com/en/manual/layout/d3-force>.

## Value

A list containing the configuration for G6 AntV D3 Force layout.

## Examples

``` r
# Basic D3 force layout
d3_force_config <- d3_force_layout()

# Custom link distance and collision radius
d3_force_config <- d3_force_layout(
  link = list(
    distance = 150,
    strength = 0.5,
    iterations = 3
  ),
  collide = list(
    radius = 30,
    strength = 0.8
  )
)
```
