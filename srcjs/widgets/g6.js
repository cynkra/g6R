import 'widgets';
import { Graph } from '@antv/g6';

HTMLWidgets.widget({

  name: 'g6',

  type: 'output',

  factory: function (el, width, height) {

    // TODO: define shared variables for this instance
    let graph;

    return {

      renderValue: function (x, id = el.id) {

        // TODO: code to render the widget, e.g.
        graph = new Graph({
          container: el.id,
          data: {
            nodes: [
              { id: 'node-1', style: { x: 50, y: 50 } },
              { id: 'node-2', style: { x: 150, y: 50 } },
            ],
            edges: [{ source: 'node-1', target: 'node-2' }],
          },
        });

        graph.render();

      },

      resize: function (width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
