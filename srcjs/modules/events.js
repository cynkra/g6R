import { getBehavior, resetOtherElementTypes } from "./utils";
import { GraphEvent, CanvasEvent } from '@antv/g6';

// Since users are not supposed to prefix elements IDs by their
// type, we have to save the state without prefixes too. This
// does not modify original data!
const unprefixIds = (data) => {
  // Deep copy to avoid mutating the original
  const dat = JSON.parse(JSON.stringify(data));
  if (dat.nodes) {
    dat.nodes.forEach((node) => {
      node.id = node.id.replace(/^node-/, "");
      if (node.combo) node.combo = node.combo.replace(/^combo-/, "");
    });
  }
  if (dat.edges) {
    dat.edges.forEach((edge) => {
      edge.id = edge.id.replace(/^edge-/, "");
      edge.source = edge.source.replace(/^node-/, "");
      edge.target = edge.target.replace(/^node-/, "");
    });
  }
  if (dat.combos) {
    dat.combos.forEach((combo) => {
      combo.id = combo.id.replace(/^combo-/, "");
    });
  }
  return dat;
}

const setClickEvents = (events, graph, el) => {
  // Loop over events

  for (let event of events) {
    graph.on(event, (e) => {
      const { target } = e; // Get the ID of the clicked node
      const prefix = new RegExp(`^${target.type}-`, "i");
      const inputName = `${el.id}-selected_${target.type}`;
      const clickSelect = getBehavior(graph.getBehaviors(), "click-select");
      if (!clickSelect.length) return;
      const isMultiple = clickSelect[0].multiple;

      if (!e.shiftKey) {
        resetOtherElementTypes(el.id, target.type);
      }

      // If multiclick is allowed ...
      if (isMultiple && e.shiftKey) {
        // If initial state, we set an array with the current value
        if (Shiny.shinyapp.$inputValues[inputName] === undefined || Shiny.shinyapp.$inputValues[inputName] === null) {
          Shiny.setInputValue(inputName, [target.id.replace(prefix, "")]);
        } else {
          // add new element if never clicked
          if (graph.getElementState(target.id).length === 0 || graph.getElementState(target.id)[0] === undefined) {
            Shiny.shinyapp.$inputValues[inputName].push(target.id.replace(prefix, ""))
            Shiny.setInputValue(inputName, Shiny.shinyapp.$inputValues[inputName]);
          } else {
            // remove otherwise
            const newInput = Shiny.shinyapp.$inputValues[inputName].filter(function (el) {
              return el !== target.id.replace(prefix, "");
            });
            Shiny.setInputValue(inputName, newInput);
          }
        }
      } else {
        // No multiclick, this is simple
        if (graph.getElementState(target.id).length === 0) {
          Shiny.setInputValue(inputName, [target.id.replace(prefix, "")]);
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
        Shiny.setInputValue(el.id + '-state', unprefixIds(graph.getData()));
      }
      // Update the state any time there is a change.
      // Useful to serialise and restore. Only do it when initialized.
      if (Shiny.shinyapp.$inputValues[el.id + '-initialized']) {
        Shiny.setInputValue(el.id + '-state', unprefixIds(graph.getData()));
      }

      // Canvas drop
      if (event === CanvasEvent.DROP) {
        Shiny.setInputValue(el.id + '-canvas_drop', e.targetType);
      }
    })
  }
}

export { setClickEvents, setGraphEvents };