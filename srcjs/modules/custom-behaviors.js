import { CreateEdge, CanvasEvent, ComboEvent, CommonEvent, EdgeEvent, NodeEvent } from '@antv/g6';
import { uniqueId } from '@antv/util';
import { sendNotification, getPortConnections } from './utils';

const ASSIST_EDGE_ID = 'g6-create-edge-assist-edge-id';
const ASSIST_NODE_ID = 'g6-create-edge-assist-node-id';

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
      // Prevent edge to self
      if (event.target && event.target.id === this.source) {
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

      // If dropped on canvas, create edge to ASSIST_NODE_ID
      if (targetType === 'canvas') {
        this.customCreateEdge({
          target: { id: ASSIST_NODE_ID },
          targetType: 'canvas'
        });
        this.cancelEdge();
        return;
      }
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

    // prevent edge creation if source port is hidden
    if (targetPort?.attributes.visibility == 'hidden') {
      this.sourcePort = null;
      return
    }

    const edgeStyle = Object.assign({}, style, {
      sourcePort: sourcePort?.key,
      targetPort: targetPort?.key
    });

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

      if (sourcePort && targetPort) {
        sourcePort.connections = (sourcePort.connections || 0) + 1;
      }
      if (targetPort) {
        targetPort.connections = (targetPort.connections || 0) + 1;
      }
    }
    this.sourcePort = null;
  }

  // JS conversion of handleCreateEdge
  async customHandleCreateEdge(event) {
    const mode = this.context.graph.options.mode;
    const node = this.context.graph.getElementData(event.target?.id);
    this.sourcePort = event.originalTarget;

    if (node && node.style && Array.isArray(node.style.ports) && node.style.ports.length > 0) {
      if (!this.sourcePort.key) {
        return;
      }
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
          { pointerEvents: 'none', sourcePort: this.sourcePort.key },
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
