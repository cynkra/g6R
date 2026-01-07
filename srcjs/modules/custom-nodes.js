import { Circle } from '@antv/g6';
import { Circle as GCircle } from '@antv/g';

// Custom rectangle node with port key attachment
class CustomCircleNode extends Circle {
  // Override to attach port key to each port shape
  drawPortShapes(attributes, container) {
    const portsStyle = this.getPortsStyle(attributes);
    const graphId = this.context.graph.options.container;

    Object.keys(portsStyle).forEach((key) => {
      const style = portsStyle[key];
      const shapeKey = `port-${key}`;
      const [x, y] = this.getPortXY(attributes, style);

      const portShape = this.createPortShape(shapeKey, style, container, key);
      const portLabelShape = this.createPortLabel(key, style, x, y, container);

      this.addPortEvents(portShape, portLabelShape, style);

      this.createConnectionGuides(key, style, x, y, container, graphId, this.id);
    });
  }

  createPortShape(shapeKey, style, container, key) {
    const portShape = this.upsert(shapeKey, GCircle, { ...style }, container);
    if (portShape) {
      portShape.key = key;
      portShape.connections = 0;
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

  addPortEvents(portShape, portLabelShape, style) {
    const cursorMap = {
      left: 'w-resize',
      right: 'e-resize',
      top: 'n-resize',
      bottom: 's-resize'
    };

    portShape.addEventListener('mouseenter', (e) => {
      const cursor = cursorMap[style.placement] || 'pointer';
      portShape.attr('cursor', cursor);
      portShape.attr('lineWidth', 2);
      portLabelShape.attr('visibility', 'visible');
    });

    portShape.addEventListener('mouseleave', (e) => {
      portShape.attr('cursor', 'default');
      portShape.attr('lineWidth', e.currentTarget.config.style.lineWidth);
      portLabelShape.attr('visibility', 'hidden');
    });
  }

  createConnectionGuides(key, style, x, y, container, graphId, nodeId) {
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
    this.upsert(
      `hover-line-${key}`,
      'line',
      {
        x1, y1, x2, y2,
        stroke: '#000',
        lineWidth: 2,
        zIndex: 10
      },
      container
    );

    // Rectangle at end
    this.upsert(
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
        zIndex: 11
      },
      container
    );

    // Plus sign in rectangle
    const plusShape = this.upsert(
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
        cursor: 'copy'
      },
      container
    );

    // Add click event listener to set shiny input
    plusShape.addEventListener('click', () => {
      Shiny.setInputValue(
        `${graphId}-selected_port`,
        { node: nodeId, port: key },
        { priority: 'event' }
      );
      // Avoid to click on the node.
      e.stopPropagation();
    });
  }

  // Render method: rectangle and ports
  render(attributes = this.parsedAttributes, container) {
    // Draw base rectangle and main label, and ports with our override
    super.render(attributes, container);
  }
}

export { CustomCircleNode };