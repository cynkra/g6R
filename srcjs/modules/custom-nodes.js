import { Circle } from '@antv/g6';
import { Circle as GCircle } from '@antv/g';

// Custom rectangle node with port key attachment
class CustomCircleNode extends Circle {
  // count initial connections for each port of this node
  getPortConnections(nodeId) {
    const edges = this.context.graph.getEdgeData();
    const portConnections = {};

    edges.forEach(edge => {
      const style = edge.style || {};

      if (edge.source === nodeId && style.sourcePort) {
        portConnections[style.sourcePort] = (portConnections[style.sourcePort] || 0) + 1;
      }
      if (edge.target === nodeId && style.targetPort) {
        portConnections[style.targetPort] = (portConnections[style.targetPort] || 0) + 1;
      }
    });

    return portConnections;
  }
  // Override to attach port key to each port shape
  drawPortShapes(attributes, container) {
    const portsStyle = this.getPortsStyle(attributes);
    const graphId = this.context.graph.options.container;
    let portConnections = this.getPortConnections(this.id);

    Object.keys(portsStyle).forEach((key) => {
      const style = portsStyle[key];
      const [x, y] = this.getPortXY(attributes, style);
      style.connections = portConnections[key] || 0;

      const portShape = this.createPortShape(`port-${key}`, style, container, key);
      const portLabelShape = this.createPortLabel(key, style, x, y, container);

      // Create guide elements but keep them hidden initially
      const guide = style.showGuides
        ? this.createConnectionGuide(key, style, x, y, container, graphId, this.id)
        : null;

      this.addPortEvents(portShape, portLabelShape, style, guide);
    });
  }

  showGuide(guide) {
    guide.line.attr('visibility', 'visible');
    guide.rect.attr('visibility', 'visible');
    guide.plus.attr('visibility', 'visible');
    if (guide.bbox) guide.bbox.attr('visibility', 'visible');
  }

  hideGuide(guide) {
    guide.line.attr('visibility', 'hidden');
    guide.rect.attr('visibility', 'hidden');
    guide.plus.attr('visibility', 'hidden');
    if (guide.bbox) guide.bbox.attr('visibility', 'hidden');
  }

  handleGuideMouseLeave(e, guide) {
    // Only hide if not entering another guide element
    const related = e.relatedTarget;
    if (!related || !Object.values(guide).includes(related)) {
      this.hideGuide(guide);
    }
  }

  addPortEvents(portShape, portLabelShape, style, guide = null) {
    const cursorMap = {
      left: 'w-resize',
      right: 'e-resize',
      top: 'n-resize',
      bottom: 's-resize'
    };

    // Helper to update connections and guide visibility
    const handlePortHover = () => {
      const portConnections = this.getPortConnections(this.id);
      portShape.connections = portConnections[portShape.key] || 0;
      portShape.attr('cursor', portShape.connections >= portShape.arity ? 'not-allowed' : cursorMap[style.placement]);
      if (guide) {
        if (portShape.connections < portShape.arity) {
          this.showGuide(guide);
        } else {
          this.hideGuide(guide);
        }
      }
    };

    portShape.addEventListener('mouseenter', (e) => {
      portLabelShape.attr('visibility', 'visible');
      portShape.attr('lineWidth', 2);
      handlePortHover();
    });

    portShape.addEventListener('mouseleave', (e) => {
      portLabelShape.attr('visibility', 'hidden');
      portShape.attr('lineWidth', e.currentTarget.config.style.lineWidth);
      portShape.attr('cursor', 'default');
      if (guide) this.handleGuideMouseLeave(e, guide);
    });

    // Guide elements: keep visible on hover, hide only when leaving all
    if (guide) {
      ['line', 'rect', 'plus', 'bbox'].forEach(el => {
        if (guide[el]) {
          guide[el].addEventListener('mouseenter', handlePortHover);
          guide[el].addEventListener('mouseleave', (e) => {
            const related = e.relatedTarget;
            if (!related || !Object.values(guide).includes(related)) {
              this.hideGuide(guide);
            }
          });
        }
      });
    }
  }

  createPortShape(shapeKey, style, container, key) {
    const portShape = this.upsert(shapeKey, GCircle, { ...style }, container);
    if (portShape) {
      portShape.key = key;
      portShape.connections = style.connections;
      portShape.arity = style.arity;
    }
    return portShape;
  }

  createPortLabel(key, style, x, y, container) {
    const gap = 8;
    const r = style.r || 4;
    const labelX = x;
    const labelY = (style.placement === 'bottom') ? y + r + gap : y - r - gap;

    const portLabelStyle = {
      x: labelX,
      y: labelY,
      text: style.label,
      fontSize: 7,
      fill: '#262626',
      fontWeight: 'bold',
      textAlign: 'center',
      textBaseline: 'middle',
      visibility: 'hidden'
    };
    return this.upsert(`label-${key}`, 'text', portLabelStyle, container);
  }

  createConnectionGuide(key, style, x, y, container, graphId, nodeId) {
    const lineLength = 50;
    const rectWidth = 12;
    const rectHeight = 12;
    const plusFontSize = 7;
    const r = style.r || 4;

    let x1 = x, y1 = y, x2 = x, y2 = y;
    let rectX = x, rectY = y;

    if (style.placement === 'left') {
      x1 = x - r;
      x2 = x1 - lineLength;
      rectX = x2 - rectWidth / 2;
      rectY = y - rectHeight / 2;
    } else if (style.placement === 'right') {
      x1 = x + r;
      x2 = x1 + lineLength;
      rectX = x2 - rectWidth / 2;
      rectY = y - rectHeight / 2;
    } else if (style.placement === 'top') {
      y1 = y - r;
      y2 = y1 - lineLength;
      rectX = x - rectWidth / 2;
      rectY = y2 - rectHeight / 2;
    } else if (style.placement === 'bottom') {
      y1 = y + r;
      y2 = y1 + lineLength;
      rectX = x - rectWidth / 2;
      rectY = y2 - rectHeight / 2;
    }

    // Dashed line
    const line = this.upsert(
      `hover-line-${key}`,
      'line',
      {
        x1, y1, x2, y2,
        stroke: '#000',
        lineWidth: 2,
        zIndex: 10,
        visibility: 'hidden' // Initially hidden
      },
      container
    );

    // Rectangle at end
    const rect = this.upsert(
      `hover-rect-${key}`,
      'rect',
      {
        x: rectX,
        y: rectY,
        width: rectWidth,
        height: rectHeight,
        fill: '#fff',
        stroke: '#000',
        radius: 2,
        zIndex: 11,
        visibility: 'hidden' // Initially hidden
      },
      container
    );

    // Plus sign in rectangle
    const plus = this.upsert(
      `hover-plus-${key}`,
      'text',
      {
        x: Math.round(rectX + rectWidth / 2),
        y: Math.round(rectY + rectHeight / 2),
        text: '+',
        fontSize: plusFontSize,
        fill: '#000',
        fontWeight: 'bold',
        textAlign: 'center',
        textBaseline: 'middle',
        zIndex: 12,
        cursor: 'copy',
        visibility: 'hidden' // Initially hidden
      },
      container
    );

    // Add click event listener to set shiny input
    plus.addEventListener('click', (e) => {
      Shiny.setInputValue(
        `${graphId}-selected_port`,
        { node: nodeId, port: key, type: style.type }//,
        //{ priority: 'event' }
      );
      // Avoid to click on the node.
      e.stopPropagation();
    });

    // Calculate bounding box coordinates
    const bboxPadding = 2; // Adjust for larger detection area
    const minX = Math.min(x1, x2, rectX) - bboxPadding;
    const maxX = Math.max(x1, x2, rectX + rectWidth) + bboxPadding;
    const minY = Math.min(y1, y2, rectY) - bboxPadding;
    const maxY = Math.max(y1, y2, rectY + rectHeight) + bboxPadding;

    // Invisible bounding box for easier hover
    const bbox = this.upsert(
      `hover-guide-bbox-${key}`,
      'rect',
      {
        x: minX,
        y: minY,
        width: maxX - minX,
        height: maxY - minY,
        fill: 'transparent',
        stroke: 'none',
        pointerEvents: 'all',
        zIndex: 9,
        visibility: 'hidden'
      },
      container
    );

    // Add listeners to the bounding box
    bbox.addEventListener('mouseenter', () => {
      line.attr('visibility', 'visible');
      rect.attr('visibility', 'visible');
      plus.attr('visibility', 'visible');
      bbox.attr('visibility', 'visible');
    });
    bbox.addEventListener('mouseleave', (e) => {
      line.attr('visibility', 'hidden');
      rect.attr('visibility', 'hidden');
      plus.attr('visibility', 'hidden');
      bbox.attr('visibility', 'hidden');
    });

    // Also show/hide bbox with the rest of the guide
    line.attr('visibility', 'hidden');
    rect.attr('visibility', 'hidden');
    plus.attr('visibility', 'hidden');
    bbox.attr('visibility', 'hidden');

    // Return references for event logic
    return { line, rect, plus, bbox };
  }

  // Render method: rectangle and ports
  render(attributes = this.parsedAttributes, container) {
    // Draw base rectangle and main label, and ports with our override
    super.render(attributes, container);
  }
}

export { CustomCircleNode };