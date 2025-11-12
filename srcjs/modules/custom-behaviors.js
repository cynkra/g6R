import { CreateEdge, CanvasEvent, ComboEvent, CommonEvent, EdgeEvent, NodeEvent } from '@antv/g6';
import { uniqueId } from '@antv/util';

const ASSIST_NODE_ID = 'g6-create-edge-assist-node-id';

class CustomCreateEdge extends CreateEdge {
  bindEvents() {
    const graph = this.context.graph;
    const trigger = this.options.trigger;
    this.unbindEvents();

    if (trigger === 'click') {
      graph.on(NodeEvent.CLICK, this.handleCreateEdge.bind(this));
      graph.on(ComboEvent.CLICK, this.handleCreateEdge.bind(this));
      graph.on(CanvasEvent.CLICK, this.cancelEdge.bind(this));
      graph.on(EdgeEvent.CLICK, this.cancelEdge.bind(this));
    } else {
      graph.on(NodeEvent.DRAG_START, this.handleCreateEdge.bind(this));
      graph.on(ComboEvent.DRAG_START, this.handleCreateEdge.bind(this));
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
      this.handleCreateEdge(event);
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

    const edgeData = onCreate({ id, source: this.source, targetType: event.targetType, target, style });
    if (edgeData) {
      graph.addEdgeData([edgeData]);
      onFinish(edgeData);
    }
  };
}

export { CustomCreateEdge };

