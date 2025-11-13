# Configure Click Select Behavior

Creates a configuration object for the click-select behavior in G6. This
allows users to select graph elements by clicking.

## Usage

``` r
click_select(
  key = "click-select",
  animation = TRUE,
  degree = 0,
  enable = TRUE,
  multiple = FALSE,
  state = c("selected", "active", "inactive", "disabled", "highlight"),
  neighborState = c("selected", "active", "inactive", "disabled", "highlight"),
  unselectedState = NULL,
  onClick = NULL,
  trigger = "shift",
  ...
)
```

## Arguments

- key:

  Behavior unique identifier. Useful to modify this behavior from JS
  side.

- animation:

  Whether to enable animation effects when switching element states
  (boolean, default: TRUE).

- degree:

  Controls the highlight spread range (number or function, default: 0).

- enable:

  Whether to enable the click element function (boolean or function,
  default: TRUE).

- multiple:

  Whether to allow multiple selections (boolean, default: FALSE).

- state:

  The state applied when an element is selected (string, default:
  "selected").

- neighborState:

  The state applied to elements with n-degree relationships (string,
  default: "selected").

- unselectedState:

  The state applied to all other elements (string, default: NULL).

- onClick:

  Callback when an element is clicked (function, default: NULL).

- trigger:

  Keys for multi-selection (character vector, default: c("shift")).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/behavior/click-select>.

## Value

A list with the configuration settings for the click select behavior.

## Examples

``` r
# Basic configuration
config <- click_select()

# Custom configuration
config <- click_select(
  animation = FALSE,
  degree = 1,
  multiple = TRUE,
  state = "active",
  neighborState = "highlight",
  unselectedState = "inactive",
  trigger = c("Control")
)

# Example leveraging the input[["<GRAPH_ID>-selected_<ELEMENT_TYPE>"]]
if (interactive()) {
  library(shiny)
  library(g6R)
  library(bslib)

  nodes <- data.frame(id = c("node1", "node2"))
  edges <- data.frame(source = "node1", target = "node2")
  combos <- data.frame(id = "combo1", type = "rect")

  ui <- page_fluid(
    g6_output("graph"),
    verbatimTextOutput("selected_elements")
  )

  server <- function(input, output, session) {
    output$graph <- render_g6({
      g6(
        nodes = nodes,
        edges = edges,
        combos = combos
      ) |>
        g6_layout() |>
        g6_behaviors(
          click_select(multiple = TRUE),
          brush_select(
            enableElements = c("node", "edge", "combo"),
            immediately = TRUE
          )
        )
    })

    output$selected_elements <- renderPrint({
      list(
        selected_nodes = input[["graph-selected_node"]],
        selected_edges = input[["graph-selected_edge"]],
        selected_combos = input[["graph-selected_combo"]]
      )
    })
  }

  shinyApp(ui, server)
}
```
