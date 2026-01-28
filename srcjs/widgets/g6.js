import 'widgets';
import {
  ExtensionCategory,
  register
} from '@antv/g6';
import { AntLine, FlyMarkerCubic, CircleComboWithExtraButton } from '../modules/extensions';
import { setupIcons, loadAndInitGraph, getGraph } from '../modules/utils';
import { CustomCreateEdge } from '../modules/custom-behaviors';
import {
  CustomCircleNode,
  CustomRectNode,
  CustomEllipseNode,
  CustomDiamondNode,
  CustomTriangleNode,
  CustomStarNode,
  CustomHexagonNode,
  CustomImageNode,
  CustomDonutNode
} from '../modules/custom-nodes';

import { Renderer as SVGRenderer } from '@antv/g-svg';

if (typeof window !== 'undefined') {
  window.SVGRenderer = SVGRenderer;
}

const nodeTypes = [
  { name: 'circle', cls: CustomCircleNode },
  { name: 'rect', cls: CustomRectNode },
  { name: 'ellipse', cls: CustomEllipseNode },
  { name: 'diamond', cls: CustomDiamondNode },
  { name: 'triangle', cls: CustomTriangleNode },
  { name: 'star', cls: CustomStarNode },
  { name: 'hexagon', cls: CustomHexagonNode },
  { name: 'image', cls: CustomImageNode },
  { name: 'donut', cls: CustomDonutNode }
];

// Ant lines
register(ExtensionCategory.EDGE, 'ant-line', AntLine);
// Animated lines
register(ExtensionCategory.EDGE, 'fly-marker-cubic', FlyMarkerCubic);
// Circle combo
register(ExtensionCategory.COMBO, 'circle-combo-with-extra-button', CircleComboWithExtraButton);
// Custom create edge but ovrerrides the default one
register(ExtensionCategory.BEHAVIOR, 'create-edge', CustomCreateEdge);
// Register the custom node with G6
nodeTypes.forEach(({ name, cls }) => {
  register(ExtensionCategory.NODE, `custom-${name}-node`, cls);
});

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

        // Prevent text selection during drag
        el.style.userSelect = 'none';
        el.style.webkitUserSelect = 'none';

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
