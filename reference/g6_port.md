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
  showGuides = TRUE,
  ...
)

g6_input_port(key, label = key, arity = 1, fill = "#52C41A", ...)

g6_output_port(key, label = key, arity = 1, fill = "#FF4D4F", ...)
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

- showGuides:

  Logical. Whether to show connection guides when hovering over the port
  (default: TRUE). Only works when used within a Shiny app.

- ...:

  Additional port style parameters. See
  <https://g6.antv.antgroup.com/en/manual/element/node/base-node#portstyleprops>.

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
#> $label
#> [1] "port 1"
#> 
#> $arity
#> [1] 2
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
g6_port("output-1", label = "port 2", type = "output", placement = "right")
#> $key
#> [1] "output-1"
#> 
#> $type
#> [1] "output"
#> 
#> $label
#> [1] "port 2"
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
```
