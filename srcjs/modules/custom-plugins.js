import { BasePlugin, CommonEvent } from '@antv/g6';

// Search box for navigating a large graph.
//
// G6 ships no search UI, but it does expose everything one needs: element data
// to match against and `focusElement()` to move the viewport. This renders a
// small input over the canvas, filters elements client-side as you type, and
// focuses the pick. Client-side on purpose: it works in a plain widget (Quarto,
// pkgdown, a vignette) and not only under Shiny, and it does not wait on a
// server round-trip per keystroke.
const CONTAINER_CLASS = 'g6-search';

// Matches `click_select()`'s default, so a searched element reads as selected to
// anything already listening for selection.
const SELECTED_STATE = 'selected';

// Where a match can come from. Ids are stable but ugly (`node-s01_b2`); the
// label is what a reader actually sees, so it is matched first and shown.
const labelOf = (datum) =>
  datum?.style?.labelText ??
  datum?.data?.label ??
  datum?.label ??
  String(datum?.id ?? '');

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
        const parent = d.combo ?? d.data?.combo ?? null;
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

  // What to show on the right of a row: the group a node sits in, or failing
  // that the kind of thing it is, named as the consumer chose.
  contextOf(hit) {
    return hit.context || (this.options.labels || {})[hit.type] || hit.type;
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

      // Shape, not a word: a filled square for a block, an outlined box for a
      // group, echoing how each looks on the canvas.
      const glyph = document.createElement('span');
      glyph.className = `${CONTAINER_CLASS}-glyph`;
      glyph.dataset.type = hit.type;
      glyph.setAttribute('aria-hidden', 'true');

      const name = document.createElement('span');
      name.className = `${CONTAINER_CLASS}-label`;
      name.textContent = hit.label;

      const kind = document.createElement('span');
      kind.className = `${CONTAINER_CLASS}-kind`;
      kind.textContent = this.contextOf(hit);

      // Screen readers get the type in words; sighted users get the glyph.
      li.setAttribute(
        'aria-label',
        `${hit.label}, ${(this.options.labels || {})[hit.type] || hit.type}`
      );

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

  // Combo ancestry of an element, innermost first.
  ancestors(id) {
    const { graph } = this.context;
    const chain = [];
    const seen = new Set();
    let current = id;

    while (current && !seen.has(current)) {
      seen.add(current);
      let parent = null;
      try {
        const datum =
          graph.getElementType(current) === 'combo'
            ? graph.getComboData(current)
            : graph.getNodeData(current);
        parent = datum?.combo ?? datum?.data?.combo ?? null;
      } catch (e) {
        parent = null;
      }
      if (!parent) break;
      chain.push(parent);
      current = parent;
    }

    return chain;
  }

  // A node inside a collapsed combo has no place on screen to focus, so open
  // whatever is closed on the way to it. Collapse lives in `style.collapsed`
  // (G6's own `isCollapsed()` reads that), not in the element's state. Expand
  // outermost first: an inner combo cannot open while its parent is still shut.
  async revealAncestors(id) {
    const { graph } = this.context;

    for (const combo of this.ancestors(id).reverse()) {
      try {
        if (graph.getComboData(combo)?.style?.collapsed) {
          await graph.expandElement(combo, false);
        }
      } catch (e) {
        // Not expandable, or already open: focusing still does the right thing.
      }
    }
  }

  async pick(index) {
    const hit = this.hits[index];
    if (!hit) return;

    const { graph } = this.context;

    if (this.options.expandAncestors) {
      await this.revealAncestors(hit.id);
    }

    try {
      await graph.focusElement(hit.id, this.options.animation);
    } catch (e) {
      return;
    }

    if (this.options.select) {
      // Deselect the previous pick first, or consecutive searches pile up
      // selections. Only what this box selected is cleared, and only the
      // selected state: a selection the user made by clicking, and any other
      // state on the element, are left alone.
      if (this.lastPick && this.lastPick !== hit.id) {
        try {
          const keep = (graph.getElementState(this.lastPick) || []).filter(
            (state) => state !== SELECTED_STATE
          );
          graph.setElementState({ [this.lastPick]: keep });
        } catch (e) {
          // The element may be gone; nothing to clear then.
        }
      }

      try {
        graph.setElementState({ [hit.id]: SELECTED_STATE });
        this.lastPick = hit.id;
      } catch (e) {
        // Selection is a nicety; a failed state must not break navigation.
      }
    }

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

export { Search };
