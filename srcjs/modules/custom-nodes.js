import { Circle } from '@antv/g6';
import { Circle as GCircle } from '@antv/g';

// Custom rectangle node with port key attachment
class CustomCircleNode extends Circle {
  // Override to attach port key to each port shape
  drawPortShapes(attributes, container) {
    const portsStyle = this.getPortsStyle(attributes);

    Object.keys(portsStyle).forEach((key) => {
      const style = portsStyle[key];
      const shapeKey = `port-${key}`;
      const [x, y] = this.getPortXY(attributes, style);

      // Draw the port shape
      const portShape = this.upsert(shapeKey, GCircle, { ...style }, container);
      if (portShape) {
        portShape.key = key;
        portShape.connections = 0;
      }

      // Label positioning
      const gap = 8;
      const r = style.r || 4;

      // Center label horizontally, offset vertically
      let labelX = x;
      let labelY = (style.placement === 'bottom')
        ? y + r + gap
        : y - r - gap;

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
      const portLabelShape = this.upsert(`label-${key}`, 'text', portLabelStyle, container);

      // Manage port cursor:
      // we show the user that they can connect by dragging
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
    });
  }

  // Render method: rectangle and ports
  render(attributes = this.parsedAttributes, container) {
    // Draw base rectangle and main label, and ports with our override
    super.render(attributes, container);
  }
}

export { CustomCircleNode };