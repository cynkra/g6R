import 'widgets';
import {
  ExtensionCategory,
  register
} from '@antv/g6';
import { AntLine, FlyMarkerCubic, CircleComboWithExtraButton } from '../modules/extensions';
import { setupIcons, loadAndInitGraph, getGraph } from '../modules/utils';
import { CustomCreateEdge } from '../modules/custom-behaviors';
import { CustomCircleNode } from '../modules/custom-nodes';

import { Renderer as SVGRenderer } from '@antv/g-svg';

if (typeof window !== 'undefined') {
  window.SVGRenderer = SVGRenderer;
}

// Ant lines
register(ExtensionCategory.EDGE, 'ant-line', AntLine);
// Animated lines
register(ExtensionCategory.EDGE, 'fly-marker-cubic', FlyMarkerCubic);
// Circle combo
register(ExtensionCategory.COMBO, 'circle-combo-with-extra-button', CircleComboWithExtraButton);

// Custom create edge
register(ExtensionCategory.BEHAVIOR, 'create-edge', CustomCreateEdge);

// Register the custom node with G6
register(ExtensionCategory.NODE, 'custom-circle-node', CustomCircleNode);

HTMLWidgets.widget({

  name: 'g6',

  type: 'output',

  factory: function (el, width, height) {

    // Define shared variables for this instance
    let graph;

    return {

      renderValue: function (x) {

        // code to render the widget, e.g.
        let config = x;
        // Don't change the container
        config.container = el.id;

        // This is to be able to use custom icons.
        setupIcons(config.iconsUrl);

        loadAndInitGraph(config, this);
      },
      getWidget: function () {
        return getGraph()
      },
      resize: function (width, height) {
        // code to re-render the widget with a new size
        if (getGraph()) {
          getGraph().resize();
        }
      }

    };
  }
});
