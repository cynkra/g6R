import {
  CanvasEvent,
  ComboEvent,
  EdgeEvent,
  NodeEvent,
  GraphEvent
} from '@antv/g6';

import { setClickEvents, setGraphEvents } from './events';
import { registerShinyHandlers } from './handlers';

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

export { getBehavior, setupGraph, setupIcons };