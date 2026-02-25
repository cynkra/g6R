import {
  Line,
  CubicHorizontal,
  subStyleProps,
  CircleCombo,
  RectCombo
} from '@antv/g6';
import { AABB, Circle, Path, Text, Rect as GRect } from '@antv/g';
import { dagCollapsedNodes } from './custom-nodes';

class AntLine extends Line {
  onCreate() {
    const shape = this.shapeMap.key;
    shape.animate([{ lineDashOffset: -20 }, { lineDashOffset: 0 }], {
      duration: 500,
      iterations: Infinity,
    });
  }
}

class FlyMarkerCubic extends CubicHorizontal {
  getMarkerStyle(attributes) {
    return { r: 5, fill: '#000', offsetPath: this.shapeMap.key, ...subStyleProps(attributes, 'marker') };
  }

  onCreate() {
    const marker = this.upsert('marker', Circle, this.getMarkerStyle(this.attributes), this);
    marker.animate([{ offsetDistance: 0 }, { offsetDistance: 1 }], {
      duration: 3000,
      iterations: Infinity,
    });
  }
}

// Line-only paths for combo collapse button (circle border comes from hit-area shape)
const collapsePath = (x, y, r) => {
  return [
    ['M', x - r + 4, y],
    ['L', x + r - 4, y],
  ];
};

const expandPath = (x, y, r) => {
  return [
    ['M', x - r + 4, y],
    ['L', x + r - 4, y],
    ['M', x, y - r + 4],
    ['L', x, y + r - 4],
  ];
};

// Track which combos have been collapsed via our custom button.
// We bypass G6's built-in collapseElement/expandElement (which destroys
// and recreates child elements, breaking border nodes) and instead use
// hideElement/showElement, consistent with the DAG collapse approach.
// Maps comboId → { alreadyHidden: Set, hiddenCount: number, dagCollapsedMembers: Set }
const collapsedCombos = new Map();
const PROXY_EDGE_PREFIX = '__combo_proxy__';

/**
 * Hide combos whose members are all hidden; show combos that have at least
 * one visible member.  Skipped for combos that are explicitly collapsed via
 * the combo button (those stay visible with a "+N" badge).
 */
const refreshComboVisibilityFromExtensions = async (graph) => {
  const combos = graph.getComboData();
  if (!combos || combos.length === 0) return;
  const allNodes = graph.getNodeData();
  const comboMembers = {};
  for (const node of allNodes) {
    if (!node.combo) continue;
    if (!comboMembers[node.combo]) comboMembers[node.combo] = [];
    comboMembers[node.combo].push(node);
  }
  const toHide = [];
  const toShow = [];
  for (const combo of combos) {
    // Never auto-hide a combo that is explicitly collapsed
    if (collapsedCombos.has(combo.id)) continue;
    const members = comboMembers[combo.id];
    if (!members || members.length === 0) continue;
    const allHidden = members.every((n) => n.style?.visibility === 'hidden');
    const comboIsHidden = combo.style?.visibility === 'hidden';
    if (allHidden && !comboIsHidden) toHide.push(combo.id);
    else if (!allHidden && comboIsHidden) toShow.push(combo.id);
  }
  if (toHide.length > 0) await graph.hideElement(toHide, false);
  if (toShow.length > 0) await graph.showElement(toShow, false);
};

const createComboWithExtraButton = (BaseCombo) => {
  return class ComboWithExtraButton extends BaseCombo {
    // Override to exclude hidden children from combo bounds calculation
    getContentBBox(attributes) {
      const { childrenNode = [], padding } = attributes;
      const allElements = childrenNode
        .map((id) => this.context.element?.getElement(id))
        .filter(Boolean);

      // Elements not created yet (initial render) — use default behaviour
      if (allElements.length === 0) {
        return super.getContentBBox(attributes);
      }

      const children = allElements.filter((child) => child.style?.visibility !== 'hidden');

      if (children.length === 0) {
        // All children hidden — use the cached center from when children
        // were last visible.  This prevents the combo from jumping to
        // the origin (0,0) when bounds are recalculated with no visible
        // children.
        const bbox = new AABB();
        const { collapsedSize = 32 } = attributes;
        const s = typeof collapsedSize === 'number' ? collapsedSize : collapsedSize[0] || 32;
        const cx = this._lastContentCenterX ?? attributes.x ?? 0;
        const cy = this._lastContentCenterY ?? attributes.y ?? 0;
        bbox.setMinMax([cx - s / 2, cy - s / 2, 0], [cx + s / 2, cy + s / 2, 0]);
        return bbox;
      }

      // Combine bounds of visible children only
      const bboxes = children.map((child) => child.getBounds());
      let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
      for (const b of bboxes) {
        const lo = b.getMin();
        const hi = b.getMax();
        if (lo[0] < minX) minX = lo[0];
        if (lo[1] < minY) minY = lo[1];
        if (hi[0] > maxX) maxX = hi[0];
        if (hi[1] > maxY) maxY = hi[1];
      }
      const combined = new AABB();
      combined.setMinMax([minX, minY, 0], [maxX, maxY, 0]);

      // Cache the center so we can reuse it when all children are hidden
      this._lastContentCenterX = (minX + maxX) / 2;
      this._lastContentCenterY = (minY + maxY) / 2;

      if (!padding) return combined;

      // Expand by padding
      const p = Array.isArray(padding) ? padding : [padding, padding, padding, padding];
      const [top, right, bottom, left] = p.length === 1 ? [p[0], p[0], p[0], p[0]]
        : p.length === 2 ? [p[0], p[1], p[0], p[1]]
        : p.length === 3 ? [p[0], p[1], p[2], p[1]]
        : p;
      const min = combined.getMin();
      const max = combined.getMax();
      const expanded = new AABB();
      expanded.setMinMax(
        [min[0] - left, min[1] - top, 0],
        [max[0] + right, max[1] + bottom, 0]
      );
      return expanded;
    }

    render(attributes, container) {
      super.render(attributes, container);
      this.drawButton(attributes);
    }

    drawButton(attributes) {
      // Check our custom collapsed state (not G6's built-in one)
      const state = collapsedCombos.get(this.id);
      const collapsed = !!state;
      const collapseConfig = attributes.collapse || {};
      const [width, height] = this.getKeySize(attributes);
      const btnR = collapseConfig.r || 8;
      const placement = collapseConfig.placement || 'bottom';

      // Compute button position based on placement
      let x, y;
      if (Array.isArray(placement)) {
        x = (placement[0] - 0.5) * width;
        y = (placement[1] - 0.5) * height;
      } else {
        switch (placement) {
          case 'top':          x = 0; y = -height / 2 - btnR; break;
          case 'bottom':       x = 0; y = height / 2 + btnR; break;
          case 'right':        x = width / 2 + btnR; y = 0; break;
          case 'left':         x = -width / 2 - btnR; y = 0; break;
          case 'right-top':    x = width / 2; y = -height / 2; break;
          case 'right-bottom': x = width / 2; y = height / 2; break;
          case 'left-top':     x = -width / 2; y = -height / 2; break;
          case 'left-bottom':  x = -width / 2; y = height / 2; break;
          default:             x = 0; y = height / 2 + btnR;
        }
      }

      // Read styling from config with defaults
      const fill = collapseConfig.fill || '#fff';
      const stroke = collapseConfig.stroke || '#CED4D9';
      const lineWidth = collapseConfig.lineWidth || 1;
      const iconStroke = collapseConfig.iconStroke || '#CED4D9';
      const iconLineWidth = collapseConfig.iconLineWidth || 1.4;
      const cursor = collapseConfig.cursor || 'pointer';
      const zIndex = collapseConfig.zIndex || 999;

      // Handle visibility mode
      const collapseVisibility = collapseConfig.visibility || 'visible';
      this._comboCollapseVisibility = collapseVisibility;
      // When hovering, keep button visible even in hover mode (same as node)
      const initiallyVisible = collapsed || collapseVisibility === 'visible' ||
        (collapseVisibility === 'hover' && this._isHoveringCombo);

      // Track the previous hit-area type so we know when to rebind
      const prevType = this._hitAreaType;
      let needsRebind = false;

      if (collapsed && state.hiddenCount > 0) {
        // Pill-shaped button with "+ N" label (like node collapse)
        const label = `+ ${state.hiddenCount}`;
        const fontSize = btnR * 1.1;
        const labelPadding = btnR * 0.4;
        const textWidth = label.length * fontSize * 0.55;
        const pillWidth = textWidth + labelPadding * 2;

        // Remove old shapes if switching from circle to pill
        if (prevType !== 'pill') {
          const existingCircle = this.shapeMap['hit-area'];
          if (existingCircle) { existingCircle.remove(); delete this.shapeMap['hit-area']; }
          const existingPath = this.shapeMap['button'];
          if (existingPath) { existingPath.remove(); delete this.shapeMap['button']; }
          needsRebind = true;
        }

        this.upsert('hit-area', GRect, {
          x: x - pillWidth / 2,
          y: y - btnR,
          width: pillWidth,
          height: btnR * 2,
          radius: btnR,
          fill: fill,
          stroke: stroke,
          lineWidth: lineWidth,
          cursor: cursor,
          zIndex: zIndex,
          visibility: 'visible',
        }, this);

        this.upsert('button', Text, {
          x: x,
          y: y,
          text: label,
          fontSize: fontSize,
          fontWeight: 'bold',
          fill: iconStroke,
          textAlign: 'center',
          textBaseline: 'middle',
          cursor: cursor,
          zIndex: zIndex + 1,
        }, this.shapeMap['hit-area']);
        this._hitAreaType = 'pill';
      } else {
        // Remove old shapes if switching from pill to circle
        if (prevType === 'pill') {
          const existingRect = this.shapeMap['hit-area'];
          if (existingRect) { existingRect.remove(); delete this.shapeMap['hit-area']; }
          const existingText = this.shapeMap['button'];
          if (existingText) { existingText.remove(); delete this.shapeMap['button']; }
          needsRebind = true;
        }

        // Circle button with collapse/expand icon
        const d = collapsed ? expandPath(x, y, btnR) : collapsePath(x, y, btnR);
        this.upsert('hit-area', Circle, {
          cx: x,
          cy: y,
          r: btnR,
          fill: fill,
          stroke: stroke,
          lineWidth: lineWidth,
          cursor: cursor,
          zIndex: zIndex,
          visibility: initiallyVisible ? 'visible' : 'hidden',
          opacity: initiallyVisible ? 1 : 0,
        }, this);
        this.upsert('button', Path, {
          stroke: iconStroke,
          lineWidth: iconLineWidth,
          d,
          cursor: cursor,
          zIndex: zIndex + 1,
          visibility: initiallyVisible ? 'visible' : 'hidden',
          opacity: initiallyVisible ? 1 : 0,
        }, this.shapeMap['hit-area']);
        this._hitAreaType = 'circle';
      }

      // Rebind click handler when the hit-area element was replaced
      if (needsRebind && this._comboClickHandler) {
        this.shapeMap['hit-area'].addEventListener('click', this._comboClickHandler);
      }

      // Bind hover handlers for hover-mode visibility (re-bind after shape recreation)
      if (collapseVisibility === 'hover') {
        this._setupComboHoverHandlers();
      }
    }

    _setupComboHoverHandlers() {
      // Bind on key shape (only once)
      const keyShape = this.shapeMap?.key;
      if (keyShape && !keyShape._hasComboCollapseHover) {
        keyShape._hasComboCollapseHover = true;
        keyShape.addEventListener('mouseenter', () => this.showComboCollapseButton());
        keyShape.addEventListener('mouseleave', () => this.hideComboCollapseButton());
      }
      // Bind on hit-area (re-bind after shape recreation via needsRebind)
      const hitArea = this.shapeMap?.['hit-area'];
      if (hitArea && !hitArea._hasComboCollapseHover) {
        hitArea._hasComboCollapseHover = true;
        hitArea.addEventListener('mouseenter', () => this.showComboCollapseButton());
        hitArea.addEventListener('mouseleave', () => this.hideComboCollapseButton());
      }
    }

    showComboCollapseButton() {
      if (this._comboCollapseVisibility !== 'hover') return;
      this._isHoveringCombo = true;
      const hitArea = this.shapeMap['hit-area'];
      const button = this.shapeMap['button'];
      if (!hitArea) return;
      // Cancel any pending hide
      if (this._comboCollapseHideTimeout) {
        clearTimeout(this._comboCollapseHideTimeout);
        this._comboCollapseHideTimeout = null;
      }
      // Already fully visible — nothing to do
      if (hitArea.attr('visibility') === 'visible' && hitArea.attr('opacity') >= 1) return;
      // Already animating in — let it continue
      if (this._comboCollapseShowAnimation) return;
      hitArea.attr({ visibility: 'visible', opacity: 0 });
      if (button) button.attr({ visibility: 'visible', opacity: 0 });
      const startTime = performance.now();
      const animate = (currentTime) => {
        const progress = Math.min((currentTime - startTime) / 500, 1);
        const eased = 1 - Math.pow(1 - progress, 2);
        hitArea.attr('opacity', eased);
        if (button) button.attr('opacity', eased);
        if (progress < 1) {
          this._comboCollapseShowAnimation = requestAnimationFrame(animate);
        } else {
          this._comboCollapseShowAnimation = null;
        }
      };
      this._comboCollapseShowAnimation = requestAnimationFrame(animate);
    }

    hideComboCollapseButton() {
      if (this._comboCollapseVisibility !== 'hover') return;
      this._isHoveringCombo = false;
      // When collapsed, always keep button visible
      if (collapsedCombos.has(this.id)) return;
      if (!this.shapeMap['hit-area']) return;
      // Cancel any pending hide to avoid stacking
      if (this._comboCollapseHideTimeout) {
        clearTimeout(this._comboCollapseHideTimeout);
      }
      // Debounce: wait before hiding so cursor can move from key shape to button
      this._comboCollapseHideTimeout = setTimeout(() => {
        this._comboCollapseHideTimeout = null;
        if (this._comboCollapseShowAnimation) {
          cancelAnimationFrame(this._comboCollapseShowAnimation);
          this._comboCollapseShowAnimation = null;
        }
        const hitArea = this.shapeMap['hit-area'];
        const button = this.shapeMap['button'];
        if (hitArea) hitArea.attr({ visibility: 'hidden', opacity: 0 });
        if (button) button.attr({ visibility: 'hidden', opacity: 0 });
      }, 150);
    }

    onCreate() {
      this._comboClickHandler = async () => {
        const { graph } = this.context;
        const comboId = this.id;
        const isCollapsed = collapsedCombos.has(comboId);

        // Get member nodes (nodes belonging to this combo)
        const allNodes = graph.getNodeData();
        const memberIds = allNodes
          .filter((n) => n.combo === comboId)
          .map((n) => n.id);

        if (memberIds.length === 0) return;

        const memberSet = new Set(memberIds);
        const allEdges = graph.getEdgeData();

        // Edges where at least one endpoint is a combo member (exclude proxy edges)
        const connectedEdgeIds = allEdges
          .filter((e) => e.id && !e.id.startsWith(PROXY_EDGE_PREFIX) &&
            (memberSet.has(e.source) || memberSet.has(e.target)))
          .map((e) => e.id);

        if (isCollapsed) {
          // === EXPAND ===
          const state = collapsedCombos.get(comboId) || {};
          const previouslyHidden = state.alreadyHidden || new Set();
          const savedDagCollapsed = state.dagCollapsedMembers || new Set();
          collapsedCombos.delete(comboId);

          // Restore dagCollapsedNodes for members that were DAG-collapsed
          // when the combo was collapsed (they may have been cleared by
          // a parent DAG expand while the combo was collapsed).
          for (const mid of savedDagCollapsed) {
            dagCollapsedNodes.add(mid);
            const mData = graph.getNodeData(mid);
            if (mData?.style?.collapse && !mData.style.collapse.collapsed) {
              graph.updateNodeData([{
                id: mid,
                style: { collapse: { ...mData.style.collapse, collapsed: true } }
              }]);
            }
          }

          // Only show members that were NOT already hidden before combo collapse
          const membersToShow = memberIds.filter((id) => !previouslyHidden.has(id));
          if (membersToShow.length > 0) {
            await graph.showElement(membersToShow, false);
          }

          // Reset port visibility on shown members
          for (const nid of membersToShow) {
            try {
              const el = graph.context.element?.getElement(nid);
              if (el?._hidePortsImmediately) el._hidePortsImmediately();
            } catch (_) {}
          }

          // Show edges that were NOT previously hidden and where BOTH endpoints are now visible
          const edgesToShow = connectedEdgeIds.filter((eid) => {
            if (previouslyHidden.has(eid)) return false;
            const edge = allEdges.find((e) => e.id === eid);
            if (!edge) return false;
            const srcData = graph.getNodeData(edge.source);
            const tgtData = graph.getNodeData(edge.target);
            return srcData?.style?.visibility !== 'hidden' &&
                   tgtData?.style?.visibility !== 'hidden';
          });

          if (edgesToShow.length > 0) {
            await graph.showElement(edgesToShow, false);
          }

          // Re-hide descendants of DAG-collapsed members (including non-member nodes).
          const allGraphEdges = graph.getEdgeData();
          const collectDescendants = (nodeId) => {
            const result = [];
            const visited = new Set();
            const walk = (id) => {
              allGraphEdges.forEach((e) => {
                if (e.source === id && !visited.has(e.target) && !e.id?.startsWith(PROXY_EDGE_PREFIX)) {
                  visited.add(e.target);
                  result.push(e.target);
                  walk(e.target);
                }
              });
            };
            walk(nodeId);
            return result;
          };

          for (const mid of membersToShow) {
            const mData = graph.getNodeData(mid);
            if (mData?.style?.collapse?.collapsed || dagCollapsedNodes.has(mid)) {
              const descs = collectDescendants(mid);
              const descEdges = [];
              const descSet = new Set(descs);
              allGraphEdges.forEach((e) => {
                if (e.id && !e.id.startsWith(PROXY_EDGE_PREFIX) &&
                    (descSet.has(e.source) || descSet.has(e.target))) {
                  descEdges.push(e.id);
                }
              });
              const toRehide = [...descs, ...descEdges].filter((id) => {
                try {
                  const type = graph.getElementType(id);
                  const d = type === 'edge' ? graph.getEdgeData(id) : graph.getNodeData(id);
                  return d?.style?.visibility !== 'hidden';
                } catch (_) { return false; }
              });
              if (toRehide.length > 0) {
                await graph.hideElement(toRehide, false);
              }
            }
          }

          // Final pass: show any hidden edges connected to our members
          // where BOTH endpoints are now visible.  This catches edges that
          // fell through the cracks when multiple combos hide the same
          // edge and are expanded in different orders (the edge ends up
          // in one combo's alreadyHidden but the other combo can't show
          // it because the target was still hidden at expand time).
          const freshEdges = graph.getEdgeData();
          const finalEdgesToShow = [];
          for (const edge of freshEdges) {
            if (!edge.id || edge.id.startsWith(PROXY_EDGE_PREFIX)) continue;
            if (edge.style?.visibility !== 'hidden') continue;
            if (!memberSet.has(edge.source) && !memberSet.has(edge.target)) continue;
            const srcData = graph.getNodeData(edge.source);
            const tgtData = graph.getNodeData(edge.target);
            if (srcData?.style?.visibility !== 'hidden' &&
                tgtData?.style?.visibility !== 'hidden') {
              finalEdgesToShow.push(edge.id);
            }
          }
          if (finalEdgesToShow.length > 0) {
            await graph.showElement(finalEdgesToShow, false);
          }

          // Redraw collapse buttons for restored DAG-collapsed members
          for (const mid of savedDagCollapsed) {
            try {
              const el = graph.context.element?.getElement(mid);
              if (el?.drawCollapseButton && el?.parsedAttributes) {
                el.drawCollapseButton(el.parsedAttributes);
              }
            } catch (_) {}
          }
        } else {
          // === COLLAPSE ===
          // Snapshot elements that are already hidden (e.g. by DAG collapse)
          const alreadyHidden = new Set();
          for (const id of memberIds) {
            const data = graph.getNodeData(id);
            if (data?.style?.visibility === 'hidden') alreadyHidden.add(id);
          }
          for (const id of connectedEdgeIds) {
            try {
              const data = graph.getEdgeData(id);
              if (data?.style?.visibility === 'hidden') alreadyHidden.add(id);
            } catch (_) {}
          }

          // Snapshot which members are DAG-collapsed so we can restore
          // their state after a parent DAG expand clears dagCollapsedNodes.
          const dagCollapsedMembers = new Set();
          for (const mid of memberIds) {
            if (dagCollapsedNodes.has(mid)) {
              dagCollapsedMembers.add(mid);
            }
          }

          // Hide member nodes and all their connected edges
          const toHide = [...memberIds, ...connectedEdgeIds]
            .filter((id) => !alreadyHidden.has(id));
          if (toHide.length > 0) {
            await graph.hideElement(toHide, false);
          }

          const hiddenCount = memberIds.length - [...alreadyHidden].filter((id) => memberSet.has(id)).length;
          collapsedCombos.set(comboId, { alreadyHidden, hiddenCount, dagCollapsedMembers });
        }

        // Hide/show other combos whose member visibility changed
        await refreshComboVisibilityFromExtensions(graph);

        // Force the combo to recalculate its bounds (shrink or expand)
        const comboData = graph.getComboData().find((c) => c.id === comboId);
        if (comboData) {
          const el = graph.context.element?.getElement(comboId);
          if (el) {
            const style = graph.context.element.getElementComputedStyle('combo', comboData);
            el.update(style);
          }
        }

        // Sync proxy edges AFTER bounds are recalculated
        await ensureProxyEdges(graph);

        // Final pass: force-hide port shapes on ALL currently hidden nodes
        forceHidePortsOnHiddenNodes(graph);
      };
      this.shapeMap['hit-area'].addEventListener('click', this._comboClickHandler);
    }
  };
};

const CircleComboWithExtraButton = createComboWithExtraButton(CircleCombo);
const RectComboWithExtraButton = createComboWithExtraButton(RectCombo);

/**
 * Re-enforce combo collapsed state after external operations (e.g. DAG expand)
 * that may have shown members of collapsed combos.
 * - Restores dagCollapsedNodes and node data for members that were DAG-collapsed
 * - Re-hides member nodes and their edges
 * - Re-hides external descendants of DAG-collapsed members
 * - Force-hides ports on hidden members
 */
const reapplyComboCollapseState = async (graph) => {
  if (collapsedCombos.size === 0) return;

  const allEdges = graph.getEdgeData();

  // Helper to collect all descendants via outgoing edges
  const collectDescendants = (nodeId) => {
    const result = [];
    const visited = new Set();
    const walk = (id) => {
      allEdges.forEach((e) => {
        if (e.source === id && !visited.has(e.target) && !e.id?.startsWith(PROXY_EDGE_PREFIX)) {
          visited.add(e.target);
          result.push(e.target);
          walk(e.target);
        }
      });
    };
    walk(nodeId);
    return result;
  };

  for (const [comboId, state] of collapsedCombos) {
    const allNodes = graph.getNodeData();
    const memberIds = allNodes
      .filter((n) => n.combo === comboId)
      .map((n) => n.id);
    if (memberIds.length === 0) continue;

    const memberSet = new Set(memberIds);

    // Restore DAG collapse state for members that were DAG-collapsed
    // when the combo was collapsed. The parent's DAG expand may have
    // cleared dagCollapsedNodes and set collapse.collapsed = false.
    const dagCollapsedMembers = state.dagCollapsedMembers || new Set();
    if (dagCollapsedMembers.size > 0) {
      const updates = [];
      for (const mid of dagCollapsedMembers) {
        dagCollapsedNodes.add(mid);
        const mData = graph.getNodeData(mid);
        if (mData?.style?.collapse) {
          updates.push({
            id: mid,
            style: { collapse: { ...mData.style.collapse, collapsed: true } }
          });
        }
      }
      if (updates.length > 0) {
        graph.updateNodeData(updates);
      }

      // Re-hide external descendants of DAG-collapsed members
      // (these may have been shown by the parent DAG expand)
      for (const mid of dagCollapsedMembers) {
        const descs = collectDescendants(mid);
        if (descs.length === 0) continue;
        const descSet = new Set(descs);
        const descEdges = allEdges
          .filter((e) => e.id && !e.id.startsWith(PROXY_EDGE_PREFIX) &&
            (descSet.has(e.source) || descSet.has(e.target)))
          .map((e) => e.id);
        const toHideDesc = [...descs, ...descEdges].filter((id) => {
          try {
            const type = graph.getElementType(id);
            const d = type === 'edge' ? graph.getEdgeData(id) : graph.getNodeData(id);
            return d?.style?.visibility !== 'hidden';
          } catch (_) { return false; }
        });
        if (toHideDesc.length > 0) {
          await graph.hideElement(toHideDesc, false);
        }
      }
    }

    // Edges connecting combo members (excluding proxy edges)
    const freshEdges = graph.getEdgeData();
    const connectedEdgeIds = freshEdges
      .filter((e) => e.id && !e.id.startsWith(PROXY_EDGE_PREFIX) &&
        (memberSet.has(e.source) || memberSet.has(e.target)))
      .map((e) => e.id);

    // Re-hide all member nodes and their edges
    const toHide = [...memberIds, ...connectedEdgeIds].filter((id) => {
      try {
        const type = graph.getElementType(id);
        const data = type === 'edge' ? graph.getEdgeData(id) : graph.getNodeData(id);
        return data?.style?.visibility !== 'hidden';
      } catch (_) { return false; }
    });

    if (toHide.length > 0) {
      await graph.hideElement(toHide, false);
    }

    // Force-hide ports on hidden members
    forceHidePortsOnHiddenNodes(graph);
  }
};

/**
 * Force-hide port shapes on all currently hidden nodes.
 * graph.draw() and combo update can trigger re-renders that recreate ports
 * with their default visibility, overriding earlier hide calls.
 */
const forceHidePortsOnHiddenNodes = (graph) => {
  const hiddenNodes = graph.getNodeData().filter((n) => n.style?.visibility === 'hidden');
  for (const node of hiddenNodes) {
    try {
      const el = graph.context.element?.getElement(node.id);
      if (!el?._portShapes) continue;
      el._portShapes.forEach(({ shape, indicator }) => {
        shape.attr({ visibility: 'hidden' });
        if (indicator) {
          indicator.circle?.attr({ visibility: 'hidden' });
          indicator.innerCircle?.attr({ visibility: 'hidden' });
          indicator.plus?.attr({ visibility: 'hidden' });
          if (indicator.hitArea) indicator.hitArea.attr({ visibility: 'hidden' });
        }
      });
    } catch (_) {}
  }
};

/**
 * Pure computation: determine which proxy edges should exist right now.
 *
 * Returns a Map of "source_to_target" → edge data objects.
 * Uses stable deterministic IDs: __combo_proxy__${source}_to_${target}
 */
const computeDesiredProxies = (graph) => {
  if (collapsedCombos.size === 0) return new Map();

  const allNodes = graph.getNodeData();
  const nodeMap = new Map(allNodes.map((n) => [n.id, n]));

  // Set of collapsed combo IDs whose combo element is visible
  const visibleCollapsedCombos = new Set();
  for (const [comboId] of collapsedCombos) {
    const cd = graph.getComboData().find((c) => c.id === comboId);
    if (cd && cd.style?.visibility !== 'hidden') visibleCollapsedCombos.add(comboId);
  }

  const resolveNode = (nodeId) => {
    const node = nodeMap.get(nodeId);
    if (!node) return null;
    if (node.combo && visibleCollapsedCombos.has(node.combo)) return node.combo;
    if (node.style?.visibility !== 'hidden') return nodeId;
    return null;
  };

  // Walk every real edge, resolve both endpoints, collect unique proxy edges
  const allEdges = graph.getEdgeData();
  const proxyKeys = new Map();

  for (const edge of allEdges) {
    if (!edge.id || edge.id.startsWith(PROXY_EDGE_PREFIX)) continue;

    const src = resolveNode(edge.source);
    const tgt = resolveNode(edge.target);

    if (!src || !tgt) continue;
    if (src === tgt) continue;
    if (!visibleCollapsedCombos.has(src) && !visibleCollapsedCombos.has(tgt)) continue;

    const key = `${src}_to_${tgt}`;
    if (!proxyKeys.has(key)) {
      proxyKeys.set(key, { source: src, target: tgt });
    }
  }

  // Detect reverse pairs (A→B AND B→A) so we can curve them apart
  const hasReverse = new Set();
  for (const [key] of proxyKeys) {
    const [src, tgt] = key.split('_to_');
    if (proxyKeys.has(`${tgt}_to_${src}`)) hasReverse.add(key);
  }

  // Build edge data objects with stable IDs
  const defaultEdgeStyle = graph.options?.edge?.style || {};
  const baseProxyStyle = {
    lineDash: [4, 4],
    stroke: defaultEdgeStyle.stroke || '#C0C0C0',
    endArrow: defaultEdgeStyle.endArrow !== undefined ? defaultEdgeStyle.endArrow : true,
  };

  const desired = new Map();
  for (const [key, { source, target }] of proxyKeys) {
    const pid = `${PROXY_EDGE_PREFIX}${key}`;
    const needsCurve = hasReverse.has(key);
    const edgeData = {
      id: pid, source, target,
      style: { ...baseProxyStyle, visibility: 'visible' },
    };
    if (needsCurve) {
      edgeData.type = 'quadratic';
      edgeData.style.curveOffset = 20;
    }
    desired.set(key, edgeData);
  }

  return desired;
};

/**
 * Robust draw wrapper: call graph.draw() and restore hidden state afterwards.
 *
 * graph.draw() re-renders ALL elements, which can corrupt hideElement/showElement
 * visibility state. This wrapper snapshots hidden element IDs before draw,
 * then re-hides any that got un-hidden.
 */
const safeDrawForProxyEdges = async (graph) => {
  // Snapshot ALL hidden element IDs before draw
  const hiddenNodeIds = graph.getNodeData()
    .filter((n) => n.style?.visibility === 'hidden')
    .map((n) => n.id);
  const hiddenEdgeIds = graph.getEdgeData()
    .filter((e) => e.id && !e.id.startsWith(PROXY_EDGE_PREFIX) && e.style?.visibility === 'hidden')
    .map((e) => e.id);
  const hiddenComboIds = graph.getComboData()
    .filter((c) => c.style?.visibility === 'hidden')
    .map((c) => c.id);

  await graph.draw();

  // Re-hide any previously-hidden elements that draw() made visible
  const allHidden = [...hiddenNodeIds, ...hiddenEdgeIds, ...hiddenComboIds];
  const toRestore = allHidden.filter((id) => {
    try {
      const type = graph.getElementType(id);
      const d = type === 'edge' ? graph.getEdgeData(id)
        : type === 'combo' ? graph.getComboData().find((c) => c.id === id)
        : graph.getNodeData(id);
      return d?.style?.visibility !== 'hidden';
    } catch (_) { return false; }
  });
  if (toRestore.length > 0) {
    await graph.hideElement(toRestore, false);
  }

  // Force all visible combos to recalculate bounds after draw().
  // graph.draw() may render proxy edges BEFORE the combo's getContentBBox
  // override repositions it, causing edges to point to stale positions.
  // Re-updating combos ensures they are at the correct cached position.
  const postDrawCombos = graph.getComboData();
  for (const combo of postDrawCombos) {
    if (combo.style?.visibility === 'hidden') continue;
    const el = graph.context.element?.getElement(combo.id);
    if (el) {
      const style = graph.context.element.getElementComputedStyle('combo', combo);
      el.update(style);
    }
  }

  // Now re-update proxy edge elements so they pick up the corrected
  // combo positions (their endpoints may have moved).
  const proxyEdges = graph.getEdgeData().filter(
    (e) => e.id?.startsWith(PROXY_EDGE_PREFIX) && e.style?.visibility !== 'hidden'
  );
  for (const e of proxyEdges) {
    try {
      const el = graph.context.element?.getElement(e.id);
      if (el) {
        const style = graph.context.element.getElementComputedStyle('edge', e);
        el.update(style);
      }
    } catch (_) {}
  }

  // Force-hide ports on all hidden nodes (BaseShape.update corrupts port visibility)
  forceHidePortsOnHiddenNodes(graph);
};

/**
 * Diff-based proxy edge management.
 *
 * Computes the desired set of proxy edges from the current graph state,
 * diffs against existing proxy edges, and applies minimal changes.
 * Only calls graph.draw() (via safeDrawForProxyEdges) if edges were added or removed.
 *
 * Call after ANY operation that changes visibility of nodes/combos.
 */
const ensureProxyEdges = async (graph) => {
  const desired = computeDesiredProxies(graph);

  // Get existing proxy edges from the graph
  const allEdges = graph.getEdgeData();
  const existingProxies = new Map();
  for (const e of allEdges) {
    if (e.id && e.id.startsWith(PROXY_EDGE_PREFIX)) {
      // Extract key from ID: __combo_proxy__source_to_target
      const key = e.id.slice(PROXY_EDGE_PREFIX.length);
      existingProxies.set(key, e);
    }
  }

  // Compute diff
  const toAdd = [];
  const toShow = [];
  const toHide = [];

  // Edges in desired but not existing → add
  // Edges in desired and existing but hidden → show
  for (const [key, edgeData] of desired) {
    if (!existingProxies.has(key)) {
      toAdd.push(edgeData);
    } else {
      const existing = existingProxies.get(key);
      if (existing.style?.visibility === 'hidden') {
        toShow.push(existing.id);
      }
    }
  }

  // Edges in existing but not desired → remove or hide
  const toRemove = [];
  for (const [key, existing] of existingProxies) {
    if (!desired.has(key)) {
      toRemove.push(existing.id);
    }
  }

  // Apply structural changes (add/remove) — requires draw()
  const needsDraw = toAdd.length > 0 || toRemove.length > 0;

  if (toRemove.length > 0) {
    graph.removeEdgeData(toRemove);
  }

  if (toAdd.length > 0) {
    for (const edgeData of toAdd) {
      graph.addEdgeData([edgeData]);
    }
  }

  if (needsDraw) {
    await safeDrawForProxyEdges(graph);
  }

  // Toggle visibility with showElement/hideElement (safe, no cascade)
  if (toShow.length > 0) {
    await graph.showElement(toShow, false);
  }
  if (toHide.length > 0) {
    await graph.hideElement(toHide, false);
  }

  // Force-show ALL desired proxy edges at element level
  // (graph.draw or parent combo visibility can hide them)
  const desiredIds = [...desired.values()].map((e) => e.id);
  const proxyToShow = desiredIds.filter((pid) => {
    try {
      const el = graph.context.element?.getElement(pid);
      return el && el.style?.visibility === 'hidden';
    } catch (_) { return false; }
  });
  if (proxyToShow.length > 0) {
    await graph.showElement(proxyToShow, false);
  }
};

export {
  CircleComboWithExtraButton,
  RectComboWithExtraButton,
  FlyMarkerCubic,
  AntLine,
  reapplyComboCollapseState,
  ensureProxyEdges,
  collapsedCombos,
  PROXY_EDGE_PREFIX
};
