import {
  BaseLayout,
  CompactBoxLayout,
  DendrogramLayout,
  IndentedLayout,
  MindmapLayout,
  parseSize
} from '@antv/g6';

// G6's tree layouts (`compact-box`, `dendrogram`, `indented`, `mindmap`) take
// a node's children from its successors and lay out every root from the same
// origin. On a graph that is not a forest, a node with several parents is
// placed under one of them while the others keep an empty slot, and separate
// roots are drawn on top of each other.
//
// `spanning-tree` runs the same layouts on a spanning tree of the graph
// instead: every node keeps one parent, roots hang side by side under a hidden
// root, and the other edges are still drawn, they just don't place anything.
// Any graph lays out, including one with cycles.

const BASES = {
  'compact-box': CompactBoxLayout,
  dendrogram: DendrogramLayout,
  indented: IndentedLayout,
  mindmap: MindmapLayout
};

const VIRTUAL_ROOT = '__g6r_spanning_tree_root__';

// One parent per node: the node's `data.treeParent` when that is one of its
// sources, otherwise the source of its first incoming edge.
export const pickParents = (nodes, edges) => {
  const ids = new Set(nodes.map((n) => n.id));
  const incoming = new Map(nodes.map((n) => [n.id, []]));

  edges.forEach(({ source, target }) => {
    if (source === target || !ids.has(source) || !ids.has(target)) return;
    incoming.get(target).push(source);
  });

  const parent = new Map();
  nodes.forEach((n) => {
    const sources = incoming.get(n.id);
    if (!sources.length) return;
    const hint = n.data && n.data.treeParent;
    parent.set(n.id, sources.includes(hint) ? hint : sources[0]);
  });

  return parent;
};

// Children lists of the spanning tree. Nodes no root reaches (a cycle, or a
// node hanging off one) become roots themselves, first in node order, until
// every node is placed once.
export const spanningTree = (nodes, edges) => {
  const parent = pickParents(nodes, edges);
  const children = new Map(nodes.map((n) => [n.id, []]));

  parent.forEach((p, id) => children.get(p).push(id));

  const roots = nodes.filter((n) => !parent.has(n.id)).map((n) => n.id);
  const seen = new Set();

  const visit = (root) => {
    const stack = [root];
    while (stack.length) {
      const id = stack.pop();
      if (seen.has(id)) continue;
      seen.add(id);
      children.get(id).forEach((c) => stack.push(c));
    }
  };

  roots.forEach(visit);

  nodes.forEach((n) => {
    if (seen.has(n.id)) return;
    // Break the cycle here: drop the edge from its parent and make it a root.
    const p = parent.get(n.id);
    if (p !== undefined) {
      const siblings = children.get(p);
      siblings.splice(siblings.indexOf(n.id), 1);
      parent.delete(n.id);
    }
    roots.push(n.id);
    visit(n.id);
  });

  return { roots, children };
};

const toHierarchy = (id, children) => ({
  id,
  children: children.get(id).map((c) => toHierarchy(c, children))
});

// Lay `units` out as one spanning tree with a hierarchy layout and return
// each unit's centre. `sizeOf(id)` gives a unit's [width, height].
const runTree = (layout, units, edges, sizeOf, options) => {
  const { roots, children } = spanningTree(units, edges);

  let root;
  if (roots.length === 1) {
    root = toHierarchy(roots[0], children);
  } else {
    children.set(VIRTUAL_ROOT, roots);
    root = toHierarchy(VIRTUAL_ROOT, children);
  }

  const result = layout(root, Object.assign(
    {
      getId: (d) => d.id,
      getWidth: (d) => (d.id === VIRTUAL_ROOT ? 0 : sizeOf(d.id)[0]),
      getHeight: (d) => (d.id === VIRTUAL_ROOT ? 0 : sizeOf(d.id)[1])
    },
    options
  ));

  // A hierarchy node's x and y are its box's top-left corner, gaps included
  // on both sides, so its centre is half its box further.
  const centres = new Map();
  const walk = (node) => {
    if (node.id !== VIRTUAL_ROOT) {
      centres.set(node.id, [node.x + node.width / 2, node.y + node.height / 2]);
    }
    (node.children || []).forEach(walk);
  };
  walk(result);
  return centres;
};

const parsePadding = (padding) => {
  if (padding == null) return [20, 20, 20, 20];
  if (typeof padding === 'number') return [padding, padding, padding, padding];
  const [t, r = t, b = t, l = r] = padding;
  return [t, r, b, l];
};

export class SpanningTreeLayout extends BaseLayout {
  constructor(...args) {
    super(...args);
    this.id = 'spanning-tree';
  }

  async execute(model, options) {
    const { base = 'indented', nodeSize, combos: byCombo, comboPadding, ...rest } =
      Object.assign({}, SpanningTreeLayout.defaultOptions, this.options, options);

    const layout = BASES[base];
    if (!layout) {
      throw new Error(
        `spanning-tree: unknown base '${base}'. Use one of ${Object.keys(BASES).join(', ')}.`
      );
    }

    const nodes = model.nodes || [];
    if (!nodes.length) return { nodes: [] };
    const edges = model.edges || [];

    const byId = new Map(nodes.map((n) => [n.id, n]));
    const nodeSizeOf = (id) => {
      const size = typeof nodeSize === 'function' ? nodeSize(byId.get(id)) : nodeSize;
      const [w, h] = parseSize(size) || [0, 0];
      return [w, h];
    };

    // The top-level combo a node sits in, if combos are laid out as units.
    const comboParent = new Map((model.combos || []).map((c) => [c.id, c.combo]));
    const topCombo = (id) => {
      let combo = byId.get(id).combo;
      if (combo == null || !byCombo) return null;
      const seen = new Set();
      while (comboParent.get(combo) != null && !seen.has(combo)) {
        seen.add(combo);
        combo = comboParent.get(combo);
      }
      return combo;
    };
    const unitOf = new Map(nodes.map((n) => [n.id, topCombo(n.id) || n.id]));

    const out = [];

    if (![...unitOf].some(([id, unit]) => unit !== id)) {
      const centres = runTree(layout, nodes, edges, nodeSizeOf, rest);
      centres.forEach(([x, y], id) => out.push({ id, style: { x, y } }));
      return { nodes: centerInView(out, this.context) };
    }

    // 1. Each combo's members as their own tree, which fixes the combo's box.
    const [pt, pr, pb, pl] = parsePadding(comboPadding);
    const members = new Map();
    nodes.forEach((n) => {
      const unit = unitOf.get(n.id);
      if (unit === n.id) return;
      if (!members.has(unit)) members.set(unit, []);
      members.get(unit).push(n);
    });

    const inner = new Map();
    members.forEach((list, combo) => {
      const ids = new Set(list.map((n) => n.id));
      const within = edges.filter((e) => ids.has(e.source) && ids.has(e.target));
      const centres = runTree(layout, list, within, nodeSizeOf, rest);
      let [x0, y0, x1, y1] = [Infinity, Infinity, -Infinity, -Infinity];
      centres.forEach(([x, y], id) => {
        const [w, h] = nodeSizeOf(id);
        x0 = Math.min(x0, x - w / 2);
        y0 = Math.min(y0, y - h / 2);
        x1 = Math.max(x1, x + w / 2);
        y1 = Math.max(y1, y + h / 2);
      });
      inner.set(combo, {
        centres,
        // where the content's centre sits relative to the box's centre
        mid: [(x0 + x1) / 2, (y0 + y1) / 2],
        shift: [(pl - pr) / 2, (pt - pb) / 2],
        size: [x1 - x0 + pl + pr, y1 - y0 + pt + pb]
      });
    });

    // 2. The combos and the nodes outside them as one tree. Links between
    // units stand in for the links between their members; a combo hangs under
    // the parent its first member with an outside parent was given.
    const units = [];
    const seenUnit = new Set();
    nodes.forEach((n) => {
      const unit = unitOf.get(n.id);
      if (seenUnit.has(unit)) return;
      seenUnit.add(unit);
      units.push({ id: unit, data: {} });
    });
    const unitById = new Map(units.map((u) => [u.id, u]));
    nodes.forEach((n) => {
      const hint = n.data && n.data.treeParent;
      if (hint == null || !unitOf.has(hint)) return;
      const unit = unitById.get(unitOf.get(n.id));
      const parent = unitOf.get(hint);
      if (parent !== unit.id && unit.data.treeParent === undefined) {
        unit.data.treeParent = parent;
      }
    });

    const pairs = new Set();
    const between = [];
    edges.forEach(({ source, target }) => {
      const s = unitOf.get(source);
      const t = unitOf.get(target);
      if (s === undefined || t === undefined || s === t) return;
      const key = `${s}\u0000${t}`;
      if (pairs.has(key)) return;
      pairs.add(key);
      between.push({ source: s, target: t });
    });

    const unitSize = (id) => (inner.has(id) ? inner.get(id).size : nodeSizeOf(id));
    const outer = runTree(layout, units, between, unitSize, rest);

    // 3. Every node at its place: on its own, or inside its combo's box.
    nodes.forEach((n) => {
      const unit = unitOf.get(n.id);
      const [ux, uy] = outer.get(unit);
      if (unit === n.id) {
        out.push({ id: n.id, style: { x: ux, y: uy } });
        return;
      }
      const { centres, mid, shift } = inner.get(unit);
      const [x, y] = centres.get(n.id);
      out.push({ id: n.id, style: { x: ux + shift[0] + x - mid[0], y: uy + shift[1] + y - mid[1] } });
    });

    return { nodes: centerInView(out, this.context) };
  }
}

SpanningTreeLayout.defaultOptions = {
  base: 'indented',
  combos: false
};

// As G6 does for its own tree layouts: keep the result where it is when it
// fits the viewport, otherwise centre it there.
const centerInView = (nodes, context) => {
  const canvas = context && context.canvas;
  if (!canvas || !nodes.length) return nodes;

  let [minX, maxX, minY, maxY] = [Infinity, -Infinity, Infinity, -Infinity];
  nodes.forEach(({ style: { x, y } }) => {
    minX = Math.min(minX, x);
    maxX = Math.max(maxX, x);
    minY = Math.min(minY, y);
    maxY = Math.max(maxY, y);
  });

  const [x1, y1] = canvas.getCanvasByViewport([0, 0]);
  const [x2, y2] = canvas.getCanvasByViewport(canvas.getSize());
  if (minX >= x1 && maxX <= x2 && minY >= y1 && maxY <= y2) return nodes;

  const dx = (x1 + x2) / 2 - (minX + maxX) / 2;
  const dy = (y1 + y2) / 2 - (minY + maxY) / 2;
  return nodes.map(({ id, style: { x, y } }) => ({ id, style: { x: x + dx, y: y + dy } }));
};

// Positions a layout cannot have meant: a non-finite coordinate, or several
// nodes all on one point.
const unusable = (graph) => {
  const nodes = graph.getNodeData();
  const points = nodes.map((n) => [n.style && n.style.x, n.style && n.style.y]);
  if (points.some(([x, y]) => !Number.isFinite(x) || !Number.isFinite(y))) {
    return 'a node has no finite position';
  }
  if (nodes.length > 1 && points.every(([x, y]) => x === points[0][0] && y === points[0][1])) {
    return 'every node is on the same point';
  }
  return null;
};

// Every `graph.layout()` run goes through here, however it was asked for (the
// proxy, a client-side switch, a re-layout on data change). When the new
// layout throws or leaves unusable positions, the last layout that worked is
// put back and run, and `<id>-layout_fallback` says what happened.
export const guardLayout = (graph, id) => {
  const run = graph.layout.bind(graph);
  let lastGood = graph.getOptions().layout;

  graph.layout = async (...args) => {
    const attempt = graph.getOptions().layout;
    let reason = null;

    try {
      await run(...args);
      reason = unusable(graph);
    } catch (err) {
      reason = (err && err.message) || String(err);
    }

    if (!reason) {
      lastGood = attempt;
      return;
    }

    const type = attempt && attempt.type;
    if (lastGood && lastGood !== attempt) {
      graph.setLayout(lastGood);
      await run(...args);
    }

    if (typeof Shiny !== 'undefined' && Shiny.setInputValue) {
      Shiny.setInputValue(
        `${id}-layout_fallback`,
        { type: type || null, reason, restored: (lastGood && lastGood.type) || null },
        { priority: 'event' }
      );
    }
  };
};
