# Create a G6 Port

Create a G6 Port

Create a single-connection input port

Create an output port (single connection by default)

## Usage

``` r
g6_port(
  key,
  label = key,
  type = c("input", "output"),
  arity = 1,
  visibility = c("visible", "hover", "hidden"),
  ...
)

g6_input_port(
  key,
  label = key,
  arity = 1,
  visibility = c("visible", "hover", "hidden"),
  fill = "#52C41A",
  ...
)

g6_output_port(
  key,
  label = key,
  arity = 1,
  visibility = c("visible", "hover", "hidden"),
  fill = "#FF4D4F",
  ...
)
```

## Arguments

- key:

  Character. Unique identifier for the port (required).

- label:

  Character. Label text for the port (optional).

- type:

  Character. Either "input" or "output" (required).

- arity:

  Numeric. Maximum number of connections this port can accept (default:
  1). Use 0, Inf, or any non-negative integer.

- visibility:

  Character. Controls port visibility behavior:

  - `"visible"`: Ports are always shown (default).

  - `"hover"`: Ports appear only when hovering over the node.

  - `"hidden"`: Ports are never visible.

- ...:

  Additional port style parameters, e.g. `placement` and `r` (radius,
  default 6). See
  <https://g6.antv.antgroup.com/en/manual/element/node/base-node#portstyleprops>.
  In addition to G6's native placements (`"left"`, `"right"`, `"top"`,
  `"bottom"`, or a `c(x, y)` pair), g6R adds
  `placement = "label-bottom"`: the port snaps to the bottom-centre of
  the node's label background when the node has a bottom label, falling
  back to a normal bottom-of-node port otherwise. Pass `ripple = FALSE`
  to disable the hover ripple for a port, or `haloFill` to override the
  colour of the ring that makes the port look set into the node surface.

- fill:

  Character. Color of the port (default: "#52C41A" for input ports,
  "#FF4D4F" for output ports).

## Value

An S3 object of class 'g6_port'.

## Note

To create an (input/output) port with multiple connections, simply set
the arity to `Inf` or any positive integer.

## Examples

``` r
g6_port("input-1", label = "port 1", type = "input", arity = 2, placement = "left")
#> $key
#> [1] "input-1"
#> 
#> $type
#> [1] "input"
#> 
#> $arity
#> [1] 2
#> 
#> $visibility
#> [1] "visible"
#> 
#> $label
#> [1] "port 1"
#> 
#> $placement
#> [1] "left"
#> 
#> $r
#> [1] 6
#> 
#> attr(,"class")
#> [1] "g6_port"
g6_port("output-1", label = "port 2", type = "output", placement = "right")
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
#> [1] "port 2"
#> 
#> $placement
#> [1] "right"
#> 
#> $r
#> [1] 6
#> 
#> attr(,"class")
#> [1] "g6_port"
g6_port("input-2", type = "input", visibility = "hover")
#> $key
#> [1] "input-2"
#> 
#> $type
#> [1] "input"
#> 
#> $arity
#> [1] 1
#> 
#> $visibility
#> [1] "hover"
#> 
#> $label
#> [1] "input-2"
#> 
#> $r
#> [1] 6
#> 
#> attr(,"class")
#> [1] "g6_port"
```
