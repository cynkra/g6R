import 'widgets';
import './g6.css';
import {
  ExtensionCategory,
  register
} from '@antv/g6';
import { AntLine, FlyMarkerCubic, CircleComboWithExtraButton, RectComboWithExtraButton } from '../modules/extensions';
import { setupIcons, loadAndInitGraph } from '../modules/utils';
import { CustomCreateEdge, CustomDragElement, CustomCollapseExpand } from '../modules/custom-behaviors';
import { Search, Outline } from '../modules/custom-plugins';
import {
  CustomCircleNode,
  CustomRectNode,
  CustomEllipseNode,
  CustomDiamondNode,
  CustomTriangleNode,
  CustomStarNode,
  CustomHexagonNode,
  CustomImageNode,
  CustomDonutNode,
  CustomHTMLNode,
  registerNodeContent
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
  { name: 'donut', cls: CustomDonutNode },
  { name: 'html', cls: CustomHTMLNode }
];

// Ant lines
register(ExtensionCategory.EDGE, 'ant-line', AntLine);
// Animated lines
register(ExtensionCategory.EDGE, 'fly-marker-cubic', FlyMarkerCubic);
// Combos with collapse/expand button
register(ExtensionCategory.COMBO, 'circle-combo-with-extra-button', CircleComboWithExtraButton);
register(ExtensionCategory.COMBO, 'rect-combo-with-extra-button', RectComboWithExtraButton);
// Custom create edge but ovrerrides the default one
register(ExtensionCategory.BEHAVIOR, 'create-edge', CustomCreateEdge);
// Same, for dragging: keeps a combo drag from following its members' children
register(ExtensionCategory.BEHAVIOR, 'drag-element', CustomDragElement);
// Same, so double-clicks inside HTML node content do not collapse the node
register(ExtensionCategory.BEHAVIOR, 'collapse-expand', CustomCollapseExpand);
// G6 has no search UI; this one focuses the element you pick
register(ExtensionCategory.PLUGIN, 'search', Search);
// A list view of the graph, for when the drawing is too big to read
register(ExtensionCategory.PLUGIN, 'outline', Outline);
// Register the custom node with G6
nodeTypes.forEach(({ name, cls }) => {
  register(ExtensionCategory.NODE, `custom-${name}-node`, cls);
});

HTMLWidgets.widget({

  name: 'g6',

  type: 'output',

  factory: function (el, width, height) {

    // This instance's graph, set once it is built.
    let graph = null;

    // A press on the canvas or on an HTML node's drag handle starts a drag,
    // not a text selection: without this, panning across HTML nodes, or
    // dragging one by its handle, selects the text it passes over. Presses
    // inside node content keep selecting text as usual.
    let pressOrigin = null;
    el.addEventListener('pointerdown', (event) => {
      pressOrigin = event.target;
    }, true);
    el.addEventListener('selectstart', (event) => {
      const origin = pressOrigin;
      if (!(origin instanceof Element)) return;
      if (origin.tagName === 'CANVAS' || origin.closest('[data-g6-drag-handle]')) {
        event.preventDefault();
      }
    });

    return {

      renderValue: function (x) {

        // code to render the widget, e.g.
        let config = x;
        // Don't change the container
        config.container = el.id;

        // This is to be able to use custom icons.
        setupIcons(config.iconsUrl);

        // Content of HTML nodes given as g6_node(ui = )
        registerNodeContent(el.id, config.nodeContent, { prune: true });

        loadAndInitGraph(config, this, (g) => {
          graph = g;
        });
      },
      getWidget: function () {
        return graph;
      },
      resize: function (width, height) {
        if (graph && !graph.destroyed) {
          graph.resize();
        }
      }

    };
  }
});
