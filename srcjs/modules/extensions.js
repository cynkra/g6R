import {
  Line,
  CubicHorizontal,
  subStyleProps,
  CircleCombo
} from '@antv/g6';
import { Circle, Path } from '@antv/g';

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