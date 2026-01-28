import { Circle, Rect, Ellipse, Diamond, Triangle, Star, Hexagon, Image, Donut } from '@antv/g6';
import { Circle as GCircle, Rect as GRect } from '@antv/g';
import { getPortConnections } from './utils';

// Animation constants
const ANIMATION_DURATION_MS = 500;
const HIDE_DELAY_MS = 400;
const INDICATOR_RADIUS_MULTIPLIER = 2.5;
const INNER_CIRCLE_RATIO = 0.75;
const PLUS_FONT_RATIO = 1.6;

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

// Label colors matching blockr.dock design system
const getLabelColors = () => {
  return {
    background: '#f3f4f6',  // --blockr-grey-100
    border: '#e5e7eb',      // --blockr-grey-200
    text: '#6b7280'         // --blockr-grey-500
  };
}

// Factory to create custom nodes with port key attachment
const createCustomNode = (BaseShape) => {
  return class CustomNode extends BaseShape {
    // Override to apply label colors matching blockr.dock design system
    drawLabelShape(attributes, container) {
      const colors = getLabelColors();

      // Selection style constants (must match events.js SELECTED_LABEL_STYLE)
      const SELECTION_BG_FILL = '#dbeafe';
      const SELECTION_BG_STROKE = '#0D99FF';
      const SELECTION_FONT_WEIGHT = 700;

      if (attributes.labelText) {
        // Check if this node has selection styling applied
        // G6 puts updateNodeData style values directly on attributes
        const isSelected = attributes.labelBackgroundFill === SELECTION_BG_FILL ||
                          attributes.labelFontWeight === SELECTION_FONT_WEIGHT;

        // Apply selection style if selected, otherwise use defaults
        attributes = {
          ...attributes,
          labelFill: colors.text,
          labelBackground: true,
          labelBackgroundFill: isSelected ? SELECTION_BG_FILL : colors.background,
          labelBackgroundStroke: isSelected ? SELECTION_BG_STROKE : colors.border,
          labelBackgroundLineWidth: 1,
          labelBackgroundRadius: 4,
          labelBackgroundOpacity: 1,
          labelPadding: [1, 6, 1, 6],
          labelFontSize: 11,
          labelFontWeight: isSelected ? SELECTION_FONT_WEIGHT : 500
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

        // Determine initial visibility based on visibility parameter
        // "visible" = always shown, "hover" = show on hover, "hidden" = never shown
        const portVisibility = style.visibility || 'visible';
        const initiallyVisible = portVisibility === 'visible';

        // Solid filled port circle for occupied ports
        const portStyle = {
          ...style,
          zIndex: 1,
          r: baseRadius,
          fill: style.fill,
          stroke: 'transparent',
          lineWidth: 0,
          visibility: initiallyVisible ? 'visible' : 'hidden',
          class: 'port'  // Required for edge creation validation
        };
        const portShape = this.createPortShape(`port-${key}`, portStyle, x, y, container, key);

        // Store for hover expansion
        portShape._baseRadius = baseRadius;
        portShape._expandedRadius = baseRadius * INDICATOR_RADIUS_MULTIPLIER;
        portShape._originalFill = style.fill;
        portShape._visibility = portVisibility;  // Store visibility mode

        // Create add indicator with block's accent color
        // Pass style for arity/type needed for edge creation
        const addIndicator = this.createAddIndicator(key, x, y, baseRadius * INDICATOR_RADIUS_MULTIPLIER, style.fill, container, style);
        addIndicator._visibility = portVisibility;  // Store visibility mode on indicator too

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
          // Skip ports with visibility "hidden" or "visible" (visible ports are always shown)
          const visibilityMode = shape._visibility || 'visible';
          if (visibilityMode === 'hidden') return;  // Never show hidden ports
          if (visibilityMode === 'visible') return;  // Already visible, no hover behavior needed

          // Only "hover" mode ports need show/hide on hover
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
            // Only hide "hover" mode ports; "visible" ports stay visible
            const visibilityMode = shape._visibility || 'visible';
            if (visibilityMode !== 'hover') return;

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
        }, HIDE_DELAY_MS);
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
          // Only hide "hover" mode ports; "visible" ports stay visible
          const visibilityMode = shape._visibility || 'visible';
          if (visibilityMode !== 'hover') return;

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
      // Note: Click handlers removed - edge creation now handles port interactions via drag
      // Only add hover events if port is not hidden
      if (indicator && indicator.hitArea && graphId && nodeId && style.visibility !== 'hidden') {
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
        // Only show tooltip for input ports with labels
        if (style.type === 'input' && style.label) {
          showTooltip(e);
        }
      });

      addUniqueEventListener(portShape, 'mouseleave', (e) => {
        // Don't hide indicator on port leave - node mouseleave handles that
        // This prevents the + from reverting to small circle
        hideTooltip();
      });

      // Note: Click handler removed - edge creation now handles port interactions via drag
      // Dropping on canvas triggers append_block_action, dropping on port creates edge
    }

    createPortShape(shapeKey, style, x, y, container, key) {
      const portShape = this.upsert(shapeKey, GCircle, { ...style }, container);
      if (portShape) {
        portShape.key = key;
        portShape.arity = (style.arity === "Infinity") ? Infinity : style.arity;
      }
      return portShape;
    }

    // Creates an "add" indicator with rotating dashed circle and solid inner circle
    createAddIndicator(key, x, y, radius, accentColor, container, portStyle = {}) {
      const innerRadius = radius * INNER_CIRCLE_RATIO;

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
          fontSize: innerRadius * PLUS_FONT_RATIO,
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
      const duration = ANIMATION_DURATION_MS;
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

      const duration = HIDE_DELAY_MS;
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

    // Animate both ports and indicators fading in together
    animateAllIn() {
      if (!this._portShapes) return;

      // Cancel any ongoing animation
      if (this._portsAnimation) {
        cancelAnimationFrame(this._portsAnimation);
      }

      const duration = ANIMATION_DURATION_MS;
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
