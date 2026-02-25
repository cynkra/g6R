library(shiny)
library(g6R)

options(
  "g6R.mode" = "dev",
  "g6R.max_collapse_depth" = Inf,
  # In theory this is automatically set whenever a g6_node has some children ...
  "g6R.directed_graph" = TRUE
)

ui <- fluidPage(
  g6_output("dag", height = "1000px"),
  verbatimTextOutput("clicked_port"),
  verbatimTextOutput("removed_node")
)

server <- function(input, output, session) {
  output$dag <- render_g6(
    g6(
      nodes = g6_nodes(
        # a = dataset_block("iris") — outside combos
        g6_node(
          id = "a",
          type = "custom-rect-node",
          style = list(
            labelText = "dataset: iris"
          ),
          ports = g6_ports(
            g6_output_port(
              key = "output-a",
              placement = "bottom",
              label = "data"
            )
          ),
          children = c("b"),
          collapse = g6_collapse_options(
            collapsed = TRUE,
            visibility = "hover",
            placement = "right-top"
          )
        ),
        # b = head_block(n = 10) — combo1 (stack1)
        g6_node(
          id = "b",
          type = "custom-rect-node",
          style = list(
            labelText = "head(n=10)"
          ),
          ports = g6_ports(
            g6_input_port(
              key = "input-b",
              placement = "top",
              label = "data"
            ),
            g6_output_port(
              key = "output-b",
              placement = "bottom",
              label = "data"
            )
          ),
          combo = "combo1",
          children = c("c", "f"),
          collapse = g6_collapse_options(
            placement = "right-top"
          )
        ),
        # c = subset_block() — combo1 (stack1)
        g6_node(
          id = "c",
          type = "custom-rect-node",
          style = list(
            labelText = "subset"
          ),
          ports = g6_ports(
            g6_input_port(
              key = "input-c",
              placement = "top",
              label = "data"
            ),
            g6_output_port(
              key = "output-c",
              placement = "bottom",
              label = "data"
            )
          ),
          combo = "combo1",
          children = "d"
        ),
        # d = head_block(n = 5) — combo1 (stack1)
        g6_node(
          id = "d",
          type = "custom-rect-node",
          style = list(
            labelText = "head(n=5)"
          ),
          ports = g6_ports(
            g6_input_port(
              key = "input-d",
              placement = "top",
              label = "data"
            ),
            g6_output_port(
              key = "output-d",
              placement = "bottom",
              label = "data"
            )
          ),
          combo = "combo1",
          children = c("e"),
          collapse = g6_collapse_options(
            collapsed = FALSE,
            placement = "right-top"
          )
        ),
        # e = rbind_block() — outside combos
        g6_node(
          id = "e",
          type = "custom-rect-node",
          style = list(
            labelText = "rbind"
          ),
          ports = g6_ports(
            g6_input_port(
              key = "input-e-1",
              placement = "top",
              label = "1",
              arity = Inf
            ),
            g6_input_port(
              key = "input-e-2",
              placement = "top",
              label = "2",
              arity = Inf
            ),
            g6_output_port(
              key = "output-e",
              placement = "bottom",
              label = "data",
              arity = Inf
            )
          ),
          children = c("g"),
          collapse = g6_collapse_options(
            collapsed = FALSE,
            placement = "right-top"
          )
        ),
        # f = subset_block() — combo2 (stack2)
        g6_node(
          id = "f",
          type = "custom-rect-node",
          style = list(
            labelText = "subset"
          ),
          ports = g6_ports(
            g6_input_port(
              key = "input-f",
              placement = "top",
              label = "data"
            ),
            g6_output_port(
              key = "output-f",
              placement = "bottom",
              label = "data"
            )
          ),
          combo = "combo2",
          children = c("e", "g"),
          collapse = g6_collapse_options(
            collapsed = FALSE,
            placement = "right-top"
          )
        ),
        # g = rbind_block() — combo2 (stack2)
        g6_node(
          id = "g",
          type = "custom-rect-node",
          style = list(
            labelText = "rbind"
          ),
          ports = g6_ports(
            g6_input_port(
              key = "input-g-1",
              placement = "top",
              label = "1",
              arity = Inf
            ),
            g6_input_port(
              key = "input-g-2",
              placement = "top",
              label = "2",
              arity = Inf
            ),
            g6_output_port(
              key = "output-g",
              placement = "bottom",
              label = "data",
              arity = Inf
            )
          ),
          combo = "combo2",
          children = c("h"),
          collapse = g6_collapse_options(
            collapsed = FALSE,
            placement = "right-top"
          )
        ),
        # h = head_block(n = 3) — outside combos
        g6_node(
          id = "h",
          type = "custom-rect-node",
          style = list(
            labelText = "head(n=3)"
          ),
          ports = g6_ports(
            g6_input_port(
              key = "input-h",
              placement = "top",
              label = "data"
            ),
            g6_output_port(
              key = "output-h",
              placement = "bottom",
              label = "data"
            )
          ),
          children = c("i"),
          collapse = g6_collapse_options(
            collapsed = FALSE,
            placement = "right-top"
          )
        ),
        # i = scatter_block(x = "Sepal.Length", y = "Sepal.Width") — outside combos
        g6_node(
          id = "i",
          type = "custom-rect-node",
          style = list(
            labelText = "scatter plot"
          ),
          ports = g6_ports(
            g6_input_port(
              key = "input-i",
              placement = "top",
              label = "data"
            ),
            g6_output_port(
              key = "output-i",
              placement = "bottom",
              label = "data"
            )
          ),
          children = c("j"),
          collapse = g6_collapse_options(
            placement = "right-top"
          )
        ),
        # --- Bubble set nodes (descendants of i, no combo) ---
        g6_node(
          id = "j",
          type = "custom-rect-node",
          style = list(labelText = "filter"),
          ports = g6_ports(
            g6_input_port(key = "input-j", placement = "top", label = "data"),
            g6_output_port(
              key = "output-j",
              placement = "bottom",
              label = "data"
            )
          ),
          children = c("k", "l"),
          collapse = g6_collapse_options(placement = "right-top")
        ),
        g6_node(
          id = "k",
          type = "custom-rect-node",
          style = list(labelText = "summarise"),
          ports = g6_ports(
            g6_input_port(key = "input-k", placement = "top", label = "data"),
            g6_output_port(
              key = "output-k",
              placement = "bottom",
              label = "data"
            )
          ),
          children = c("m"),
          collapse = g6_collapse_options(placement = "right-top")
        ),
        # --- Hull nodes (descendants of i, no combo) ---
        g6_node(
          id = "l",
          type = "custom-rect-node",
          style = list(labelText = "mutate"),
          ports = g6_ports(
            g6_input_port(key = "input-l", placement = "top", label = "data"),
            g6_output_port(
              key = "output-l",
              placement = "bottom",
              label = "data"
            )
          ),
          children = c("n"),
          collapse = g6_collapse_options(placement = "right-top")
        ),
        g6_node(
          id = "m",
          type = "custom-rect-node",
          style = list(labelText = "arrange"),
          ports = g6_ports(
            g6_input_port(key = "input-m", placement = "top", label = "data"),
            g6_output_port(
              key = "output-m",
              placement = "bottom",
              label = "data"
            )
          )
        ),
        g6_node(
          id = "n",
          type = "custom-rect-node",
          style = list(labelText = "select"),
          ports = g6_ports(
            g6_input_port(key = "input-n", placement = "top", label = "data")
          )
        )
      ),
      edges = g6_edges(
        # a -> b (data)
        g6_edge(
          source = "a",
          target = "b",
          style = list(
            sourcePort = "output-a",
            targetPort = "input-b",
            endArrow = TRUE,
            startArrow = FALSE,
            endArrowType = "vee"
          )
        ),
        # b -> c (data)
        g6_edge(
          source = "b",
          target = "c",
          style = list(
            sourcePort = "output-b",
            targetPort = "input-c",
            endArrow = TRUE,
            startArrow = FALSE,
            endArrowType = "vee"
          )
        ),
        # c -> d (data)
        g6_edge(
          source = "c",
          target = "d",
          style = list(
            sourcePort = "output-c",
            targetPort = "input-d",
            endArrow = TRUE,
            startArrow = FALSE,
            endArrowType = "vee"
          )
        ),
        # b -> f (data) — cross-combo: combo1 -> combo2
        g6_edge(
          source = "b",
          target = "f",
          style = list(
            sourcePort = "output-b",
            targetPort = "input-f",
            endArrow = TRUE,
            startArrow = FALSE,
            endArrowType = "vee"
          )
        ),
        # d -> e (input 1) — combo1 -> outside
        g6_edge(
          source = "d",
          target = "e",
          style = list(
            sourcePort = "output-d",
            targetPort = "input-e-1",
            endArrow = TRUE,
            startArrow = FALSE,
            endArrowType = "vee"
          )
        ),
        # f -> e (input 2) — combo2 -> outside
        g6_edge(
          source = "f",
          target = "e",
          style = list(
            sourcePort = "output-f",
            targetPort = "input-e-2",
            endArrow = TRUE,
            startArrow = FALSE,
            endArrowType = "vee"
          )
        ),
        # e -> g (input 1) — outside -> combo2
        g6_edge(
          source = "e",
          target = "g",
          style = list(
            sourcePort = "output-e",
            targetPort = "input-g-1",
            endArrow = TRUE,
            startArrow = FALSE,
            endArrowType = "vee"
          )
        ),
        # f -> g (input 2) — inside combo2
        g6_edge(
          source = "f",
          target = "g",
          style = list(
            sourcePort = "output-f",
            targetPort = "input-g-2",
            endArrow = TRUE,
            startArrow = FALSE,
            endArrowType = "vee"
          )
        ),
        # g -> h (data) — combo2 -> outside
        g6_edge(
          source = "g",
          target = "h",
          style = list(
            sourcePort = "output-g",
            targetPort = "input-h",
            endArrow = TRUE,
            startArrow = FALSE,
            endArrowType = "vee"
          )
        ),
        # h -> i (data) — outside -> outside
        g6_edge(
          source = "h",
          target = "i",
          style = list(
            sourcePort = "output-h",
            targetPort = "input-i",
            endArrow = TRUE,
            startArrow = FALSE,
            endArrowType = "vee"
          )
        ),
        # i -> j
        g6_edge(
          source = "i",
          target = "j",
          style = list(
            sourcePort = "output-i",
            targetPort = "input-j",
            endArrow = TRUE,
            startArrow = FALSE,
            endArrowType = "vee"
          )
        ),
        # j -> k (bubble set member)
        g6_edge(
          source = "j",
          target = "k",
          style = list(
            sourcePort = "output-j",
            targetPort = "input-k",
            endArrow = TRUE,
            startArrow = FALSE,
            endArrowType = "vee"
          )
        ),
        # j -> l (bubble set member)
        g6_edge(
          source = "j",
          target = "l",
          style = list(
            sourcePort = "output-j",
            targetPort = "input-l",
            endArrow = TRUE,
            startArrow = FALSE,
            endArrowType = "vee"
          )
        ),
        # k -> m (hull member)
        g6_edge(
          source = "k",
          target = "m",
          style = list(
            sourcePort = "output-k",
            targetPort = "input-m",
            endArrow = TRUE,
            startArrow = FALSE,
            endArrowType = "vee"
          )
        ),
        # l -> n (hull member)
        g6_edge(
          source = "l",
          target = "n",
          style = list(
            sourcePort = "output-l",
            targetPort = "input-n",
            endArrow = TRUE,
            startArrow = FALSE,
            endArrowType = "vee"
          )
        )
      ),
      combos = g6_combos(
        g6_combo(
          "combo1",
          collapse = g6_collapse_options(visibility = "hover")
        ),
        g6_combo("combo2", collapse = g6_collapse_options())
      )
    ) |>
      g6_layout(antv_dagre_layout(sortByCombo = TRUE)) |>
      g6_options(
        animation = FALSE,
        autoFit = TRUE,
        node = list(
          style = list(
            #fill = "#CED4D9",
            #fillOpacity = 0
          )
        ),
        combo = list(),
        renderer = JS("() => new SVGRenderer()"),
        edge = list(style = list(endArrow = TRUE))
      ) |>
      g6_behaviors(
        collapse_expand(
          enable = JS(
            "(e) => {
              return e.targetType === 'combo'
            }"
          )
        ),
        click_select(multiple = TRUE),
        drag_element(),
        drag_canvas(
          enable = JS(
            "(e) => {
          return e.targetType === 'canvas' && !e.shiftKey && !e.altKey;
        }"
          )
        ),
        zoom_canvas(),
        create_edge(
          enable = JS(
            "(e) => {
            return e.targetType === 'node' && e.targetType !== 'combo';
          }"
          ),
          onFinish = NULL
        )
      ) |>
      # Allow to dynamically remove an edge or node
      g6_plugins(
        bubble_sets(
          key = "bubble-set-1",
          members = c("j", "k"),
          label = TRUE,
          labelText = "bubble set",
          fill = "#F08F56",
          stroke = "#F08F56",
          labelBackground = TRUE,
          labelPlacement = "top",
          labelFill = "#fff",
          labelPadding = 2,
          labelBackgroundFill = "#F08F56",
          labelBackgroundRadius = 5
        ),
        hull(
          key = "hull-1",
          members = c("l", "m", "n"),
          labelText = "Super hull",
          labelAutoRotate = FALSE,
          labelCloseToPath = FALSE,
          fill = "#7B68EE",
          stroke = "#7B68EE",
          labelBackground = TRUE,
          labelPlacement = "top",
          labelFill = "#fff",
          labelPadding = 2,
          labelBackgroundFill = "#7B68EE",
          labelBackgroundRadius = 5
        ),
        context_menu(
          enable = JS("(e) => true"),
          getItems = JS(
            "(e) => {
              if (e.targetType === 'edge') {
                return [{ name: 'Remove edge', value: 'remove_edge' }];
              } else if (e.targetType === 'node') {
                return [{ name: 'Remove node', value: 'remove_node' }];
              }
              return [];
            }"
          ),
          onClick = JS(
            "(value, target, current) => {
              const graph = HTMLWidgets
                .find(`#${target.closest('.g6').id}`)
                .getWidget();
              if (current.id === undefined) return;
              if (value === 'remove_edge') {
              console.log(target);
              Shiny.setInputValue(target.closest('.g6').id + '-removed_edge',
                  {id: current.id},
                  {priority: 'event'});
              } else if (value === 'remove_node') {
                // Send node ID to Shiny before removing
                Shiny.setInputValue(target.closest('.g6').id + '-removed_node',
                  {id: current.id},
                  {priority: 'event'});
              }
            }
          "
          )
        )
      )
  )

  output$clicked_port <- renderPrint({
    input[["dag-selected_port"]]
  })

  output$removed_node <- renderPrint({
    input[["dag-removed_node"]]
  })

  proxy <- g6_proxy("dag")

  # Add a new node when a port is clicked from the guide
  # at the mouse position (close to the guide)
  observeEvent(input[["dag-selected_port"]], {
    new_id <- as.character(round(as.numeric(Sys.time())))
    pos <- input[["dag-mouse_position"]]
    parent_id <- as.character(input[["dag-selected_port"]][["node"]])

    proxy |>
      g6_add_nodes(
        g6_node(
          id = new_id,
          type = "custom-circle-node",
          style = list(
            x = pos$x + 50, # avoids overlapping with the guide.
            y = pos$y,
            labelText = paste("Node", new_id)
          ),
          ports = g6_ports(
            g6_input_port(
              key = sprintf("input-%s", new_id),
              placement = "left",
              arity = Inf
            ),
            g6_output_port(
              key = sprintf("output-%s", new_id),
              placement = "right",
              arity = Inf
            )
          )
        )
      ) |>
      g6_add_edges(
        g6_edge(
          source = parent_id,
          target = new_id,
          style = list(
            sourcePort = input[["dag-selected_port"]][["port"]],
            targetPort = sprintf("input-%s", new_id),
            endArrow = TRUE
          )
        )
      )
  })

  observeEvent(input[["dag-removed_edge"]], {
    proxy |>
      g6_remove_edges(input[["dag-removed_edge"]]$id)
  })

  # Handle node removal - update parent's children list
  observeEvent(input[["dag-removed_node"]], {
    proxy |>
      g6_remove_nodes(input[["dag-removed_node"]]$id)
  })
}

shinyApp(ui, server)
