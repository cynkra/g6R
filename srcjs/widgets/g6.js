import 'widgets';
import {
  Graph,
  ExtensionCategory,
  register
} from '@antv/g6';
import { AntLine, FlyMarkerCubic, CircleComboWithExtraButton } from '../modules/extensions';
import { setupGraph, setupIcons } from '../modules/utils';


// Ant lines
register(ExtensionCategory.EDGE, 'ant-line', AntLine);
// Animated lines
register(ExtensionCategory.EDGE, 'fly-marker-cubic', FlyMarkerCubic);
// Circle combo
register(ExtensionCategory.COMBO, 'circle-combo-with-extra-button', CircleComboWithExtraButton);

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

        // This is to be able to use custom icons.
        setupIcons(config.iconsUrl);

        // Bypass R data processing an fetch JSON data from JS
        if (config.jsonUrl !== null) {
          fetch(x.jsonUrl)
            .then((res) => res.json())
            .then((data) => {
              config.data = data;
              graph = new Graph(config);
              setupGraph(graph, el, this);
            })
        } else {
          graph = new Graph(config);
          setupGraph(graph, el, this);
        }

      },
      getWidget: function () {
        return graph
      },
      resize: function (width, height) {
        // TODO: code to re-render the widget with a new size
        graph.resize();

      }

    };
  }
});
