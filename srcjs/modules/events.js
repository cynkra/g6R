import { getBehavior } from "./utils";
import {
  GraphEvent
} from '@antv/g6';

const setClickEvents = (events, graph, el) => {
  // Loop over events

  for (let event of events) {
    graph.on(event, (e) => {
      const inputName = `${el.id}-selected_${e.targetType}`;
      // TBD set shiny input with el.id namespace
      const { target } = e; // Get the ID of the clicked node
      const clickSelect = getBehavior(graph.getBehaviors(), "click-select");
      const isMultiple = clickSelect[0].multiple;

      // If multiclick is allowed ...
      if (isMultiple && e.shiftKey) {
        // If initial state, we set an array with the current value
        if (Shiny.shinyapp.$inputValues[inputName] === undefined) {
          Shiny.setInputValue(inputName, [target.id]);
        } else {
          // add new element if never clicked
          if (graph.getElementState(target.id).length === 0) {
            Shiny.setInputValue(inputName, [Shiny.shinyapp.$inputValues[inputName], target.id])
          } else {
            // remove otherwise
            const newInput = Shiny.shinyapp.$inputValues[inputName].filter(function (el) {
              return el !== target.id;
            });
            Shiny.setInputValue(inputName, newInput)
          }
        }
      } else {
        // No multiclick, this is simple
        if (graph.getElementState(target.id).length === 0) {
          Shiny.setInputValue(inputName, target.id)
        } else {
          Shiny.setInputValue(inputName, null);
        }
      }
    })
  }
}

const setGraphEvents = (events, graph, el) => {
  for (let event of events) {
    graph.on(event, (e) => {
      // add/remove node should trigger fit to center
      // to avoid going out of bounds
      // TBD: causing some buif performance issues when animation is TRUE
      //graph.fitCenter();

      // Set an input to set that the graph is rendered
      if (event === GraphEvent.AFTER_RENDER) {
        Shiny.setInputValue(el.id + '-initialized', true);
      }
      // Update the state any time there is a change.
      // Useful to serialise and restore. Only do it when initialized.
      if (Shiny.shinyapp.$inputValues[el.id + '-initialized']) {
        Shiny.setInputValue(el.id + '-state', graph.getData())
      }
    })
  }
}

export { setClickEvents, setGraphEvents };