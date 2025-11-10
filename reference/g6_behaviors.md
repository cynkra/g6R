# Create G6 Graph Behaviors Configuration

Configures interaction behaviors for a G6 graph visualization. This
function collects and combines multiple behavior configurations into a
list that can be passed to graph initialization functions.

## Usage

``` r
g6_behaviors(graph, ...)
```

## Arguments

- graph:

  A g6 graph instance.

- ...:

  Behavior configuration objects created by behavior-specific functions.
  These can include any of the following behaviors:

  **Navigation behaviors:**

  - [`drag_canvas()`](https://cynkra.github.io/g6R/reference/drag_canvas.md) -
    Drag the entire canvas view

  - [`zoom_canvas()`](https://cynkra.github.io/g6R/reference/zoom_canvas.md) -
    Zoom the canvas view

  - [`scroll_canvas()`](https://cynkra.github.io/g6R/reference/scroll_canvas.md) -
    Scroll the canvas using the wheel

  - [`optimize_viewport_transform()`](https://cynkra.github.io/g6R/reference/optimize_viewport_transform.md) -
    Optimize view transform performance

  **Selection behaviors:**

  - [`click_select()`](https://cynkra.github.io/g6R/reference/click_select.md) -
    Click to select graph elements

  - [`brush_select()`](https://cynkra.github.io/g6R/reference/brush_select.md) -
    Select elements by dragging a rectangular area

  - [`lasso_select()`](https://cynkra.github.io/g6R/reference/lasso_select.md) -
    Freely draw an area to select elements

  **Editing behaviors:**

  - [`create_edge()`](https://cynkra.github.io/g6R/reference/create_edge.md) -
    Interactively create new edges

  - [`drag_element()`](https://cynkra.github.io/g6R/reference/drag_element.md) -
    Drag nodes or combos

  - [`drag_element_force()`](https://cynkra.github.io/g6R/reference/drag_element_force.md) -
    Drag nodes in force-directed layout

  **Data Exploration behaviors:**

  - [`collapse_expand()`](https://cynkra.github.io/g6R/reference/collapse_expand.md) -
    Expand or collapse subtree nodes

  - [`focus_element()`](https://cynkra.github.io/g6R/reference/focus_element.md) -
    Focus on specific elements and automatically adjust the view

  - [`hover_activate()`](https://cynkra.github.io/g6R/reference/hover_activate.md) -
    Highlight elements when hovering

  **Visual Optimization behaviors:**

  - [`fix_element_size()`](https://cynkra.github.io/g6R/reference/fix_element_size.md) -
    Fix the element size to a specified value

  - [`auto_adapt_label()`](https://cynkra.github.io/g6R/reference/auto_adapt_label.md) -
    Automatically adjust label position

## Value

A list of behavior configuration objects that can be passed to G6 graph
initialization

## Note

You can create custom behaviors from JavaScript and use them on the R
side. See more at
<https://g6.antv.antgroup.com/en/manual/behavior/custom-behavior>.

## Examples

``` r
# Create a basic set of behaviors
behaviors <- g6_behaviors(
  g6(),
  drag_canvas(),
  zoom_canvas(),
  click_select()
)

# Create a more customized set of behaviors
behaviors <- g6_behaviors(
  g6(),
  drag_canvas(),
  zoom_canvas(sensitivity = 1.5),
  hover_activate(state = "highlight"),
  fix_element_size(
    node = list(
      list(shape = "circle", fields = c("r", "lineWidth"))
    )
  )
)
```
