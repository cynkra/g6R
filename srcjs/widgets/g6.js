import 'widgets';
import { EdgeEvent, Graph, GraphEvent, NodeEvent } from '@antv/g6';

HTMLWidgets.widget({

  name: 'g6',

  type: 'output',

  factory: function (el, width, height) {

    // TODO: define shared variables for this instance
    let graph;

    return {

      renderValue: function (x, id = el.id) {

        // TODO: code to render the widget, e.g.
        let config = x;
        // Don't change the container
        config.container = el.id;
        graph = new Graph(config);

        //graph.on(GraphEvent.AFTER_ELEMENT_CREATE, (e) => {
        //  console.log(e);
        //});

        if (HTMLWidgets.shinyMode) {
          graph.on(NodeEvent.CLICK, (e) => {
            // TBD set shiny input with el.id namespace
            const { target } = e; // Get the ID of the clicked node
            // Get node data
            const nodeData = graph.getNodeData(target.id);
            // Modify node state
            Shiny.setInputValue(el.id + '-selected_node', nodeData);
          })

          graph.on(EdgeEvent.CLICK, (e) => {
            // TBD set shiny input with el.id namespace
            const { target } = e; // Get the ID of the clicked node
            // Get node data
            const edgeData = graph.getEdgeData(target.id);
            // Modify node state
            Shiny.setInputValue(el.id + '-selected_edge', edgeData);
          })

          // Update/remove/add nodes or combo or edges
          Shiny.addCustomMessageHandler(el.id + '_g6-data', (m) => {
            try {
              // TBD: check if nodes data are also updated
              graph[`${m.action}${m.type}Data`](m.el);
              graph.draw();
              if (m.action !== 'update') {
                graph.layout();
              }
            } catch (error) {
              Shiny.notifications.show({ html: error, type: 'error' })
            }
          })

          // Canvas resize
          Shiny.addCustomMessageHandler(el.id + '_g6-canvas-resize', (m) => {
            try {
              graph.setSize(m.width, m.height);
            } catch (error) {
              Shiny.notifications.show({ html: error, type: 'error' })
            }
          })

          // Focus element
          Shiny.addCustomMessageHandler(el.id + '_g6-focus-element', (m) => {
            try {
              if (m.animation !== undefined) {
                graph.focusElement(m.ids, m.animation);
              } else {
                graph.focusElement(m.ids);
              }
            } catch (error) {
              Shiny.notifications.show({ html: error, type: 'error' })
            }
          })
        }

        graph.render();
        graph.draw();

      },
      getWidget: function () {
        return graph
      },
      resize: function (width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
