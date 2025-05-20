import { getBehavior } from "./utils";
import {
  ComboEvent,
  EdgeEvent,
  NodeEvent
} from '@antv/g6';

const setClickEvents = (events, graph, el) => {
  // Loop over events

  for (let event of events) {
    graph.on(event, (e) => {
      const inputName = `${el.id}-selected_${e.targetType}`;

      let getFunc;
      switch (event) {
        case NodeEvent.CLICK:
          getFunc = graph.getNodeData;
          break;
        case EdgeEvent.CLICK:
          getFunc = graph.getEdgeData;
          break;
        case ComboEvent.CLICK:
          getFunc = graph.getEdgeData;
          break;
        default:
          break;
      }

      // TBD set shiny input with el.id namespace
      const { target } = e; // Get the ID of the clicked node
      // Get node data
      const nodeData = graph.getNodeData(target.id);
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

export { setClickEvents };