# Generate G6 AntV Compact Box layout configuration

This function creates a configuration list for G6 AntV Compact Box
layout with all available options as parameters. The Compact Box layout
is designed for efficiently laying out trees and hierarchical
structures.

## Usage

``` r
compact_box_layout(
  direction = c("LR", "RL", "TB", "BT", "H", "V"),
  getSide = NULL,
  getId = NULL,
  getWidth = NULL,
  getHeight = NULL,
  getHGap = NULL,
  getVGap = NULL,
  radial = FALSE,
  ...
)
```

## Arguments

- direction:

  Layout direction: "LR" (left to right), "RL" (right to left), "TB"
  (top to bottom), "BT" (bottom to top), "H" (horizontal), or "V"
  (vertical)

- getSide:

  Function to set the nodes to be arranged on the left/right side of the
  root node. If not set, the algorithm automatically assigns the nodes
  to the left/right side. Note: This parameter is only effective when
  the layout direction is "H". Function format:
  `function(node) { return "left" or "right" }`

- getId:

  Callback function for generating node IDs. Function format:
  `function(node) { return string }`

- getWidth:

  Function to calculate the width of each node. Function format:
  `function(node) { return number }`

- getHeight:

  Function to calculate the height of each node. Function format:
  `function(node) { return number }`

- getHGap:

  Function to calculate the horizontal gap for each node. Function
  format: `function(node) { return number }`

- getVGap:

  Function to calculate the vertical gap for each node. Function format:
  `function(node) { return number }`

- radial:

  Whether to enable radial layout

- ...:

  Additional parameters to pass to the layout. See
  <https://g6.antv.antgroup.com/en/manual/layout/compact-box-layout>.

## Value

A list containing the configuration for G6 AntV Compact Box layout.

## Examples

``` r
# Basic compact box layout
box_config <- compact_box_layout()

# Vertical compact box layout
box_config <- compact_box_layout(
  direction = "TB"
)

# Radial layout
box_config <- compact_box_layout(
  radial = TRUE
)
```
