import { getBehavior, resetOtherElementTypes } from "./utils";
import { GraphEvent, CanvasEvent, CommonEvent } from '@antv/g6';

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
        Shiny.setInputValue(id + '-state', graph.getData());
      }
      // Update the state any time there is a change.
      // Useful to serialise and restore. Only do it when initialized.
      if (Shiny.shinyapp.$inputValues[id + '-initialized']) {
        Shiny.setInputValue(id + '-state', graph.getData());
      }
    })
  }
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

export { setClickEvents, setGraphEvents, captureMousePosition };