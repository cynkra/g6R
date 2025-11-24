# Changelog

## g6R 0.5.0

### Potential breaking changes

Due to the new data validation for nodes, edges and combos, some
existing code might break if the data provided to g6R functions is not
valid. See the corresponding
[documentation](https://cynkra.github.io/g6R/articles/nodes.html#data-properties)
section. If you had to pass custom data you can do it in the `data`
slot.

### New features and fixes

- Layout is not recomputed when calling data proxy functions, except if
  `options("g6R.layout_on_data_change" = TRUE)`. In the later case, the
  layout is recomputed after drawing.
- New option `g6R.preserve_elements_position`. If TRUE, and only if
  `g6_options(animation = FALSE)`, the elements (nodes and combos)
  coordinates are preserved when updating the layout to avoid elements
  from jumping to new positions. Default is FALSE. A warning is raised
  if this option is TRUE and animation is TRUE to tell the user that the
  option will be ignored.
- New
  [`g6_update_layout()`](https://cynkra.github.io/g6R/reference/g6_update_layout.md)
  proxy function to order the layout re-execution and optionally update
  its parameters.
- New `input[["<graph_ID>-mouse_position"]]`: any click/right click or
  drag release event captures the mouse position.
  `input[["<graph_ID>-mouse_position"]]` contains the x and y
  coordinates of the mouse relative to the canvas. This is useful to add
  a node where the mouse was clicked, a context menu was triggered or
  the create edge was released on the canvas without a specific target.
- Elements selected via
  [`brush_select()`](https://cynkra.github.io/g6R/reference/brush_select.md)
  have a custom input handler. This may give:

``` r
input[["<graph_ID>-selected_combo"]]
[1] "1" "2"
attr(,"eventType")
[1] "brush_select"
```

Notice the extra attribute, which allows to make a difference between
[`click_select()`](https://cynkra.github.io/g6R/reference/click_select.md)
and
[`brush_select()`](https://cynkra.github.io/g6R/reference/brush_select.md)
events.

- Get correct element type on click: it was possible that whenclicking a
  combo it appeared under `input$<graph_ID>-selected_node` instead of
  `input$<graph_ID>-selected_combo`. This is now fixed.
- [`create_edge()`](https://cynkra.github.io/g6R/reference/create_edge.md)
  behavior improved: when creating an edge and it is release on the
  canvas, the edge isn’t cancelled and data are available. We added a
  `targetType` property which allows to know where the edge was dragged.
- Added new elements API:
  [`g6_node()`](https://cynkra.github.io/g6R/reference/g6_element.md),
  [`g6_edge()`](https://cynkra.github.io/g6R/reference/g6_element.md),
  [`g6_combo()`](https://cynkra.github.io/g6R/reference/g6_element.md)
  to create nodes, edges and combos respectively. We suggest to use them
  instead of passing lists or dataframes to g6 as they provide safety
  checks. We also added
  [`g6_nodes()`](https://cynkra.github.io/g6R/reference/g6_elements.md),
  [`g6_edges()`](https://cynkra.github.io/g6R/reference/g6_elements.md)
  and
  [`g6_combos()`](https://cynkra.github.io/g6R/reference/g6_elements.md)
  which are internally used by some proxy functions like
  [`g6_add_nodes()`](https://cynkra.github.io/g6R/reference/g6-add.md)
  to provide more flexibility.
- New `options("g6R.mode)` that can be `dev` or `prod` (default). In
  `dev` mode, Shiny notifications are displayed in the UI whenever a
  JavaScript error happens (they are still available in the JS console).
- [`g6_focus_elements()`](https://cynkra.github.io/g6R/reference/g6-focus.md),
  [`g6_hide_elements()`](https://cynkra.github.io/g6R/reference/g6-element-toggle.md)
  and
  [`g6_show_elements()`](https://cynkra.github.io/g6R/reference/g6-element-toggle.md)
  gain more specific siblings:
  [`g6_focus_nodes()`](https://cynkra.github.io/g6R/reference/g6-focus.md),
  [`g6_focus_edges()`](https://cynkra.github.io/g6R/reference/g6-focus.md),
  [`g6_focus_combos()`](https://cynkra.github.io/g6R/reference/g6-focus.md),
  [`g6_hide_nodes()`](https://cynkra.github.io/g6R/reference/g6-element-toggle.md),
  [`g6_hide_edges()`](https://cynkra.github.io/g6R/reference/g6-element-toggle.md),
  [`g6_hide_combos()`](https://cynkra.github.io/g6R/reference/g6-element-toggle.md),
  [`g6_show_nodes()`](https://cynkra.github.io/g6R/reference/g6-element-toggle.md),
  [`g6_show_edges()`](https://cynkra.github.io/g6R/reference/g6-element-toggle.md),
  [`g6_show_combos()`](https://cynkra.github.io/g6R/reference/g6-element-toggle.md).
- [`brush_select()`](https://cynkra.github.io/g6R/reference/brush_select.md),
  [`lasso_select()`](https://cynkra.github.io/g6R/reference/lasso_select.md)
  and
  [`create_edge()`](https://cynkra.github.io/g6R/reference/create_edge.md)
  gain an `outputId` parameter which allows to manually pass the Shiny
  output ID of the graph instance. This is useful when the graph is
  initialised outside the shiny render function and the ID cannot be
  automatically inferred with
  [`shiny::getCurrentOutputInfo()`](https://rdrr.io/pkg/shiny/man/getCurrentOutputInfo.html).
  This allows to set input values from the callback function with the
  right namespace and graph ID. You must typically pass
  `session$ns("graphid")` to ensure this also works in modules.
- Improvements to
  [`brush_select()`](https://cynkra.github.io/g6R/reference/brush_select.md):
  now it correctly returns the list of selected nodes, edges and combos,
  available via `input$<graph_ID>-selected_node`,
  `input$<graph_ID>-selected_edge` and
  `input$<graph_ID>-selected_combo`, thanks to the internal IDs
  refactoring. After a brush select operation, you can now shift click
  (depending on the
  [`click_select()`](https://cynkra.github.io/g6R/reference/click_select.md)
  multiple selection trigger settings you set, it might be another key)
  to add/remove elements to/from the current selection.
- [`lasso_select()`](https://cynkra.github.io/g6R/reference/lasso_select.md)
  also gets the same quality of life improvements.
- Fix: when selecting (simple select not multiselect) an
  edge/node/combo, if another type of element was selected, the
  corresponding input is reset. This avoids to accidentally delete a
  previously selected element when another type of element is selected.
- Fix: state never get set on first render.
- Fix [\#23](https://github.com/cynkra/g6R/issues/23): graph has to be
  re-rendered after dynamic plugin addition so that new elements like
  `hull` are drawn.
- Fix [\#22](https://github.com/cynkra/g6R/issues/22): internal typo in
  JS function when an error was caught in the graph.
- Add `input$<graph_ID>-contextmenu` to extract the type and id of
  element which was clicked in the context menu. This can be listened to
  from the Shiny server function.
- Fix layout and behavior issues in some examples: `drag_element_force`
  only works when `animation` is TRUE. Also added `autoFit = TRUE`
  wherever required (manual layout vignette).

## g6R 0.1.0

CRAN release: 2025-07-10

- Initial CRAN submission.
