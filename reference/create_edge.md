# Configure Create Edge Behavior

Creates a configuration object for the create-edge behavior in G6. This
allows users to create edges between nodes by clicking or dragging.

## Usage

``` r
create_edge(
  key = "create-edge",
  trigger = "drag",
  enable = FALSE,
  onCreate = NULL,
  onFinish = NULL,
  style = NULL,
  notify = FALSE,
  outputId = NULL,
  ...
)
```

## Arguments

- key:

  Behavior unique identifier. Useful to modify this behavior from JS
  side.

- trigger:

  The way to trigger edge creation: "click" or "drag" (string, default:
  "drag").

- enable:

  Whether to enable this behavior (boolean or function, default: FALSE).
  Our default implementation works in parallel with the
  [context_menu](https://cynkra.github.io/g6R/reference/context_menu.md)
  plugin which is responsible for activating the edge behavior when edge
  creation is selected.

- onCreate:

  Callback function for creating an edge, returns edge data (function,
  default: NULL).

- onFinish:

  Callback function for successfully creating an edge (function). By
  default, we provide an internal implementation that disables the edge
  mode when the edge creation is succesful so that it does not conflict
  with other drag behaviors.

- style:

  Style of the newly created edge (list, default: NULL).

- notify:

  Whether to show a feedback message in the ui.

- outputId:

  Manually pass the Shiny output ID. This is useful when the graph is
  initialised outside the shiny render function and the ID cannot be
  automatically inferred. This allows to set input values from the
  callback function with the right namespace and graph ID. You must
  typically pass `session$ns("graphid")` to ensure this also works in
  modules.

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/behavior/create-edge>.

## Value

A list with the configuration settings for the create-edge behavior.

## Examples

``` r
# Basic configuration
config <- create_edge()
if (interactive()) {
  library(shiny)
  library(bslib)
  library(g6R)

  nodes <- list(
    list(
      id = "node1"
    ),
    list(
      id = "node2"
    )
  )

  modUI <- function(id) {
    ns <- NS(id)
    tagList(
      g6Output(ns("graph"))
    )
  }

  modServer <- function(id) {
    moduleServer(id, function(input, output, session) {
      output$graph <- renderG6({
        g6(nodes) |>
          g6_options(
            animation = FALSE,
            edge = edge_options(
              style = list(
                endArrow = TRUE
              )
            )
          ) |>
          g6_layout(d3_force_layout()) |>
          g6_behaviors(
            # avoid conflict with internal function
            g6R::create_edge(
              target = c("node", "combo", "canvas"),
              enable = JS(
                "(e) => {
                  return e.shiftKey;
                }"
              ),
              onFinish = JS(
                sprintf(
                  "(edge) => {
                    const graph = HTMLWidgets.find('#%s').getWidget();
                    // Avoid to create edges in combos. If so, we remove it
                    if (edge.targetType === 'combo') {
                      graph.removeEdgeData([edge.id]);
                      return;
                    }
                    Shiny.setInputValue('%s', edge);
                  }",
                  session$ns("graph"),
                  session$ns("added_edge")
                )
              )
            )
          )
      })

      observeEvent(input[["added_edge"]], {
        showNotification(
          sprintf("Edge dropped on: %s", input[["added_edge"]]$targetType),
          type = "message"
        )
      })
    })
  }

  ui <- page_fluid(
    modUI("test")
  )

  server <- function(input, output, session) {
    modServer("test")
  }

  shinyApp(ui, server)
}
```
