import {
  Circle, Rect, Ellipse, Diamond, Triangle, Star, Hexagon, Image, Donut, GraphEvent, Badge, CommonEvent
} from '@antv/g6';
import { Circle as GCircle, Rect as GRect, Group } from '@antv/g';
import { getPortConnections } from './utils';
import { reapplyComboCollapseState, ensureProxyEdges, collapsedCombos, PROXY_EDGE_PREFIX } from './extensions';

// Map to store node port refresh functions for edge creation events
const nodePortRefreshFunctions = new Map();

// Force all combos to recalculate their bounds based on current child visibility.
// graph.draw() alone is insufficient because hideElement/showElement only marks
// child nodes as changed, not the parent combos, so combos never re-render.
const refreshComboBounds = (graph) => {
  const combos = graph.getComboData();
  for (const combo of combos) {
    // Skip hidden combos — no need to recalculate their bounds
    if (combo.style?.visibility === 'hidden') continue;
    const el = graph.context.element?.getElement(combo.id);
    if (el) {
      const style = graph.context.element.getElementComputedStyle('combo', combo);
      el.update(style);
    }
  }
};

// After DAG collapse/expand, hide combos whose member nodes are ALL hidden,
// and restore them when at least one member becomes visible again.
const refreshComboVisibility = async (graph) => {
  const combos = graph.getComboData();
  if (!combos || combos.length === 0) return;

  const allNodes = graph.getNodeData();

  // Build combo → member nodes map
  const comboMembers = {};
  for (const node of allNodes) {
    const comboId = node.combo;
    if (!comboId) continue;
    if (!comboMembers[comboId]) comboMembers[comboId] = [];
    comboMembers[comboId].push(node);
  }

  const toHide = [];
  const toShow = [];

  for (const combo of combos) {
    const members = comboMembers[combo.id];
    if (!members || members.length === 0) continue;

    const allHidden = members.every((n) => n.style?.visibility === 'hidden');
    const comboIsHidden = combo.style?.visibility === 'hidden';

    if (allHidden && !comboIsHidden) {
      // Never auto-hide a combo that is explicitly collapsed via the combo button
      // (those stay visible with a "+N" badge)
      if (!collapsedCombos.has(combo.id)) {
        toHide.push(combo.id);
      }
    } else if (!allHidden && comboIsHidden) {
      // Always allow showing a combo when members become visible again
      toShow.push(combo.id);
    }
  }

  if (toHide.length > 0) await graph.hideElement(toHide, false);
  if (toShow.length > 0) await graph.showElement(toShow, false);
};

// After DAG collapse/expand, update all overlay plugins (BubbleSets, Hull)
// so that hidden members are temporarily removed from the shape.  We store
// the full original member list on each plugin instance (_g6rOriginalMembers)
// so that members can be restored when they become visible again.
const refreshOverlayPlugins = (graph) => {
  const pluginMap = graph.context?.plugin?.extensionMap;
  if (!pluginMap) return;

  for (const instance of Object.values(pluginMap)) {
    // Duck-type check for overlay plugins (BubbleSets, Hull)
    if (typeof instance.getMember !== 'function' || typeof instance.updateMember !== 'function') continue;

    // Store the full original member list once
    if (!instance._g6rOriginalMembers) {
      instance._g6rOriginalMembers = [...instance.getMember()];
    }

    // Filter to only include members whose elements are currently visible
    const visibleMembers = instance._g6rOriginalMembers.filter((id) => {
      try {
        const type = graph.getElementType(id);
        if (type === 'edge') {
          const data = graph.getEdgeData(id);
          return data?.style?.visibility !== 'hidden';
        } else {
          const data = graph.getNodeData(id);
          return data?.style?.visibility !== 'hidden';
        }
      } catch (_) {
        // Element may not exist (removed) — exclude it
        return false;
      }
    });

    instance.updateMember(visibleMembers);
  }
};

// Track DAG-collapsed nodes independently from G6's tree model
// (G6's tree model only supports one parent per node, which breaks DAG collapse)
const dagCollapsedNodes = new Set();

// Animation constants
const ANIMATION_DURATION_MS = 500;
const HIDE_DELAY_MS = 0;
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
  ctx.self.showCollapseButton?.();
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
    ctx.self.hideCollapseButton?.();
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
  ctx.self.hideCollapseButtonImmediate?.();
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

// Helper to get port zIndex from attributes, with fallback
const getPortZIndex = (attributes) => {
  return typeof attributes.portZIndex === 'number' ? attributes.portZIndex : 10;
}

const createIndicatorHitArea = (self, key, x, y, radius, container, portStyle, portZIndex) =>
  self.upsert(
    `port-hitarea-${key}`,
    GCircle,
    {
      cx: x,
      cy: y,
      r: radius + 2,
      fill: 'transparent',
      stroke: 'transparent',
      zIndex: portZIndex + 1,
      cursor: 'pointer',
      visibility: 'hidden',
      class: 'port',
      type: portStyle.type || 'input',
      arity: portStyle.arity || 1
    },
    container
  );

const createIndicatorCircle = (self, key, x, y, radius, accentColor, container, portZIndex) =>
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
      zIndex: portZIndex + 2,
      cursor: 'pointer',
      visibility: 'hidden',
      transformOrigin: 'center',
      pointerEvents: 'none'
    },
    container
  );

const createIndicatorInnerCircle = (self, key, x, y, innerRadius, accentColor, container, portZIndex) =>
  self.upsert(
    `add-inner-${key}`,
    GCircle,
    {
      cx: x,
      cy: y,
      r: innerRadius,
      fill: accentColor,
      stroke: 'transparent',
      zIndex: portZIndex + 3,
      cursor: 'pointer',
      visibility: 'hidden',
      pointerEvents: 'none'
    },
    container
  );

const createIndicatorPlus = (self, key, x, y, innerRadius, container, portZIndex) =>
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
      zIndex: portZIndex + 4,
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

const createPortShapeForKey = (self, key, style, baseRadius, container, portVisibility, portZIndex) => {
  const portStyle = {
    ...style,
    zIndex: portZIndex,
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

const createIndicatorForKey = (self, key, x, y, baseRadius, style, container, portVisibility, portZIndex) => {
  const indicator = self.createAddIndicator(
    key,
    x,
    y,
    baseRadius * INDICATOR_RADIUS_MULTIPLIER,
    style.fill,
    container,
    style,
    portZIndex
  );
  indicator._visibility = portVisibility;
  return indicator;
};

// --- Main class ---

const createCustomNode = (BaseShape) => {
  return class CustomNode extends BaseShape {

    childrenData() {
      return this.context.model.getChildrenData(this.id) || [];
    }

    getNodeDepth() {
      const allEdges = this.context.graph.getEdgeData();
      const parentMap = {};
      allEdges.forEach(edge => {
        if (!parentMap[edge.target]) parentMap[edge.target] = [];
        parentMap[edge.target].push(edge.source);
      });
      let depth = 0;
      let current = new Set([this.id]);
      const visited = new Set([this.id]);
      while (current.size > 0) {
        let foundRoot = false;
        for (const id of current) {
          if (!parentMap[id] || parentMap[id].length === 0) {
            foundRoot = true;
            break;
          }
        }
        if (foundRoot) return depth;
        depth++;
        const next = new Set();
        for (const id of current) {
          for (const p of (parentMap[id] || [])) {
            if (!visited.has(p)) {
              visited.add(p);
              next.add(p);
            }
          }
        }
        current = next;
      }
      return 0;
    }

    drawCollapseButton(attributes) {
      // Check both the attributes and the node data for children
      const childrenFromAttributes = attributes.children || [];
      const nodeData = this.context.graph.getNodeData(this.id);
      const childrenFromNodeData = nodeData?.children || [];
      const childrenFromModel = this.childrenData();
      const hasChildren = childrenFromAttributes.length > 0 ||
        childrenFromNodeData.length > 0 ||
        childrenFromModel.length > 0;

      // If no children, remove collapse button if it exists
      if (!hasChildren) {
        const existingButton = this.shapeMap['collapse-button'];
        const existingHitArea = this.shapeMap['collapse-hit-area'];
        if (existingButton) {
          existingButton.remove();
          delete this.shapeMap['collapse-button'];
        }
        if (existingHitArea) {
          existingHitArea.remove();
          delete this.shapeMap['collapse-hit-area'];
        }
        return;
      }

      // Depth gate: -1 disables all collapsing, otherwise only show if depth <= maxCollapseDepth
      const maxCollapseDepth = this.context.graph.options.maxCollapseDepth ?? Infinity;
      if (maxCollapseDepth === -1 || (maxCollapseDepth !== Infinity && this.getNodeDepth() > maxCollapseDepth)) {
        const existingButton = this.shapeMap['collapse-button'];
        const existingHitArea = this.shapeMap['collapse-hit-area'];
        if (existingButton) {
          existingButton.remove();
          delete this.shapeMap['collapse-button'];
        }
        if (existingHitArea) {
          existingHitArea.remove();
          delete this.shapeMap['collapse-hit-area'];
        }
        return;
      }

      // If no collapse config, don't show collapse button
      if (!attributes.collapse) {
        const existingButton = this.shapeMap['collapse-button'];
        const existingHitArea = this.shapeMap['collapse-hit-area'];
        if (existingButton) {
          existingButton.remove();
          delete this.shapeMap['collapse-button'];
        }
        if (existingHitArea) {
          existingHitArea.remove();
          delete this.shapeMap['collapse-hit-area'];
        }
        return;
      }

      // Get collapse configuration from attributes
      const collapseConfig = attributes.collapse;

      const collapsed = dagCollapsedNodes.has(this.id) || collapseConfig.collapsed || attributes.collapsed || false;
      const [width, height] = this.getSize(attributes);

      // Get position from placement
      const placement = collapseConfig.placement || 'right-top';
      let x, y;

      if (Array.isArray(placement)) {
        // Custom coordinates [x, y] where values are between 0-1
        x = (placement[0] - 0.5) * width;
        y = (placement[1] - 0.5) * height;
      } else {
        // Named placement
        switch (placement) {
          case 'top':
            x = 0;
            y = -height / 2;
            break;
          case 'right':
            x = width / 2;
            y = 0;
            break;
          case 'bottom':
            x = 0;
            y = height / 2;
            break;
          case 'left':
            x = -width / 2;
            y = 0;
            break;
          case 'right-top':
            x = width / 2;
            y = -height / 2;
            break;
          case 'right-bottom':
            x = width / 2;
            y = height / 2;
            break;
          case 'left-top':
            x = -width / 2;
            y = -height / 2;
            break;
          case 'left-bottom':
            x = -width / 2;
            y = height / 2;
            break;
          default:
            x = width / 2;
            y = -height / 2;
        }
      }

      const btnR = collapseConfig.r || 8;

      // Path for minus sign
      const collapsePath = [
        ['M', x - btnR + 4, y],
        ['L', x + btnR - 4, y]
      ];

      // Path for plus sign
      const expandPath = [
        ['M', x - btnR + 4, y],
        ['L', x + btnR - 4, y],
        ['M', x, y - btnR + 4],
        ['L', x, y + btnR - 4]
      ];

      const d = collapsed ? expandPath : collapsePath;

      // Determine collapse button visibility mode
      const collapseVisibility = collapseConfig.visibility || 'visible';
      this._collapseVisibility = collapseVisibility;
      // When collapsed, always show the button + count (even in hover mode)
      const initiallyVisible = collapsed || collapseVisibility === 'visible' ||
        (collapseVisibility === 'hover' && this._isHoveringNode?.());
      this._isCollapsed = collapsed;

      // When collapsed, compute label text "+ N"
      let collapseLabel = null;
      if (collapsed) {
        const { descendants } = this.collectDAGDescendants(this.id);
        collapseLabel = `+ ${descendants.length}`;
      }

      // Measure width needed: use pill shape for collapsed (wider), circle for expanded
      const labelPadding = btnR * 0.4;
      const fontSize = btnR * 1.1;
      // Estimate text width: each character roughly 0.55 * fontSize
      const textWidth = collapseLabel ? collapseLabel.length * fontSize * 0.55 : 0;
      const pillWidth = collapseLabel ? textWidth + labelPadding * 2 : 0;

      if (collapsed) {
        // Remove circle hit-area if switching from expanded
        const existingCircle = this.shapeMap['collapse-hit-area'];
        if (existingCircle) {
          existingCircle.remove();
          delete this.shapeMap['collapse-hit-area'];
        }
        // Pill-shaped hit area for "+ N"
        const isLeftSide = typeof placement === 'string' && placement.startsWith('left');
        const pillX = isLeftSide ? x - pillWidth / 2 : x - pillWidth / 2;
        this.upsert('collapse-hit-area', 'rect', {
          x: pillX,
          y: y - btnR,
          width: pillWidth,
          height: btnR * 2,
          radius: btnR,
          fill: collapseConfig.fill || '#fff',
          stroke: collapseConfig.stroke || '#CED4D9',
          lineWidth: collapseConfig.lineWidth || 1,
          cursor: collapseConfig.cursor || 'pointer',
          zIndex: collapseConfig.zIndex || 999,
          visibility: 'visible',
          opacity: 1
        }, this);

        // "+ N" text label replaces the path button
        const existingPath = this.shapeMap['collapse-button'];
        if (existingPath) {
          existingPath.remove();
          delete this.shapeMap['collapse-button'];
        }
        this.upsert('collapse-button', 'text', {
          x: x,
          y: y,
          text: collapseLabel,
          fontSize: fontSize,
          fontWeight: 'bold',
          fill: collapseConfig.iconStroke || '#000',
          textAlign: 'center',
          textBaseline: 'middle',
          cursor: collapseConfig.cursor || 'pointer',
          zIndex: (collapseConfig.zIndex || 999) + 1,
          visibility: 'visible',
          opacity: 1
        }, this.shapeMap['collapse-hit-area']);
      } else {
        // Remove rect hit-area if switching from collapsed
        const existingRect = this.shapeMap['collapse-hit-area'];
        if (existingRect) {
          existingRect.remove();
          delete this.shapeMap['collapse-hit-area'];
        }
        // Circle hit area for "-"
        this.upsert('collapse-hit-area', 'circle', {
          cx: x,
          cy: y,
          r: btnR,
          fill: collapseConfig.fill || '#fff',
          stroke: collapseConfig.stroke || '#CED4D9',
          lineWidth: collapseConfig.lineWidth || 1,
          cursor: collapseConfig.cursor || 'pointer',
          zIndex: collapseConfig.zIndex || 999,
          visibility: initiallyVisible ? 'visible' : 'hidden',
          opacity: initiallyVisible ? 1 : 0
        }, this);

        // Remove text button if switching from collapsed
        const existingText = this.shapeMap['collapse-button'];
        if (existingText) {
          existingText.remove();
          delete this.shapeMap['collapse-button'];
        }
        // Minus path button
        this.upsert('collapse-button', 'path', {
          d: d,
          stroke: collapseConfig.iconStroke || '#000',
          lineWidth: collapseConfig.iconLineWidth || 1.4,
          cursor: collapseConfig.cursor || 'pointer',
          zIndex: (collapseConfig.zIndex || 999) + 1,
          visibility: initiallyVisible ? 'visible' : 'hidden',
          opacity: initiallyVisible ? 1 : 0
        }, this.shapeMap['collapse-hit-area']);
      }

      // Remove separate count label (no longer used)
      const existingCount = this.shapeMap['collapse-count'];
      if (existingCount) {
        existingCount.remove();
        delete this.shapeMap['collapse-count'];
      }

      // Bind click listener (only once)
      this.bindCollapseListener();

      // When hover mode, ensure hover handlers exist even without ports,
      // and add mouseenter/mouseleave on the hit-area to prevent flickering
      // (same pattern ports use to keep the node "hovered" while over the indicator)
      if (collapseVisibility === 'hover') {
        this.addNodeHoverHandlers(this._renderContainer || this);
        const hitArea = this.shapeMap['collapse-hit-area'];
        addUniqueEventListener(hitArea, 'mouseenter', () => {
          if (this._showPorts) this._showPorts();
        });
        addUniqueEventListener(hitArea, 'mouseleave', () => {
          if (this._hidePorts) this._hidePorts();
        });
      }
    }

    // Collect all DAG descendants of nodeId via outgoing REAL edges
    // (proxy edges are excluded — they point to combos, not real nodes)
    collectDAGDescendants(nodeId) {
      const { graph } = this.context;
      const allEdges = graph.getEdgeData();
      const descendants = [];
      const visited = new Set();
      const collect = (id) => {
        allEdges.forEach(edge => {
          if (edge.source === id && !visited.has(edge.target) &&
              !edge.id?.startsWith(PROXY_EDGE_PREFIX)) {
            visited.add(edge.target);
            descendants.push(edge.target);
            collect(edge.target);
          }
        });
      };
      collect(nodeId);
      return { descendants, allEdges };
    }

    // After collapse/expand, update all visible nodes' collapse buttons
    // to reflect the actual visibility of their children.
    // This handles sibling nodes whose shared descendants were hidden/shown.
    refreshCollapseStates() {
      const { graph } = this.context;
      const allNodes = graph.getNodeData();
      const allEdges = graph.getEdgeData();

      // Build parent→children map from real edges only (exclude proxy edges)
      const childrenOf = {};
      allEdges.forEach(edge => {
        if (edge.id?.startsWith(PROXY_EDGE_PREFIX)) return;
        if (!childrenOf[edge.source]) childrenOf[edge.source] = [];
        childrenOf[edge.source].push(edge.target);
      });

      allNodes.forEach(node => {
        const children = childrenOf[node.id] || [];
        if (children.length === 0) return;

        // Skip nodes without collapse config
        if (!node.style?.collapse) return;

        // Skip hidden nodes
        if (node.style?.visibility === 'hidden') return;

        const allChildrenHidden = children.every(childId => {
          const childNode = graph.getNodeData(childId);
          if (childNode?.style?.visibility !== 'hidden') return false;
          // Don't count children as "hidden" if they're hidden because
          // their combo is collapsed (not because of DAG collapse).
          // Otherwise the parent node gets auto-collapsed just because
          // a combo was collapsed, making it impossible to toggle.
          if (childNode?.combo && collapsedCombos.has(childNode.combo)) return false;
          return true;
        });

        const anyChildVisible = children.some(childId => {
          const childNode = graph.getNodeData(childId);
          return childNode?.style?.visibility !== 'hidden';
        });

        if (allChildrenHidden && !dagCollapsedNodes.has(node.id)) {
          dagCollapsedNodes.add(node.id);
        } else if (anyChildVisible && dagCollapsedNodes.has(node.id)) {
          dagCollapsedNodes.delete(node.id);
        }

        // Redraw the collapse button for this node
        try {
          const el = graph.context.element?.getElement(node.id);
          if (el?.drawCollapseButton && el?.parsedAttributes) {
            el.drawCollapseButton(el.parsedAttributes);
          }
        } catch (_) { /* element may not exist */ }
      });
    }

    bindCollapseListener() {
      const hitArea = this.shapeMap['collapse-hit-area'];
      if (hitArea && !hitArea._collapseListenerBound) {
        hitArea._collapseListenerBound = true;
        const { graph } = this.context;

        hitArea.addEventListener('click', async (e) => {
          e.stopPropagation();

          // Guard against concurrent collapse/expand
          if (graph._g6rCollapseInProgress) return;
          graph._g6rCollapseInProgress = true;

          try {
            const isCollapsed = dagCollapsedNodes.has(this.id);
            const { descendants, allEdges } = this.collectDAGDescendants(this.id);

            if (descendants.length === 0) return;

            const descendantSet = new Set(descendants);

            if (isCollapsed) {
              // === EXPAND ===
              dagCollapsedNodes.delete(this.id);
              // Recursive expand: also clear any nested collapsed descendants
              descendants.forEach(dId => dagCollapsedNodes.delete(dId));

              // Update collapsed state in node data so getData() reflects reality
              // Only update nodes that already have a collapse config
              const updates = [];
              const thisCollapse = graph.getNodeData(this.id)?.style?.collapse;
              if (thisCollapse) {
                updates.push({ id: this.id, style: { collapse: { ...thisCollapse, collapsed: false } } });
              }
              descendants.forEach(dId => {
                const dc = graph.getNodeData(dId)?.style?.collapse;
                if (dc) {
                  updates.push({ id: dId, style: { collapse: { ...dc, collapsed: false } } });
                }
              });
              if (updates.length > 0) {
                graph.updateNodeData(updates);
              }

              // Show ALL descendants unconditionally (overrides sibling collapses
              // on shared nodes — refreshCollapseStates will fix sibling buttons)
              const elementsToShow = [...descendants];

              // Show edges where both endpoints will be visible after expand
              allEdges.forEach(edge => {
                if (!edge.id || edge.id.startsWith(PROXY_EDGE_PREFIX)) return;
                if (descendantSet.has(edge.source) || descendantSet.has(edge.target)) {
                  const srcOk = descendantSet.has(edge.source) ||
                    edge.source === this.id ||
                    (graph.getNodeData(edge.source)?.style?.visibility !== 'hidden');
                  const tgtOk = descendantSet.has(edge.target) ||
                    edge.target === this.id ||
                    (graph.getNodeData(edge.target)?.style?.visibility !== 'hidden');
                  if (srcOk && tgtOk) {
                    elementsToShow.push(edge.id);
                  }
                }
              });

              if (elementsToShow.length > 0) {
                await graph.showElement(elementsToShow, false);

                // Reset port indicators to hidden on shown descendants
                // (showElement re-renders nodes which can expose port indicators)
                for (const dId of descendants) {
                  try {
                    const el = graph.context.element?.getElement(dId);
                    if (el?._hidePortsImmediately) el._hidePortsImmediately();
                  } catch (_) { /* element may not exist */ }
                }
              }

            } else {
              // === COLLAPSE ===
              dagCollapsedNodes.add(this.id);

              // Update collapsed state in node data so getData() reflects reality
              const collapseData = graph.getNodeData(this.id)?.style?.collapse || {};
              graph.updateNodeData([
                { id: this.id, style: { collapse: { ...collapseData, collapsed: true } } }
              ]);

              const elementsToHide = [...descendants];
              allEdges.forEach(edge => {
                if (!edge.id || edge.id.startsWith(PROXY_EDGE_PREFIX)) return;
                if (descendantSet.has(edge.source) || descendantSet.has(edge.target)) {
                  elementsToHide.push(edge.id);
                }
              });

              if (elementsToHide.length > 0) {
                await graph.hideElement(elementsToHide, false);
              }
            }

            // Hide combos whose members are all hidden, show those with visible members
            await refreshComboVisibility(graph);

            // When collapsing, explicitly hide collapsed combos whose ALL
            // members are descendants of the just-collapsed node.
            // refreshComboVisibility skips collapsed combos (they stay
            // visible when their own button hid members), but when a DAG
            // ancestor collapses everything, the combo should disappear.
            if (!isCollapsed && collapsedCombos.size > 0) {
              const combosToHide = [];
              for (const [comboId] of collapsedCombos) {
                try {
                  const cd = graph.getComboData().find(c => c.id === comboId);
                  if (!cd || cd.style?.visibility === 'hidden') continue;
                  const members = graph.getNodeData().filter(n => n.combo === comboId);
                  if (members.length > 0 && members.every(m => descendantSet.has(m.id))) {
                    combosToHide.push(comboId);
                  }
                } catch (_) {}
              }
              if (combosToHide.length > 0) {
                await graph.hideElement(combosToHide, false);
              }
            }

            // Re-enforce collapsed state for combos that were collapsed before DAG expand
            await reapplyComboCollapseState(graph);

            // Force visible combos to recalculate bounds
            refreshComboBounds(graph);

            // Resize overlay plugins (bubble sets, hull) to only encompass visible members
            refreshOverlayPlugins(graph);

            // Sync proxy edges AFTER bounds are recalculated so edges point to correct positions
            await ensureProxyEdges(graph);

            // Update the button visual (+/-)
            this.drawCollapseButton(this.parsedAttributes);

            // Update sibling nodes' collapse buttons to reflect
            // the actual visibility of their children
            this.refreshCollapseStates();

            // Reset port indicators on all visible nodes
            // (hideElement/showElement + upsert in refreshCollapseStates
            // can trigger re-renders that expose port indicators)
            const visibleNodes = graph.getNodeData().filter(
              n => n.style?.visibility !== 'hidden'
            );
            for (const n of visibleNodes) {
              try {
                const el = graph.context.element?.getElement(n.id);
                if (el?._hidePortsImmediately) el._hidePortsImmediately();
              } catch (_) { /* element may not exist */ }
            }

            // Re-show collapse button on this node since the user is still hovering it
            if (this._collapseVisibility === 'hover') {
              this.showCollapseButton();
            }

          } finally {
            graph._g6rCollapseInProgress = false;
          }
        });
      }
    }

    onCreate() {
      this.bindCollapseListener();

      // If node is initially collapsed, trigger collapse using DAG-aware hide
      const collapseConfig = this.attributes.collapse || {};
      if (collapseConfig.collapsed || this.attributes.collapsed) {
        const { graph } = this.context;
        setTimeout(async () => {
          dagCollapsedNodes.add(this.id);
          const { descendants, allEdges } = this.collectDAGDescendants(this.id);
          if (descendants.length === 0) return;

          const descendantSet = new Set(descendants);
          const elementsToHide = [...descendants];
          allEdges.forEach(edge => {
            if (!edge.id || edge.id.startsWith(PROXY_EDGE_PREFIX)) return;
            if (descendantSet.has(edge.source) || descendantSet.has(edge.target)) {
              elementsToHide.push(edge.id);
            }
          });

          if (elementsToHide.length > 0) {
            await graph.hideElement(elementsToHide, false);
            await refreshComboVisibility(graph);
            refreshComboBounds(graph);
            refreshOverlayPlugins(graph);
            await ensureProxyEdges(graph);
          }
        }, 0);
      }
    }

    drawPortShapes(attributes, container) {
      const portsStyle = this.getPortsStyle(attributes);
      const graphId = this.context.graph.options.container;
      this._portShapes = [];
      const portZIndex = getPortZIndex(attributes);

      Object.keys(portsStyle).forEach((key) => {
        const style = portsStyle[key];
        if (!style) return;
        const [x, y] = this.getPortXY(attributes, style);
        const baseRadius = style.r || 4;
        const portVisibility = style.visibility || 'visible';
        const initiallyVisible = portVisibility === 'visible';

        const portShape = createPortShapeForKey(this, key, style, baseRadius, container, portVisibility, portZIndex);
        const indicator = createIndicatorForKey(this, key, x, y, baseRadius, style, container, portVisibility, portZIndex);

        if (initiallyVisible && indicator.hitArea) {
          indicator.hitArea.attr({ visibility: 'visible' });
        }
        this._portShapes.push({ shape: portShape, indicator });
        this.addPortEvents(portShape, style, indicator, graphId, this.id);
      });

      this.addNodeHoverHandlers(container);
    }

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

    createAddIndicator(key, x, y, radius, accentColor, container, portStyle = {}, portZIndex = 10) {
      const innerRadius = radius * INNER_CIRCLE_RATIO;
      const hitArea = createIndicatorHitArea(this, key, x, y, radius, container, portStyle, portZIndex);
      hitArea.key = key;
      hitArea.arity = portStyle.arity === "Infinity" ? Infinity : (portStyle.arity || 1);

      const circle = createIndicatorCircle(this, key, x, y, radius, accentColor, container, portZIndex);
      const innerCircle = createIndicatorInnerCircle(this, key, x, y, innerRadius, accentColor, container, portZIndex);
      const plus = createIndicatorPlus(this, key, x, y, innerRadius, container, portZIndex);

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

    showCollapseButton() {
      if (this._collapseVisibility !== 'hover') return;
      const hitArea = this.shapeMap['collapse-hit-area'];
      const button = this.shapeMap['collapse-button'];
      if (!hitArea) return;
      // Cancel any pending debounced hide
      if (this._collapseHideTimeout) {
        clearTimeout(this._collapseHideTimeout);
        this._collapseHideTimeout = null;
      }
      // Already fully visible — nothing to do
      if (hitArea.attr('visibility') === 'visible' && hitArea.attr('opacity') >= 1) return;
      // Already animating in — let it continue
      if (this._collapseShowAnimation) return;
      hitArea.attr({ visibility: 'visible', opacity: 0 });
      if (button) button.attr({ visibility: 'visible', opacity: 0 });
      const startTime = performance.now();
      const animate = (currentTime) => {
        const progress = Math.min((currentTime - startTime) / ANIMATION_DURATION_MS, 1);
        const eased = 1 - Math.pow(1 - progress, 2);
        hitArea.attr('opacity', eased);
        if (button) button.attr('opacity', eased);
        if (progress < 1) {
          this._collapseShowAnimation = requestAnimationFrame(animate);
        } else {
          this._collapseShowAnimation = null;
        }
      };
      this._collapseShowAnimation = requestAnimationFrame(animate);
    }

    hideCollapseButton() {
      if (this._collapseVisibility !== 'hover') return;
      // When collapsed, keep button + count always visible
      if (this._isCollapsed) return;
      if (!this.shapeMap['collapse-hit-area']) return;
      // Cancel any pending hide to avoid stacking
      if (this._collapseHideTimeout) {
        clearTimeout(this._collapseHideTimeout);
      }
      // Debounce: wait a short period before actually hiding,
      // so brief mouse boundary crossings don't cause flicker
      this._collapseHideTimeout = setTimeout(() => {
        this._collapseHideTimeout = null;
        if (this._collapseShowAnimation) {
          cancelAnimationFrame(this._collapseShowAnimation);
          this._collapseShowAnimation = null;
        }
        const hitArea = this.shapeMap['collapse-hit-area'];
        const button = this.shapeMap['collapse-button'];
        if (hitArea) hitArea.attr({ visibility: 'hidden', opacity: 0 });
        if (button) button.attr({ visibility: 'hidden', opacity: 0 });
      }, 150);
    }

    hideCollapseButtonImmediate() {
      if (this._collapseVisibility !== 'hover') return;
      // When collapsed, keep button + count always visible
      if (this._isCollapsed) return;
      // Cancel any pending debounced hide
      if (this._collapseHideTimeout) {
        clearTimeout(this._collapseHideTimeout);
        this._collapseHideTimeout = null;
      }
      if (this._collapseShowAnimation) {
        cancelAnimationFrame(this._collapseShowAnimation);
        this._collapseShowAnimation = null;
      }
      const hitArea = this.shapeMap['collapse-hit-area'];
      const button = this.shapeMap['collapse-button'];
      if (hitArea) hitArea.attr({ visibility: 'hidden', opacity: 0 });
      if (button) button.attr({ visibility: 'hidden', opacity: 0 });
    }

    update(attr) {
      super.update(attr);
      const nodeHidden = this.attributes?.visibility === 'hidden';
      if (nodeHidden) {
        // Node is hidden — force ALL port shapes hidden regardless of their mode.
        // _hidePortsImmediately would re-show "always visible" ports, so bypass it.
        if (this._portShapes) {
          this._portShapes.forEach(({ shape, indicator }) => {
            shape.attr({ visibility: 'hidden' });
            if (indicator) {
              indicator.circle?.attr({ visibility: 'hidden' });
              indicator.innerCircle?.attr({ visibility: 'hidden' });
              indicator.plus?.attr({ visibility: 'hidden' });
              if (indicator.hitArea) indicator.hitArea.attr({ visibility: 'hidden' });
            }
          });
        }
      } else if (this._isHoveringNode?.()) {
        // G6's BaseShape.update() calls setVisibility() after render(),
        // which sets ALL child shapes to the node's visibility ('visible'),
        // including indicators for at-capacity ports.
        // Re-run the capacity-aware showPorts to fix visibility.
        if (this._showPorts) {
          this._showPorts();
        }
      } else {
        // Not hovering — hide everything that should be hidden.
        if (this._hidePortsImmediately) {
          this._hidePortsImmediately();
        }
      }
      // Re-hide collapse button that should only show on hover
      if (this._collapseVisibility === 'hover' && !this._isHoveringNode?.()) {
        this.hideCollapseButtonImmediate?.();
      }
    }

    render(attributes = this.parsedAttributes, container) {
      super.render(attributes, container);
      this._renderContainer = container;
      this.drawCollapseButton(attributes);
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
  CustomDonutNode,
  dagCollapsedNodes
};