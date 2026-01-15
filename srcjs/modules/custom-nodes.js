import { Circle, Rect, Ellipse, Diamond, Triangle, Star, Hexagon, Image, Donut } from '@antv/g6';
import { Circle as GCircle } from '@antv/g';
import { getPortConnections } from './utils';


// To add event listener only once because of re-renders
// we don't want to rebind the same events.
const addUniqueEventListener = (element, type, listener) => {
  const flag = `_hasListener_${type}`;
  if (!element[flag]) {
    element.addEventListener(type, listener);
    element[flag] = true;
  }
}

const getContrastColor = (bg) => {
  // Accepts hex color string, e.g. "#444"
  let c = bg.replace('#', '');
  if (c.length === 3) c = c.split('').map(x => x + x).join('');
  const r = parseInt(c.substr(0, 2), 16);
  const g = parseInt(c.substr(2, 2), 16);
  const b = parseInt(c.substr(4, 2), 16);
  // Perceptual luminance formula
  const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
  return luminance > 0.5 ? '#000' : '#fff';
}

// Factory to create custom nodes with port key attachment
const createCustomNode = (BaseShape) => {
  return class CustomNode extends BaseShape {
    // Override to attach port key to each port shape
    drawPortShapes(attributes, container) {
      const portsStyle = this.getPortsStyle(attributes);
      const graphId = this.context.graph.options.container;
      let portConnections = getPortConnections(this.context.graph, this.id);

      Object.keys(portsStyle).forEach((key) => {
        const style = portsStyle[key];
        // TBD: understand why sometimes style isn't valid.
        // I could not reproduce this reliably.
        if (!style) return;
        const [x, y] = this.getPortXY(attributes, style);
        style.connections = portConnections[key] || 0;

        const portShape = this.createPortShape(`port-${key}`, style, x, y, container, key);

        // Create guide elements but keep them hidden initially
        const guide = style.showGuides
          ? this.createConnectionGuide(key, style, x, y, container, graphId, this.id)
          : null;

        this.addPortEvents(portShape, style, guide);
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

    getCursorForPlacement(placement) {
      if (typeof placement === "string") {
        if (placement === "left" || placement === "right") return "ew-resize";
        if (placement === "top" || placement === "bottom") return "ns-resize";
        return "pointer";
      }
      if (Array.isArray(placement)) {
        const [x, y] = placement;
        const near = (val, target) => Math.abs(val - target) < 0.2;
        if (x === 1 && y === 1) return "se-resize";
        if (x === 0 && y === 0) return "nw-resize";
        if (x === 1 && y === 0) return "ne-resize";
        if (x === 0 && y === 1) return "se-resize";
        // Prioritize vertical edges
        if (near(y, 0)) return "ns-resize";      // top
        if (near(y, 1)) return "ns-resize";      // bottom
        if (near(x, 0)) return "ew-resize";      // left
        if (near(x, 1)) return "ew-resize";      // right
        return "pointer";
      }
      return "pointer";
    }

    addPortEvents(portShape, style, guide = null) {
      // Helper to update connections and guide visibility
      const handlePortHover = () => {
        const portConnections = getPortConnections(this.context.graph, this.id);
        portShape.connections = portConnections[portShape.key] || 0;
        portShape.attr('cursor', portShape.connections >= portShape.arity ? 'not-allowed' : this.getCursorForPlacement(style.placement));
        if (guide) {
          if (portShape.connections < portShape.arity) {
            this.showGuide(guide);
          } else {
            this.hideGuide(guide);
          }
        }
      }

      // Tooltip logic
      const showTooltip = (e) => {
        let tooltip = document.getElementById('g6-port-tooltip');
        if (!tooltip) {
          tooltip = document.createElement('div');
          tooltip.id = 'g6-port-tooltip';
          tooltip.style.position = 'fixed';
          tooltip.style.pointerEvents = 'none';
          tooltip.style.background = style.stroke;
          tooltip.style.color = getContrastColor(style.stroke);
          tooltip.style.borderRadius = '6px';
          tooltip.style.padding = '4px 10px';
          tooltip.style.fontSize = '12px';
          tooltip.style.zIndex = '9999';
          document.body.appendChild(tooltip);
        }
        tooltip.textContent = style.label || '';
        tooltip.style.left = (e.clientX + 12) + 'px';
        tooltip.style.top = (e.clientY - 12) + 'px';
        tooltip.style.display = 'block';
      };

      const hideTooltip = () => {
        const tooltip = document.getElementById('g6-port-tooltip');
        if (tooltip) tooltip.style.display = 'none';
      };

      addUniqueEventListener(portShape, 'mouseenter', (e) => {
        portShape.attr('lineWidth', 2);
        handlePortHover();
        showTooltip(e);
      });

      addUniqueEventListener(portShape, 'mouseleave', (e) => {
        portShape.attr('lineWidth', e.currentTarget.config.style.lineWidth);
        portShape.attr('cursor', 'default');
        hideTooltip();
        if (guide) this.handleGuideMouseLeave(e, guide);
      });

      // Guide elements: keep visible on hover, hide only when leaving all
      if (guide) {
        // Only show guide if arity not reached, otherwise always hide
        const guideHover = () => {
          const portConnections = getPortConnections(this.context.graph, this.id);
          const connections = portConnections[portShape.key] || 0;
          if (connections < portShape.arity) {
            this.showGuide(guide);
          } else {
            this.hideGuide(guide);
          }
        };
        ['line', 'rect', 'plus', 'bbox'].forEach(el => {
          if (guide[el]) {
            addUniqueEventListener(guide[el], 'mouseenter', guideHover);
            addUniqueEventListener(guide[el], 'mouseleave', (e) => {
              const related = e.relatedTarget;
              if (!related || !Object.values(guide).includes(related)) {
                this.hideGuide(guide);
              }
            });
          }
        });
      }
    }

    createInfinitySymbol(key, x, y, style, container, fill) {
      let px = 0.5, py = 0.5;
      const placement = style.placement;
      if (Array.isArray(placement)) {
        [px, py] = placement;
      } else if (placement) {
        if (placement === 'top') py = 0;
        else if (placement === 'bottom') py = 1;
        else if (placement === 'left') px = 0;
        else if (placement === 'right') px = 1;
      }
      const r = style.r;
      const infX = (py === 0 || py === 1) ? x - r * 2.2 : x;
      const infY = (py === 0 || py === 1) ? y : y - r * 2.2;
      return this.upsert(
        `inf-symbol-${key}`,
        'text',
        {
          x: infX,
          y: infY,
          text: '∞',
          fontWeight: 'bold',
          fontSize: r * 2,
          fill: fill,
          textAlign: 'center',
          textBaseline: 'middle',
          zIndex: 20
        },
        container
      );
    }

    createPortShape(shapeKey, style, x, y, container, key) {
      const portShape = this.upsert(shapeKey, GCircle, { ...style }, container);
      if (portShape) {
        portShape.key = key;
        portShape.connections = style.connections;
        portShape.arity = style.arity;

        // Infinity symbol placement logic
        if (portShape.arity === Infinity || portShape.arity === 'Infinity') {
          const nodeStyle = container.config.style;
          this.createInfinitySymbol(
            key,
            x,
            y,
            style,
            container,
            nodeStyle.stroke
          );
        }

      }
      return portShape;
    }

    createConnectionGuide(key, style, x, y, container, graphId, nodeId) {
      const lineLength = 25;
      const rectWidth = 12;
      const rectHeight = 12;
      const plusFontSize = 7;
      const r = style.r || 4;

      let direction = style.placement;
      // If placement is an array, infer direction from coordinates
      if (!['left', 'right', 'top', 'bottom'].includes(direction) && Array.isArray(style.placement)) {
        const [relX, relY] = style.placement;
        // Use strict equality for corners, otherwise pick the closest side
        if (relY === 0) direction = 'top';
        else if (relY === 1) direction = 'bottom';
        else if (relX === 0) direction = 'left';
        else if (relX === 1) direction = 'right';
        else {
          // If not exactly on a side, pick the closest
          if (relY > 0.75) direction = 'bottom';
          else if (relY < 0.25) direction = 'top';
          else if (relX > 0.75) direction = 'right';
          else if (relX < 0.25) direction = 'left';
          else direction = 'right'; // fallback
        }
      }

      // Use the absolute port position (x, y) for guide start
      let x1 = x, y1 = y, x2 = x, y2 = y;
      let rectX = x, rectY = y;

      if (direction === 'left') {
        x1 = x - r;
        x2 = x1 - lineLength;
        rectX = x2 - rectWidth / 2;
        rectY = y - rectHeight / 2;
      } else if (direction === 'right') {
        x1 = x + r;
        x2 = x1 + lineLength;
        rectX = x2 - rectWidth / 2;
        rectY = y - rectHeight / 2;
      } else if (direction === 'top') {
        y1 = y - r;
        y2 = y1 - lineLength;
        rectX = x - rectWidth / 2;
        rectY = y2 - rectHeight / 2;
      } else if (direction === 'bottom') {
        y1 = y + r;
        y2 = y1 + lineLength;
        rectX = x - rectWidth / 2;
        rectY = y2 - rectHeight / 2;
      }

      const nodeStyle = container.config.style;

      // Dashed line
      const line = this.upsert(
        `hover-line-${key}`,
        'line',
        {
          x1, y1, x2, y2,
          stroke: nodeStyle.stroke,
          lineWidth: 2,
          zIndex: 10,
          visibility: 'hidden'
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
          fill: this.context.graph.options.background || '#ffffff',
          stroke: nodeStyle.stroke,
          radius: 2,
          zIndex: 11,
          visibility: 'hidden'
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
          fill: nodeStyle.stroke,
          fontWeight: 'bold',
          textAlign: 'center',
          textBaseline: 'middle',
          zIndex: 12,
          cursor: 'copy',
          visibility: 'hidden'
        },
        container
      );

      // Add click event listener to set shiny input
      addUniqueEventListener(plus, 'click', (e) => {
        if (HTMLWidgets.shinyMode) {
          Shiny.setInputValue(
            `${graphId}-selected_port`,
            { node: nodeId, port: key, type: style.type },
            { priority: 'event' }
          );
        }
        e.stopPropagation();
      });

      // Calculate bounding box coordinates
      const bboxPadding = 2;
      const minX = Math.min(x1, x2, rectX) - bboxPadding;
      const maxX = Math.max(x1, x2, rectX + rectWidth) + bboxPadding;
      const minY = Math.min(y1, y2, rectY) - bboxPadding;
      const maxY = Math.max(y1, y2, rectY + rectHeight) + bboxPadding;

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

      // Add listeners to the bounding box and guide elements
      const showGuideIfAllowed = () => {
        const portConnections = getPortConnections(this.context.graph, this.id);
        const connections = portConnections[key] || 0;
        if (connections < (style.arity ?? Infinity)) {
          line.attr('visibility', 'visible');
          rect.attr('visibility', 'visible');
          plus.attr('visibility', 'visible');
          bbox.attr('visibility', 'visible');
        } else {
          line.attr('visibility', 'hidden');
          rect.attr('visibility', 'hidden');
          plus.attr('visibility', 'hidden');
          bbox.attr('visibility', 'hidden');
        }
      };

      ['bbox', 'line', 'rect', 'plus'].forEach(el => {
        addUniqueEventListener(eval(el), 'mouseenter', showGuideIfAllowed);
        addUniqueEventListener(eval(el), 'mouseleave', (e) => {
          line.attr('visibility', 'hidden');
          rect.attr('visibility', 'hidden');
          plus.attr('visibility', 'hidden');
          bbox.attr('visibility', 'hidden');
        });
      });

      line.attr('visibility', 'hidden');
      rect.attr('visibility', 'hidden');
      plus.attr('visibility', 'hidden');
      bbox.attr('visibility', 'hidden');

      return { line, rect, plus, bbox };
    }

    // Render method: rectangle and ports
    render(attributes = this.parsedAttributes, container) {
      // Draw base rectangle and main label, and ports with our override
      super.render(attributes, container);
    }
  };
}

// Build custom classes from factory
const CustomCircleNode = createCustomNode(Circle);
const CustomRectNode = createCustomNode(Rect);
const CustomEllipseNode = createCustomNode(Ellipse);
const CustomDiamondNode = createCustomNode(Diamond);
const CustomTriangleNode = createCustomNode(Triangle);
const CustomStarNode = createCustomNode(Star);
const CustomHexagonNode = createCustomNode(Hexagon);
const CustomImageNode = createCustomNode(Image);
const CustomDonutNode = createCustomNode(Donut);

export {
  CustomCircleNode,
  CustomRectNode,
  CustomEllipseNode,
  CustomDiamondNode,
  CustomTriangleNode,
  CustomStarNode,
  CustomHexagonNode,
  CustomImageNode,
  CustomDonutNode
};