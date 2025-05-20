import 'widgets';
import {
  CanvasEvent,
  ComboEvent,
  EdgeEvent,
  Graph,
  GraphEvent,
  NodeEvent
} from '@antv/g6';
import { setClickEvents } from '../modules/events';
import { registerShinyHandlers } from '../modules/handlers';

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

          const clickEvents = [
            NodeEvent.CLICK,
            EdgeEvent.CLICK,
            ComboEvent.CLICK
          ]

          setClickEvents(clickEvents, graph, el);

          // When click on canvas and target isn't node or edge or combo
          // we have to reset the Shiny selected-node or edge or combo
          graph.on(CanvasEvent.CLICK, (e) => {
            Shiny.setInputValue(el.id + '-selected_node', null);
            Shiny.setInputValue(el.id + '-selected_edge', null);
            Shiny.setInputValue(el.id + '-selected_combo', null);
          });

          registerShinyHandlers(graph, el);
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
