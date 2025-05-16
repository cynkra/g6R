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
        }

        graph.render();
        graph.setTheme(config.theme);
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
