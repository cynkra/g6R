import {
  CanvasEvent,
  ComboEvent,
  EdgeEvent,
  NodeEvent,
  GraphEvent,
  CommonEvent,
  Graph
} from '@antv/g6';

import { setClickEvents, setGraphEvents } from './events';
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
  if (data.nodes) {
    data.nodes.map((node) => {
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
  if (data.edges) {
    data.edges.map((edge) => {
      // Assign id to edge if not defined
      if (edge.id == null) {
        // If no ID is defined, we create one
        edge.id = `${edge.source}-${edge.target}`;
      }
      if (typeof edge.source !== 'string') {
        edge.source = edge.source.toString();
      }
      if (typeof edge.target !== 'string') {
        edge.target = edge.target.toString();
      }
      return edge.id
    });
  }
  if (data.combos) {
    data.combos.map((combo) => {
      // Convert ID to string if not already
      if (typeof combo.id !== 'string') {
        combo.id = combo.id.toString();
      }
      return combo.id
    });
  }
  return data;
}

const setupGraph = (graph, widget, mode) => {
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

    registerShinyHandlers(graph, mode);
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
      setupGraph(graph, widget, config.mode);
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

export { getBehavior, setupIcons, sendNotification, resetOtherElementTypes, loadAndInitGraph, getGraph };