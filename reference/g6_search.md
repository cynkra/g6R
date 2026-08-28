# Search box to navigate a large graph

Renders a search box over the canvas: type to match nodes and combos by
label or id, pick one, and the viewport moves to it. G6 ships no search
UI, so `g6_search()` adds one on top of
[`g6_focus_nodes()`](https://cynkra.github.io/g6R/reference/g6-focus.md)'s
underlying `focusElement()`.

## Usage

``` r
g6_search(
  key = "search",
  placeholder = "Search",
  limit = 8,
  elements = c("node", "combo"),
  expandAncestors = TRUE,
  select = TRUE,
  position = c("top-left", "top-right", "bottom-left", "bottom-right"),
  labels = c(node = "node", combo = "combo", edge = "edge"),
  width = 220,
  animation = NULL,
  outputId = NULL,
  onSelect = NULL,
  ...
)
```

## Arguments

- key:

  Unique identifier for the plugin (string).

- placeholder:

  Placeholder shown in the empty box.

- limit:

  Maximum number of matches listed.

- elements:

  Element types to search, any of `"node"`, `"combo"` and `"edge"`.
  Edges are rarely worth searching, so they are off by default.

- expandAncestors:

  Expand collapsed combos on the way to a match. A node inside a
  collapsed combo has nowhere on screen to focus, so leaving this on is
  what makes search useful on a board whose groups are collapsed.

- select:

  Also select the picked element, so anything driven by selection (a
  sidebar, a details panel) follows the search.

- position:

  Corner to render in: `"top-left"` (default), `"top-right"`,
  `"bottom-left"` or `"bottom-right"`.

- labels:

  How to name each element type in the results, as a named character
  vector over `"node"`, `"combo"` and `"edge"`. `"combo"` is g6 jargon,
  so an app that calls them something else ("stack", "stage", "group")
  should say so here. Only used where a match has no group to show
  instead.

- width:

  Width of the box, in px.

- animation:

  Viewport animation passed to `focusElement()`, e.g.
  `list(duration = 500, easing = "ease-in")`. `NULL` uses G6's default.

- outputId:

  Graph output id. When set (and running under Shiny), picking a match
  sets `input$<outputId>-searched_element` to a list with `id`, `type`
  and `label`.

- onSelect:

  Optional [`JS()`](https://cynkra.github.io/g6R/reference/JS.md)
  callback `(hit, graph) => {}` run after the viewport has moved, for
  anything beyond focus and select.

- ...:

  Additional parameters passed to the plugin configuration.

## Value

A list with the configuration for the search plugin.

## Details

Matching runs in the browser, so the box works in a plain widget (a
Quarto document, a pkgdown page, a vignette) and not only in a Shiny
app, and it does not wait on the server between keystrokes. Under Shiny
the pick is also reported as an input when `outputId` is given.

## Examples

``` r
# Nodes and combos, focusing the pick
config <- g6_search()

# Report the pick to Shiny, and keep collapsed groups closed
config <- g6_search(
  outputId = "graph",
  expandAncestors = FALSE,
  position = "top-right"
)

# Name the element types the way the app does
config <- g6_search(labels = c(node = "block", combo = "stack"))
```
