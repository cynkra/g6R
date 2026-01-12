import { sendNotification, getPortConnections } from './utils';

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

const updateNodePorts = (graph, ids, ops) => {
  const nodeData = graph.getNodeData();
  const edgeData = graph.getEdgeData();
  const updates = [];
  let removedPortKeys = new Set();

  ids.forEach(nid => {
    const node = nodeData.find(n => n.id === nid);
    if (!node) return;
    let style = node.style ? { ...node.style } : {};
    let ports = Array.isArray(style.ports) ? [...style.ports] : [];

    // Node-specific operations
    const nodeOps = ops[nid] || {};

    // Remove ports (always prefix)
    if (nodeOps.remove) {
      const keysToRemove = nodeOps.remove.map(k => k.startsWith(nid + "-") ? k : `${nid}-${k}`);
      ports = ports.filter(port => !keysToRemove.includes(port.key));
      keysToRemove.forEach(k => removedPortKeys.add(k));
    }

    // Add ports (always prefix)
    if (nodeOps.add) {
      const portsToAdd = nodeOps.add.map(port => ({
        ...port,
        key: port.key.startsWith(nid + "-") ? port.key : `${nid}-${port.key}`
      }));
      ports = ports.concat(portsToAdd);
    }

    // Update ports (always prefix)
    if (nodeOps.update) {
      nodeOps.update.forEach(updateObj => {
        const updateKey = updateObj.key.startsWith(nid + "-") ? updateObj.key : `${nid}-${updateObj.key}`;
        const idx = ports.findIndex(port => port.key === updateKey);
        if (idx !== -1) {
          ports[idx] = { ...ports[idx], ...updateObj, key: updateKey };
        }
      });
    }

    style.ports = ports;
    updates.push({ id: nid, style });
  });

  if (updates.length > 0) {
    graph.updateNodeData(updates);
    graph.draw();
  }

  // Remove edges connected to removed ports (prefix by node id)
  if (removedPortKeys.size > 0) {
    const edgeIdsToRemove = edgeData
      .filter(edge => {
        const srcPort = edge.style?.sourcePort;
        const tgtPort = edge.style?.targetPort;
        return (
          (srcPort && removedPortKeys.has(srcPort)) ||
          (tgtPort && removedPortKeys.has(tgtPort))
        );
      })
      .map(edge => edge.id);

    if (edgeIdsToRemove.length > 0) {
      graph.removeEdgeData(edgeIdsToRemove);
      graph.draw();
    }
  }
};

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
            if (e.source != null && typeof e.source !== 'string') {
              e.source = e.source.toString();
            }
            if (e.target != null && typeof e.target !== 'string') {
              e.target = e.target.toString();
            }
            // Also process combo
            if (e.combo != null && typeof e.combo !== 'string') {
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

        // draw only (no layout called here)
        graph.draw();
        // Layout if needed
        if (m.layout) {
          graph.layout();
        }
      }
    }, mode);
  })

  Shiny.addCustomMessageHandler(id + '_g6-update-ports', (m) => {
    // m.ops: { add, remove, update } see R API
    // m.ids: array of node ids
    updateNodePorts(graph, m.ids, m.ops);
  })

  // Layout update and execution
  Shiny.addCustomMessageHandler(id + '_g6-update-layout', (m) => {
    tryCatchDev(() => {
      graph.setLayout((prevLayout) => {
        if ('nodeOrder' in prevLayout) {
          return prevLayout;
        }
        return {
          ...prevLayout,
          ...m
        }
      });
      graph.layout();
    })
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
      graph.render();
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