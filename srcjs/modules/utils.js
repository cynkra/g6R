import { guardLayout } from './spanning-tree-layout';
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
import { scopeGraphConfig } from './graph-scope';

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

// Converts { id: {...}, ... } to [{...}, ...] recursively for nodes, edges, combos
// Does the opposite of preprocessGraphState
const normalizeGraphState = (state) => {
  const objectToArray = (obj, portKey = false) => {
    if (!obj) return [];
    return Object.values(obj).map(item => {
      // Recursively handle ports if present
      if (item.style && item.style.ports && !Array.isArray(item.style.ports)) {
        item.style.ports = objectToArray(item.style.ports, true);
      }
      return item;
    });
  };

  const result = {};
  if (state.nodes && !Array.isArray(state.nodes)) {
    result.nodes = objectToArray(state.nodes);
  } else if (state.nodes) {
    result.nodes = state.nodes;
  }
  if (state.edges && !Array.isArray(state.edges)) {
    result.edges = objectToArray(state.edges);
  } else if (state.edges) {
    result.edges = state.edges;
  }
  if (state.combos && !Array.isArray(state.combos)) {
    result.combos = objectToArray(state.combos);
  } else if (state.combos) {
    result.combos = state.combos;
  }
  if (result.nodes) result.nodes = withTreeDepth(result.nodes);
  return result;
};

// Nodes that carry `children` form a tree, and some tree layouts (fishbone)
// read each node's `depth`, which G6's own treeToGraphData() would have set.
// Fill it in from the tree when it is missing.
const withTreeDepth = (nodes) => {
  const hasTree = nodes.some((n) => Array.isArray(n.children) && n.children.length);
  if (!hasTree) return nodes;

  const byId = new Map(nodes.map((n) => [String(n.id), n]));
  const isChild = new Set();
  nodes.forEach((n) => (n.children || []).forEach((c) => isChild.add(String(c))));

  const depth = new Map();
  const queue = nodes.filter((n) => !isChild.has(String(n.id))).map((n) => [String(n.id), 0]);
  while (queue.length) {
    const [id, d] = queue.shift();
    if (depth.has(id)) continue;
    depth.set(id, d);
    ((byId.get(id) || {}).children || []).forEach((c) => queue.push([String(c), d + 1]));
  }

  return nodes.map((n) => (n.depth == null && depth.has(String(n.id)) ? { ...n, depth: depth.get(String(n.id)) } : n));
};

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
      // Prefix port keys
      if (node.style && Array.isArray(node.style.ports)) {
        node.style.ports.forEach(port => {
          if (!port.key.startsWith(node.id + "-")) {
            port.key = `${node.id}-${port.key}`;
          }
        });
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
      // Prefix sourcePort and targetPort
      if (edge.style) {
        if (edge.style.sourcePort && edge.source) {
          if (!edge.style.sourcePort.startsWith(edge.source + "-")) {
            edge.style.sourcePort = `${edge.source}-${edge.style.sourcePort}`;
          }
        }
        if (edge.style.targetPort && edge.target) {
          if (!edge.style.targetPort.startsWith(edge.target + "-")) {
            edge.style.targetPort = `${edge.target}-${edge.style.targetPort}`;
          }
        }
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
  // Check for duplicate IDs
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

    // Capture mouse position for clever placement of
    // new nodes
    captureMousePosition(graph);

    // TO DO: check why animation breaks position preservation ...
    if (!config.animation && config.preservePosition) {
      preserveElementsPosition(graph);
    }

    registerShinyHandlers(graph, config.mode, config.directed);
  }

  graph.render();

  // Use ResizeObserver to detect container size changes (e.g. from
  // DOM reparenting, panel resize, CSS visibility toggles) instead
  // of relying solely on window resize events.
  const containerEl = document.getElementById(graph.options.container);
  if (containerEl) {
    const ro = new ResizeObserver(() => {
      widget.resize();
    });
    ro.observe(containerEl);
  }
  // Keep window resize as fallback for cases where the container
  // itself doesn't change size but its contents need reflowing.
  window.addEventListener('resize', () => {
    widget.resize();
  })
}

// `onGraph` hands the graph back to the widget instance that asked for it:
// several widgets can share a page, and each must keep its own.
const loadAndInitGraph = (config, widget, onGraph) => {
  tryCatchDev(() => {
    const initialize = (data) => {
      config.data = checkIds(normalizeGraphState(data));
      // Plugin and behavior callbacks may name `graph`; give them this one.
      const provideGraph = scopeGraphConfig(config);
      const graph = new Graph(config);
      provideGraph(graph);
      guardLayout(graph, config.container);
      if (onGraph) onGraph(graph);
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

export { getBehavior, setupIcons, sendNotification, resetOtherElementTypes, loadAndInitGraph, getPortConnections };