import { getBehavior, resetOtherElementTypes } from "./utils";
import { GraphEvent, CanvasEvent, CommonEvent } from '@antv/g6';

// Helper to allows for better graph state:
//{
//  nodes: {
//    1: {id: 1, ...},
//    2: {id: 2, ...}
//  },
//  edges: {
//    1: {id: 1, ...},
//    2: {id: 2, ...}
//  },
//  combos: {
//    1: {id: 1, ...},
//    2: {id: 2, ...}
//  }
//}
// On the R side, instead of getting unnamed lists
// for nodes, edges and combos, list is named by elements
// IDs.
const preprocessGraphState = (graphState) => {
  const arrayToObject = (arr, key = "id") =>
    arr
      ? arr.reduce((acc, item) => {
        // For ports, use 'key'
        if (item.style && Array.isArray(item.style.ports)) {
          item.style.ports = arrayToObject(item.style.ports, "key");
        }
        acc[item[key]] = item;
        return acc;
      }, {})
      : {};

  // Deep copy to avoid mutating original
  const state = structuredClone(graphState);

  if (Array.isArray(state.nodes)) {
    state.nodes = arrayToObject(state.nodes, "id");
  }
  if (Array.isArray(state.edges)) {
    state.edges = arrayToObject(state.edges, "id");
  }
  if (Array.isArray(state.combos)) {
    state.combos = arrayToObject(state.combos, "id");
  }

  return state;
}

// Track currently selected nodes and their original styles
// Map: nodeId -> { labelFontWeight, labelBackgroundFill, labelBackgroundStroke }
let currentSelectedNodes = new Map();

// Style constants for selection
const SELECTED_LABEL_STYLE = {
  labelFontWeight: 700,
  labelBackgroundFill: '#dbeafe',
  labelBackgroundStroke: '#0D99FF'
};

const updateNodeSelectionStyle = (graph, nodeId, isSelected) => {
  try {
    if (isSelected) {
      // Store original style before selecting
      const nodeData = graph.getNodeData(nodeId);
      const originalStyle = {
        labelFontWeight: nodeData?.style?.labelFontWeight,
        labelBackgroundFill: nodeData?.style?.labelBackgroundFill,
        labelBackgroundStroke: nodeData?.style?.labelBackgroundStroke
      };
      currentSelectedNodes.set(nodeId, originalStyle);

      // Apply selection style
      graph.updateNodeData([{ id: nodeId, style: SELECTED_LABEL_STYLE }]);
    } else {
      // Restore original style (undefined values will use defaults in drawLabelShape)
      const originalStyle = currentSelectedNodes.get(nodeId) || {};
      graph.updateNodeData([{ id: nodeId, style: originalStyle }]);
      currentSelectedNodes.delete(nodeId);
    }
    graph.draw();
  } catch (err) {
    console.error('[selection] Failed to update node style:', err);
  }
};

// Clear all selection styling (called on canvas click)
const clearNodeSelectionStyling = (graph) => {
  currentSelectedNodes.forEach((originalStyle, nodeId) => {
    updateNodeSelectionStyle(graph, nodeId, false);
  });
  // Map is cleared by updateNodeSelectionStyle via delete, but clear anyway
  currentSelectedNodes.clear();
};

const setClickEvents = (events, graph) => {
  // Loop over events
  const id = graph.options.container;

  for (let event of events) {
    graph.on(event, (e) => {
      const { target } = e; // Get the ID of the clicked node
      // Get correct type: target.type would not work as it may
      // possibly return node instead of combo ...
      const type = graph.getElementType(target.id);
      const inputName = `${id}-selected_${type}`;
      const clickSelect = getBehavior(graph.getBehaviors(), "click-select");
      if (!clickSelect.length) return;
      const isMultiple = clickSelect[0].multiple;

      if (!e.shiftKey) {
        resetOtherElementTypes(id, target.type);
      }

      // Handle node selection styling
      if (type === 'node') {
        if (!e.shiftKey) {
          // Clear previous selection styling (except for the clicked node)
          currentSelectedNodes.forEach((originalStyle, nodeId) => {
            if (nodeId !== target.id) {
              updateNodeSelectionStyle(graph, nodeId, false);
            }
          });
        }

        // Toggle selection for clicked node
        const wasSelected = currentSelectedNodes.has(target.id);
        if (wasSelected) {
          updateNodeSelectionStyle(graph, target.id, false);
        } else {
          updateNodeSelectionStyle(graph, target.id, true);
        }
      }

      // If multiclick is allowed ...
      if (isMultiple && e.shiftKey) {
        // If initial state, we set an array with the current value
        if (Shiny.shinyapp.$inputValues[inputName] === undefined || Shiny.shinyapp.$inputValues[inputName] === null) {
          Shiny.setInputValue(inputName, [target.id]);
        } else {
          // add new element if never clicked
          if (graph.getElementState(target.id).length === 0 || graph.getElementState(target.id)[0] === undefined) {
            Shiny.shinyapp.$inputValues[inputName].push(target.id)
            Shiny.setInputValue(inputName, Shiny.shinyapp.$inputValues[inputName]);
          } else {
            // remove otherwise
            const newInput = Shiny.shinyapp.$inputValues[inputName].filter(function (el) {
              return el !== target.id;
            });
            Shiny.setInputValue(inputName, newInput);
          }
        }
      } else {
        // No multiclick, this is simple
        if (graph.getElementState(target.id).length === 0) {
          Shiny.setInputValue(inputName, [target.id]);
        } else {
          Shiny.setInputValue(inputName, null);
        }
      }
    })
  }
}

const setGraphEvents = (events, graph) => {
  const id = graph.options.container;

  for (let event of events) {
    graph.on(event, (e) => {
      // add/remove node should trigger fit to center
      // to avoid going out of bounds
      // TBD: causing some buif performance issues when animation is TRUE
      //graph.fitCenter();

      // Set an input to set that the graph is rendered
      if (event === GraphEvent.AFTER_RENDER) {
        Shiny.setInputValue(id + '-initialized', true);
        Shiny.setInputValue(id + '-state', preprocessGraphState(graph.getData()));
      }
      // Update the state any time there is a change.
      // Useful to serialise and restore. Only do it when initialized.
      if (Shiny.shinyapp.$inputValues[id + '-initialized']) {
        Shiny.setInputValue(id + '-state', preprocessGraphState(graph.getData()));
      }
    })
  }
}

const preserveElementsPosition = (graph) => {
  let oldPositions = {};

  const forEachElementType = (graph, callback) => {
    const data = graph.getData();
    if (data.nodes) callback(data.nodes, node => node.id);
    if (data.combos) callback(data.combos, combo => combo.id);
  };

  const storePositions = (elements, getId) => {
    elements.forEach(el => {
      try {
        graph.getElementRenderStyle(getId(el));
        const pos = graph.getElementPosition(getId(el));
        if (!(pos[0] === 0 && pos[1] === 0)) {
          oldPositions[getId(el)] = [pos[0], pos[1]];
        }
      } catch (e) {
        // Element not rendered, skip
      }
    });
  };

  const restorePositions = (elements, getId) => {
    elements.forEach(el => {
      const pos = oldPositions[getId(el)];
      if (!pos) return;
      graph.translateElementTo(getId(el), pos, false);
    });
  };

  graph.on(GraphEvent.BEFORE_LAYOUT, () => {
    forEachElementType(graph, storePositions);
  });

  graph.on(GraphEvent.AFTER_LAYOUT, () => {
    forEachElementType(graph, restorePositions);
  });
}

const captureMousePosition = (graph) => {
  const id = graph.options.container;
  const events = [CommonEvent.CONTEXT_MENU, CommonEvent.POINTER_UP];
  const handler = (e) => {
    if (e.type === 'contextmenu') {
      e.preventDefault();
    }
    Shiny.setInputValue(id + '-mouse_position', { x: e.canvas.x, y: e.canvas.y });
  };
  events.forEach(event => graph.on(event, handler));
}

export { setClickEvents, setGraphEvents, captureMousePosition, preserveElementsPosition, clearNodeSelectionStyling };
