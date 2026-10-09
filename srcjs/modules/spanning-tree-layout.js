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

export class SpanningTreeLayout extends BaseLayout {
  constructor(...args) {
    super(...args);
    this.id = 'spanning-tree';
  }

  async execute(model, options) {
    const { base = 'indented', nodeSize, ...rest } = Object.assign(
      {},
      SpanningTreeLayout.defaultOptions,
      this.options,
      options
    );

    const layout = BASES[base];
    if (!layout) {
      throw new Error(
        `spanning-tree: unknown base '${base}'. Use one of ${Object.keys(BASES).join(', ')}.`
      );
    }

    const nodes = model.nodes || [];
    if (!nodes.length) return { nodes: [] };

    const { roots, children } = spanningTree(nodes, model.edges || []);

    const byId = new Map(nodes.map((n) => [n.id, n]));
    const sizeOf = (id) => {
      if (id === VIRTUAL_ROOT) return [0, 0];
      const size = typeof nodeSize === 'function' ? nodeSize(byId.get(id)) : nodeSize;
      const [w, h] = parseSize(size) || [0, 0];
      return [w, h];
    };

    let root;
    if (roots.length === 1) {
      root = toHierarchy(roots[0], children);
    } else {
      children.set(VIRTUAL_ROOT, roots);
      root = toHierarchy(VIRTUAL_ROOT, children);
    }

    // Sizes come from the drawn nodes unless the caller gives its own.
    const result = layout(root, Object.assign(
      {
        getId: (d) => d.id,
        getWidth: (d) => sizeOf(d.id)[0],
        getHeight: (d) => sizeOf(d.id)[1]
      },
      rest
    ));

    // A hierarchy node's x and y are its box's top-left corner, gaps included
    // on both sides, so its centre is half its box further. Read as the
    // centre, nodes of different sizes came out misaligned.
    const out = [];
    const walk = (node) => {
      if (node.id !== VIRTUAL_ROOT) {
        out.push({
          id: node.id,
          style: { x: node.x + node.width / 2, y: node.y + node.height / 2 }
        });
      }
      (node.children || []).forEach(walk);
    };
    walk(result);

    return { nodes: centerInView(out, this.context) };
  }
}

SpanningTreeLayout.defaultOptions = {
  base: 'indented'
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
