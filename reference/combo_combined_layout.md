# Create an AntV Combo Combined Layout

Creates a combo combined layout configuration for G6 graphs. The graph
is laid out one hierarchy level at a time: each combo's children are
arranged first, the combo is sized to fit them, and the resulting boxes
are then arranged among themselves. A graph with combos is therefore
packed in two dimensions instead of a single row.

## Usage

``` r
combo_combined_layout(
  center = NULL,
  comboPadding = 10,
  comboSpacing = NULL,
  layout = NULL,
  nodeSize = 10,
  nodeSpacing = NULL,
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

- comboSpacing:

  Spacing between combos. Can be a number or a JS function of the combo.
  Default is NULL (G6's own default of 0).

- layout:

  Layout applied at each level of the hierarchy. Either a single layout
  configuration (as returned by
  [`antv_dagre_layout()`](https://cynkra.github.io/g6R/reference/antv_dagre_layout.md)
  and friends), used at every level, or a
  [`JS()`](https://cynkra.github.io/g6R/reference/JS.md) callback
  `(comboId) => config` receiving the combo id, or `null` for the
  outermost level, so each level can use a different layout. `NULL`
  (default) leaves G6's own defaults: a `force` layout on the outermost
  level and `concentric` inside each combo. A single configuration is a
  plain list and stays JSON-serialisable; a
  [`JS()`](https://cynkra.github.io/g6R/reference/JS.md) callback does
  not survive serialisation.

- nodeSize:

  Node size (diameter), used for collision detection and to size the
  nodes the layout lays out. Can be a number, numeric vector, function,
  or JS function. Default is 10, which is smaller than most rendered
  nodes: set it to roughly the drawn node size, or nodes end up
  touching.

- nodeSpacing:

  Gap to leave around each node, on top of `nodeSize`. A number or a JS
  function of the node. `NULL` (default) leaves G6's own default of 0,
  which places nodes exactly edge to edge.

- ...:

  Additional parameters passed to the layout configuration. See
  <https://g6.antv.antgroup.com/en/manual/layout/combo-combined-layout>.

## Value

A layout configuration object for use with G6 graphs.

## Details

Edges are lifted to the level being laid out: an edge between two combo
members is resolved to the nearest enclosing element on that level and
dropped when both ends resolve to the same one. The outermost pass
therefore sees the combo-to-combo graph, so a layered `layout` keeps the
flow between combos readable.

A graph without combos is not a special case: every node is a child of
the (implicit) root, so only the outermost level runs and the result is
whatever `layout` describes, applied to the whole graph.

## See also

[`antv_dagre_layout`](https://cynkra.github.io/g6R/reference/antv_dagre_layout.md)
for dagre layout configuration

## Examples

``` r
# Basic combo combined layout
layout <- combo_combined_layout()

# Custom configuration. `nodeSize` should be about the drawn node size and
# `nodeSpacing` is the gap left around each one.
layout <- combo_combined_layout(
  comboPadding = 20,
  comboSpacing = 8,
  nodeSize = 32,
  nodeSpacing = 20
)

# Layered layout at every level: combo members and the combos themselves are
# both arranged top-to-bottom. Serialisable, unlike a JS() callback.
layout <- combo_combined_layout(
  layout = antv_dagre_layout(rankdir = "TB", nodesep = 20)
)

# Per-level layouts: dagre between combos, concentric inside each of them.
layout <- combo_combined_layout(
  layout = JS(
    "(comboId) => comboId ?
       { type: 'concentric' } :
       { type: 'antv-dagre', rankdir: 'TB' }"
  )
)
```
