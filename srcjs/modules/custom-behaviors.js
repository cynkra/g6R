import { CreateEdge, CanvasEvent, ComboEvent, CommonEvent, EdgeEvent, NodeEvent } from '@antv/g6';
import { uniqueId } from '@antv/util';
import { sendNotification, getPortConnections } from './utils';

const ASSIST_EDGE_ID = 'g6-create-edge-assist-edge-id';
const ASSIST_NODE_ID = 'g6-create-edge-assist-node-id';
const MIN_DRAG_DISTANCE = 10; // Minimum pixels to consider it a drag vs click

// Global flag to indicate edge creation is active (port was clicked)
window._g6EdgeCreationActive = false;

class CustomCreateEdge extends CreateEdge {
  bindEvents() {
    const graph = this.context.graph;
    const trigger = this.options.trigger;
    this.unbindEvents();

    if (trigger === 'click') {
      graph.on(NodeEvent.CLICK, this.customHandleCreateEdge.bind(this));
      graph.on(ComboEvent.CLICK, this.customHandleCreateEdge.bind(this));
      graph.on(CanvasEvent.CLICK, this.cancelEdge.bind(this));
      graph.on(EdgeEvent.CLICK, this.cancelEdge.bind(this));
    } else {
      graph.on(NodeEvent.POINTER_DOWN, this.customHandleCreateEdge.bind(this));
      graph.on(ComboEvent.POINTER_DOWN, this.customHandleCreateEdge.bind(this));
      // Bind to custom drop method
      graph.on(CommonEvent.POINTER_UP, this.customDrop.bind(this));
    }
    graph.on(CommonEvent.POINTER_MOVE, this.updateAssistEdge.bind(this));
  }

  customDrop(event) {
    const mode = this.context.graph.options.mode;
    const targetType = event.targetType;
    const sourcePort = this.sourcePort;
    const targetPort = event.originalTarget;

    if (['node', 'combo', 'canvas'].indexOf(targetType) !== -1 && this.source) {
      // Calculate distance from start position to detect click vs drag
      const startX = this.startX ?? 0;
      const startY = this.startY ?? 0;
      const endX = event.canvas?.x ?? event.client?.x ?? 0;
      const endY = event.canvas?.y ?? event.client?.y ?? 0;
      const dx = endX - startX;
      const dy = endY - startY;
      const distance = Math.sqrt(dx * dx + dy * dy);

      // If user didn't drag (just clicked), cancel without doing anything
      if (distance < MIN_DRAG_DISTANCE) {
        window._g6EdgeCreationActive = false;
        this.cancelEdge();
        return;
      }

      // Prevent edge to self
      if (event.target && event.target.id === this.source) {
        this.cancelEdge();
        return;
      }

      // If dropped on canvas, trigger add block dialog
      if (targetType === 'canvas') {
        this.customCreateEdge({
          target: { id: ASSIST_NODE_ID },
          sourcePort: sourcePort?.key,
          targetType: 'canvas'
        });
        this.cancelEdge();
        return;
      }

      // Check if the target node has ports
      const targetNode = this.context.graph.getElementData(event.target?.id);
      const targetHasPorts = targetNode && targetNode.style && Array.isArray(targetNode.style.ports) && targetNode.style.ports.length > 0;

      if (targetHasPorts) {
        // Must drop on a port
        if (
          !targetPort ||
          !targetPort.attributes ||
          !targetPort.attributes.class ||
          !targetPort.attributes.class.includes('port')
        ) {
          if (mode === "dev") {
            sendNotification(
              "Please release the connecting edge on a port.",
              "warning",
              5000
            );
          }
          this.cancelEdge();
          return;
        }

        // Prevent edge creation if both ports are of the same type
        if (
          sourcePort?.attributes?.type &&
          targetPort?.attributes?.type &&
          sourcePort.attributes.type === targetPort.attributes.type
        ) {
          if (mode === "dev") {
            sendNotification(
              "Edge creation failed: source and target ports must be of different types.",
              "warning",
              5000
            );
          }
          this.cancelEdge();
          return;
        }

        // Don't allow drop when target has reached max arity
        const portConnections = getPortConnections(this.context.graph, event.target?.id);
        const currentConnections = portConnections?.[targetPort.key] ?? 0;
        const targetArity = targetPort.attributes.arity === "Infinity"
          ? Infinity
          : targetPort.attributes.arity;
        if (currentConnections >= targetArity) {
          if (mode === "dev") {
            sendNotification(
              "Target port has reached its maximum arity, can't connect.",
              "warning",
              5000
            );
          }
          this.cancelEdge();
          return;
        }
      }
      // If here: either target has no ports, or all port checks passed
      this.customCreateEdge(event);
    } else {
      this.cancelEdge();
    }
  }

  customCreateEdge(event) {
    const { graph } = this.context;
    const { style, onFinish, onCreate } = this.options;
    const targetId = event.target?.id;
    if (targetId === undefined || this.source === undefined) return;

    const target = this.getSelectedNodeIDs([event.target.id])?.[0];
    const id = `${this.source}-${target}-${uniqueId()}`;

    const sourcePort = this.sourcePort;
    const targetPort = event.originalTarget;

    // Only check port visibility if ports exist
    if (sourcePort && targetPort && targetPort?.attributes?.visibility == 'hidden') {
      this.sourcePort = null;
      return;
    }

    // Only add port keys if ports exist
    const edgeStyle = Object.assign(
      {},
      style,
      sourcePort ? { sourcePort: sourcePort.key } : {},
      targetPort ? { targetPort: targetPort.key } : {}
    );

    const edgeData = onCreate({
      id,
      source: this.source,
      targetType: event.targetType,
      target,
      style: edgeStyle
    });
    if (edgeData) {
      graph.addEdgeData([edgeData]);
      onFinish(edgeData);
    }
    this.sourcePort = null;
    window._g6EdgeCreationActive = false;
    this.cancelEdge();
  }

  // JS conversion of handleCreateEdge
  async customHandleCreateEdge(event) {
    // Store start position to detect click vs drag
    this.startX = event.canvas.x;
    this.startY = event.canvas.y;

    const mode = this.context.graph.options.mode;
    const node = this.context.graph.getElementData(event.target?.id);

    // Only set sourcePort if node has ports
    let hasPorts = node && node.style && Array.isArray(node.style.ports) && node.style.ports.length > 0;
    if (hasPorts) {
      this.sourcePort = event.originalTarget;
      if (!this.sourcePort || !this.sourcePort.key) {
        return;
      }
      // Set global flag to indicate edge creation from port (disables drag_element)
      window._g6EdgeCreationActive = true;
      // Always recompute current connections for this port
      const portConnections = getPortConnections(this.context.graph, node.id);
      const currentConnections = portConnections[this.sourcePort.key] || 0;
      if (currentConnections >= this.sourcePort.arity) {
        if (mode === "dev") {
          sendNotification(
            "Current port has reached its maximum arity, can't drag.",
            "warning",
            5000
          );
        }
        return;
      }
    } else {
      this.sourcePort = null;
    }
    // If node has no ports, allow drag from node as usual

    if (!this.validate(event)) return;
    const { graph, canvas, batch, element } = this.context;
    const { style } = this.options;

    if (this.source) {
      this.customCreateEdge(event);
      await this.cancelEdge();
      return;
    }

    if (batch) batch.startBatch();
    if (canvas) canvas.setCursor('crosshair');
    const selectedIds = this.getSelectedNodeIDs([event.target.id]);
    this.source = selectedIds && selectedIds[0];

    const sourceNode = graph.getElementData(this.source);

    graph.addNodeData([
      {
        id: ASSIST_NODE_ID,
        style: {
          visibility: 'hidden',
          ports: [{ key: 'port-1', placement: [0.5, 0.5] }],
          x: sourceNode && sourceNode.style ? sourceNode.style.x : undefined,
          y: sourceNode && sourceNode.style ? sourceNode.style.y : undefined,
        },
      },
    ]);

    graph.addEdgeData([
      {
        id: ASSIST_EDGE_ID,
        source: this.source,
        target: ASSIST_NODE_ID,
        style: Object.assign(
          { pointerEvents: 'none' },
          hasPorts && this.sourcePort ? { sourcePort: this.sourcePort.key } : {},
          style
        ),
      },
    ]);
    if (element && element.draw) {
      const result = element.draw({ animation: false });
      if (result && result.finished) await result.finished;
    }
  }
}

export { CustomCreateEdge };
