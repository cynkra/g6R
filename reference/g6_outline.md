# Outline panel listing the graph

Renders a panel over the canvas listing the graph as a tree: each combo
is an accordion holding its members, and clicking a row moves the
viewport to that element. Where
[`g6_search()`](https://cynkra.github.io/g6R/reference/g6_search.md)
answers "take me to the thing I am looking for", an outline answers
"show me what is in here", which is the question a large graph usually
raises.

## Usage

``` r
g6_outline(
  key = "outline",
  title = "Outline",
  position = c("top-right", "top-left", "bottom-left", "bottom-right"),
  width = 240,
  anchor = c("canvas", "search"),
  open = TRUE,
  groupsOpen = TRUE,
  followCollapse = TRUE,
  expandAncestors = TRUE,
  select = TRUE,
  labels = c(node = "node", combo = "combo", edge = "edge"),
  animation = NULL,
  outputId = NULL,
  ...
)
```

## Arguments

- key:

  Unique identifier for the plugin (string).

- title:

  Text on the panel's toggle button.

- position:

  Corner to render in: `"top-right"` (default), `"top-left"`,
  `"bottom-left"` or `"bottom-right"`.

- width:

  Width of the panel, in px. Ignored when anchored to the search box,
  where the width comes from that box.

- anchor:

  Where the panel lives: `"canvas"` (default) puts it in the corner
  named by `position`; `"search"` hangs it under
  [`g6_search()`](https://cynkra.github.io/g6R/reference/g6_search.md)'s
  box as a dropdown, so the two read as one control. Anchoring needs a
  [`g6_search()`](https://cynkra.github.io/g6R/reference/g6_search.md)
  listed *before* this plugin, since they are built in order; without
  one the panel falls back to its own corner.

- open:

  Start with the panel open.

- groupsOpen:

  Start with the groups unfolded. A group already collapsed on the
  canvas starts folded regardless, when `followCollapse` is on.

- followCollapse:

  Follow the canvas: collapsing or expanding a group there folds or
  unfolds its rows here. One-way, so folding a group in the panel leaves
  the canvas alone and a group can be skimmed without redrawing the
  graph; the next collapse or expand on the canvas takes that fold back
  over.

- expandAncestors:

  Expand collapsed combos on the way to a clicked element, as
  [`g6_search()`](https://cynkra.github.io/g6R/reference/g6_search.md)
  does.

- select:

  Also select the clicked element, so anything driven by selection
  follows the panel.

- labels:

  How to name each element type, as a named character vector over
  `"node"`, `"combo"` and `"edge"`. Names the unit in a group's count
  and in the accessible name of every row.

- animation:

  Viewport animation passed to `focusElement()`.

- outputId:

  Graph output id. When set (and running under Shiny), clicking a row
  sets `input$<outputId>-outlined_element` to a list with `id`, `type`
  and `label`.

- ...:

  Additional parameters passed to the plugin configuration.

## Value

A list with the configuration for the outline plugin.

## Details

It also makes collapsing the canvas safe: with everything listed, the
drawing no longer has to be legible at fit-to-view, so groups can stay
collapsed and any element is still two clicks away.

Folding a group in the panel is independent of collapsing it on the
canvas, so the list can be explored without redrawing the graph.
Selecting an element on the canvas marks and scrolls to its row, so the
panel follows where you are.

Each group row also reports how many elements it holds, counted through
nested groups so the number means the same thing at every level, and
reported for a folded group too: the count describes the graph, not the
panel. The toggle carries the same figure for the graph as a whole, so
the size of it is legible while the panel is shut. `labels` names both
in the accessible text.

## See also

[`g6_search()`](https://cynkra.github.io/g6R/reference/g6_search.md) to
jump straight to a named element.

## Examples

``` r
config <- g6_outline()

# As a dropdown under the search box, closed until asked for
config <- g6_outline(anchor = "search", open = FALSE, title = "Contents")

# Start folded, and name the types the way the app does
config <- g6_outline(
  groupsOpen = FALSE,
  labels = c(node = "block", combo = "stack"),
  outputId = "graph"
)
```
