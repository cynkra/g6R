library(shiny)
library(bslib)
library(g6R)

nodes <- list(
  list(
    id = "node1",
    combo = "combo1",
    style = list(
      halo = FALSE, # Whether to display the node halo
      port = TRUE,
      ports = list(
        list(
          key = "top",
          placement = c(0.5, 1),
          fill = "#7E92B5"
        ),
        list(
          key = "right",
          placement = c(1, 0.5),
          fill = "#F4664A"
        ),
        list(
          key = "bottom",
          placement = c(0.5, 0),
          fill = "#FFBE3A"
        ),
        list(
          key = "left",
          placement = c(0, 0.5),
          fill = "#D580FF"
        )
      ),
      portR = 3,
      portLineWidth = 1,
      portStroke = "#fff"
    )
  ),
  list(
    id = "node2",
    style = list(
      x = 150,
      y = 50,
      badge = TRUE, # Whether to display the badge
      badges = list(
        list(
          text = "A",
          placement = "right-top"
        ),
        list(
          text = "Important",
          placement = "right"
        ),
        list(
          text = "Notice",
          placement = "right-bottom"
        )
      ),
      badgePalette = c("#7E92B5", "#F4664A", "#FFBE3A"), # Badge background color palette
      badgeFontSize = 7 # Badge font size
    ),
    combo = "combo1"
  )
)

edges <- list(
  list(type = "fly-marker-cubic", source = "node1", target = "node2")
)
combos <- list(
  list(
    id = "combo1",
    type = "rect",
    data = list(label = "Combo A")
  )
)

ui <- page_fluid(
  g6Output("graph"),
  verbatimTextOutput("selected_elements"),
  actionButton("set_data", "Set data")
)

server <- function(input, output, session) {
  output$graph <- renderG6({
    g6() |>
      g6_options(
        edge = list(
          type = "fly-marker-cubic",
          style = list(
            endArrow = TRUE
          )
        )
      ) |>
      g6_layout(d3_force_layout()) |>
      g6_behaviors(
        zoom_canvas(),
        drag_element(dropEffect = "link"),
        click_select(
          multiple = TRUE,
          onClick = JS(
            "(e) => {
              console.log(e);  
            }"
          )
        ),
        brush_select(immediately = TRUE),
        collapse_expand(),
        drag_canvas(
          trigger = list(
            up = c("ArrowUp"),
            down = c("ArrowDown"),
            left = c("ArrowLeft"),
            right = c("ArrowRight")
          ),
          animation = list(duration = 100)
        )
      ) |>
      g6_plugins(
        minimap(),
        fullscreen(),
        tooltips(
          title = "Tooltip",
          enable = JS(
            "(e) => { return e.targetType === 'node';}"
          ),
          #getContent = JS(
          #  "(e, items) => {
          #      let result = `<h4>Custom Content</h4>`;
          #      items.forEach((item) => {
          #        console.log(item.id);
          #        result += `<p>Type: ${item.id}</p>`;
          #      });
          #      return result;
          #    }"
          #),
          onOpenChange = JS(
            "( open ) => {   
            console.log(open);
          }"
          ),
          trigger = "click"
        ),
        toolbar(
          style = list(
            backgroundColor = "#f5f5f5",
            padding = "8px",
            boxShadow = "0 2px 8px rgba(0, 0, 0, 0.15)",
            borderRadius = "8px",
            border = "1px solid #e8e8e8",
            opacity = "0.9",
            marginTop = "12px",
            marginLeft = "12px"
          ),
          getItems = JS(
            "( ) => [   
                { id : 'zoom-in' , value : 'zoom-in' } ,  
                { id : 'zoom-out' , value : 'zoom-out' } ,   
                { id : 'auto-fit' , value : 'auto-fit' } ,
                { id: 'delete', value: 'delete' }, 
                { id: 'request-fullscreen', value: 'request-fullscreen' },
                { id: 'exit-fullscreen', value: 'exit-fullscreen' }
              ]"
          ),
          key = "toolbar",
          className = NULL,
          position = c(
            "top-left",
            "top",
            "top-right",
            "right",
            "bottom-right",
            "bottom",
            "bottom-left",
            "left"
          ),
          onClick = JS(
            "( value, target, current ) => {   
                // Handle button click events
              const graph = HTMLWidgets.find(`#${target.closest('.g6').id}`).getWidget();
              const fullScreen = graph.getPluginInstance('fullscreen');
              const zoomLevel = graph.getZoom();
                if ( value === 'zoom-in' ) {   
                  graph.zoomTo (graph.getZoom() + 0.1);
                } else if ( value === 'zoom-out' ) {     
                  graph.zoomTo (graph.getZoom() - 0.1);
                } else if ( value === 'auto-fit' ) {     
                  graph.fitView ( ) ;
                } else if (value === 'delete') {
                  const selectedNodes = graph.getElementDataByState('node', 'selected').map((node) => {
                    return node.id
                  });
                  graph.removeNodeData(selectedNodes);
                  graph.draw();
                } else if (value === 'request-fullscreen') {
                  if (fullScreen !== undefined) {
                    fullScreen.request();
                  }
                } else if (value === 'exit-fullscreen') {
                  if (fullScreen !== undefined) {
                    fullScreen.exit();
                  }
                }
              }"
          )
        ),
        context_menu(
          enable = JS(
            "(e) => {
                  return e.targetType === 'node'
                }"
          ),
          getItems = JS(
            "() => {
                  return [
                    { name: 'Create edge', value: 'create_edge' },
                    { name: 'Remove node', value: 'remove_node' }
                  ];
                }"
          ),
          onClick = JS(
            "(value, target, current) => {
                  const graph = HTMLWidgets.find(`#${target.closest('.g6').id}`).getWidget();
                  if (value === 'create_edge') {
                    graph.updateBehavior({
                      key: 'create-edge', // Specify the behavior to update
                      enable: true,
                    });
                    // Select node
                    graph.setElementState(current.id, 'selected');
                    // Disable drag node as it is incompatible with edge creation
                    graph.updateBehavior({ key: 'drag-element', enable: false });
                  } else if (value === 'remove_node') {
                    graph.removeNodeData([current.id]);
                    graph.draw();
                  }
                }"
          )
        )
      )
  })

  observeEvent(input$set_data, {
    g6_proxy("graph") |>
      g6_set_data(
        list(
          nodes = nodes,
          edges = edges,
          combos = combos
        )
      )
  })

  output$selected_elements <- renderPrint({
    list(
      node = input[["graph-selected_node"]],
      edge = input[["graph-selected_edge"]],
      combo = input[["graph-selected_combo"]],
      node2_state = input[["graph-node2-state"]]$combo
    )
  })
}

shinyApp(ui, server)
