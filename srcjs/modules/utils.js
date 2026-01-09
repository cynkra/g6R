import {
  CanvasEvent,
  ComboEvent,
  EdgeEvent,
  NodeEvent,
  GraphEvent,
  CommonEvent,
  Graph
} from '@antv/g6';

import { setClickEvents, setGraphEvents, captureMousePosition, preserveElementsPosition } from './events';
import { tryCatchDev, registerShinyHandlers } from './handlers';

const sendNotification = (message, type = "error", duration = null) => {
  if (HTMLWidgets.shinyMode) {
    Shiny.notifications.show({
      html: message,
      type: type,
      duration: duration
    });
  } else {
    alert(message)
  }
}

const getBehavior = (behaviors, value) => {
  return behaviors.filter((behavior) => {
    if (typeof behavior === 'string') return behavior === value;
    return behavior.type === value;
  });
}

// Extract reset function for better code organization
const resetOtherElementTypes = (elementId, targetType) => {
  const resetMap = {
    'edge': ['node', 'combo'],
    'node': ['edge', 'combo'],
    'combo': ['node', 'edge']
  };

  const typesToReset = resetMap[targetType];
  if (typesToReset) {
    typesToReset.forEach(type => {
      Shiny.setInputValue(`${elementId}-selected_${type}`, null);
    });
  }
}

const checkIds = (data) => {
  let nodeIds = [];
  if (data.nodes) {
    nodeIds = data.nodes.map((node) => {
      // Convert ID to string if not already
      if (typeof node.id !== 'string') {
        node.id = node.id.toString();
      }
      if (node.combo != null && typeof node.combo !== 'string') {
        node.combo = node.combo.toString();
      }
      return node.id
    });
  }
  let edgesIds = [];
  if (data.edges) {
    edgesIds = data.edges.map((edge) => {
      if (typeof edge.source !== 'string') {
        edge.source = edge.source.toString();
      }
      if (typeof edge.target !== 'string') {
        edge.target = edge.target.toString();
      }
      // needed if data are passed from JSON
      // as g6_edge will be bypassed in that case
      if (edge.id == null) {
        edge.id = `${edge.source}-${edge.target}`;
      }
      return edge.id
    });
  }
  let combosIds = [];
  if (data.combos) {
    combosIds = data.combos.map((combo) => {
      // Convert ID to string if not already
      if (typeof combo.id !== 'string') {
        combo.id = combo.id.toString();
      }
      return combo.id
    });
  }
  const allIds = nodeIds.concat(edgesIds).concat(combosIds);
  const uniqueIds = new Set(allIds);
  if (allIds.length !== uniqueIds.size) {
    sendNotification('Cannot initialize graph. Duplicated IDs found.')
    throw new Error("Invalid graph data: execution aborted");
  } else {
    return (data)
  }
}

// count initial connections for each port of this node
const getPortConnections = (graph, nodeId) => {
  const edges = graph.getEdgeData();
  const portConnections = {};
  edges.forEach(edge => {
    if (edge.style && edge.style.sourcePort && edge.source === nodeId) {
      portConnections[edge.style.sourcePort] = (portConnections[edge.style.sourcePort] || 0) + 1;
    }
    if (edge.style && edge.style.targetPort && edge.target === nodeId) {
      portConnections[edge.style.targetPort] = (portConnections[edge.style.targetPort] || 0) + 1;
    }
  });
  return portConnections;
}

const setupGraph = (graph, widget, config) => {
  const id = graph.options.container;

  if (HTMLWidgets.shinyMode) {

    const clickEvents = [
      NodeEvent.CLICK,
      EdgeEvent.CLICK,
      ComboEvent.CLICK
    ]
    setClickEvents(clickEvents, graph);

    // Is this enough? :)
    const graphEvents = [
      GraphEvent.AFTER_ELEMENT_CREATE,
      GraphEvent.AFTER_ELEMENT_DESTROY,
      GraphEvent.AFTER_DRAW,
      GraphEvent.AFTER_LAYOUT,
      GraphEvent.AFTER_ANIMATE,
      GraphEvent.AFTER_RENDER,
      ComboEvent.DROP,
      CanvasEvent.DROP
    ]
    setGraphEvents(graphEvents, graph);

    // When click on canvas and target isn't node or edge or combo
    // we have to reset the Shiny selected-node or edge or combo
    graph.on(CanvasEvent.CLICK, (e) => {
      Shiny.setInputValue(id + '-selected_node', null);
      Shiny.setInputValue(id + '-selected_edge', null);
      Shiny.setInputValue(id + '-selected_combo', null);
    });

    // Recover the target of a right click event
    graph.on(CommonEvent.CONTEXT_MENU, (e) => {
      const { targetType, target } = e;
      // If target is canvas, id will be null.
      Shiny.setInputValue(id + '-contextmenu', { type: targetType, id: target.id })
    });

    //graph.on(CommonEvent.POINTER_DOWN, (e) => {
    //  console.log(e);
    //})

    graph.on('node:pointerdown', function (e) {
      if (e.originalTarget && e.originalTarget.key) {
        console.log(e.originalTarget);
      }
    });

    // Capture mouse position for clever placement of
    // new nodes
    captureMousePosition(graph);

    // TO DO: check why animation breaks position preservation ...
    if (!config.animation && config.preservePosition) {
      preserveElementsPosition(graph);
    }

    registerShinyHandlers(graph, config.mode);
  }

  graph.render();

  window.addEventListener('resize', () => {
    widget.resize();
  })
}

let graph = null;

const loadAndInitGraph = (config, widget) => {
  tryCatchDev(() => {
    const initialize = (data) => {
      config.data = checkIds(data);
      graph = new Graph(config);
      setupGraph(graph, widget, config);
    };

    if (config.jsonUrl !== null) {
      fetch(config.jsonUrl)
        .then((res) => res.json())
        .then((data) => {
          // You can add checks here if needed
          initialize(data);
        })
        .catch((err) => {
          if (config.mode === "dev") sendNotification(`Failed to fetch JSON: ${err}`, "error");
          throw err;
        });
    } else {
      // You can add checks here if needed
      initialize(config.data);
    }
  }, config.mode);
}

// Getter for graph
const getGraph = () => graph;

const setupIcons = (url) => {
  // https://at.alicdn.com/t/project/2678727/caef142c-804a-4a2f-a914-ae82666a31ee.html?spm=a313x.7781069.1998910419.35
  const iconURLs = [];
  iconURLs.push(url);

  iconURLs.map((url) => {
    let iconFont = document.createElement('script');
    iconFont.src = url;
    document.head.appendChild(iconFont);
  })
}

export { getBehavior, setupIcons, sendNotification, resetOtherElementTypes, loadAndInitGraph, getGraph, getPortConnections };