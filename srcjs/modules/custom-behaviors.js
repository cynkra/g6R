import { CreateEdge, CanvasEvent, ComboEvent, CommonEvent, EdgeEvent, NodeEvent } from '@antv/g6';
import { uniqueId } from '@antv/util';

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
    const targetType = event.targetType;
    if (['node', 'combo', 'canvas'].indexOf(targetType) !== -1 && this.source) {
      // Prevent edge to self
      if (event.target && event.target.id === this.source) {
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
      this.customHandleCreateEdge(event);
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

    // Capture target port key: that does not work all the time ...
    const targetPort = event.originalTarget && event.originalTarget.key ? event.originalTarget.key : null;

    // Add sourcePort and targetPort into style
    const edgeStyle = Object.assign({}, style, {
      sourcePort: this.sourcePort,
      targetPort: targetPort
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
    }
    // Reset sourcePort after edge creation
    this.sourcePort = null;
  };

  // JS conversion of handleCreateEdge
  async customHandleCreateEdge(event) {
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

    // Capture source port key: this works all the time ...
    this.sourcePort = event.originalTarget && event.originalTarget.key ? event.originalTarget.key : null;

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
          // added sourcePort so that the edge does not change
          // port when we move the cursor around.
          { pointerEvents: 'none', sourcePort: this.sourcePort },
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

