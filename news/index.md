# Changelog

## g6R 0.6.5

### New features

- Bumped the bundled AntV G6 engine from 5.0.49 to 5.1.1 (with `@antv/g`
  6.x and `@antv/g-svg` 2.1.1, deduplicating `g-lite` so the SVG
  renderer works again instead of throwing
  `Cannot read properties of undefined (reading 'fill')` on a blank
  canvas). The bump improves create-edge assist-line tracking under
  zoom/pan (G6 now derives the cursor position via
  `getCanvasByClient()`), fixes a combo/layout element-type confusion
  that crashed the canvas renderer when a combo was added at runtime
  under `g6R.layout_on_data_change`
  (`Cannot read properties of undefined (reading 'src')`), and pulls in
  upstream APIs (`hasNode()`/`hasEdge()`/`hasCombo()`, nested self-loop
  edges, `drag-element` trigger config). The widget bundle is now a
  single self-contained `g6.js` (the split `185.js` chunk was removed).

- New `placement = "label-bottom"` for ports. When a node has a bottom
  label (e.g. `labelPlacement = "bottom"`), an output port with this
  placement snaps to the bottom-centre of the label background instead
  of the node body; it falls back to a normal bottom-of-node port when
  there is no label.

- Default port radius increased from 4 to 6 so ports are easier to see
  and target.

- Calmer port hover. Hovering a port no longer grows it ~2.5x into a
  rotating dashed `+` glyph (which read as flickering noise). Ports now
  keep their size and show a soft expanding ripple ring (in the port
  colour) only while the cursor is over them; the ripple stops when the
  cursor leaves. Disable it per port with `ripple = FALSE`. Ports also
  gain a background-coloured ring so they read as set into a small hole
  punched through the node / label surface (override with the `haloFill`
  port style), and the default fill adapts to the graph theme. The large
  invisible hit-area is kept, so ports remain easy to grab.

- Port hover cursor is now a crosshair instead of a pointer, matching
  G6’s native create-edge affordance (“draw an edge from here”). The
  crosshair and the hover ripple only appear when the graph actually has
  the
  [`create_edge()`](https://cynkra.github.io/g6R/reference/create_edge.md)
  behavior, so ports don’t advertise an interaction that isn’t wired up.

- [`create_edge()`](https://cynkra.github.io/g6R/reference/create_edge.md)
  now tolerates a small miss when grabbing a port. Previously an edge
  only started when pointer-down landed exactly on the (small) port
  glyph; a near-miss on the node body fell through to
  [`drag_element()`](https://cynkra.github.io/g6R/reference/drag_element.md)
  and moved the node instead. Pointer-down now snaps to the nearest
  grabbable port within a tolerance proportional to the port radius, so
  a slight miss still starts an edge
  ([\#50](https://github.com/cynkra/g6R/issues/50)).

### Bug fixes

- [`create_edge()`](https://cynkra.github.io/g6R/reference/create_edge.md):
  the hidden rubber-band assist node now carries a transparent `src`, so
  it no longer crashes the canvas renderer with
  `Cannot read properties of undefined (reading 'src')` when the
  consumer maps every node to an image node via a fixed `node` type. The
  node stays hidden, so the pixel is never shown. The SVG renderer is
  unaffected.

- Fixed
  [`create_edge()`](https://cynkra.github.io/g6R/reference/create_edge.md)
  overwriting a consumer-supplied
  [`drag_element()`](https://cynkra.github.io/g6R/reference/drag_element.md)
  /
  [`drag_element_force()`](https://cynkra.github.io/g6R/reference/drag_element_force.md)
  `enable` predicate. While drawing an edge from a port,
  [`create_edge()`](https://cynkra.github.io/g6R/reference/create_edge.md)
  pauses node dragging and resumes it on drop. It previously resumed by
  hardcoding `enable: true`, which destroyed any custom `enable`
  function after the first edge creation (and toggled behaviors via an
  array, a no-op in current G6 where `updateBehavior()` matches a single
  `key`). The live `enable` of each drag behavior is now snapshotted
  (looked up by type, so a custom `key` still works) and restored
  verbatim on drop ([\#48](https://github.com/cynkra/g6R/issues/48)).

- Fixed the
  [`create_edge()`](https://cynkra.github.io/g6R/reference/create_edge.md)
  rubber-band (assist) edge not appearing while dragging when the graph
  had no `edge` options configured. The assist edge style read
  `graph.options.edge.style.zIndex`, which threw and aborted assist-edge
  creation; it is now read defensively and falls back to G6’s default.

- Fixed
  [`create_edge()`](https://cynkra.github.io/g6R/reference/create_edge.md)
  drops being silently canceled below 100% browser zoom. The minimum
  drag-distance threshold was measured in canvas units, which scale with
  browser/graph zoom; below 100% a real drag shrank under the threshold
  and the drop was treated as a click. Drag intent is now measured in
  client (screen) pixels, which are zoom-stable
  ([\#52](https://github.com/cynkra/g6R/issues/52)).

- Fixed the old `+` port indicator reappearing on node selection. The
  legacy indicator was replaced by the hover ripple, but its shapes were
  still created and G6’s `setVisibility()` cascade (fired on
  selection/update) flipped them back to visible. The dead indicator
  shapes (`add-inner`, `add-plus`) and their animation helpers are now
  removed entirely, leaving only the ripple ring.

## g6R 0.6.0

CRAN release: 2026-04-27

### Breaking changes

- Not a g6R change but [bslib](https://rstudio.github.io/bslib/)
  recently introduced the
  [`toolbar()`](https://cynkra.github.io/g6R/reference/toolbar.md)
  function which unfortunately overlaps with the
  [g6R](https://github.com/cynkra/g6R) one. From now, you’ll have to use
  [`g6R::toolbar()`](https://cynkra.github.io/g6R/reference/toolbar.md)
  to avoid conflicts. In later releases, we’ll provide more prefixed
  functions like `g6_toolbar`.

### New feature

- Added better port support for nodes **ports**:
  - To enable it, you must pass a custom type to
    [`g6_node()`](https://cynkra.github.io/g6R/reference/g6_element.md)
    such as `custom-circle-node`, `custom-rect-node` (We support 9
    [shapes](https://g6.antv.antgroup.com/en/manual/element/node/overview#built-in-nodes),
    except HTML which does not handle port in the g6 library)
  - [`g6_node()`](https://cynkra.github.io/g6R/reference/g6_element.md)
    get a new `ports` argument to define ports for each node. In the g6
    JS library, ports are normally defined inside `style` but we
    consider they are too important to be hidden there. Now you can
    define ports directly in the node data, g6R automatically moves them
    to `style.ports` when rendering the graph.
  - New [`g6_port()`](https://cynkra.github.io/g6R/reference/g6_port.md)
    function to create ports easily and wrap them inside
    [`g6_ports()`](https://cynkra.github.io/g6R/reference/g6_ports.md).
    A port has a unique **key**, an **arity** that is the number of
    connections it can make or take and other style parameters inherited
    from
    [g6](https://g6.antv.antgroup.com/en/manual/element/node/base-node#portstyleprops).
    When giving a key to a port, don’t worry if key names collide
    between nodes, g6R automatically makes them unique by prefixing them
    with the node ID on the JS side.
  - 2 kind of ports have been designed:
    - **input** ports
      ([`g6_input_port()`](https://cynkra.github.io/g6R/reference/g6_port.md)):
      they can only be the target of an edge.
    - **output** ports
      ([`g6_output_port()`](https://cynkra.github.io/g6R/reference/g6_port.md)):
      they can only be the source of an edge.
  - When creating edges, if you provide `sourcePort` and/or `targetPort`
    within the `style` list, the edge will be connected to the
    corresponding ports. Validation is made so we don’t connect
    incompatible ports (e.g. connecting an output port to another output
    port) or connecting a port to itself.
  - [`create_edge()`](https://cynkra.github.io/g6R/reference/create_edge.md)
    behavior was improved to work better with ports. For instance, you
    can’t drag from a port that is already at its arity limit. You can’t
    drag from a node if it has ports (drag from the ports instead).
  - Ports gain a `label` parameter to display text on the port.
  - In a Shiny context, `showGuides` allows to display connection
    **guides** when hovering over a port. Combined with
    `input[["<GRAPH_ID>-selected_port"]]` and
    `input[["<graph_ID>-mouse_position"]]`, this allows to add and
    connect nodes on the fly at the guide location.
  - Use
    [`g6_update_ports()`](https://cynkra.github.io/g6R/reference/g6_update_ports.md)
    to update port (3 possible actions: remove/add/update) ports of
    existing nodes.
  - Use
    [`g6_get_ports()`](https://cynkra.github.io/g6R/reference/get-ports.md)
    to get the ports of existing nodes. Specifically, you can call
    [`g6_get_input_ports()`](https://cynkra.github.io/g6R/reference/get-ports.md)
    and
    [`g6_get_output_ports()`](https://cynkra.github.io/g6R/reference/get-ports.md)
    to get only input or output ports respectively. This are only
    convenience functions.
- Added new `collapse` parameter to nodes. This will only work if you
  use any of the `custom-*-node` node types (see below). Now if a node
  has `children` (vector of character node IDs), it can be collapsed or
  uncollapsed. `collapse` accepts a list of options via
  [`g6_collapse_options()`](https://cynkra.github.io/g6R/reference/g6_collapse_options.md).
  When a node has `children` set (character vector/list of node IDs
  expected), an option `g6R.directed_graph` is set to TRUE so that, when
  a connection is created between 2 nodes, we automatically establish
  parent/child relation and inversely when an edge or node is removed.
  You can also manually opt-in for this setup by setting
  `options(g6R.directed_graph = TRUE)`. Importantly, the parent/child
  relations are only maintained if you use the g6R proxy functions.
  Using the direct JS G6 API yourself (like with
  `graph.removeEdgeData(...)` won’t do anything to keep the tree state
  in sync! The
  [`set_g6_max_collapse_depth()`](https://cynkra.github.io/g6R/reference/set_g6_max_collapse_depth.md)
  option controls which nodes display a collapse button based on their
  depth in the graph. Only nodes at depth `<= maxCollapseDepth` show
  collapse buttons. Defaults to `Inf` (all nodes with children are
  collapsible). Set to `0` to restrict collapsing to root nodes only.
  Set to `-1` to disable collapsing entirely (collapse buttons are
  removed even when
  [`g6_collapse_options()`](https://cynkra.github.io/g6R/reference/g6_collapse_options.md)
  is provided and nodes have children).

``` r

g6_node(
  id = 1,
  type = "custom-rect-node", # to enable use custom class
  children = c(2, 3),
  collapse = g6_collapse_options(collapsed = TRUE)
)
```

- Added new `collapse` parameter to
  [`g6_combo()`](https://cynkra.github.io/g6R/reference/g6_element.md).
  Accepts
  [`g6_collapse_options()`](https://cynkra.github.io/g6R/reference/g6_collapse_options.md)
  just like nodes. When `collapse` is provided and `type` is NULL, the
  combo type is automatically set to `"rect-combo-with-extra-button"`.
  The combo collapse button now supports all the same configuration as
  nodes: configurable `placement`, `r`, `fill`, `stroke`, `iconStroke`,
  `visibility` (including `"hover"` mode), etc.

``` r

g6_combo(
  "combo1",
  collapse = g6_collapse_options(
    placement = "bottom",
    fill = "#f0f0f0",
    visibility = "hover"
  )
)
```

- [`bubble_sets()`](https://cynkra.github.io/g6R/reference/bubble_sets.md)
  and [`hull()`](https://cynkra.github.io/g6R/reference/hull.md) now
  automatically set `pointerEvents = "none"` and `zIndex = -1` by
  default. This fixes two issues when using the SVG renderer: overlay
  shapes no longer block pointer events (drag, click) on nodes, and they
  render behind nodes so they don’t visually cover collapse buttons or
  other node UI. These defaults can be overridden by passing explicit
  values.

- Overlay plugins
  ([`bubble_sets()`](https://cynkra.github.io/g6R/reference/bubble_sets.md),
  [`hull()`](https://cynkra.github.io/g6R/reference/hull.md)) now resize
  dynamically when nodes are collapsed or uncollapsed. Hidden members
  are temporarily removed from the overlay shape and restored when
  expanded again.

- New `rect-combo-with-extra-button` combo type, the rectangular
  counterpart of `circle-combo-with-extra-button`.

- Graph now uses `ResizeObserver` to detect container size changes
  (e.g. from DOM reparenting, panel resize, CSS visibility toggles)
  instead of relying solely on `window` resize events. The `window`
  resize listener is kept as a fallback.

### Bug fixes

- Fixed [`hull()`](https://cynkra.github.io/g6R/reference/hull.md) label
  not displaying: the default `labelMaxWidth` was `0`, which caused G6
  to ellipsize the label to zero width. Changed default to `NULL`
  (consistent with
  [`bubble_sets()`](https://cynkra.github.io/g6R/reference/bubble_sets.md)).

- Fixed port `+` indicators incorrectly showing on at-capacity ports
  during node selection or drag. G6’s internal `setVisibility()` call
  during update was making all child shapes visible, and the cleanup was
  skipped when the cursor was hovering the node. Now the capacity-aware
  port logic is re-applied during updates while hovering.

- Fixed ports with `visibility = "hover"` or `"hidden"` leaking as
  visible on the initial render. G6’s `BaseShape` constructor calls
  `setVisibility()` after `render()`, which recursively cascades the
  node’s visibility to every child shape (including port circles and
  indicators), overriding the per-port visibility mode. The correction
  now also runs on initial creation via a `setVisibility()` override,
  not just on subsequent updates. Additionally, the edge-created
  listener no longer force-calls `showPorts` on non-hovered nodes, so
  the `+` indicator no longer leaks onto nodes the user isn’t actually
  hovering after initial edges load (cynkra/blockr.dag#107).

- Improvements to how
  [`drag_element()`](https://cynkra.github.io/g6R/reference/drag_element.md)
  and
  [`drag_element_force()`](https://cynkra.github.io/g6R/reference/drag_element_force.md)
  work with
  [`create_edge()`](https://cynkra.github.io/g6R/reference/create_edge.md).
  Now, the
  [`create_edge()`](https://cynkra.github.io/g6R/reference/create_edge.md)
  can be `drag` and work with
  [`drag_element()`](https://cynkra.github.io/g6R/reference/drag_element.md)
  as we handle the behavior conflicts/priorities JS side.

- `input[["<graph_ID>-state"]]` now does not return unnamed lists for
  nodes, edges and combos. Instead, each sublist is named with the
  corresponding element IDs. This makes it easier to retrieve the state
  of a specific element when we know the ID.

- Fixed
  [`tooltips()`](https://cynkra.github.io/g6R/reference/tooltips.md)
  plugin being invisible inside a
  [bslib](https://rstudio.github.io/bslib/) / Bootstrap page. G6’s
  tooltip container is rendered with `class="tooltip"`, which collides
  with Bootstrap’s own `.tooltip { opacity: 0 }` rule. The widget now
  ships a small CSS reset, scoped to `.html-widget.g6 .tooltip`, that
  restores `opacity: 1` without affecting Bootstrap tooltips elsewhere
  on the page.

## g6R 0.5.0

CRAN release: 2025-12-09

### Potential breaking changes

Due to the new data validation for nodes, edges and combos, some
existing code might break if the data provided to g6R functions is not
valid. See the corresponding
[documentation](https://cynkra.github.io/g6R/articles/nodes.html#data-properties)
section. If you had to pass custom data you can do it in the `data`
slot.

### New features and fixes

- Support for svg rendering:

``` r

g6_options(renderer = JS("() => new SVGRenderer()"))
```

- Fix issue which was preventing from removing a node from a combo.
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
  or
  [`lasso_select()`](https://cynkra.github.io/g6R/reference/lasso_select.md)
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

- Get correct element type on click: it was possible that when clicking
  a combo, it appeared under `input$<graph_ID>-selected_node` instead of
  `input$<graph_ID>-selected_combo`.
- [`create_edge()`](https://cynkra.github.io/g6R/reference/create_edge.md)
  behavior improved: when creating an edge and it is release on the
  canvas, the edge isn’t cancelled and data are available. We added a
  `targetType` property which allows to know where the edge was dropped.
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
