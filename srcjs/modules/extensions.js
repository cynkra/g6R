import {
  Line,
  CubicHorizontal,
  subStyleProps,
  CircleCombo
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

const collapse = (x, y, r) => {
  return [
    ['M', x - r, y],
    ['a', r, r, 0, 1, 0, r * 2, 0],
    ['a', r, r, 0, 1, 0, -r * 2, 0],
    ['M', x - r + 4, y],
    ['L', x + r - 4, y],
  ];
};

const expand = (x, y, r) => {
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

class CircleComboWithExtraButton extends CircleCombo {
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
    const { collapsed } = attributes;
    const [, height] = this.getKeySize(attributes);
    const btnR = 8;
    const y = height / 2 + btnR;
    const d = collapsed ? expand(0, y, btnR) : collapse(0, y, btnR);

    const hitArea = this.upsert('hit-area', Circle, { cy: y, r: 10, fill: '#fff', cursor: 'pointer' }, this);
    this.upsert('button', Path, { stroke: '#3d81f7', d, cursor: 'pointer' }, hitArea);
  }

  onCreate() {
    this.shapeMap['hit-area'].addEventListener('click', () => {
      const id = this.id;
      const collapsed = !this.attributes.collapsed;
      const { graph } = this.context;
      if (collapsed) graph.collapseElement(id);
      else graph.expandElement(id);
    });
  }
}

export { CircleComboWithExtraButton, FlyMarkerCubic, AntLine };