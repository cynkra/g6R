import { Circle, Rect, Ellipse, Diamond, Triangle, Star, Hexagon, Image, Donut, GraphEvent } from '@antv/g6';
import { Circle as GCircle, Rect as GRect } from '@antv/g';
import { getPortConnections } from './utils';

// Map to store node port refresh functions for edge creation events
const nodePortRefreshFunctions = new Map();

// Animation constants
const ANIMATION_DURATION_MS = 500;
const HIDE_DELAY_MS = 400;
const INDICATOR_RADIUS_MULTIPLIER = 2.5;
const INNER_CIRCLE_RATIO = 0.75;
const PLUS_FONT_RATIO = 1.6;

// To add event listener only once because of re-renders
const addUniqueEventListener = (element, type, listener) => {
  const flag = `_hasListener_${type}`;
  if (!element[flag]) {
    element.addEventListener(type, listener);
    element[flag] = true;
  }
}

let currentlyHoveredNode = null;

const getContrastColor = (bg) => {
  let c = bg.replace('#', '');
  if (c.length === 3) c = c.split('').map(x => x + x).join('');
  const r = parseInt(c.substr(0, 2), 16);
  const g = parseInt(c.substr(2, 2), 16);
  const b = parseInt(c.substr(4, 2), 16);
  const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
  return luminance > 0.5 ? '#000' : '#fff';
};

const createShowPortsHandler = (ctx) => () => {
  ctx.isHoveringNode = true;
  if (ctx.hideTimeout) {
    clearTimeout(ctx.hideTimeout);
    ctx.hideTimeout = null;
  }
  if (currentlyHoveredNode && currentlyHoveredNode !== ctx.self) {
    currentlyHoveredNode._hidePortsImmediately?.();
  }
  currentlyHoveredNode = ctx.self;
  if (!ctx.self._portShapes) return;
  const portConnections = getPortConnections(ctx.self.context.graph, ctx.self.id) || {};
  let needsAnimation = false;
  ctx.self._portShapes.forEach(({ shape, indicator }) => {
    const visibilityMode = shape._visibility || 'visible';
    if (visibilityMode === 'hidden') return;
    const connections = portConnections[shape.key] ?? 0;
    const arity = shape.arity === "Infinity" ? Infinity : (shape.arity || 1);
    const atCapacity = connections >= arity;
    if (!atCapacity && indicator) {
      shape.attr({ visibility: 'hidden' });
      if (indicator.circle.attr('visibility') !== 'visible') {
        if (indicator.hitArea) indicator.hitArea.attr({ visibility: 'visible' });
        indicator.circle.attr({ visibility: 'visible', opacity: 0 });
        indicator.innerCircle.attr({ visibility: 'visible', opacity: 0 });
        indicator.plus.attr({ visibility: 'visible', opacity: 0 });
        needsAnimation = true;
      }
      ctx.self.startRotationAnimation(indicator.circle);
    } else {
      if (indicator) {
        ctx.self.stopRotationAnimation(indicator.circle);
        indicator.circle.attr({ visibility: 'hidden' });
        indicator.innerCircle.attr({ visibility: 'hidden' });
        indicator.plus.attr({ visibility: 'hidden' });
      }
      if (shape.attr('visibility') !== 'visible') {
        shape.attr({
          visibility: 'visible',
          zIndex: 10,
          opacity: 0
        });
        needsAnimation = true;
      } else {
        shape.attr({ opacity: 1 });
      }
    }
  });
  if (needsAnimation) {
    ctx.self.animateAllIn();
  }
};

const createHidePortsHandler = (ctx) => () => {
  ctx.isHoveringNode = false;
  ctx.hideTimeout = setTimeout(() => {
    if (!ctx.self._portShapes) return;
    if (ctx.self._portsAnimation) {
      cancelAnimationFrame(ctx.self._portsAnimation);
      ctx.self._portsAnimation = null;
    }
    ctx.self._portShapes.forEach(({ shape, indicator }) => {
      const visibilityMode = shape._visibility || 'visible';
      if (visibilityMode === 'hover') {
        shape.attr({
          visibility: 'hidden',
          zIndex: 1,
          r: shape._baseRadius,
          opacity: 1
        });
        if (indicator?.hitArea) indicator.hitArea.attr({ visibility: 'hidden' });
      } else if (visibilityMode === 'visible') {
        shape.attr({
          visibility: 'visible',
          zIndex: 1,
          r: shape._baseRadius,
          opacity: 1
        });
      }
      if (indicator) {
        ctx.self.stopRotationAnimation(indicator.circle);
        indicator.circle.attr({ visibility: 'hidden', opacity: 1 });
        indicator.innerCircle.attr({ visibility: 'hidden', opacity: 1 });
        indicator.plus.attr({ visibility: 'hidden', opacity: 1 });
      }
    });
  }, HIDE_DELAY_MS);
};

const createHidePortsImmediateHandler = (ctx) => () => {
  ctx.isHoveringNode = false;
  if (ctx.hideTimeout) {
    clearTimeout(ctx.hideTimeout);
    ctx.hideTimeout = null;
  }
  if (ctx.self._portsAnimation) {
    cancelAnimationFrame(ctx.self._portsAnimation);
    ctx.self._portsAnimation = null;
  }
  if (!ctx.self._portShapes) return;
  ctx.self._portShapes.forEach(({ shape, indicator }) => {
    const visibilityMode = shape._visibility || 'visible';
    if (visibilityMode === 'hover') {
      shape.attr({ visibility: 'hidden', opacity: 1 });
      if (indicator?.hitArea) indicator.hitArea.attr({ visibility: 'hidden' });
    } else if (visibilityMode === 'visible') {
      shape.attr({ visibility: 'visible', opacity: 1 });
    }
    if (indicator) {
      ctx.self.stopRotationAnimation(indicator.circle);
      indicator.circle.attr({ visibility: 'hidden', opacity: 1 });
      indicator.innerCircle.attr({ visibility: 'hidden', opacity: 1 });
      indicator.plus.attr({ visibility: 'hidden', opacity: 1 });
    }
  });
};

// --- Extracted helpers for addPortEvents ---

const showTooltip = (e, style) => {
  if (showTooltip.timeout) {
    clearTimeout(showTooltip.timeout);
    showTooltip.timeout = null;
  }
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
  showTooltip.timeout = setTimeout(hideTooltip, 2000);
};

const hideTooltip = () => {
  const tooltip = document.getElementById('g6-port-tooltip');
  if (tooltip) tooltip.style.display = 'none';
};

// --- Helpers to create indicator shapes ---

const createIndicatorHitArea = (self, key, x, y, radius, container, portStyle) =>
  self.upsert(
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
      class: 'port',
      type: portStyle.type || 'input',
      arity: portStyle.arity || 1
    },
    container
  );

const createIndicatorCircle = (self, key, x, y, radius, accentColor, container) =>
  self.upsert(
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

const createIndicatorInnerCircle = (self, key, x, y, innerRadius, accentColor, container) =>
  self.upsert(
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

const createIndicatorPlus = (self, key, x, y, innerRadius, container) =>
  self.upsert(
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

// --- Port events helpers ---

const handlePortIndicatorClick = (self, portShape, style, indicator, graphId, nodeId) => (e) => {
  const connections = getPortConnections(self.context.graph, self.id)?.[portShape.key] ?? 0;
  const arity = portShape.arity === "Infinity" ? Infinity : (portShape.arity || 1);
  const atCapacity = connections >= arity;
  if (atCapacity) {
    e.stopPropagation();
    return;
  }
  if (HTMLWidgets.shinyMode) {
    Shiny.setInputValue(
      `${graphId}-selected_port`,
      { node: nodeId, port: portShape.key, type: style.type },
      { priority: 'event' }
    );
  }
  e.stopPropagation();
};

const handlePortIndicatorMouseEnter = (self, portShape, style, indicator) => (e) => {
  if (self._cancelHide) self._cancelHide();
  if (style.label) showTooltip(e, style);
  const connections = getPortConnections(self.context.graph, self.id)?.[portShape.key] ?? 0;
  const atCapacity = connections >= (portShape.arity === "Infinity" ? Infinity : portShape.arity);
  if (atCapacity) return;
  portShape.attr({ visibility: 'hidden' });
  self.showIndicatorWithAnimation(indicator);
  self.startRotationAnimation(indicator.circle);
};

const handlePortIndicatorMouseLeave = (self) => (e) => {
  hideTooltip();
  if (self._hidePorts) self._hidePorts();
};

// --- Hover Handlers ---

const getKeyShape = (container) =>
  container.querySelector('[class*="key"]') || container.children?.[0];

const setupNodeHoverContext = (self) => ({
  self,
  hideTimeout: null,
  isHoveringNode: false
});

const registerNodePortRefresh = (nodeId, showPorts) => {
  nodePortRefreshFunctions.set(String(nodeId), showPorts);
};

const ensureEdgeCreatedListener = (graph) => {
  if (!graph._hasEdgeCreatedListener) {
    graph._hasEdgeCreatedListener = true;
    graph.on(GraphEvent.AFTER_ELEMENT_CREATE, (evt) => {
      if (evt.elementType === 'edge') {
        const edgeData = evt.data;
        const sourceId = String(edgeData.source);
        const targetId = String(edgeData.target);
        if (nodePortRefreshFunctions.has(sourceId)) {
          nodePortRefreshFunctions.get(sourceId)();
        }
        if (nodePortRefreshFunctions.has(targetId)) {
          nodePortRefreshFunctions.get(targetId)();
        }
      }
    });
  }
};

const makeCancelHide = (ctx) => () => {
  if (ctx.hideTimeout) {
    clearTimeout(ctx.hideTimeout);
    ctx.hideTimeout = null;
  }
};

const makeIsHoveringNode = (ctx) => () => ctx.isHoveringNode;

// --- Port shape helpers ---

const createPortShapeForKey = (self, key, style, baseRadius, container, portVisibility) => {
  const portStyle = {
    ...style,
    zIndex: 1,
    r: baseRadius,
    fill: style.fill,
    stroke: 'transparent',
    lineWidth: 0,
    visibility: portVisibility === 'visible' ? 'visible' : 'hidden',
    pointerEvents: 'none',
    class: 'port'
  };
  const portShape = self.createPortShape(`port-${key}`, portStyle, container, key);
  portShape._baseRadius = baseRadius;
  portShape._expandedRadius = baseRadius * INDICATOR_RADIUS_MULTIPLIER;
  portShape._originalFill = style.fill;
  portShape._visibility = portVisibility;
  return portShape;
};

const createIndicatorForKey = (self, key, x, y, baseRadius, style, container, portVisibility) => {
  const indicator = self.createAddIndicator(
    key,
    x,
    y,
    baseRadius * INDICATOR_RADIUS_MULTIPLIER,
    style.fill,
    container,
    style
  );
  indicator._visibility = portVisibility;
  return indicator;
};

// --- Main class ---

const createCustomNode = (BaseShape) => {
  return class CustomNode extends BaseShape {
    // inside your CustomNode class
    drawPortShapes(attributes, container) {
      const portsStyle = this.getPortsStyle(attributes);
      const graphId = this.context.graph.options.container;
      this._portShapes = [];

      Object.keys(portsStyle).forEach((key) => {
        const style = portsStyle[key];
        if (!style) return;
        const [x, y] = this.getPortXY(attributes, style);
        const baseRadius = style.r || 4;
        const portVisibility = style.visibility || 'visible';
        const initiallyVisible = portVisibility === 'visible';

        const portShape = createPortShapeForKey(this, key, style, baseRadius, container, portVisibility);
        const indicator = createIndicatorForKey(this, key, x, y, baseRadius, style, container, portVisibility);

        if (initiallyVisible && indicator.hitArea) {
          indicator.hitArea.attr({ visibility: 'visible' });
        }
        this._portShapes.push({ shape: portShape, indicator });
        this.addPortEvents(portShape, style, indicator, graphId, this.id);
      });

      this.addNodeHoverHandlers(container);
    }

    // inside your CustomNode class

    addNodeHoverHandlers(container) {
      const keyShape = getKeyShape(container);
      if (!keyShape || keyShape._hasZIndexHover) return;
      keyShape._hasZIndexHover = true;

      const ctx = setupNodeHoverContext(this);
      const showPorts = createShowPortsHandler(ctx);
      const hidePorts = createHidePortsHandler(ctx);
      const hidePortsImmediately = createHidePortsImmediateHandler(ctx);

      this._showPorts = showPorts;
      this._hidePorts = hidePorts;
      this._hidePortsImmediately = hidePortsImmediately;
      this._cancelHide = makeCancelHide(ctx);
      this._isHoveringNode = makeIsHoveringNode(ctx);

      addUniqueEventListener(keyShape, 'mouseenter', showPorts);
      addUniqueEventListener(keyShape, 'mouseleave', hidePorts);

      registerNodePortRefresh(this.id, showPorts);
      ensureEdgeCreatedListener(this.context.graph);
    }

    addPortEvents(portShape, style, indicator = null, graphId = null, nodeId = null) {
      if (indicator && indicator.hitArea && graphId && nodeId && style.visibility !== 'hidden') {
        addUniqueEventListener(
          indicator.hitArea,
          'click',
          handlePortIndicatorClick(this, portShape, style, indicator, graphId, nodeId)
        );
        addUniqueEventListener(
          indicator.hitArea,
          'mouseenter',
          handlePortIndicatorMouseEnter(this, portShape, style, indicator)
        );
        addUniqueEventListener(
          indicator.hitArea,
          'mouseleave',
          handlePortIndicatorMouseLeave(this)
        );
      }
    }

    createPortShape(shapeKey, style, container, key) {
      const portShape = this.upsert(shapeKey, GCircle, { ...style }, container);
      if (portShape) {
        portShape.key = key;
        portShape.arity = (style.arity === "Infinity") ? Infinity : style.arity;
      }
      return portShape;
    }

    createAddIndicator(key, x, y, radius, accentColor, container, portStyle = {}) {
      const innerRadius = radius * INNER_CIRCLE_RATIO;
      const hitArea = createIndicatorHitArea(this, key, x, y, radius, container, portStyle);
      hitArea.key = key;
      hitArea.arity = portStyle.arity === "Infinity" ? Infinity : (portStyle.arity || 1);

      const circle = createIndicatorCircle(this, key, x, y, radius, accentColor, container);
      const innerCircle = createIndicatorInnerCircle(this, key, x, y, innerRadius, accentColor, container);
      const plus = createIndicatorPlus(this, key, x, y, innerRadius, container);

      circle._rotationAnimation = null;
      return { circle, innerCircle, plus, hitArea };
    }

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

    stopRotationAnimation(circle) {
      if (circle._rotationAnimation) {
        cancelAnimationFrame(circle._rotationAnimation);
        circle._rotationAnimation = null;
        circle.attr('transform', 'rotate(0deg)');
      }
    }

    showIndicatorWithAnimation(indicator) {
      const { circle, innerCircle, plus } = indicator;
      if (indicator._hideAnimation) {
        cancelAnimationFrame(indicator._hideAnimation);
        indicator._hideAnimation = null;
      }
      if (circle.attr('visibility') === 'visible' && circle.attr('opacity') >= 0.9) {
        return;
      }
      circle.attr({ visibility: 'visible', opacity: 0 });
      innerCircle.attr({ visibility: 'visible', opacity: 0 });
      plus.attr({ visibility: 'visible', opacity: 0 });
      const duration = ANIMATION_DURATION_MS;
      const startTime = performance.now();
      const animate = (currentTime) => {
        const progress = Math.min((currentTime - startTime) / duration, 1);
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

    hideIndicatorWithAnimation(indicator, callback) {
      const { circle, innerCircle, plus } = indicator;
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
          circle.attr({ visibility: 'hidden', opacity: 1 });
          innerCircle.attr({ visibility: 'hidden', opacity: 1 });
          plus.attr({ visibility: 'hidden', opacity: 1 });
          if (callback) callback();
        }
      };
      indicator._hideAnimation = requestAnimationFrame(animate);
    }

    animateAllIn() {
      if (!this._portShapes) return;
      if (this._portsAnimation) {
        cancelAnimationFrame(this._portsAnimation);
      }
      const duration = ANIMATION_DURATION_MS;
      const startTime = performance.now();
      const animate = (currentTime) => {
        const progress = Math.min((currentTime - startTime) / duration, 1);
        const eased = 1 - Math.pow(1 - progress, 2);
        this._portShapes.forEach(({ shape, indicator }) => {
          if (shape.attr('visibility') === 'visible') {
            shape.attr('opacity', eased);
          }
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
};

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