import { BasePlugin } from '@antv/g6';
import {
  SELECTED_STATE,
  labelOf,
  parentOf,
  elementDatum,
  ancestorsOf,
  goTo,
  elementRow
} from './plugin-utils';

// Search box for navigating a large graph.
//
// G6 ships no search UI, but it does expose everything one needs: element data
// to match against and `focusElement()` to move the viewport. This renders a
// small input over the canvas, filters elements client-side as you type, and
// focuses the pick. Client-side on purpose: it works in a plain widget (Quarto,
// pkgdown, a vignette) and not only under Shiny, and it does not wait on a
// server round-trip per keystroke.
const CONTAINER_CLASS = 'g6-search';

class Search extends BasePlugin {
  static defaultOptions = {
    placeholder: 'Search',
    limit: 8,
    elements: ['node', 'combo'],
    expandAncestors: true,
    select: true,
    position: 'top-left',
    width: 220,
    labels: { node: 'node', combo: 'combo', edge: 'edge' }
  };

  constructor(context, options) {
    super(context, Object.assign({}, Search.defaultOptions, options));
    this.render();
  }

  // --- DOM ------------------------------------------------------------------

  render() {
    const { canvas } = this.context;
    const container = canvas.getContainer();
    if (!container) return;

    const box = document.createElement('div');
    box.className = CONTAINER_CLASS;
    box.dataset.position = this.options.position;
    box.style.width = `${this.options.width}px`;

    this.$input = document.createElement('input');
    this.$input.type = 'search';
    this.$input.className = `${CONTAINER_CLASS}-input`;
    this.$input.placeholder = this.options.placeholder;
    this.$input.setAttribute('aria-label', this.options.placeholder);

    this.$results = document.createElement('ul');
    this.$results.className = `${CONTAINER_CLASS}-results`;
    this.$results.setAttribute('role', 'listbox');

    box.appendChild(this.$input);
    box.appendChild(this.$results);
    container.appendChild(box);
    this.$element = box;

    this.hits = [];
    this.active = -1;
    // The element this box last selected, so the next pick can deselect it.
    this.lastPick = null;

    // A pointerdown on the box must not reach the canvas, or the graph's own
    // behaviors (drag-canvas, click-select) treat it as a canvas interaction.
    ['pointerdown', 'click', 'wheel'].forEach((type) => {
      box.addEventListener(type, (e) => e.stopPropagation());
    });

    this.$input.addEventListener('input', () => this.update());
    this.$input.addEventListener('keydown', (e) => this.onKeyDown(e));
    this.$input.addEventListener('blur', () => {
      // Deferred: a click on a result fires after blur and needs the list.
      setTimeout(() => this.close(), 150);
    });
  }

  // --- matching -------------------------------------------------------------

  candidates() {
    const { graph } = this.context;
    const want = this.options.elements;
    const out = [];

    // Combo labels, so a node can show the group it lives in. On a graph where
    // many blocks share a name, that context is what tells two matches apart.
    const comboLabel = {};
    (graph.getComboData() || []).forEach((d) => {
      comboLabel[d.id] = labelOf(d);
    });

    if (want.includes('node')) {
      (graph.getNodeData() || []).forEach((d) => {
        const parent = parentOf(d);
        out.push({
          id: d.id,
          label: labelOf(d),
          type: 'node',
          context: parent ? comboLabel[parent] || parent : null
        });
      });
    }
    if (want.includes('combo')) {
      (graph.getComboData() || []).forEach((d) =>
        out.push({ id: d.id, label: labelOf(d), type: 'combo', context: null })
      );
    }
    if (want.includes('edge')) {
      (graph.getEdgeData() || []).forEach((d) =>
        out.push({ id: d.id, label: labelOf(d), type: 'edge', context: null })
      );
    }

    return out;
  }

  // Groups before blocks, so the two kinds never interleave in the list.
  typeRank(type) {
    return { combo: 0, node: 1, edge: 2 }[type] ?? 3;
  }

  search(term) {
    const needle = term.trim().toLowerCase();
    if (!needle) return [];

    const scored = [];
    this.candidates().forEach((c) => {
      const label = String(c.label).toLowerCase();
      const id = String(c.id).toLowerCase();
      // Prefer a label hit over an id hit, and a prefix over a substring, so
      // typing the start of a name puts it first.
      let rank = -1;
      if (label.startsWith(needle)) rank = 0;
      else if (label.includes(needle)) rank = 1;
      else if (id.startsWith(needle)) rank = 2;
      else if (id.includes(needle)) rank = 3;
      if (rank >= 0) scored.push(Object.assign({ rank }, c));
    });

    scored.sort(
      (a, b) =>
        this.typeRank(a.type) - this.typeRank(b.type) ||
        a.rank - b.rank ||
        a.label.localeCompare(b.label)
    );
    return scored.slice(0, this.options.limit);
  }

  update() {
    this.hits = this.search(this.$input.value);
    this.active = this.hits.length ? 0 : -1;
    this.paint();
  }

  paint() {
    this.$results.innerHTML = '';
    this.$results.style.display = this.hits.length ? 'block' : 'none';

    this.hits.forEach((hit, i) => {
      const li = document.createElement('li');
      li.className = `${CONTAINER_CLASS}-result`;
      li.setAttribute('role', 'option');
      li.setAttribute('aria-selected', String(i === this.active));
      if (i === this.active) li.dataset.active = 'true';

      const { glyph, name, kind, typeName } = elementRow(hit, this.options.labels);

      // Screen readers get the type in words; sighted users get the glyph.
      li.setAttribute('aria-label', `${hit.label}, ${typeName}`);

      li.appendChild(glyph);
      li.appendChild(name);
      li.appendChild(kind);
      li.addEventListener('mousedown', (e) => {
        e.preventDefault();
        this.pick(i);
      });
      this.$results.appendChild(li);
    });
  }

  onKeyDown(event) {
    if (!this.hits.length) {
      if (event.key === 'Escape') this.close();
      return;
    }
    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault();
        this.active = (this.active + 1) % this.hits.length;
        this.paint();
        break;
      case 'ArrowUp':
        event.preventDefault();
        this.active = (this.active - 1 + this.hits.length) % this.hits.length;
        this.paint();
        break;
      case 'Enter':
        event.preventDefault();
        this.pick(this.active);
        break;
      case 'Escape':
        this.close();
        break;
      default:
        break;
    }
  }

  close() {
    this.hits = [];
    this.active = -1;
    if (this.$results) {
      this.$results.innerHTML = '';
      this.$results.style.display = 'none';
    }
  }

  // --- acting on a pick -----------------------------------------------------

  async pick(index) {
    const hit = this.hits[index];
    if (!hit) return;

    const { graph } = this.context;

    this.lastPick = await goTo(graph, hit.id, {
      expandAncestors: this.options.expandAncestors,
      select: this.options.select,
      animation: this.options.animation,
      previous: this.lastPick
    });

    // Report the pick so a Shiny app can react (reveal a panel, open an editor).
    if (this.options.outputId && typeof Shiny !== 'undefined') {
      Shiny.setInputValue(
        `${this.options.outputId}-searched_element`,
        { id: hit.id, type: hit.type, label: hit.label },
        { priority: 'event' }
      );
    }

    if (typeof this.options.onSelect === 'function') {
      this.options.onSelect(hit, graph);
    }

    this.$input.value = hit.label;
    this.close();
  }

  destroy() {
    if (this.$element && this.$element.parentNode) {
      this.$element.parentNode.removeChild(this.$element);
    }
    this.$element = null;
    super.destroy();
  }
}


// Outline: a list view of the graph, so a drawing too big to read stays
// navigable. Groups are accordions holding their members; clicking a row goes to
// that element on the canvas. Collapsing a group here is independent of
// collapsing it on the canvas -- this is for looking inside a group without
// redrawing anything -- and a selection on the canvas scrolls the matching row
// into view, so the two stay in step.
const OUTLINE_CLASS = 'g6-outline';

class Outline extends BasePlugin {
  static defaultOptions = {
    title: 'Outline',
    position: 'top-right',
    width: 260,
    open: true,
    groupsOpen: true,
    expandAncestors: true,
    select: true,
    labels: { node: 'node', combo: 'combo', edge: 'edge' }
  };

  constructor(context, options) {
    super(context, Object.assign({}, Outline.defaultOptions, options));
    this.openGroups = new Set();
    this.rowsById = new Map();
    this.lastPick = null;
    this.render();
    this.watchGraph();
  }

  // --- the tree -------------------------------------------------------------

  // Children of a combo, or the roots when `id` is null: combos with no parent
  // plus nodes belonging to no combo. Uses the combo hierarchy, not the node
  // `children` tree, so the outline matches the boxes drawn on the canvas.
  childrenOf(id) {
    const { graph, model } = this.context;

    if (id) {
      let kids = [];
      try {
        kids = model.getChildrenData(id) || [];
      } catch (e) {
        kids = [];
      }
      return kids.map((d) => this.entry(d.id));
    }

    const roots = [];
    (graph.getComboData() || []).forEach((d) => {
      if (!parentOf(d)) roots.push(this.entry(d.id));
    });
    (graph.getNodeData() || []).forEach((d) => {
      if (!parentOf(d)) roots.push(this.entry(d.id));
    });
    return roots;
  }

  entry(id) {
    const { graph } = this.context;
    let type = 'node';
    try {
      type = graph.getElementType(id);
    } catch (e) {
      type = 'node';
    }
    const datum =
      type === 'combo' ? graph.getComboData(id) : graph.getNodeData(id);
    return { id, type, label: labelOf(datum), context: null };
  }

  // Flow order, so the list reads like the pipeline rather than in insertion
  // order. Edges are lifted to the level being sorted: an edge from a member of
  // one group to a member of another orders those two groups. A cycle between
  // siblings is possible, so fall back to leaving them as they came.
  inFlowOrder(entries, parentId) {
    if (entries.length < 2) return entries;

    const { graph } = this.context;
    const index = new Map(entries.map((e, i) => [e.id, i]));

    // Which sibling, if any, an element belongs to.
    const owner = (id) => {
      if (index.has(id)) return id;
      let current = id;
      const seen = new Set();
      while (current && !seen.has(current)) {
        seen.add(current);
        const next = parentOf(elementDatum(graph, current));
        if (!next) return null;
        if (index.has(next)) return next;
        current = next;
      }
      return null;
    };

    const incoming = new Map(entries.map((e) => [e.id, 0]));
    const outgoing = new Map(entries.map((e) => [e.id, []]));

    (graph.getEdgeData() || []).forEach((e) => {
      const from = owner(e.source);
      const to = owner(e.target);
      if (!from || !to || from === to) return;
      outgoing.get(from).push(to);
      incoming.set(to, incoming.get(to) + 1);
    });

    const queue = entries.filter((e) => incoming.get(e.id) === 0).map((e) => e.id);
    const order = [];
    const done = new Set();

    while (queue.length) {
      const id = queue.shift();
      if (done.has(id)) continue;
      done.add(id);
      order.push(id);
      (outgoing.get(id) || []).forEach((next) => {
        incoming.set(next, incoming.get(next) - 1);
        if (incoming.get(next) === 0) queue.push(next);
      });
    }

    // Anything left sat in a cycle; keep its original position.
    entries.forEach((e) => {
      if (!done.has(e.id)) order.push(e.id);
    });

    return order.map((id) => entries[index.get(id)]);
  }

  // --- DOM ------------------------------------------------------------------

  render() {
    const { canvas } = this.context;
    const container = canvas.getContainer();
    if (!container) return;

    const box = document.createElement('div');
    box.className = OUTLINE_CLASS;
    box.dataset.position = this.options.position;
    box.style.width = `${this.options.width}px`;

    this.$toggle = document.createElement('button');
    this.$toggle.type = 'button';
    this.$toggle.className = `${OUTLINE_CLASS}-toggle`;
    this.$toggle.addEventListener('click', () => this.toggle());

    this.$body = document.createElement('div');
    this.$body.className = `${OUTLINE_CLASS}-body`;
    this.$body.setAttribute('role', 'tree');

    box.appendChild(this.$toggle);
    box.appendChild(this.$body);
    container.appendChild(box);
    this.$element = box;

    ['pointerdown', 'click', 'wheel', 'dblclick'].forEach((type) => {
      box.addEventListener(type, (e) => e.stopPropagation());
    });

    this.open = this.options.open !== false;
    this.paint();
  }

  toggle() {
    this.open = !this.open;
    this.paint();
  }

  isGroupOpen(id) {
    // `groupsOpen` is the starting state; `openGroups` records every deviation.
    return this.openGroups.has(id) !== (this.options.groupsOpen !== false);
  }

  toggleGroup(id) {
    if (this.openGroups.has(id)) this.openGroups.delete(id);
    else this.openGroups.add(id);
    this.paint();
  }

  paint() {
    if (!this.$element) return;

    this.$toggle.textContent = `${this.open ? '▾' : '▸'} ${this.options.title}`;
    this.$toggle.setAttribute('aria-expanded', String(this.open));
    this.$body.style.display = this.open ? 'block' : 'none';
    this.$body.innerHTML = '';
    this.rowsById.clear();

    if (!this.open) return;

    this.$body.appendChild(this.list(null, 0));
  }

  list(parentId, depth) {
    const ul = document.createElement('ul');
    ul.className = `${OUTLINE_CLASS}-list`;

    this.inFlowOrder(this.childrenOf(parentId), parentId).forEach((entry) => {
      const li = document.createElement('li');
      li.className = `${OUTLINE_CLASS}-item`;
      li.setAttribute('role', 'treeitem');

      const row = document.createElement('div');
      row.className = `${OUTLINE_CLASS}-row`;
      row.style.paddingLeft = `${8 + depth * 14}px`;
      row.dataset.id = entry.id;

      const isGroup = entry.type === 'combo';
      const openHere = isGroup && this.isGroupOpen(entry.id);

      if (isGroup) {
        const caret = document.createElement('span');
        caret.className = `${OUTLINE_CLASS}-caret`;
        caret.textContent = openHere ? '▾' : '▸';
        caret.setAttribute('role', 'button');
        caret.setAttribute('aria-label', openHere ? 'Collapse' : 'Expand');
        caret.addEventListener('click', (e) => {
          // Only the caret folds the list; the row itself navigates.
          e.stopPropagation();
          this.toggleGroup(entry.id);
        });
        row.appendChild(caret);
        li.setAttribute('aria-expanded', String(openHere));
      } else {
        const spacer = document.createElement('span');
        spacer.className = `${OUTLINE_CLASS}-caret`;
        spacer.setAttribute('aria-hidden', 'true');
        row.appendChild(spacer);
      }

      const { glyph, name, typeName } = elementRow(entry, this.options.labels);
      row.appendChild(glyph);
      row.appendChild(name);
      row.setAttribute('aria-label', `${entry.label}, ${typeName}`);
      row.addEventListener('click', () => this.go(entry));

      li.appendChild(row);
      this.rowsById.set(entry.id, row);

      if (isGroup && openHere) {
        li.appendChild(this.list(entry.id, depth + 1));
      }

      ul.appendChild(li);
    });

    return ul;
  }

  // --- acting ---------------------------------------------------------------

  async go(entry) {
    const { graph } = this.context;

    this.lastPick = await goTo(graph, entry.id, {
      expandAncestors: this.options.expandAncestors,
      select: this.options.select,
      animation: this.options.animation,
      previous: this.lastPick
    });

    this.mark(entry.id);

    if (this.options.outputId && typeof Shiny !== 'undefined') {
      Shiny.setInputValue(
        `${this.options.outputId}-outlined_element`,
        { id: entry.id, type: entry.type, label: entry.label },
        { priority: 'event' }
      );
    }
  }

  mark(id) {
    this.rowsById.forEach((row, rowId) => {
      if (rowId === id) row.dataset.current = 'true';
      else delete row.dataset.current;
    });
  }

  // A selection made on the canvas marks and scrolls to its row, so the panel
  // tracks where you are instead of drifting out of step.
  watchGraph() {
    const { graph } = this.context;

    const follow = () => {
      if (!this.open) return;
      let selected = [];
      try {
        selected = (graph.getElementDataByState('node', SELECTED_STATE) || [])
          .concat(graph.getElementDataByState('combo', SELECTED_STATE) || [])
          .map((d) => d.id);
      } catch (e) {
        return;
      }
      if (selected.length !== 1) return;

      const id = selected[0];
      this.reveal(id);
      const row = this.rowsById.get(id);
      if (row) {
        this.mark(id);
        row.scrollIntoView({ block: 'nearest' });
      }
    };

    // No dedicated selection event, so watch the redraw that follows one.
    this.followHandler = () => window.setTimeout(follow, 0);
    try {
      graph.on('afterdraw', this.followHandler);
    } catch (e) {
      // Without the hook the panel simply does not follow the canvas.
    }
  }

  // Open the groups between the root and an element, so its row exists to be
  // scrolled to.
  reveal(id) {
    const { graph } = this.context;
    const chain = ancestorsOf(graph, id);
    let changed = false;

    chain.forEach((combo) => {
      if (!this.isGroupOpen(combo)) {
        this.toggleGroupSilently(combo);
        changed = true;
      }
    });

    if (changed) this.paint();
  }

  toggleGroupSilently(id) {
    if (this.openGroups.has(id)) this.openGroups.delete(id);
    else this.openGroups.add(id);
  }

  destroy() {
    try {
      if (this.followHandler) this.context.graph.off('afterdraw', this.followHandler);
    } catch (e) {
      // Graph already gone.
    }
    if (this.$element && this.$element.parentNode) {
      this.$element.parentNode.removeChild(this.$element);
    }
    this.$element = null;
    super.destroy();
  }
}

export { Search, Outline };
