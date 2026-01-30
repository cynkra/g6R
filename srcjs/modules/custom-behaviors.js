import { CreateEdge, CanvasEvent, ComboEvent, CommonEvent, EdgeEvent, NodeEvent } from '@antv/g6';
import { uniqueId } from '@antv/util';
import { sendNotification, getPortConnections } from './utils';

const ASSIST_EDGE_ID = 'g6-create-edge-assist-edge-id';
const ASSIST_NODE_ID = 'g6-create-edge-assist-node-id';
const MIN_DRAG_DISTANCE = 10;

class CustomCreateEdge extends CreateEdge {
  isCreatingEdge = false;
  snappedPort = null;
  snappedPortOriginalStyle = null;
  _resetSnappedPortTimeout = null;
  _processingPointerDown = false;
  _processingPointerUp = false;

  validate(event) {
    return true;
  }

  async cancelEdge() {
    const { graph } = this.context;
    this.isCreatingEdge = false;
    this.source = undefined;
    this.sourcePort = null;
    // Re-enable drag-element behavior
    try {
      graph.updateBehavior({ key: 'drag-element', enable: true });
    } catch (e) { }
    try {
      graph.removeEdgeData([ASSIST_EDGE_ID]);
      graph.removeNodeData([ASSIST_NODE_ID]);
      await graph.draw();
    } catch (e) { }
  }

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
      graph.on(CommonEvent.POINTER_UP, this.customDrop.bind(this));
    }
    graph.on(CommonEvent.POINTER_MOVE, this.customUpdateAssistEdge.bind(this));
  }

  isValidTargetPort(targetPort, targetNodeId) {
    if (!targetPort || !targetPort.key) return false;
    if (!this.sourcePort) return false;
    if (!targetPort.attributes?.class?.includes('port')) return false;
    if (targetNodeId === this.source) return false;
    if (this.sourcePort.attributes?.type === targetPort.attributes?.type) return false;

    const portConnections = getPortConnections(this.context.graph, targetNodeId);
    const currentConnections = portConnections?.[targetPort.key] ?? 0;
    const targetArity = targetPort.attributes?.arity === "Infinity"
      ? Infinity
      : (targetPort.attributes?.arity || 1);
    if (currentConnections >= targetArity) return false;

    return true;
  }

  resetSnappedPort() {
    try {
      if (this.snappedPort && this.snappedPortOriginalStyle) {
        this.snappedPort.attr({
          r: this.snappedPortOriginalStyle.r,
          stroke: this.snappedPortOriginalStyle.stroke,
          lineWidth: this.snappedPortOriginalStyle.lineWidth,
          shadowBlur: this.snappedPortOriginalStyle.shadowBlur || 0,
          shadowColor: this.snappedPortOriginalStyle.shadowColor || 'transparent',
          visibility: this.snappedPortOriginalStyle.visibility,
          fill: this.snappedPortOriginalStyle.fill,
          zIndex: this.snappedPortOriginalStyle.zIndex
        });
      }
    } catch (e) { }
    this.snappedPort = null;
    this.snappedPortOriginalStyle = null;
  }

  customUpdateAssistEdge(event) {
    if (!this.source) return;

    const { graph } = this.context;
    const targetPort = event.originalTarget;
    const targetNodeId = event.target?.id;
    const isValidPort = this.isValidTargetPort(targetPort, targetNodeId);

    if (isValidPort && targetPort !== this.snappedPort) {
      // Clear any pending reset timeout
      if (this._resetSnappedPortTimeout) {
        clearTimeout(this._resetSnappedPortTimeout);
        this._resetSnappedPortTimeout = null;
      }
      this.resetSnappedPort();
      this.snappedPort = targetPort;
      this.snappedPortOriginalStyle = {
        r: targetPort.attr('r'),
        stroke: targetPort.attr('stroke'),
        lineWidth: targetPort.attr('lineWidth'),
        shadowBlur: targetPort.attr('shadowBlur'),
        shadowColor: targetPort.attr('shadowColor'),
        visibility: targetPort.attr('visibility'),
        fill: targetPort.attr('fill'),
        zIndex: targetPort.attr('zIndex')
      };

      const nodeData = graph.getElementData(targetNodeId);
      const ports = nodeData?.style?.ports || [];
      const portsArray = Array.isArray(ports) ? ports : Object.values(ports);
      const portWithFill = portsArray.find(p => p?.fill);
      const portColor = portWithFill?.fill || '#6B7280';

      try {
        const originalR = this.snappedPortOriginalStyle.r || 10;
        targetPort.attr({
          visibility: 'visible',
          fill: 'transparent',
          stroke: portColor,
          lineWidth: 3,
          r: originalR - 2,
          zIndex: 20
        });
      } catch (e) { }

      const portBounds = targetPort.getBounds();
      if (portBounds) {
        const centerX = (portBounds.min[0] + portBounds.max[0]) / 2;
        const centerY = (portBounds.min[1] + portBounds.max[1]) / 2;
        graph.updateNodeData([{
          id: ASSIST_NODE_ID,
          style: { x: centerX, y: centerY }
        }]);
        graph.draw();
        return;
      }
    } else if (!isValidPort && this.snappedPort) {
      // Delay reset to avoid flickering on port border
      if (!this._resetSnappedPortTimeout) {
        this._resetSnappedPortTimeout = setTimeout(() => {
          this.resetSnappedPort();
          this._resetSnappedPortTimeout = null;
        }, 100);
      }
    }

    this.updateAssistEdge(event);
  }

  async customDrop(event) {
    // Prevent re-entry from event bubbling
    if (this._processingPointerUp) return;
    this._processingPointerUp = true;
    setTimeout(() => { this._processingPointerUp = false; }, 0);

    // Clear any pending reset timeout
    if (this._resetSnappedPortTimeout) {
      clearTimeout(this._resetSnappedPortTimeout);
      this._resetSnappedPortTimeout = null;
    }
    this.resetSnappedPort();

    const mode = this.context.graph.options.mode;
    const targetType = event.targetType;
    const sourcePort = this.sourcePort;
    const targetPort = event.originalTarget;

    if (['node', 'combo', 'canvas'].indexOf(targetType) !== -1 && this.source) {
      const startX = this.startX ?? 0;
      const startY = this.startY ?? 0;
      const endX = event.canvas?.x ?? event.client?.x ?? 0;
      const endY = event.canvas?.y ?? event.client?.y ?? 0;
      const dx = endX - startX;
      const dy = endY - startY;
      const distance = Math.sqrt(dx * dx + dy * dy);

      if (distance < MIN_DRAG_DISTANCE) {
        this.isCreatingEdge = false;
        await this.cancelEdge();
        return;
      }

      if (event.target && event.target.id === this.source) {
        await this.cancelEdge();
        return;
      }

      if (targetType === 'canvas') {
        const { style, onFinish, onCreate } = this.options;
        const savedSource = this.source;
        const savedSourcePort = sourcePort?.key;

        // Build edge data (but don't add to graph - no real target node)
        const rawEdgeData = {
          id: `${savedSource}-canvas-${uniqueId()}`,
          source: savedSource,
          target: ASSIST_NODE_ID,
          targetType: 'canvas',
          style: Object.assign({}, style, { sourcePort: savedSourcePort })
        };
        const edgeData = typeof onCreate === 'function' ? onCreate(rawEdgeData) : rawEdgeData;

        // Cleanup
        this.isCreatingEdge = false;
        this.source = undefined;
        this.sourcePort = null;
        try {
          const graph = this.context.graph;
          graph.updateBehavior({ key: 'drag-element', enable: true });
          graph.removeEdgeData([ASSIST_EDGE_ID]);
          graph.removeNodeData([ASSIST_NODE_ID]);
          await graph.draw();
        } catch (e) { }

        // Notify via onFinish (for blockr.dag to create new block)
        if (edgeData && typeof onFinish === 'function') {
          onFinish(edgeData);
        }
        return;
      }

      const targetNode = this.context.graph.getElementData(event.target?.id);
      const targetHasPorts = targetNode?.style?.ports?.length > 0;

      if (targetHasPorts) {
        if (!targetPort?.attributes?.class?.includes('port')) {
          if (mode === "dev") {
            sendNotification("Please release the connecting edge on a port.", "warning", 5000);
          }
          await this.cancelEdge();
          return;
        }

        if (sourcePort?.attributes?.type && targetPort?.attributes?.type &&
            sourcePort.attributes.type === targetPort.attributes.type) {
          if (mode === "dev") {
            sendNotification("Edge creation failed: source and target ports must be of different types.", "warning", 5000);
          }
          await this.cancelEdge();
          return;
        }

        const portConnections = getPortConnections(this.context.graph, event.target?.id);
        const currentConnections = portConnections?.[targetPort.key] ?? 0;
        const targetArity = targetPort.attributes.arity === "Infinity" ? Infinity : targetPort.attributes.arity;
        if (currentConnections >= targetArity) {
          if (mode === "dev") {
            sendNotification("Target port has reached its maximum arity, can't connect.", "warning", 5000);
          }
          await this.cancelEdge();
          return;
        }
      }

      await this.customCreateEdge(event);
    } else {
      await this.cancelEdge();
    }
  }

  async customCreateEdge(event) {
    const { graph } = this.context;
    const { style, onFinish, onCreate } = this.options;
    const targetId = event.target?.id;
    if (targetId === undefined || this.source === undefined) return;

    const target = this.getSelectedNodeIDs([event.target.id])?.[0];
    if (target === this.source) {
      await this.cancelEdge();
      return;
    }

    const sourcePort = this.sourcePort;
    const targetPort = event.originalTarget;

    if (sourcePort && targetPort && targetPort?.attributes?.visibility == 'hidden') {
      await this.cancelEdge();
      return;
    }

    const edgeStyle = Object.assign(
      {},
      style,
      sourcePort ? { sourcePort: sourcePort.key } : {},
      targetPort ? { targetPort: targetPort.key } : {}
    );

    const rawEdgeData = {
      id: `${this.source}-${target}-${uniqueId()}`,
      source: this.source,
      targetType: event.targetType,
      target,
      style: edgeStyle
    };

    const edgeData = typeof onCreate === 'function' ? onCreate(rawEdgeData) : rawEdgeData;

    if (edgeData) {
      graph.addEdgeData([edgeData]);

      // Emit event to refresh port visuals on affected nodes
      window.dispatchEvent(new CustomEvent('g6-edge-created', {
        detail: { sourceId: this.source, targetId: target }
      }));

      if (typeof onFinish === 'function') {
        onFinish(edgeData);
      }
    }

    this.isCreatingEdge = false;
    this.source = undefined;
    this.sourcePort = null;
    // Re-enable drag-element behavior
    try {
      graph.updateBehavior({ key: 'drag-element', enable: true });
    } catch (e) { }
    try {
      graph.removeEdgeData([ASSIST_EDGE_ID]);
      graph.removeNodeData([ASSIST_NODE_ID]);
      await graph.draw();
    } catch (e) { }
  }

  async customHandleCreateEdge(event) {
    // Prevent re-entry from event bubbling
    if (this._processingPointerDown) return;
    this._processingPointerDown = true;
    setTimeout(() => { this._processingPointerDown = false; }, 0);

    // Handle invalid state - reset if isCreatingEdge but no source
    if (this.isCreatingEdge && !this.source) {
      this.isCreatingEdge = false;
    }

    this.startX = event.canvas.x;
    this.startY = event.canvas.y;

    const mode = this.context.graph.options.mode;
    const node = this.context.graph.getElementData(event.target?.id);

    let hasPorts = node?.style?.ports?.length > 0;
    if (hasPorts) {
      const clickedPort = event.originalTarget;
      // Check if user clicked on a port (has key property)
      if (clickedPort && clickedPort.key) {
        this.sourcePort = clickedPort;
        const portConnections = getPortConnections(this.context.graph, node.id);
        const currentConnections = portConnections[this.sourcePort.key] || 0;
        if (currentConnections >= this.sourcePort.arity) {
          if (mode === "dev") {
            sendNotification("Current port has reached its maximum arity, can't drag.", "warning", 5000);
          }
          this.sourcePort = null;
          return;
        }
        // Only set flag after arity check passes
        this.isCreatingEdge = true;
        // Disable drag-element to prevent node dragging during edge creation
        try {
          this.context.graph.updateBehavior({ key: 'drag-element', enable: false });
        } catch (e) { }
      } else {
        // User clicked on node body, not on a port - don't start edge creation
        return;
      }
    } else {
      // Node has no ports - allow edge creation from anywhere on node
      this.sourcePort = null;
    }

    if (!this.validate(event)) return;

    const { graph, canvas, batch } = this.context;
    const { style } = this.options;

    if (this.source) {
      await this.customCreateEdge(event);
      return;
    }

    if (batch) batch.startBatch();
    if (canvas) canvas.setCursor('crosshair');
    const selectedIds = this.getSelectedNodeIDs([event.target.id]);
    this.source = selectedIds && selectedIds[0];

    const sourceNode = graph.getElementData(this.source);
    const cursorX = event.canvas?.x ?? (sourceNode?.style?.x || 0);
    const cursorY = event.canvas?.y ?? (sourceNode?.style?.y || 0);

    graph.addNodeData([{
      id: ASSIST_NODE_ID,
      style: {
        visibility: 'hidden',
        ports: [{ key: 'port-1', placement: [0.5, 0.5] }],
        x: cursorX,
        y: cursorY,
      },
    }]);

    const assistEdgeStyle = Object.assign(
      { pointerEvents: 'none' },
      hasPorts && this.sourcePort ? { sourcePort: this.sourcePort.key } : {},
      style || {}
    );

    graph.addEdgeData([{
      id: ASSIST_EDGE_ID,
      source: this.source,
      target: ASSIST_NODE_ID,
      style: assistEdgeStyle,
    }]);

    await graph.draw();
  }
}

export { CustomCreateEdge };
