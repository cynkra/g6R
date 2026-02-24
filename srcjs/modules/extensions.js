import {
  Line,
  CubicHorizontal,
  subStyleProps,
  CircleCombo,
  RectCombo
} from '@antv/g6';
import { AABB, Circle, Path } from '@antv/g';

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

const collapsePath = (x, y, r) => {
  return [
    ['M', x - r, y],
    ['a', r, r, 0, 1, 0, r * 2, 0],
    ['a', r, r, 0, 1, 0, -r * 2, 0],
    ['M', x - r + 4, y],
    ['L', x + r - 4, y],
  ];
};

const expandPath = (x, y, r) => {
  return [
    ['M', x - r, y],
    ['a', r, r, 0, 1, 0, r * 2, 0],
    ['a', r, r, 0, 1, 0, -r * 2, 0],
    ['M', x - r + 4, y],
    ['L', x - r + 2 * r - 4, y],
    ['M', x - r + r, y - r + 4],
    ['L', x, y + r - 4],
  ];
};

// Track which combos have been collapsed via our custom button.
// We bypass G6's built-in collapseElement/expandElement (which destroys
// and recreates child elements, breaking border nodes) and instead use
// hideElement/showElement, consistent with the DAG collapse approach.
// Maps comboId → Set of element IDs that were already hidden before combo collapse,
// so on expand we only restore what the combo itself hid (preserving DAG collapse state).
const collapsedCombos = new Map();

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
        // All children hidden — fall back to small default size
        const bbox = new AABB();
        const { x = 0, y = 0, collapsedSize = 32 } = attributes;
        const s = typeof collapsedSize === 'number' ? collapsedSize : collapsedSize[0] || 32;
        bbox.setMinMax([x - s / 2, y - s / 2, 0], [x + s / 2, y + s / 2, 0]);
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
      const collapsed = collapsedCombos.has(this.id);
      const [, height] = this.getKeySize(attributes);
      const btnR = 8;
      const y = height / 2 + btnR;
      const d = collapsed ? expandPath(0, y, btnR) : collapsePath(0, y, btnR);

      const hitArea = this.upsert('hit-area', Circle, { cy: y, r: 10, fill: '#fff', cursor: 'pointer' }, this);
      this.upsert('button', Path, { stroke: '#3d81f7', d, cursor: 'pointer' }, hitArea);
    }

    onCreate() {
      this.shapeMap['hit-area'].addEventListener('click', async () => {
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

        // Edges where at least one endpoint is a combo member
        const connectedEdgeIds = allEdges
          .filter((e) => e.id && (memberSet.has(e.source) || memberSet.has(e.target)))
          .map((e) => e.id);

        if (isCollapsed) {
          // === EXPAND ===
          // Restore only what the combo collapse itself hid
          // (preserve DAG collapse state and other prior hidden elements)
          const previouslyHidden = collapsedCombos.get(comboId) || new Set();
          collapsedCombos.delete(comboId);

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
        } else {
          // === COLLAPSE ===
          // Snapshot elements that are already hidden (e.g. by DAG collapse)
          // so we don't restore them on expand
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
          collapsedCombos.set(comboId, alreadyHidden);

          // Hide member nodes and all their connected edges
          const toHide = [...memberIds, ...connectedEdgeIds]
            .filter((id) => !alreadyHidden.has(id));
          if (toHide.length > 0) {
            await graph.hideElement(toHide, false);
          }
        }

        // Force the combo to recalculate its bounds (shrink or expand)
        const comboData = graph.getComboData().find((c) => c.id === comboId);
        if (comboData) {
          const el = graph.context.element?.getElement(comboId);
          if (el) {
            const style = graph.context.element.getElementComputedStyle('combo', comboData);
            el.update(style);
          }
        }
      });
    }
  };
};

const CircleComboWithExtraButton = createComboWithExtraButton(CircleCombo);
const RectComboWithExtraButton = createComboWithExtraButton(RectCombo);

export { CircleComboWithExtraButton, RectComboWithExtraButton, FlyMarkerCubic, AntLine };
