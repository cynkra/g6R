# Create an AntV Combo Combined Layout

Creates a combo combined layout configuration for G6 graphs. This layout
algorithm combines different layout strategies for elements inside
combos and the outermost layer, providing hierarchical organization of
graph elements.

## Usage

``` r
combo_combined_layout(
  center = NULL,
  comboPadding = 10,
  innerLayout = NULL,
  nodeSize = 10,
  outerLayout = NULL,
  spacing = NULL,
  treeKey = NULL,
  ...
)
```

## Arguments

- center:

  Layout center coordinates. A numeric vector of length 2 `[x, y]`. If
  NULL, uses the graph center. Default is NULL.

- comboPadding:

  Padding value inside the combo, used only for force calculation, not
  for rendering. It is recommended to set the same value as the visual
  padding. Can be a number, numeric vector, function, or JS function.
  Default is 10.

- innerLayout:

  Layout algorithm for elements inside the combo. Should be a Layout
  object or function. If NULL, uses ConcentricLayout as default.

- nodeSize:

  Node size (diameter), used for collision detection. If not specified,
  it is calculated from the node's size property. Can be a number,
  numeric vector, function, or JS function. Default is 10.

- outerLayout:

  Layout algorithm for the outermost layer. Should be a Layout object or
  function. If NULL, uses ForceLayout as default.

- spacing:

  Minimum spacing between node/combo edges when preventNodeOverlap or
  preventOverlap is true. Can be a number, function, or JS function for
  different nodes. Default is NULL.

- treeKey:

  Tree key identifier as a character string. Default is NULL.

- ...:

  Additional parameters passed to the layout configuration. See
  <https://g6.antv.antgroup.com/en/manual/layout/combo-combined-layout>.

## Value

A layout configuration object for use with G6 graphs.

## Details

The combo combined layout is particularly useful for graphs with
hierarchical structures where you want different layout algorithms for
different levels of the hierarchy. The inner layout handles elements
within combos, while the outer layout manages the overall arrangement.

## See also

[`antv_dagre_layout`](https://cynkra.github.io/g6R/reference/antv_dagre_layout.md)
for dagre layout configuration

## Examples

``` r
# Basic combo combined layout
layout <- combo_combined_layout()

# Custom configuration with specific center and padding
layout <- combo_combined_layout(
  comboPadding = 20,
  nodeSize = 15,
  spacing = 10
)
```
