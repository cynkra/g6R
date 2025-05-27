const registerShinyHandlers = (graph, el) => {
  // Update/remove/add nodes or combo or edges
  Shiny.addCustomMessageHandler(el.id + '_g6-data', (m) => {
    try {
      // TBD: check if nodes data are also updated
      // In case of selection, we have to update the related Shiny input
      if (m.action == 'set') {
        graph.setElementState(m.el);
        // TBD only filter selected elements
        const selected = Object.getOwnPropertyNames(m.el).map((key) => {
          if (m.el[key] === 'selected') return key;
        });
        if (selected.length > 0) {
          const inputId = `${el.id}-selected_${m.type.toLowerCase()}`;
          Shiny.setInputValue(inputId, selected);
        }
      } else {
        // store in case we need to get the state
        let res = graph[`${m.action}${m.type}Data`](m.el);
        if (m.action === 'get') {
          if (res === undefined) return;
          if (!Array.isArray(res)) {
            res = [res];
          }
          res.map((r) => {
            Shiny.setInputValue(`${el.id}-${r.id}-state`, r);
          });
          return;
        }
        graph.draw();
        if (m.action !== 'update') {
          graph.layout();
        }
      }
    } catch (error) {
      Shiny.notifications.show({ html: error, type: 'error' })
    }
  })

  // Canvas resize
  Shiny.addCustomMessageHandler(el.id + '_g6-canvas-resize', (m) => {
    try {
      graph.setSize(m.width, m.height);
    } catch (error) {
      Shiny.notifications.show({ html: error, type: 'error' })
    }
  })

  // Fit center
  Shiny.addCustomMessageHandler(el.id + '_g6-fit-center', (m) => {
    try {
      graph.fitCenter(m);
    } catch (error) {
      Shiny.notifications.show({ html: error, type: 'error' })
    }
  })

  // Focus/hide/show element
  Shiny.addCustomMessageHandler(el.id + '_g6-element-action', (m) => {
    try {
      graph[`${m.action}Element`](m.ids, m.animation);
    } catch (error) {
      Shiny.notifications.show({ html: error, type: 'error' })
    }
  })

  // Combo actions
  Shiny.addCustomMessageHandler(el.id + '_g6-combo-action', (m) => {
    try {
      if (m.options === null) {
        graph[`${m.action}Element`](m.id);
      } else {
        graph[`${m.action}Element`](m.id, m.options);
      }
    } catch (error) {
      Shiny.notifications.show({ html: error, type: 'error' })
    }
  })

  // Set options
  Shiny.addCustomMessageHandler(el.id + '_g6-set-options', (m) => {
    try {
      graph.setOptions(m);
      graph.draw();
    } catch (error) {
      Shiny.notifications.show({ html: error, type: 'error' })
    }
  })

  // Update plugin
  Shiny.addCustomMessageHandler(el.id + '_g6-update-plugin', (m) => {
    try {
      graph.updatePlugin(m);
    } catch (error) {
      Shiny.notifications.show({ html: error, type: 'error' })
    }
  })

  // Append plugin
  Shiny.addCustomMessageHandler(el.id + "_g6-add-plugin", (m) => {
    try {
      graph.setPlugins((currentPlugins) => {
        m.map((newPlugin) => {
          currentPlugins.push(newPlugin)
        })
        return currentPlugins
      });
    } catch (error) {
      Shiny.notifications.show({ html: error, type: 'error' })
    }
  });

  // Update behavior
  Shiny.addCustomMessageHandler(el.id + '_g6-update-behavior', (m) => {
    try {
      graph.updateBehavior(m);
    } catch (error) {
      Shiny.notifications.show({ html: error, type: 'error' })
    }
  })
}

export { registerShinyHandlers };