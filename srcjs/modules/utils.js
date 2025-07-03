import {
  CanvasEvent,
  ComboEvent,
  EdgeEvent,
  NodeEvent,
  GraphEvent
} from '@antv/g6';

import { setClickEvents, setGraphEvents } from './events';
import { registerShinyHandlers } from './handlers';

const sendNotification = (message, type = "error", duration = null) => {
  if (HTMLWidgets.shinyMode) {
    Shiny.setInputValue('g6-notification', {
      message: message,
      type: type,
      duration: duration
    });
  } else {
    alert(message)
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
      if (node.combo !== undefined && typeof node.combo !== 'string') {
        node.combo = node.combo.toString();
      }
      return node.id
    });
  }
  let edgesIds = [];
  if (data.edges) {
    edgesIds = data.edges.map((edge) => {
      // Assign id to edge if not defined
      if (edge.id === undefined) {
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

const getBehavior = (behaviors, value) => {
  return behaviors.filter((behavior) => {
    if (typeof behavior === 'string') return behavior === value;
    return behavior.type === value;
  });
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

export { getBehavior, setupGraph, setupIcons, checkIds, sendNotification };