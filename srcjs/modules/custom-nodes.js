import { Circle } from '@antv/g6';
import { Circle as GCircle } from '@antv/g';

// Custom rectangle node with port key attachment
class CustomCircleNode extends Circle {
  // Override to attach port key to each port shape
  drawPortShapes(attributes, container) {
    const portsStyle = this.getPortsStyle(attributes);

    Object.keys(portsStyle).forEach((key) => {
      // TBD: initialise the number of connections
      // this is linked to arity param on the R side.
      const style = portsStyle[key];
      const shapeKey = `port-${key}`;
      // Draw the port shape (circle)
      const portShape = this.upsert(shapeKey, GCircle, { ...style, name: shapeKey }, container);
      // Attach the port key for event access
      if (portShape) portShape.key = key;
    });
  }

  // Render method: rectangle and ports
  render(attributes = this.parsedAttributes, container) {
    // Draw base rectangle and main label, and ports (with our override)
    super.render(attributes, container);
  }
}

export { CustomCircleNode };