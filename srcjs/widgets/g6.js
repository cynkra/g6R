import 'widgets';
import { CanvasEvent, ComboEvent, EdgeEvent, Graph, GraphEvent, NodeEvent } from '@antv/g6';

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
            // TBD: need to find a way to know that multiple selection is TRUE ...
            if (Shiny.shinyapp.$inputValues[`${el.id}-selected_node`] == undefined) {
              Shiny.setInputValue(el.id + '-selected_node', [target.id]);
            } else {
              Shiny.setInputValue(el.id + '-selected_node', [Shiny.shinyapp.$inputValues[`${el.id}-selected_node`], target.id])
            }

          })

          // When click on canvas and target isn't node or edge or combo
          // we have to reset the Shiny selected-node or edge or combo
          graph.on(CanvasEvent.CLICK, (e) => {
            Shiny.setInputValue(el.id + '-selected_node', null);
            Shiny.setInputValue(el.id + '-selected_edge', null);
            Shiny.setInputValue(el.id + '-selected_combo', null);
          });

          graph.on(EdgeEvent.CLICK, (e) => {
            // TBD set shiny input with el.id namespace
            const { target } = e; // Get the ID of the clicked edge
            // Get edge data
            const edgeData = graph.getEdgeData(target.id);
            // Register shiny input
            if (Shiny.shinyapp.$inputValues[`${el.id}-selected_edge`] == undefined) {
              Shiny.setInputValue(el.id + '-selected_edge', [target.id]);
            } else {
              Shiny.setInputValue(el.id + '-selected_edge', [Shiny.shinyapp.$inputValues[`${el.id}-selected_edge`], target.id])
            }
          })

          graph.on(ComboEvent.CLICK, (e) => {
            // TBD set shiny input with el.id namespace
            const { target } = e; // Get the ID of the clicked combo
            // Get combo data
            const comboData = graph.getComboData(target.id);
            // Register shiny input
            if (Shiny.shinyapp.$inputValues[`${el.id}-selected_combo`] == undefined) {
              Shiny.setInputValue(el.id + '-selected_combo', [target.id]);
            } else {
              Shiny.setInputValue(el.id + '-selected_combo', [Shiny.shinyapp.$inputValues[`${el.id}-selected_combo`], target.id])
            }
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

          // Focus/hide/show element
          Shiny.addCustomMessageHandler(el.id + '_g6-element-action', (m) => {
            try {
              graph[`${m.action}Element`](m.ids, m.animation);
            } catch (error) {
              Shiny.notifications.show({ html: error, type: 'error' })
            }
          })

          // Combo actions
          Shiny.addCustomMessageHandler(el.id + '_g6-combo-action', (m) => {
            try {
              if (m.options === null) {
                graph[`${m.action}Element`](m.id);
              } else {
                graph[`${m.action}Element`](m.id, m.options);
              }
            } catch (error) {
              Shiny.notifications.show({ html: error, type: 'error' })
            }
          })

          // Set options
          Shiny.addCustomMessageHandler(el.id + '_g6-set-options', (m) => {
            try {
              graph.setOptions(m);
              graph.draw();
            } catch (error) {
              Shiny.notifications.show({ html: error, type: 'error' })
            }
          })

          // Update plugin
          Shiny.addCustomMessageHandler(el.id + '_g6-update-plugin', (m) => {
            try {
              graph.updatePlugin(m);
            } catch (error) {
              Shiny.notifications.show({ html: error, type: 'error' })
            }
          })

          // Append plugin
          Shiny.addCustomMessageHandler(el.id + "_g6-add-plugin", (m) => {
            try {
              graph.setPlugins((currentPlugins) => {
                m.map((newPlugin) => {
                  currentPlugins.push(newPlugin)
                })
                return currentPlugins
              });
            } catch (error) {
              Shiny.notifications.show({ html: error, type: 'error' })
            }
          });

          // Update behavior
          Shiny.addCustomMessageHandler(el.id + '_g6-update-behavior', (m) => {
            try {
              graph.updateBehavior(m);
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
