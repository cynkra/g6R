# g6R 0.6.0.9000

## Breaking changes

- Not a g6R change but `{bslib}` recently introduced the `toolbar()` function which unfortunately overlaps with the `{g6R}` one. From now, you'll have to use `g6R::toolbar()` to avoid conflicts. In later releases, we'll provide more prefixed functions like `g6_toolbar`.

## New feature

- Improvements to how `drag_element()` and `drag_element_force()` work with `create_edge()`. Now, the `create_edge()` can be `drag` and work with `drag_element()` as we handle the behavior conflicts/priorities JS side.

- `input[["<graph_ID>-state"]]` now does not return unnamed lists for nodes, edges and combos. Instead, each sublist is named with the corresponding element IDs. This makes it easier to retrieve the state of a specific element when we know the ID.

- Added better port support for nodes __ports__:
  - To enable it, you must pass a custom type to `g6_node()` such as `custom-circle-node`, `custom-rect-node` (We support 9 [shapes](https://g6.antv.antgroup.com/en/manual/element/node/overview#built-in-nodes), except HTML which does not handle port in the g6 library)
  - `g6_node()` get a new `ports` argument to define ports for each node. In the g6 JS library, ports are normally defined inside `style` but we consider they are too important to be hidden there. Now you can define ports directly in the node data, g6R automatically moves them to `style.ports` when rendering the graph.
  - New `g6_port()` function to create ports easily and wrap them inside `g6_ports()`. A port has a unique __key__, an __arity__ that is the number of connections it can make or take and other style parameters inherited from [g6](https://g6.antv.antgroup.com/en/manual/element/node/base-node#portstyleprops). When giving a key to a port, don't worry if key names collide between nodes, g6R automatically makes them unique by prefixing them with the node ID on the JS side.
  - 2 kind of ports have been designed:
    - __input__ ports (`g6_input_port()`): they can only be the target of an edge.
    - __output__ ports (`g6_output_port()`): they can only be the source of an edge.
  - When creating edges, if you provide `sourcePort` and/or `targetPort` within the `style` list, the edge will be connected to the corresponding ports. Validation is made so we don't connect incompatible ports (e.g. connecting an output port to another output port) or connecting a port to itself.
  - `create_edge()` behavior was improved to work better with ports. For instance, you can't drag from a port that is already at its arity limit.
  You can't drag from a node if it has ports (drag from the ports instead).
  - Ports gain a `label` parameter to display text on the port.
  - In a Shiny context, `showGuides` allows to display connection __guides__ when hovering over a port. Combined with `input[["<GRAPH_ID>-selected_port"]]` and `input[["<graph_ID>-mouse_position"]]`, this allows to add and connect nodes on the fly at the guide location.
  - Use `g6_update_ports()` to update port (3 possible actions: remove/add/update) ports of existing nodes.
  - Use `g6_get_ports()` to get the ports of existing nodes. Specifically, you can call `g6_get_input_ports()` and `g6_get_output_ports()` to get only input or output ports respectively. This are only convenience functions.

# g6R 0.5.0

## Potential breaking changes

Due to the new data validation for nodes, edges and combos, some existing code might break if the data provided to g6R functions is not valid. See the corresponding [documentation](https://cynkra.github.io/g6R/articles/nodes.html#data-properties) section. If you had to pass custom data you can do it in the `data` slot.

## New features and fixes

- Support for svg rendering:

```r
g6_options(renderer = JS("() => new SVGRenderer()"))
```

- Fix issue which was preventing from removing a node from a combo.
- Layout is not recomputed when calling data proxy functions, except if `options("g6R.layout_on_data_change" = TRUE)`. In the later case, the layout is recomputed after drawing.
- New option `g6R.preserve_elements_position`. If TRUE, and only if `g6_options(animation = FALSE)`, the elements (nodes and combos) coordinates are preserved when updating the layout to avoid elements from jumping to new positions. Default is FALSE. A warning is raised if this option is TRUE and animation is TRUE to tell the user that the option will be ignored.
- New `g6_update_layout()` proxy function to order the layout re-execution and optionally update its parameters.
- New `input[["<graph_ID>-mouse_position"]]`: any click/right click or drag release event captures the mouse position. `input[["<graph_ID>-mouse_position"]]` contains the x and y coordinates of the mouse relative to the canvas. This is useful to add a node where the mouse was clicked, a context menu was triggered or the create edge was released on the canvas without a specific target.
- Elements selected via `brush_select()` or `lasso_select()` have a custom input handler. This may give:

```r
input[["<graph_ID>-selected_combo"]]
[1] "1" "2"
attr(,"eventType")
[1] "brush_select"
```

Notice the extra attribute, which allows to make a difference between `click_select()` and `brush_select()` events.

- Get correct element type on click: it was possible that when clicking a combo, it appeared under `input$<graph_ID>-selected_node` instead of `input$<graph_ID>-selected_combo`.
- `create_edge()` behavior improved: when creating an edge and it is release on the canvas, the edge isn't cancelled and data are available. We added a `targetType` property which allows to know where the edge was dropped.
- Added new elements API: `g6_node()`, `g6_edge()`, `g6_combo()` to create nodes, edges and combos respectively. We suggest to use them instead of passing lists or dataframes to g6 as they provide
safety checks. We also added `g6_nodes()`, `g6_edges()` and `g6_combos()` which are internally used by some proxy functions like `g6_add_nodes()` to provide more flexibility.
- New `options("g6R.mode)` that can be `dev` or `prod` (default). In `dev` mode, Shiny notifications are
displayed in the UI whenever a JavaScript error happens (they are still available in the JS console).
- `g6_focus_elements()`, `g6_hide_elements()` and `g6_show_elements()` gain more specific siblings: `g6_focus_nodes()`, `g6_focus_edges()`, `g6_focus_combos()`, `g6_hide_nodes()`, `g6_hide_edges()`, `g6_hide_combos()`, `g6_show_nodes()`, `g6_show_edges()`, `g6_show_combos()`.
- `brush_select()`, `lasso_select()` and `create_edge()` gain an `outputId` parameter which allows to manually pass the Shiny output ID of the graph instance. This is useful when the graph is initialised outside the shiny render function and the ID cannot be automatically inferred with `shiny::getCurrentOutputInfo()`. This allows to set input values from the callback function with the right namespace and graph ID. You must typically pass `session$ns("graphid")` to ensure this also works in modules.
- Improvements to `brush_select()`: now it correctly returns the list of selected nodes, edges and combos, available via `input$<graph_ID>-selected_node`, `input$<graph_ID>-selected_edge` and `input$<graph_ID>-selected_combo`, thanks to the internal IDs refactoring. After a brush select operation, you can now shift click (depending on the `click_select()` multiple selection trigger settings you set, it might be another key) to add/remove elements to/from the current selection.
- `lasso_select()` also gets the same quality of life improvements.
- Fix: when selecting (simple select not multiselect) an edge/node/combo, if another type of element was selected, the corresponding input is reset. This avoids to accidentally delete a previously selected element when another type of element is selected.
- Fix: state never get set on first render.
- Fix [#23](<https://github.com/cynkra/g6R/issues/23>): graph has to be re-rendered after dynamic plugin addition so that new elements like `hull` are drawn.
- Fix [#22](<https://github.com/cynkra/g6R/issues/22>): internal typo in JS function when an error was caught in the graph.
- Add `input$<graph_ID>-contextmenu` to extract the type and id of element which was clicked in the context menu.
This can be listened to from the Shiny server function.
- Fix layout and behavior issues in some examples: `drag_element_force` only works when `animation` is TRUE. Also added `autoFit = TRUE` wherever required (manual layout vignette).

# g6R 0.1.0

- Initial CRAN submission.
