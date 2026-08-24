library(shiny)
library(g6R)

# A workflow of the size that makes a graph hard to navigate: 10 groups of 15
# blocks each, fed from one source. A group is not a chain: its head fans out and
# each branch fans out again, so a group is a wide little tree, and the groups sit
# side by side. The drawing is a wide strip in which no single block is findable
# by eye at fit-to-view.
#
# Type a label ("Filter 07-03") or an id ("g07_b03") in the box, top-left of the
# canvas, and the viewport moves to that block and selects it. The outline on the
# right lists the whole workflow: fold a stage to skim, click a row to go there.
#
# Double-click a group to collapse it, then search for a block inside it: the
# search opens the group on the way. That pairing is what keeps a big workflow
# navigable, since collapsing is what makes it readable in the first place.
#
# The groups start expanded because a combo collapsed before the first layout run
# has no member positions to size itself from, and lands beside the source
# instead of in the flow.
n_group <- 10L
per_group <- 15L
branching <- 3L

verbs <- c(
  "Filter", "Select", "Mutate", "Arrange", "Summarise",
  "Join", "Pivot", "Slice", "Rename", "Count"
)

node_list <- list(
  g6_node(
    id = "source",
    type = "custom-rect-node",
    style = list(labelText = "Raw data"),
    ports = g6_ports(
      g6_output_port(key = "source-out", placement = "bottom", arity = Inf)
    )
  )
)

edge_list <- list()
combo_list <- list()

for (g in seq_len(n_group)) {

  gid <- sprintf("g%02d", g)
  ids <- sprintf("%s_b%02d", gid, seq_len(per_group))

  node_list <- c(
    node_list,
    lapply(seq_len(per_group), function(i) {
      g6_node(
        id = ids[i],
        type = "custom-rect-node",
        style = list(labelText = sprintf("%s %02d-%02d", verbs[g], g, i)),
        combo = gid,
        ports = g6_ports(
          g6_input_port(key = sprintf("%s-in", ids[i]), placement = "top"),
          # A block feeds several downstream blocks, so its output takes many
          # edges.
          g6_output_port(
            key = sprintf("%s-out", ids[i]),
            placement = "bottom",
            arity = Inf
          )
        )
      )
    })
  )

  edge_list <- c(
    edge_list,
    list(g6_edge(
      source = "source",
      target = ids[1],
      style = list(
        sourcePort = "source-out",
        targetPort = sprintf("%s-in", ids[1]),
        endArrow = TRUE
      )
    )),
    # Each block feeds up to `branching` others, so the group spreads sideways
    # instead of running down in a single line.
    lapply(seq(2L, per_group), function(i) {
      parent <- ((i - 2L) %/% branching) + 1L
      g6_edge(
        source = ids[parent],
        target = ids[i],
        style = list(
          sourcePort = sprintf("%s-out", ids[parent]),
          targetPort = sprintf("%s-in", ids[i]),
          endArrow = TRUE
        )
      )
    })
  )

  combo_list <- c(
    combo_list,
    list(g6_combo(
      gid,
      type = "rect",
      style = list(labelText = sprintf("%s stage", verbs[g]))
    ))
  )
}

ui <- fluidPage(
  g6_output("graph", height = "700px"),
  verbatimTextOutput("picked")
)

server <- function(input, output, session) {
  output$graph <- render_g6(
    g6(
      nodes = do.call(g6_nodes, node_list),
      edges = do.call(g6_edges, edge_list),
      combos = do.call(g6_combos, combo_list)
    ) |>
      g6_layout(
        # Top-to-bottom with `sortByCombo`: each group becomes a vertical
        # column and the columns sit side by side. `nodesep` is the gap between
        # columns here, so it needs enough room for the group boxes to clear
        # each other.
        antv_dagre_layout(rankdir = "TB", nodesep = 40, ranksep = 60,
                          sortByCombo = TRUE)
      ) |>
      g6_options(
        animation = FALSE,
        combo = list(
          style = list(
            # Room at the top for the label, so it sits above the row rather
            # than across the first blocks.
            padding = c(30, 20, 20, 20),
            labelPlacement = "top",
            labelBackground = TRUE,
            fillOpacity = 0.08,
            lineWidth = 1
          )
        )
      ) |>
      g6_behaviors(
        zoom_canvas(),
        drag_canvas(),
        drag_element(),
        click_select(multiple = TRUE),
        collapse_expand()
      ) |>
      g6_plugins(
        g6_search(
          outputId = "graph",
          placeholder = "Search blocks",
          # "combo" is g6 jargon; this workflow calls them stages.
          labels = c(node = "block", combo = "stage")
        ),
        # The outline answers "what is in here", the search "take me to this".
        g6_outline(
          outputId = "graph",
          title = "Workflow",
          labels = c(node = "block", combo = "stage")
        ),
        minimap()
      )
  )

  # Both panels report their pick, so the app can react to either.
  output$picked <- renderPrint({
    list(
      searched = input[["graph-searched_element"]],
      outlined = input[["graph-outlined_element"]]
    )
  })
}

shinyApp(ui, server)
