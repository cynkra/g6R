# Configure collapse button for nodes

Configure collapse button for nodes

Check if object is a g6_collapse_options configuration

## Usage

``` r
g6_collapse_options(
  collapsed = FALSE,
  visibility = c("visible", "hover"),
  placement = "right-top",
  r = 6,
  fill = "#fff",
  stroke = "#9cabd4",
  lineWidth = 1,
  iconStroke = "#9cabd4",
  iconLineWidth = 1.4,
  cursor = "pointer",
  zIndex = 999
)

is_g6_collapse_options(x)
```

## Arguments

- collapsed:

  Logical. Whether the node should be collapsed initially. Default is
  FALSE.

- visibility:

  Character. Visibility mode of the collapse button. Either `"visible"`
  (always shown when children exist) or `"hover"` (shown only on mouse
  hover). Default is `"visible"`.

- placement:

  Character or numeric vector. Position of the collapse button. Can be
  one of: "top", "right", "bottom", "left", "right-top", "right-bottom",
  "left-top", "left-bottom", or a numeric vector of length 2 for custom
  coordinates.

- r:

  Numeric. Radius of the button. Default is 8.

- fill:

  Character. Fill color of the button background. Default is "#fff".

- stroke:

  Character. Stroke color of the button border. Default is "#CED4D9".

- lineWidth:

  Numeric. Width of the button border. Default is 1.

- iconStroke:

  Character. Stroke color of the +/- icon. Default is "#000".

- iconLineWidth:

  Numeric. Width of the +/- icon lines. Default is 1.4.

- cursor:

  Character. CSS cursor style. Default is "pointer".

- zIndex:

  Numeric. Z-index for layering. Default is 999.

- x:

  An object to check.

## Value

A list of collapse button configuration options.

Logical indicating if x is of class g6_collapse_options.

## Examples

``` r
# Default collapse button
g6_collapse_options()
#> $collapsed
#> [1] FALSE
#> 
#> $visibility
#> [1] "visible"
#> 
#> $placement
#> [1] "right-top"
#> 
#> $r
#> [1] 6
#> 
#> $fill
#> [1] "#fff"
#> 
#> $stroke
#> [1] "#9cabd4"
#> 
#> $lineWidth
#> [1] 1
#> 
#> $iconStroke
#> [1] "#9cabd4"
#> 
#> $iconLineWidth
#> [1] 1.4
#> 
#> $cursor
#> [1] "pointer"
#> 
#> $zIndex
#> [1] 999
#> 
#> attr(,"class")
#> [1] "g6_collapse_options"

# Custom styled collapse button
g6_collapse_options(
  placement = "right-top",
  fill = "#f0f0f0",
  stroke = "#333",
  r = 10
)
#> $collapsed
#> [1] FALSE
#> 
#> $visibility
#> [1] "visible"
#> 
#> $placement
#> [1] "right-top"
#> 
#> $r
#> [1] 10
#> 
#> $fill
#> [1] "#f0f0f0"
#> 
#> $stroke
#> [1] "#333"
#> 
#> $lineWidth
#> [1] 1
#> 
#> $iconStroke
#> [1] "#9cabd4"
#> 
#> $iconLineWidth
#> [1] 1.4
#> 
#> $cursor
#> [1] "pointer"
#> 
#> $zIndex
#> [1] 999
#> 
#> attr(,"class")
#> [1] "g6_collapse_options"

# Collapse button with custom coordinates
g6_collapse_options(placement = c(1, 0.2))
#> $collapsed
#> [1] FALSE
#> 
#> $visibility
#> [1] "visible"
#> 
#> $placement
#> [1] 1.0 0.2
#> 
#> $r
#> [1] 6
#> 
#> $fill
#> [1] "#fff"
#> 
#> $stroke
#> [1] "#9cabd4"
#> 
#> $lineWidth
#> [1] 1
#> 
#> $iconStroke
#> [1] "#9cabd4"
#> 
#> $iconLineWidth
#> [1] 1.4
#> 
#> $cursor
#> [1] "pointer"
#> 
#> $zIndex
#> [1] 999
#> 
#> attr(,"class")
#> [1] "g6_collapse_options"
```
