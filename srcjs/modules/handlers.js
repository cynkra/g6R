import { sendNotification } from './utils';

const tryCatchDev = (expr, mode = "prod") => {
  try {
    return expr();
  } catch (error) {
    // Try to extract caller info from stack trace
    let context = "";
    if (error && error.stack) {
      // Find the first stack line with 'Graph.' and a method name
      const stackLines = error.stack.split("\n");
      const graphLine = stackLines.find(line => /Graph\.\w+/.test(line));
      if (graphLine) {
        const match = graphLine.match(/Graph\.\w+/);
        if (match) context = match[0];
      }
    }
    const msg = context
      ? `[${context}] ${error.message || error}`
      : `${error.message || error}`;
    if (mode === "dev") sendNotification(msg, "error");
    // propagate error as normal: 
    // try is just here to show notification in dev mode
    throw error;
  }
}

const registerShinyHandlers = (graph, mode) => {
  const id = graph.options.container;

  // Update/remove/add nodes or combo or edges
  Shiny.addCustomMessageHandler(id + '_g6-data', (m) => {
    tryCatchDev(() => {
      // TBD: this became a bit ugly with the different actions and types
      // Maybe we can create separate handler for each action type for easier
      // maintenance.

      // Replace/update/add graph data
      if (m.type === "Data") {
        graph[`${m.action}Data`](m.data);
        graph.render();
        return;
      }

      if (m.action == 'set') {
        // Set state
        graph.setElementState(m.el);
        // TBD only filter selected elements
        const selected = Object.getOwnPropertyNames(m.el).map((key) => {
          if (m.el[key] === 'selected') return key;
        });
        if (selected.length > 0) {
          const inputId = `${id}-selected_${m.type.toLowerCase()}`;
          Shiny.setInputValue(inputId, selected);
        }
      } else {
        // Convert ids to string
        if (m.action === 'get' || m.action === 'remove') {
          if (Array.isArray(m.el)) {
            m.el = m.el.map((e) => e.toString());
          } else {
            m.el = m.el.toString();
          }
        } else {
          // For other actions like update or add ...
          m.el = m.el.map((e) => {
            e.id = e.id.toString();
            // Also process combo
            if (e.combo != null) {
              e.combo = e.combo.toString();
            }
            return e;
          });
        }

        // Call g6 method
        let res = graph[`${m.action}${m.type}Data`](m.el);

        // Set state input if method was get
        if (m.action === 'get') {
          if (res === undefined) return;

          // If we passed only one node
          if (!Array.isArray(res)) {
            res = [res];
          }
          res.map((r) => {
            Shiny.setInputValue(`${id}-${r.id}-state`, r);
          });
          return;
        }

        // Redraw and layout if needed
        graph.draw();
        if (m.action !== 'update') {
          graph.layout();
        }
      }
    }, mode);
  })

  // Canvas resize
  Shiny.addCustomMessageHandler(id + '_g6-canvas-resize', (m) => {
    tryCatchDev(() => graph.setSize(m.width, m.height), mode);
  })

  // Fit center
  Shiny.addCustomMessageHandler(id + '_g6-fit-center', (m) => {
    tryCatchDev(() => graph.fitCenter(m), mode);
  })

  // Focus/hide/show element
  Shiny.addCustomMessageHandler(id + '_g6-element-action', (m) => {
    tryCatchDev(() => graph[`${m.action}Element`](m.ids, m.animation), mode);
  })

  // Combo actions
  Shiny.addCustomMessageHandler(id + '_g6-combo-action', (m) => {
    tryCatchDev(() => {
      if (m.options === null) {
        graph[`${m.action}Element`](m.id);
      } else {
        graph[`${m.action}Element`](m.id, m.options);
      }
    }, mode)
  })

  // Set options
  Shiny.addCustomMessageHandler(id + '_g6-set-options', (m) => {
    tryCatchDev(() => {
      graph.setOptions(m);
      graph.draw();
    }, mode);
  })

  // This can also be done with setOptions but this is better to be more specific
  Shiny.addCustomMessageHandler(id + '_g6-set-theme', (m) => {
    tryCatchDev(() => {
      graph.setOptions(m.theme);
      graph.draw();
    }, mode);
  })

  // Update plugin
  Shiny.addCustomMessageHandler(id + '_g6-update-plugin', (m) => {
    tryCatchDev(() => {
      // Transform each eval member into a function call
      for (var i = 0; m.evals && i < m.evals.length; i++) {
        window.HTMLWidgets.evaluateStringMember(m.opts, m.evals[i]);
      }
      graph.updatePlugin(m.opts);
    }, mode);
  })

  // Append plugin
  Shiny.addCustomMessageHandler(id + "_g6-add-plugin", (m) => {
    tryCatchDev(() => {
      // TBD: support JS wrapped options
      graph.setPlugins(
        (currentPlugins) => {
          let plugins;
          if (currentPlugins.length) {
            plugins = currentPlugins.concat(m);
          } else {
            plugins = m;
          }
          return plugins;
        }
      );
      // Re-render the graph to draw the new plugin
      graph.render();
    }, mode);
  });

  // Update behavior
  Shiny.addCustomMessageHandler(id + '_g6-update-behavior', (m) => {
    tryCatchDev(() => {
      // Transform each eval member into a function call
      for (var i = 0; m.evals && i < m.evals.length; i++) {
        window.HTMLWidgets.evaluateStringMember(m.opts, m.evals[i]);
      }
      graph.updateBehavior(m.opts);
    }, mode);
  })
}

export { registerShinyHandlers, tryCatchDev };