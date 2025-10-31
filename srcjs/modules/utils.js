import {
  CanvasEvent,
  ComboEvent,
  EdgeEvent,
  NodeEvent,
  GraphEvent,
  CommonEvent,
} from '@antv/g6';

import { setClickEvents, setGraphEvents } from './events';
import { registerShinyHandlers } from './handlers';

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

const checkIds = (data) => {
  const nodeIds = [];
  if (data.nodes) {
    data.nodes.forEach((node) => {
      if (typeof node.id !== 'string') {
        node.id = node.id.toString();
      }
      if (node.combo !== undefined && typeof node.combo !== 'string') {
        node.combo = node.combo.toString();
      }
      node.id = `node-${node.id}`;
      node.combo = node.combo ? `combo-${node.combo}` : undefined;
      nodeIds.push(node.id);
    });
  }
  const edgesIds = [];
  if (data.edges) {
    data.edges.forEach((edge) => {
      if (edge.id === undefined) {
        edge.id = `${edge.source}-${edge.target}`;
      }
      if (typeof edge.source !== 'string') {
        edge.source = edge.source.toString();
      }
      if (typeof edge.target !== 'string') {
        edge.target = edge.target.toString();
      }
      edge.source = `node-${edge.source}`;
      edge.target = `node-${edge.target}`;
      edge.id = `edge-${edge.id}`;
      edgesIds.push(edge.id);
    });
  }
  const combosIds = [];
  if (data.combos) {
    data.combos.forEach((combo) => {
      if (typeof combo.id !== 'string') {
        combo.id = combo.id.toString();
      }
      combo.id = `combo-${combo.id}`;
      combosIds.push(combo.id);
    });
  }
  const allIds = nodeIds.concat(edgesIds, combosIds);
  const uniqueIds = new Set(allIds);
  if (allIds.length !== uniqueIds.size) {
    sendNotification('Cannot initialize/update graph. Duplicated IDs found.');
    throw new Error("Invalid graph data: execution aborted");
  }
  return data;
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

const setupGraph = (graph, el, widget) => {
  if (HTMLWidgets.shinyMode) {

    const clickEvents = [
      NodeEvent.CLICK,
      EdgeEvent.CLICK,
      ComboEvent.CLICK
    ]
    setClickEvents(clickEvents, graph, el);

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
    setGraphEvents(graphEvents, graph, el);

    // When click on canvas and target isn't node or edge or combo
    // we have to reset the Shiny selected-node or edge or combo
    graph.on(CanvasEvent.CLICK, (e) => {
      Shiny.setInputValue(el.id + '-selected_node', null);
      Shiny.setInputValue(el.id + '-selected_edge', null);
      Shiny.setInputValue(el.id + '-selected_combo', null);
    });

    // Recover the target of a right click event
    graph.on(CommonEvent.CONTEXT_MENU, (e) => {
      const { targetType, target } = e;
      // If target is canvas, id will be null.
      Shiny.setInputValue(el.id + '-contextmenu', { type: targetType, id: target.id })
    });

    registerShinyHandlers(graph, el);
  }

  graph.render();

  window.addEventListener('resize', () => {
    widget.resize();
  })
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

export { getBehavior, setupGraph, setupIcons, checkIds, sendNotification, resetOtherElementTypes };