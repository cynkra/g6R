import 'widgets';
import { EdgeEvent, Graph, GraphEvent, NodeEvent } from '@antv/g6';

HTMLWidgets.widget({

  name: 'g6',

  type: 'output',

  factory: function (el, width, height) {

    // TODO: define shared variables for this instance
    let graph;

    return {

      renderValue: function (x, id = el.id) {

        // TODO: code to render the widget, e.g.
        graph = new Graph({
          container: el.id,
          data: {
            nodes: [
              {
                id: 'node-1',
                combo: 'combo1',
                style: {
                  halo: false, // Whether to display the node halo
                  port: true,
                  ports: [
                    { key: 'top', placement: [0.5, 1], fill: '#7E92B5' },
                    { key: 'right', placement: [1, 0.5], fill: '#F4664A' },
                    { key: 'bottom', placement: [0.5, 0], fill: '#FFBE3A' },
                    { key: 'left', placement: [0, 0.5], fill: '#D580FF' },
                  ],
                  portR: 3,
                  portLineWidth: 1,
                  portStroke: '#fff',
                }
              },
              {
                id: 'node-2',
                style: {
                  x: 150,
                  y: 50,
                  badge: true, // Whether to display the badge
                  badges: [
                    { text: 'A', placement: 'right-top' },
                    { text: 'Important', placement: 'right' },
                    { text: 'Notice', placement: 'right-bottom' },
                  ],
                  badgePalette: ['#7E92B5', '#F4664A', '#FFBE3A'], // Badge background color //palette
                  badgeFontSize: 7, // Badge font size,
                },
                combo: 'combo1',
              },
            ],
            //edges: [{ source: 'node-1', target: 'node-2' }],
            combos: [
              {
                id: 'combo1',
                type: "rect",
                data: { label: 'Combo A' },
              }
            ]
          },
          edge: {
            style: {
              endArrow: true,
            },
          },
          node: {
            //type: 'html',
            style: {
              innerHTML: (d) => {
                //console.log(d);
                return `<div class="card" style="width: 18rem;">
                  <div class="card-header">
                    Featured
                  </div>
                  <div class="card-body">
                    <h5 class="card-title">Special title treatment</h5>
                    <p class="card-text">With supporting text below as a natural lead-in to //additional content.</p>
                    <a href="#" class="btn btn-primary">Go somewhere</a>
                  </div>
                  <div class="card-footer text-body-secondary">
                    2 days ago
                  </div>
                </div>`;
              },
            }
          },
          combo: {
            style: {
              padding: 2,
              // Bug: if not specified, the combo text appears white ...
              labelFill: '#000',
              labelText: (d) => d.data.label,
              labelPlacement: 'top',
            },
          },
          layout: {
            type: 'force',
          },
          theme: 'dark',
          // See https://g6.antv.antgroup.com/en/manual/behavior/overview#built-in-behaviors
          behaviors: [
            // drag-canvas and brush-select are incompatible
            {
              type: 'drag-canvas',
              trigger: {
                up: ['ArrowUp'],
                down: ['ArrowDown'],
                left: ['ArrowLeft'],
                right: ['ArrowRight'],
              },
              animation: {
                duration: 100, // Add smooth animation effect
              },
            },
            'zoom-canvas',
            {
              key: 'drag-element',
              type: 'drag-element'
            },
            'collapse-expand',
            {
              type: 'create-edge',
              key: 'create-edge',
              trigger: 'drag', // Behavior configuration, create edge by clicking
              style: {}, // Custom edge style
              enable: false,
              onFinish: (edge) => {
                // disable edge within a combo
                const targetType = graph.getElementType(edge.target);
                if (targetType !== 'node') {
                  graph.removeEdgeData([edge.id]);
                } else {

                  // If target node has ports, we assign the edge to a port
                  if (graph.getNodeData(edge.target).style.ports !== undefined) {
                    const targetNodePorts = graph.getNodeData(edge.target).style.ports.map((port) => {
                      return port.key
                    })
                    const reservedPorts = graph.getEdgeData().map((el) => {
                      if (el.target === edge.target) {
                        return el.style.targetPort
                      }
                    })
                    const availablePorts = targetNodePorts.filter(x => !reservedPorts.includes(x))
                    if (availablePorts.length) {
                      // Reserve the first available port
                      graph.updateEdgeData([{ id: edge.id, style: { targetPort: availablePorts[0] } }])

                    }
                  }

                  // Then we reset the behaviors so there is no conflict
                  graph.updateBehavior({
                    key: 'create-edge', // Specify the behavior to update
                    enable: false,
                  });
                  // Re-enable drag elements
                  graph.updateBehavior({ key: 'drag-element', enable: true });

                }
              }
            },
            {
              type: 'click-select',
              multiple: true
            },
            {
              type: 'brush-select',
              key: 'brush-select-1',
              immediately: true, // Elements are immediately selected as the box encloses them
              //trigger: ['shift', 'alt', 'control'], // Use multiple keys for selection
            },
            //This one is for adding / removing elements to/ from combo by drag and drop
            //{
            //  type: 'drag-element',
            //  dropEffect: 'link',
            //}
          ],
          plugins: [
            'minimap',
            // Bug: if enabled, triggers some js issue ...
            //{ type: 'grid-line', follow: true },
            {
              type: 'contextmenu',
              trigger: 'contextmenu',
              // Enable right-click menu only on nodes, by default all elements are enabled
              enable: (e) => {
                return e.targetType === 'node'
              },
              getItems: () => {
                return [
                  { name: 'Create edge', value: 'create_edge' },
                  { name: 'Remove node', value: 'remove_node' }
                ];
              },
              onClick: (value, target, current) => {
                if (value === 'create_edge') {
                  graph.updateBehavior({
                    key: 'create-edge', // Specify the behavior to update
                    enable: true,
                  });
                  // Select node
                  graph.setElementState(current.id, 'selected');
                  // Disable drag node as it is incompatible with edge creation
                  graph.updateBehavior({ key: 'drag-element', enable: false });
                } else if (value === 'remove_node') {
                  graph.removeNodeData([current.id]);
                  graph.draw();
                }
              }
            },
            {
              type: 'toolbar',
              position: 'top-left',
              onClick: (value) => {
                switch (value) {
                  case "delete":
                    const selectedNodes = graph.getElementDataByState('node', 'selected').map((node) => {
                      return node.id
                    });
                    graph.removeNodeData(selectedNodes);
                    break;
                  default:
                    break;
                }
                // Important: redraw;
                graph.draw();
              },
              getItems: () => {
                return [
                  { id: 'delete', value: 'delete' },
                ];
              },
            },
          ]
        });

        //graph.on(GraphEvent.AFTER_ELEMENT_CREATE, (e) => {
        //  console.log(e);
        //});

        if (HTMLWidgets.shinyMode) {
          graph.on(NodeEvent.CLICK, (e) => {
            // TBD set shiny input with el.id namespace
            const { target } = e; // Get the ID of the clicked node
            // Get node data
            const nodeData = graph.getNodeData(target.id);
            // Modify node state
            Shiny.setInputValue(el.id + '-selected_node', nodeData);
          })

          graph.on(EdgeEvent.CLICK, (e) => {
            // TBD set shiny input with el.id namespace
            const { target } = e; // Get the ID of the clicked node
            // Get node data
            const edgeData = graph.getEdgeData(target.id);
            // Modify node state
            Shiny.setInputValue(el.id + '-selected_edge', edgeData);
          })
        }

        graph.render();

      },

      resize: function (width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
