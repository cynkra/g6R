import { Circle, Rect, Ellipse, Diamond, Triangle, Star, Hexagon, Image, Donut } from '@antv/g6';
import { Circle as GCircle, Rect as GRect } from '@antv/g';
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

// Track currently hovered node to hide others when switching
let currentlyHoveredNode = null;

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

// Generate themed label colors from accent color
const getThemedLabelColors = (accentColor) => {
  if (!accentColor) return null;

  let c = accentColor.replace('#', '');
  if (c.length === 3) c = c.split('').map(x => x + x).join('');
  const r = parseInt(c.substr(0, 2), 16);
  const g = parseInt(c.substr(2, 2), 16);
  const b = parseInt(c.substr(4, 2), 16);

  // Light background (like bg-color-50): mix with white ~90%
  const bgR = Math.round(r + (255 - r) * 0.88);
  const bgG = Math.round(g + (255 - g) * 0.88);
  const bgB = Math.round(b + (255 - b) * 0.88);

  // Border (like border-color-200): mix with white ~70%
  const borderR = Math.round(r + (255 - r) * 0.7);
  const borderG = Math.round(g + (255 - g) * 0.7);
  const borderB = Math.round(b + (255 - b) * 0.7);

  // Text (like text-color-700): darken the color
  const textR = Math.round(r * 0.55);
  const textG = Math.round(g * 0.55);
  const textB = Math.round(b * 0.55);

  const toHex = (r, g, b) => '#' + [r, g, b].map(x => x.toString(16).padStart(2, '0')).join('');

  return {
    background: toHex(bgR, bgG, bgB),
    border: toHex(borderR, borderG, borderB),
    text: toHex(textR, textG, textB)
  };
}

// Factory to create custom nodes with port key attachment
const createCustomNode = (BaseShape) => {
  return class CustomNode extends BaseShape {
    // Override to apply themed label colors based on node's accent color
    drawLabelShape(attributes, container) {
      // Get accent color from stroke or fill
      const accentColor = attributes.stroke || attributes.fill;
      const colors = getThemedLabelColors(accentColor);

      if (colors && attributes.labelText) {
        // Override label style with themed colors
        attributes = {
          ...attributes,
          labelFill: colors.text,
          labelBackground: true,
          labelBackgroundFill: colors.background,
          labelBackgroundStroke: colors.border,
          labelBackgroundLineWidth: 1,
          labelBackgroundRadius: 6,
          labelPadding: [4, 10, 4, 10],
          labelFontSize: 12,
          labelFontWeight: 500
        };
      }

      super.drawLabelShape(attributes, container);
    }

    // Override to attach port key to each port shape
    drawPortShapes(attributes, container) {
      const portsStyle = this.getPortsStyle(attributes);
      const graphId = this.context.graph.options.container;

      // Store port shapes for z-index manipulation on hover
      this._portShapes = [];

      Object.keys(portsStyle).forEach((key) => {
        const style = portsStyle[key];
        // TBD: understand why sometimes style isn't valid.
        // I could not reproduce this reliably.
        if (!style) return;
        const [x, y] = this.getPortXY(attributes, style);

        const baseRadius = style.r || 4;

        // Solid filled port circle for occupied ports
        const portStyle = {
          ...style,
          zIndex: 1,
          r: baseRadius,
          fill: style.fill,
          stroke: 'transparent',
          lineWidth: 0,
          visibility: 'hidden',
          class: 'port'  // Required for edge creation validation
        };
        const portShape = this.createPortShape(`port-${key}`, portStyle, x, y, container, key);

        // Store for hover expansion
        portShape._baseRadius = baseRadius;
        portShape._expandedRadius = baseRadius * 2.5;
        portShape._originalFill = style.fill;

        // Create add indicator with block's accent color
        // Pass style for arity/type needed for edge creation
        const addIndicator = this.createAddIndicator(key, x, y, baseRadius * 2.5, style.fill, container, style);

        this._portShapes.push({ shape: portShape, indicator: addIndicator });

        this.addPortEvents(portShape, style, addIndicator, graphId, this.id);
      });

      // Add node hover to bring ports to front
      this.addNodeHoverForZIndex(container);
    }

    addNodeHoverForZIndex(container) {
      const keyShape = container.querySelector('[class*="key"]') || container.children?.[0];
      if (!keyShape || keyShape._hasZIndexHover) return;
      keyShape._hasZIndexHover = true;

      // Track if we're hovering node or any port/indicator
      let hideTimeout = null;
      let isHoveringNode = false;

      const showPorts = () => {
        isHoveringNode = true;
        if (hideTimeout) {
          clearTimeout(hideTimeout);
          hideTimeout = null;
        }

        // Hide previous node's indicators immediately
        if (currentlyHoveredNode && currentlyHoveredNode !== this) {
          currentlyHoveredNode._hidePortsImmediately?.();
        }
        currentlyHoveredNode = this;

        if (!this._portShapes) return;

        const portConnections = getPortConnections(this.context.graph, this.id) || {};

        // Check if already showing (to avoid flicker on re-enter)
        let needsAnimation = false;

        // Show + indicators for available ports, small circles for occupied ports
        this._portShapes.forEach(({ shape, indicator }) => {
          const connections = portConnections[shape.key] ?? 0;
          const arity = shape.arity === "Infinity" ? Infinity : (shape.arity || 1);
          const atCapacity = connections >= arity;

          if (!atCapacity && indicator) {
            // Show + indicator for ports that can accept connections
            shape.attr({ visibility: 'hidden' });
            // Only reset opacity if not already visible
            if (indicator.circle.attr('visibility') !== 'visible') {
              if (indicator.hitArea) indicator.hitArea.attr({ visibility: 'visible' });
              indicator.circle.attr({ visibility: 'visible', opacity: 0 });
              indicator.innerCircle.attr({ visibility: 'visible', opacity: 0 });
              indicator.plus.attr({ visibility: 'visible', opacity: 0 });
              needsAnimation = true;
            }
            this.startRotationAnimation(indicator.circle);
          } else {
            // Show small port circle for occupied ports
            if (shape.attr('visibility') !== 'visible') {
              shape.attr({
                visibility: 'visible',
                zIndex: 10,
                opacity: 0
              });
              needsAnimation = true;
            }
          }
        });

        if (needsAnimation) {
          this.animateAllIn();
        }
      };

      const hidePorts = () => {
        isHoveringNode = false;
        // Delay hiding to allow moving to indicators
        hideTimeout = setTimeout(() => {
          const tooltip = document.getElementById('g6-port-tooltip');
          if (tooltip) tooltip.style.display = 'none';

          if (!this._portShapes) return;
          if (this._portsAnimation) {
            cancelAnimationFrame(this._portsAnimation);
            this._portsAnimation = null;
          }
          this._portShapes.forEach(({ shape, indicator }) => {
            shape.attr({
              visibility: 'hidden',
              zIndex: 1,
              r: shape._baseRadius,
              opacity: 1
            });
            if (indicator) {
              this.stopRotationAnimation(indicator.circle);
              if (indicator.hitArea) indicator.hitArea.attr({ visibility: 'hidden' });
              indicator.circle.attr({ visibility: 'hidden', opacity: 1 });
              indicator.innerCircle.attr({ visibility: 'hidden', opacity: 1 });
              indicator.plus.attr({ visibility: 'hidden', opacity: 1 });
            }
          });
        }, 400); // 400ms delay before hiding
      };

      // Immediately hide all ports/indicators (no delay)
      const hidePortsImmediately = () => {
        isHoveringNode = false;
        if (hideTimeout) {
          clearTimeout(hideTimeout);
          hideTimeout = null;
        }
        if (this._portsAnimation) {
          cancelAnimationFrame(this._portsAnimation);
          this._portsAnimation = null;
        }
        if (!this._portShapes) return;
        this._portShapes.forEach(({ shape, indicator }) => {
          shape.attr({ visibility: 'hidden', opacity: 1 });
          if (indicator) {
            this.stopRotationAnimation(indicator.circle);
            if (indicator.hitArea) indicator.hitArea.attr({ visibility: 'hidden' });
            indicator.circle.attr({ visibility: 'hidden', opacity: 1 });
            indicator.innerCircle.attr({ visibility: 'hidden', opacity: 1 });
            indicator.plus.attr({ visibility: 'hidden', opacity: 1 });
          }
        });
      };

      // Store functions for ports/indicators to call
      this._showPorts = showPorts;
      this._hidePorts = hidePorts;
      this._hidePortsImmediately = hidePortsImmediately;
      this._cancelHide = () => {
        if (hideTimeout) {
          clearTimeout(hideTimeout);
          hideTimeout = null;
        }
      };
      this._isHoveringNode = () => isHoveringNode;

      addUniqueEventListener(keyShape, 'mouseenter', showPorts);
      addUniqueEventListener(keyShape, 'mouseleave', hidePorts);
    }

    // Lighten a hex color by mixing with white
    lightenColor(hex, amount) {
      if (!hex) return '#cccccc';
      let c = hex.replace('#', '');
      if (c.length === 3) c = c.split('').map(x => x + x).join('');
      const r = parseInt(c.substr(0, 2), 16);
      const g = parseInt(c.substr(2, 2), 16);
      const b = parseInt(c.substr(4, 2), 16);
      // Mix with white
      const newR = Math.round(r + (255 - r) * amount);
      const newG = Math.round(g + (255 - g) * amount);
      const newB = Math.round(b + (255 - b) * amount);
      return `#${newR.toString(16).padStart(2, '0')}${newG.toString(16).padStart(2, '0')}${newB.toString(16).padStart(2, '0')}`;
    }

    showGuide(guide) {
      if (guide.plus) guide.plus.attr('visibility', 'visible');
      // Legacy support for old guide structure
      if (guide.line) guide.line.attr('visibility', 'visible');
      if (guide.rect) guide.rect.attr('visibility', 'visible');
      if (guide.bbox) guide.bbox.attr('visibility', 'visible');
    }

    hideGuide(guide) {
      if (guide.plus) guide.plus.attr('visibility', 'hidden');
      // Legacy support for old guide structure
      if (guide.line) guide.line.attr('visibility', 'hidden');
      if (guide.rect) guide.rect.attr('visibility', 'hidden');
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
        switch (placement) {
          case "left": return "w-resize";
          case "right": return "e-resize";
          case "top": return "n-resize";
          case "bottom": return "s-resize";
          case "top-left": return "nw-resize";
          case "top-right": return "ne-resize";
          case "bottom-left": return "sw-resize";
          case "bottom-right": return "se-resize";
          default: return "pointer";
        }
      }
      if (Array.isArray(placement)) {
        const [x, y] = placement;
        // Corners
        if (x === 0 && y === 0) return "nw-resize";
        if (x === 1 && y === 0) return "ne-resize";
        if (x === 0 && y === 1) return "sw-resize";
        if (x === 1 && y === 1) return "se-resize";
        // Sides
        if (y === 0) return "n-resize";
        if (y === 1) return "s-resize";
        if (x === 0) return "w-resize";
        if (x === 1) return "e-resize";
        return "pointer";
      }
      return "pointer";
    }

    addPortEvents(portShape, style, indicator = null, graphId = null, nodeId = null) {
      // Helper to show add indicator on hover with pop animation
      const handlePortHover = () => {
        const connections = getPortConnections(this.context.graph, this.id)?.[portShape.key] ?? 0;
        const atCapacity = connections >= (portShape.arity === "Infinity" ? Infinity : portShape.arity);

        if (!atCapacity && indicator) {
          // Hide port, show rotating dashed circle + solid circle + plus with animation
          portShape.attr('visibility', 'hidden');
          this.showIndicatorWithAnimation(indicator);
          this.startRotationAnimation(indicator.circle);
        }
      }

      // Add event handlers to indicator hitArea (covers entire indicator)
      if (indicator && indicator.hitArea && graphId && nodeId && style.showGuides) {
        const handleIndicatorClick = (e) => {
          if (HTMLWidgets.shinyMode) {
            Shiny.setInputValue(
              `${graphId}-selected_port`,
              { node: nodeId, port: portShape.key, type: style.type },
              { priority: 'event' }
            );
          }
          e.stopPropagation();
        };

        addUniqueEventListener(indicator.hitArea, 'click', handleIndicatorClick);

        addUniqueEventListener(indicator.hitArea, 'mouseenter', () => {
          if (this._cancelHide) this._cancelHide();
          portShape.attr('visibility', 'hidden');
          this.showIndicatorWithAnimation(indicator);
          this.startRotationAnimation(indicator.circle);
        });

        addUniqueEventListener(indicator.hitArea, 'mouseleave', (e) => {
          // Don't trigger hide - let keyShape mouseleave handle it
        });
      }

      // Tooltip logic with auto-hide safety
      let tooltipTimeout = null;

      const showTooltip = (e) => {
        // Clear any pending hide
        if (tooltipTimeout) {
          clearTimeout(tooltipTimeout);
          tooltipTimeout = null;
        }

        let tooltip = document.getElementById('g6-port-tooltip');
        if (!tooltip) {
          tooltip = document.createElement('div');
          tooltip.id = 'g6-port-tooltip';
          tooltip.style.position = 'fixed';
          tooltip.style.pointerEvents = 'none';
          tooltip.style.background = '#f5f5f5';
          tooltip.style.color = '#666';
          tooltip.style.border = '1px solid #ddd';
          tooltip.style.borderRadius = '4px';
          tooltip.style.padding = '3px 8px';
          tooltip.style.fontSize = '11px';
          tooltip.style.fontWeight = 'normal';
          tooltip.style.boxShadow = '0 1px 3px rgba(0,0,0,0.1)';
          tooltip.style.zIndex = '9999';
          document.body.appendChild(tooltip);
        }
        tooltip.textContent = style.label || '';
        tooltip.style.left = (e.clientX + 12) + 'px';
        tooltip.style.top = (e.clientY - 12) + 'px';
        tooltip.style.display = 'block';

        // Auto-hide after 2 seconds as safety
        tooltipTimeout = setTimeout(hideTooltip, 2000);
      };

      const hideTooltip = () => {
        const tooltip = document.getElementById('g6-port-tooltip');
        if (tooltip) tooltip.style.display = 'none';
      };

      addUniqueEventListener(portShape, 'mouseenter', (e) => {
        // Cancel any pending hide
        if (this._cancelHide) this._cancelHide();
        handlePortHover();
        // Only show tooltip for input ports (output names are auto-generated)
        if (style.type === 'input') {
          showTooltip(e);
        }
      });

      addUniqueEventListener(portShape, 'mouseleave', (e) => {
        // Don't hide indicator on port leave - node mouseleave handles that
        // This prevents the + from reverting to small circle
        hideTooltip();
      });

      // Add click handler on port to trigger add action
      if (graphId && nodeId && style.showGuides) {
        addUniqueEventListener(portShape, 'click', (e) => {
          const connections = getPortConnections(this.context.graph, this.id)?.[portShape.key] ?? 0;
          const atCapacity = connections >= (portShape.arity === "Infinity" ? Infinity : portShape.arity);
          if (!atCapacity && HTMLWidgets.shinyMode) {
            Shiny.setInputValue(
              `${graphId}-selected_port`,
              { node: nodeId, port: portShape.key, type: style.type },
              { priority: 'event' }
            );
          }
          e.stopPropagation();
        });
      }
    }

    createPortShape(shapeKey, style, x, y, container, key) {
      const portShape = this.upsert(shapeKey, GCircle, { ...style }, container);
      if (portShape) {
        portShape.key = key;
        // REMOVE: portShape.connections = style.connections;
        portShape.arity = (style.arity === "Infinity") ? Infinity : style.arity;
      }
      return portShape;
    }

    // Creates an "add" indicator with rotating dashed circle and solid inner circle
    createAddIndicator(key, x, y, radius, accentColor, container, portStyle = {}) {
      const innerRadius = radius * 0.75;

      // Large invisible hit area to catch all pointer events
      // Also serves as the port target for edge creation (shift+drag)
      const hitArea = this.upsert(
        `port-hitarea-${key}`,
        GCircle,
        {
          cx: x,
          cy: y,
          r: radius + 2,
          fill: 'transparent',
          stroke: 'transparent',
          zIndex: 14,
          cursor: 'pointer',
          visibility: 'hidden',
          class: 'port',  // Required for edge creation validation
          type: portStyle.type || 'input',  // For port type validation
          arity: portStyle.arity || 1  // For arity checking
        },
        container
      );
      // Add port properties for edge creation behavior
      hitArea.key = key;
      hitArea.arity = portStyle.arity === "Infinity" ? Infinity : (portStyle.arity || 1);

      // Outer dashed circle that will rotate
      const circle = this.upsert(
        `add-circle-${key}`,
        GCircle,
        {
          cx: x,
          cy: y,
          r: radius,
          fill: 'transparent',
          stroke: accentColor,
          lineWidth: 1.5,
          lineDash: [4, 4],
          zIndex: 15,
          cursor: 'pointer',
          visibility: 'hidden',
          transformOrigin: 'center',
          pointerEvents: 'none'
        },
        container
      );

      // Inner solid circle
      const innerCircle = this.upsert(
        `add-inner-${key}`,
        GCircle,
        {
          cx: x,
          cy: y,
          r: innerRadius,
          fill: accentColor,
          stroke: 'transparent',
          zIndex: 16,
          cursor: 'pointer',
          visibility: 'hidden',
          pointerEvents: 'none'
        },
        container
      );

      // Light plus sign on top of solid circle
      const plus = this.upsert(
        `add-plus-${key}`,
        'text',
        {
          x: x - 0.5,
          y: y - 0.5,
          text: '+',
          fontSize: innerRadius * 1.6,
          fill: '#fff',
          fontWeight: '400',
          textAlign: 'center',
          textBaseline: 'middle',
          zIndex: 17,
          pointerEvents: 'none',
          visibility: 'hidden'
        },
        container
      );

      // Store animation reference
      circle._rotationAnimation = null;

      return { circle, innerCircle, plus, hitArea };
    }

    // Start rotation animation on circle
    startRotationAnimation(circle) {
      if (circle._rotationAnimation) return;

      let rotation = 0;
      const animate = () => {
        rotation = (rotation + 1) % 360;
        circle.attr('transform', `rotate(${rotation}deg)`);
        circle._rotationAnimation = requestAnimationFrame(animate);
      };
      circle._rotationAnimation = requestAnimationFrame(animate);
    }

    // Stop rotation animation
    stopRotationAnimation(circle) {
      if (circle._rotationAnimation) {
        cancelAnimationFrame(circle._rotationAnimation);
        circle._rotationAnimation = null;
        circle.attr('transform', 'rotate(0deg)');
      }
    }

    // Show indicator with fade-in animation (opacity only to avoid flicker)
    showIndicatorWithAnimation(indicator) {
      const { circle, innerCircle, plus } = indicator;

      // Cancel any ongoing hide animation
      if (indicator._hideAnimation) {
        cancelAnimationFrame(indicator._hideAnimation);
        indicator._hideAnimation = null;
      }

      // Don't reset if already visible with full opacity
      if (circle.attr('visibility') === 'visible' && circle.attr('opacity') >= 0.9) {
        return;
      }

      // Make visible first at zero opacity
      circle.attr({ visibility: 'visible', opacity: 0 });
      innerCircle.attr({ visibility: 'visible', opacity: 0 });
      plus.attr({ visibility: 'visible', opacity: 0 });

      // Animate opacity from 0 to 1
      const duration = 500; // ms
      const startTime = performance.now();

      const animate = (currentTime) => {
        const progress = Math.min((currentTime - startTime) / duration, 1);
        // Ease out
        const eased = 1 - Math.pow(1 - progress, 2);

        circle.attr('opacity', eased);
        innerCircle.attr('opacity', eased);
        plus.attr('opacity', eased);

        if (progress < 1) {
          indicator._showAnimation = requestAnimationFrame(animate);
        } else {
          indicator._showAnimation = null;
        }
      };

      indicator._showAnimation = requestAnimationFrame(animate);
    }

    // Hide indicator with fade-out animation
    hideIndicatorWithAnimation(indicator, callback) {
      const { circle, innerCircle, plus } = indicator;

      // Cancel any ongoing show animation
      if (indicator._showAnimation) {
        cancelAnimationFrame(indicator._showAnimation);
        indicator._showAnimation = null;
      }

      const duration = 400; // ms
      const startTime = performance.now();

      const animate = (currentTime) => {
        const progress = Math.min((currentTime - startTime) / duration, 1);
        const opacity = 1 - progress;

        circle.attr('opacity', opacity);
        innerCircle.attr('opacity', opacity);
        plus.attr('opacity', opacity);

        if (progress < 1) {
          indicator._hideAnimation = requestAnimationFrame(animate);
        } else {
          indicator._hideAnimation = null;
          // Hide completely and reset
          circle.attr({ visibility: 'hidden', opacity: 1 });
          innerCircle.attr({ visibility: 'hidden', opacity: 1 });
          plus.attr({ visibility: 'hidden', opacity: 1 });
          if (callback) callback();
        }
      };

      indicator._hideAnimation = requestAnimationFrame(animate);
    }

    // Animate port circles fading in
    animatePortsIn() {
      if (!this._portShapes) return;

      // Cancel any ongoing animation
      if (this._portsAnimation) {
        cancelAnimationFrame(this._portsAnimation);
      }

      const duration = 500; // ms
      const startTime = performance.now();

      const animate = (currentTime) => {
        const progress = Math.min((currentTime - startTime) / duration, 1);
        // Ease out
        const eased = 1 - Math.pow(1 - progress, 2);

        this._portShapes.forEach(({ shape }) => {
          if (shape.attr('visibility') === 'visible') {
            shape.attr('opacity', eased);
          }
        });

        if (progress < 1) {
          this._portsAnimation = requestAnimationFrame(animate);
        } else {
          this._portsAnimation = null;
        }
      };

      this._portsAnimation = requestAnimationFrame(animate);
    }

    // Animate both ports and indicators fading in together
    animateAllIn() {
      if (!this._portShapes) return;

      // Cancel any ongoing animation
      if (this._portsAnimation) {
        cancelAnimationFrame(this._portsAnimation);
      }

      const duration = 500; // ms
      const startTime = performance.now();

      const animate = (currentTime) => {
        const progress = Math.min((currentTime - startTime) / duration, 1);
        // Ease out
        const eased = 1 - Math.pow(1 - progress, 2);

        this._portShapes.forEach(({ shape, indicator }) => {
          // Animate port circles
          if (shape.attr('visibility') === 'visible') {
            shape.attr('opacity', eased);
          }
          // Animate indicators
          if (indicator && indicator.circle.attr('visibility') === 'visible') {
            indicator.circle.attr('opacity', eased);
            indicator.innerCircle.attr('opacity', eased);
            indicator.plus.attr('opacity', eased);
          }
        });

        if (progress < 1) {
          this._portsAnimation = requestAnimationFrame(animate);
        } else {
          this._portsAnimation = null;
        }
      };

      this._portsAnimation = requestAnimationFrame(animate);
    }

    // Creates a rectangular "+" button indicator for the port (legacy)
    createPortPlusIndicator(key, style, x, y, container) {
      const r = style.r || 4;
      const rectSize = r * 3; // Larger rectangular button
      const plusFontSize = rectSize * 0.8;

      // Rectangle background for the plus button
      const rect = this.upsert(
        `port-rect-${key}`,
        'rect',
        {
          x: x - rectSize / 2,
          y: y - rectSize / 2,
          width: rectSize,
          height: rectSize,
          fill: style.fill || '#52C41A',
          stroke: style.stroke || style.fill || '#52C41A',
          lineWidth: 2,
          radius: 3, // Rounded corners
          zIndex: 11,
          cursor: 'copy',
          visibility: 'hidden'
        },
        container
      );

      // Plus sign centered on the rectangle
      const plus = this.upsert(
        `port-plus-${key}`,
        'text',
        {
          x: x,
          y: y,
          text: '+',
          fontSize: plusFontSize,
          fill: '#fff',
          fontWeight: 'bold',
          textAlign: 'center',
          textBaseline: 'middle',
          zIndex: 12,
          pointerEvents: 'none', // Let clicks pass through to rect
          visibility: 'hidden'
        },
        container
      );

      return { rect, plus };
    }

    createConnectionGuide(key, style, x, y, container, graphId, nodeId) {
      const lineLength = 25;
      const rectWidth = 12;
      const rectHeight = 12;
      const plusFontSize = 14;
      const r = style.r || 4;

      let direction = style.placement;
      // If placement is an array, infer direction from coordinates
      if (!['left', 'right', 'top', 'bottom', 'top-left', 'top-right', 'bottom-left', 'bottom-right'].includes(direction) && Array.isArray(style.placement)) {
        const [relX, relY] = style.placement;
        // Handle corners first
        if (relX === 0 && relY === 0) direction = 'top-left';
        else if (relX === 1 && relY === 0) direction = 'top-right';
        else if (relX === 0 && relY === 1) direction = 'bottom-left';
        else if (relX === 1 && relY === 1) direction = 'bottom-right';
        // Then handle sides
        else if (relY === 0) direction = 'top';
        else if (relY === 1) direction = 'bottom';
        else if (relX === 0) direction = 'left';
        else if (relX === 1) direction = 'right';
        // Otherwise pick the closest
        else {
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
      } else if (direction === 'top-left') {
        x1 = x - r * 0.7071;
        y1 = y - r * 0.7071;
        x2 = x1 - lineLength * 0.7071;
        y2 = y1 - lineLength * 0.7071;
        rectX = x2 - rectWidth / 2;
        rectY = y2 - rectHeight / 2;
      } else if (direction === 'top-right') {
        x1 = x + r * 0.7071;
        y1 = y - r * 0.7071;
        x2 = x1 + lineLength * 0.7071;
        y2 = y1 - lineLength * 0.7071;
        rectX = x2 - rectWidth / 2;
        rectY = y2 - rectHeight / 2;
      } else if (direction === 'bottom-left') {
        x1 = x - r * 0.7071;
        y1 = y + r * 0.7071;
        x2 = x1 - lineLength * 0.7071;
        y2 = y1 + lineLength * 0.7071;
        rectX = x2 - rectWidth / 2;
        rectY = y2 - rectHeight / 2;
      } else if (direction === 'bottom-right') {
        x1 = x + r * 0.7071;
        y1 = y + r * 0.7071;
        x2 = x1 + lineLength * 0.7071;
        y2 = y1 + lineLength * 0.7071;
        rectX = x2 - rectWidth / 2;
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
          x: rectX + rectWidth / 2 - 0.5,
          y: rectY + rectHeight / 2 - 0.5,
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
      const bboxPadding = 3;
      const bboxOffset = 10;

      // Compute direction vector (dx, dy) for offset
      let dx = 0, dy = 0;
      if (Array.isArray(style.placement)) {
        // Normalize to [-1, 1]
        dx = (style.placement[0] - 0.5) * 2;
        dy = (style.placement[1] - 0.5) * 2;
        // If exactly center, fallback to direction string
        if (dx === 0 && dy === 0 && typeof direction === "string") {
          if (direction.includes("left")) dx = -1;
          if (direction.includes("right")) dx = 1;
          if (direction.includes("top")) dy = -1;
          if (direction.includes("bottom")) dy = 1;
        }
      } else if (typeof direction === "string") {
        if (direction.includes("left")) dx = -1;
        if (direction.includes("right")) dx = 1;
        if (direction.includes("top")) dy = -1;
        if (direction.includes("bottom")) dy = 1;
      }

      // Normalize diagonal
      if (dx !== 0 && dy !== 0) {
        const norm = Math.sqrt(dx * dx + dy * dy);
        dx /= norm;
        dy /= norm;
      }

      // Offset the bbox start point away from the port
      const minX = Math.min(x1, x2, rectX) - bboxPadding + dx * bboxOffset;
      const maxX = Math.max(x1, x2, rectX + rectWidth) + bboxPadding + dx * bboxOffset;
      const minY = Math.min(y1, y2, rectY) - bboxPadding + dy * bboxOffset;
      const maxY = Math.max(y1, y2, rectY + rectHeight) + bboxPadding + dy * bboxOffset;

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
        const connections = getPortConnections(this.context.graph, this.id)?.[key] ?? 0;
        if (connections < (style.arity === "Infinity" ? Infinity : style.arity)) {
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