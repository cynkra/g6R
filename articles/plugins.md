# Plugins

## Introduction

Plugins extend the functionality of G6 graphs by adding interactive
features, UI components, and visual enhancements. They can be added to
the graph using the
[`g6_plugins()`](https://cynkra.github.io/g6R/reference/g6_plugins.md)
function. Similar to behaviors, there are 2 ways to add plugins to the
graph - either by calling plugin names as strings or by passing plugin
functions with specific configurations:

``` r
# Defaults
g6() |>
  g6_plugins("minimap", "tooltip")

# Fine tune parameters
g6() |>
  g6_plugins(
    minimap(...),
    tooltip_plugin(...)
  )
```

## Contextmenu

Displays a menu of selectable operations on right-click for
context-sensitive actions.

``` r
nodes <- data.frame(
  id = letters[1:8]
)

edges <- data.frame(
  source = c("a", "b", "c", "e", "f", "g", "a", "d"),
  target = c("b", "c", "d", "f", "g", "h", "e", "h")
)

g6(nodes, edges) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        ),
        labelPlacement = "center",
        labelFontSize = 12
      )
    ),
    edges = list(
      style = list(
        stroke = "#666",
        lineWidth = 2
      )
    )
  ) |>
  g6_plugins(" contextmenu ")
```

------------------------------------------------------------------------

## Edge Filter Lens

Filters and displays edges within a specified area for focused analysis.

``` r
nodes <- data.frame(
  id = letters[1:8]
)

edges <- data.frame(
  source = c("a", "b", "c", "e", "f", "g", "a", "d"),
  target = c("b", "c", "d", "f", "g", "h", "e", "h")
)

g6(nodes, edges) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        ),
        labelPlacement = "center",
        labelFontSize = 12
      )
    ),
    edges = list(
      style = list(
        stroke = "#666",
        lineWidth = 2
      )
    )
  ) |>
  g6_plugins(" edge-filter-lens ")
```

------------------------------------------------------------------------

## Fisheye

Provides a focus + context exploration experience with distortion
effects.

``` r
nodes <- data.frame(
  id = letters[1:8]
)

edges <- data.frame(
  source = c("a", "b", "c", "e", "f", "g", "a", "d"),
  target = c("b", "c", "d", "f", "g", "h", "e", "h")
)

g6(nodes, edges) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        ),
        labelPlacement = "center",
        labelFontSize = 12
      )
    ),
    edges = list(
      style = list(
        stroke = "#666",
        lineWidth = 2
      )
    )
  ) |>
  g6_plugins(" fisheye ")
```

------------------------------------------------------------------------

## Grid Line

Displays grid reference lines on the canvas to help with element
alignment and positioning.

``` r
nodes <- data.frame(
  id = letters[1:8]
)

edges <- data.frame(
  source = c("a", "b", "c", "e", "f", "g", "a", "d"),
  target = c("b", "c", "d", "f", "g", "h", "e", "h")
)

g6(nodes, edges) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        ),
        labelPlacement = "center",
        labelFontSize = 12
      )
    ),
    edges = list(
      style = list(
        stroke = "#666",
        lineWidth = 2
      )
    )
  ) |>
  g6_plugins(" grid-line ")
```

------------------------------------------------------------------------

## Minimap

Displays a thumbnail preview of the graph, supporting navigation in
large graphs.

``` r
nodes <- data.frame(
  id = letters[1:8]
)

edges <- data.frame(
  source = c("a", "b", "c", "e", "f", "g", "a", "d"),
  target = c("b", "c", "d", "f", "g", "h", "e", "h")
)

g6(nodes, edges) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        ),
        labelPlacement = "center",
        labelFontSize = 12
      )
    ),
    edges = list(
      style = list(
        stroke = "#666",
        lineWidth = 2
      )
    )
  ) |>
  g6_plugins(" minimap ")
```

------------------------------------------------------------------------

## Snapline

Displays alignment reference lines when dragging elements to ensure
precise positioning.

``` r
nodes <- data.frame(
  id = letters[1:8]
)

edges <- data.frame(
  source = c("a", "b", "c", "e", "f", "g", "a", "d"),
  target = c("b", "c", "d", "f", "g", "h", "e", "h")
)

g6(nodes, edges) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        ),
        labelPlacement = "center",
        labelFontSize = 12
      )
    ),
    edges = list(
      style = list(
        stroke = "#666",
        lineWidth = 2
      )
    )
  ) |>
  g6_plugins(" snapline ")
```

------------------------------------------------------------------------

## Toolbar

Provides a collection of common operation buttons for graph
manipulation. If you wish to use custom icons, you can browse at
<https://at.alicdn.com/t/project/2678727/caef142c-804a-4a2f-a914-ae82666a31ee.html?spm=a313x.7781069.1998910419.35>
and then pass the icon name as `icon-<NAME>` in the toolbar `getItems`
parameter. See more
[here](https://g6.antv.antgroup.com/en/manual/plugin/build-in/toolbar#custom-icons).

``` r
nodes <- data.frame(
  id = letters[1:8]
)

edges <- data.frame(
  source = c("a", "b", "c", "e", "f", "g", "a", "d"),
  target = c("b", "c", "d", "f", "g", "h", "e", "h")
)

g6(nodes, edges) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        ),
        labelPlacement = "center",
        labelFontSize = 12
      )
    ),
    edges = list(
      style = list(
        stroke = "#666",
        lineWidth = 2
      )
    )
  ) |>
  g6_plugins(" toolbar ")
```

------------------------------------------------------------------------

## Tooltip

Displays detailed information about elements on hover for enhanced
interactivity. Doesn’t work with Shiny yet due to a compatibility issue
with Bootstrap tooltips class.

``` r
nodes <- data.frame(
  id = letters[1:8]
)

edges <- data.frame(
  source = c("a", "b", "c", "e", "f", "g", "a", "d"),
  target = c("b", "c", "d", "f", "g", "h", "e", "h")
)

g6(nodes, edges) |>
  g6_options(
    nodes = list(
      style = list(
        labelText = JS(
          "(d) => {
            return d.id
          }"
        ),
        labelPlacement = "center",
        labelFontSize = 12
      )
    ),
    edges = list(
      style = list(
        stroke = "#666",
        lineWidth = 2
      )
    )
  ) |>
  g6_plugins(" tooltip ")
```

------------------------------------------------------------------------

## Background

Adds background images or colors to the canvas for visual enhancement
and branding.

``` r
# Create and render the G6 plot
g6(nodes, edges) |>
  g6_layout() |>
  g6_behaviors("drag-element") |>
  g6_options(
    animation = FALSE,
    node = nodes_options
  ) |>
  g6_plugins(
    background(backgroundColor = "#f0f2f5")
  )
```

## Bubble sets

Creates smooth bubble-like element outlines for enhanced visual
grouping.

``` r
# Create and render the G6 plot
g6(nodes, edges) |>
  g6_layout() |>
  g6_behaviors("drag-element") |>
  g6_options(
    animation = FALSE,
    node = nodes_options
  ) |>
  g6_plugins(
    bubble_sets(
      key = "bubble-set-1",
      members = c("a", "b", "c", "d"),
      label = TRUE,
      labelText = "cluster 1",
      fill = "#F08F56",
      stroke = "#F08F56",
      labelBackground = TRUE,
      labelPlacement = "top",
      labelFill = "#fff",
      labelPadding = 2,
      labelBackgroundFill = "#F08F56",
      labelBackgroundRadius = 5
    ),
    bubble_sets(
      key = "bubble-set-2",
      members = c("e", "f", "g", "h"),
      label = TRUE,
      labelText = "cluster 2",
      fill = "#D580FF",
      stroke = "#D580FF",
      labelBackground = TRUE,
      labelPlacement = "top",
      labelFill = "#fff",
      labelPadding = 2,
      labelBackgroundFill = "#D580FF",
      labelBackgroundRadius = 5
    )
  )
```

## Fullscreen

Supports full-screen display and exit for charts to maximize viewing
area.

``` r
g6(nodes, edges) |>
  g6_layout() |>
  g6_behaviors("drag-element") |>
  g6_options(
    animation = FALSE,
    nodes = nodes_options
  ) |>
  g6_plugins(
    toolbar(),
    fullscreen()
  )
```

## Hull

Creates an outline for a specified set of nodes to visually group
related elements.

``` r
# Create and render the G6 plot
g6(nodes, edges) |>
  g6_layout() |>
  g6_behaviors("drag-element") |>
  g6_options(
    animation = FALSE,
    node = nodes_options
  ) |>
  g6_plugins(
    hull(
      key = "bubble-set-1",
      members = c("a", "b", "c", "d"),
      labelText = "cluster 1",
      fill = "#F08F56",
      stroke = "#F08F56",
      labelFill = "#fff",
      labelPadding = 2,
      labelBackgroundFill = "#F08F56",
      labelBackgroundRadius = 5
    ),
    hull(
      key = "bubble-set-2",
      members = c("e", "f", "g", "h"),
      labelText = "cluster 2",
      fill = "#D580FF",
      stroke = "#D580FF",
      labelFill = "#fff",
      labelPadding = 2,
      labelBackgroundFill = "#D580FF",
      labelBackgroundRadius = 5
    )
  )
```

## Legend

Displays categories and corresponding style descriptions of chart data.

``` r
custom_nodes <- lapply(1:8, \(i) {
  list(
    id = letters[i],
    style = list(
      fill = ifelse(i <= 4, "#F08F56", "#D580FF")
    ),
    data = list(cluster = ifelse(i <= 4, "1", "2"))
  )
})
# Create and render the G6 plot
g6(custom_nodes, edges) |>
  g6_layout() |>
  g6_behaviors("drag-element") |>
  g6_options(
    animation = FALSE,
    node = nodes_options
  ) |>
  g6_plugins(
    legend(
      position = "top-left",
      nodeField = "cluster"
    )
  )
```

## Timebar

does not work yet …

Provides filtering and playback control for temporal data visualization.

``` r
start_date <- as.POSIXct("2023-08-01", tz = "UTC")
dates <- as.character(seq(start_date, by = "1 days", length.out = 3))
times <- lapply(seq_along(dates), \(i) {
  list(
    value = i,
    time = JS(sprintf("new Date('%s').getTime()", dates[i]))
  )
})

custom_nodes <- lapply(seq_along(times), \(i) {
  list(
    id = letters[i],
    data = list(timestamp = JS(sprintf("new Date('%s').getTime()", dates[i])))
  )
})
# Create and render the G6 plot
g6(custom_nodes) |>
  g6_layout() |>
  g6_behaviors("drag-element") |>
  g6_options(
    animation = FALSE,
    node = nodes_options
  ) |>
  g6_plugins(
    timebar(
      data = times,
      height = 100
    )
  )
```

## Watermark

Adds a watermark to the canvas to protect copyright and brand the
visualization.

``` r
g6(nodes, edges) |>
  g6_layout() |>
  g6_behaviors("drag-element") |>
  g6_options(
    animation = FALSE,
    node = nodes_options
  ) |>
  g6_plugins(
    watermark(
      text = "G6 Graph",
      opacity = 0.2,
      rotate = pi / 12
    )
  )
```

## History

The history plugin provides undo and redo functionality for graph
modifications, allowing users to revert changes or reapply them. It
works well with the `toolbar` plugin to provide a user interface for
these actions:

``` r
g6(nodes, edges) |>
  g6_layout() |>
  g6_behaviors("drag-element") |>
  g6_options(
    animation = FALSE,
    node = nodes_options
  ) |>
  g6_plugins(
    toolbar(
      getItems = JS(
        "() => [
          { id: 'undo', value: 'undo' },
          { id: 'redo', value: 'redo' },
        ]"
      ),
      onClick = JS(
        "(value, target, current) => {
          // redo, undo need to be used with the history plugin
          const graph = HTMLWidgets
            .find(`#${target.closest('.g6').id}`)
            .getWidget();
          const history = graph.getPluginInstance('history');
          switch (value) {
            case 'undo':
              history?.undo();
              break;
            case 'redo':
              history?.redo();
              break;
            default:
              break;
          }
        }"
      )
    ),
    # Keep 100 events in memory
    history(stackSize = 100)
  )
```

## Dynamically interact with plugins

### Add

To add a plugin dynamically from the server side of a Shiny app, you can
use the
[`g6_add_plugin()`](https://cynkra.github.io/g6R/reference/g6_add_plugin.md)
function. This function allows you to append new plugins to an existing
G6 graph based on user interactions or other reactive data.

### Update

To update a plugin from the server side of a Shiny app, you can use the
[`g6_update_plugin()`](https://cynkra.github.io/g6R/reference/g6_update_plugin.md)
function. This function allows you to modify the plugin’s parameters
dynamically based on user input or other reactive data.
