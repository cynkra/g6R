import { BasePlugin } from '@antv/g6';
import {
  SELECTED_STATE,
  labelOf,
  parentOf,
  elementDatum,
  ancestorsOf,
  goTo,
  elementRow,
  glyphFor,
  caretFor,
  imageOf,
  colorOf,
  fingerprint
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

// Announced, bubbling, from whichever list a pick came from, so one handler on
// the search box reacts to a pick from its results and from an outline hung
// under it alike.
const PICK_EVENT = 'g6:pick';

// Announced on the search box when it is shown, for whatever hangs under it.
const SHOW_EVENT = 'g6:show';

class Search extends BasePlugin {
  static defaultOptions = {
    placeholder: 'Search',
    limit: 8,
    elements: ['node', 'combo'],
    expandAncestors: true,
    select: true,
    position: 'top-left',
    width: 220,
    labels: { node: 'node', combo: 'combo', edge: 'edge' },
    // Start hidden, to be opened by the app (a toolbar tool, a shortcut) with
    // `show()` or `toggle()`, and dismissed by Escape, a click outside or a pick.
    collapsed: false
  };

  constructor(context, options) {
    super(context, Object.assign({}, Search.defaultOptions, options));
    this.render();
  }

  get collapsible() {
    return this.options.collapsed === true;
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
    this.visible = !this.collapsible;
    box.hidden = !this.visible;

    // A pointerdown on the box must not reach the canvas, or the graph's own
    // behaviors (drag-canvas, click-select) treat it as a canvas interaction.
    ['pointerdown', 'click', 'wheel'].forEach((type) => {
      box.addEventListener(type, (e) => e.stopPropagation());
    });

    this.$input.addEventListener('input', () => this.update());
    this.$input.addEventListener('keydown', (e) => this.onKeyDown(e));

    // Escape anywhere in the box, so it also works from an outline under it.
    box.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.collapsible) this.hide();
    });

    // A pick from either list closes a collapsible box.
    box.addEventListener(PICK_EVENT, () => {
      if (this.collapsible) this.hide();
    });

    // A click outside closes it too. Capture phase on the document, since the
    // canvas and the panels stop the events they handle from bubbling.
    if (this.collapsible) {
      this.onOutside = (e) => this.dismissFrom(e);
      document.addEventListener('pointerdown', this.onOutside, true);
    }
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
          image: imageOf(graph, d),
          context: parent ? comboLabel[parent] || parent : null
        });
      });
    }
    if (want.includes('combo')) {
      (graph.getComboData() || []).forEach((d) =>
        out.push({
          id: d.id,
          label: labelOf(d),
          type: 'combo',
          color: colorOf(graph, d),
          context: null
        })
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
    // While there is a query, an outline hung under the box makes way for the
    // matches (see g6.css).
    this.$element.toggleAttribute('data-searching', this.$input.value !== '');
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
      li.dataset.type = hit.type;
      if (hit.color) li.style.setProperty('--g6-element-color', hit.color);
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
      if (event.key === 'Escape' && !this.collapsible) this.close();
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
        // A collapsible box hides on Escape, from the box's own handler.
        if (!this.collapsible) this.close();
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

  // --- showing and hiding ---------------------------------------------------
  //
  // Reachable as `graph.getPluginInstance(key)`, for an app that opens the box
  // from its own control. Each opening starts from an empty query, with the
  // focus in the box.

  show() {
    if (!this.$element) return;
    this.visible = true;
    this.$element.hidden = false;
    this.$input.value = '';
    this.update();
    // A plain focus() scrolls a narrow canvas to bring the box into view,
    // sliding whatever sits around it out of place.
    this.$input.focus({ preventScroll: true });
    this.$element.dispatchEvent(new CustomEvent(SHOW_EVENT));
  }

  hide() {
    if (!this.$element) return;
    this.visible = false;
    this.$element.hidden = true;
    this.close();
    if (this.$element.contains(document.activeElement)) {
      document.activeElement.blur();
    }
  }

  // A control that toggles the box sits outside it, so pressing it while the
  // box is open first dismisses the box (pointerdown) and then toggles
  // (click), which would open it straight back. The dismissal is remembered
  // until that click has run, and a toggle within the same press leaves the
  // box closed.
  toggle() {
    if (this.dismissing) return;
    if (this.visible) this.hide();
    else this.show();
  }

  dismissFrom(event) {
    if (!this.visible || !this.$element) return;
    if (this.$element.contains(event.target)) return;

    this.hide();
    this.dismissing = true;
    const settle = () => {
      document.removeEventListener('pointerup', settle, true);
      document.removeEventListener('pointercancel', settle, true);
      // After the click that follows this pointerup.
      setTimeout(() => {
        this.dismissing = false;
      }, 0);
    };
    document.addEventListener('pointerup', settle, true);
    document.addEventListener('pointercancel', settle, true);
  }

  // --- acting on a pick -----------------------------------------------------

  async pick(index) {
    const hit = this.hits[index];
    if (!hit) return;

    const { graph } = this.context;

    await goTo(graph, hit.id, {
      expandAncestors: this.options.expandAncestors,
      select: this.options.select,
      animation: this.options.animation
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

    this.$element.dispatchEvent(
      new CustomEvent(PICK_EVENT, {
        bubbles: true,
        detail: { id: hit.id, type: hit.type, label: hit.label }
      })
    );
  }

  destroy() {
    if (this.onOutside) {
      document.removeEventListener('pointerdown', this.onOutside, true);
    }
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
    width: 240,
    open: true,
    groupsOpen: true,
    expandAncestors: true,
    select: true,
    // Where the panel lives: its own corner of the canvas, or hanging under the
    // search box as a dropdown, so the two read as one control.
    anchor: 'canvas',
    // Mirror the canvas: collapsing a group there folds its rows here. A fold
    // made in the panel still does not touch the canvas, so a group can be
    // skimmed without redrawing the graph.
    followCollapse: true,
    labels: { node: 'node', combo: 'combo', edge: 'edge' },
    // The toggle row with the title and totals. Without it the list is always
    // open: what an outline hung under a collapsible search wants, since the
    // search box already opens and closes the pair.
    header: true
  };

  constructor(context, options) {
    super(context, Object.assign({}, Outline.defaultOptions, options));
    // Folded state per group, filled in on first use from `groupsOpen` and the
    // canvas. Explicit rather than a deviation-from-baseline set, so both the
    // option and the canvas can drive it without one silently winning.
    this.folded = new Map();
    this.rowsById = new Map();
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

  // Elements a group holds, counted through nested groups so the number means
  // the same thing at every level. Folded groups still report their contents:
  // the count is about the graph, not about what the panel happens to show.
  contentCount(id) {
    return this.childrenOf(id).reduce(
      (total, child) =>
        total + (child.type === 'combo' ? this.contentCount(child.id) : 1),
      0
    );
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
    return {
      id,
      type,
      label: labelOf(datum),
      image: type === 'combo' ? null : imageOf(graph, datum),
      color: type === 'combo' ? colorOf(graph, datum) : null,
      context: null
    };
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

    // Anchoring to the search box only works if that box exists: plugins are
    // built in the order given, so fall back to a floating panel rather than
    // not rendering at all.
    const host =
      this.options.anchor === 'search'
        ? container.querySelector('.g6-search')
        : null;

    const box = document.createElement('div');
    box.className = OUTLINE_CLASS;
    box.dataset.anchor = host ? 'search' : 'canvas';

    if (host) {
      // Width and placement come from the search box it hangs under.
      box.style.width = '100%';
    } else {
      box.dataset.position = this.options.position;
      box.style.width = `${this.options.width}px`;
    }

    const header = this.options.header !== false;

    if (header) {
      this.$toggle = document.createElement('button');
      this.$toggle.type = 'button';
      this.$toggle.className = `${OUTLINE_CLASS}-toggle`;
      this.$toggle.addEventListener('click', () => this.toggle());
      box.appendChild(this.$toggle);
    } else {
      box.dataset.header = 'false';
    }

    this.$body = document.createElement('div');
    this.$body.className = `${OUTLINE_CLASS}-body`;
    this.$body.setAttribute('role', 'tree');
    this.$body.setAttribute('aria-label', this.options.title);

    box.appendChild(this.$body);
    (host || container).appendChild(box);
    this.$element = box;

    ['pointerdown', 'click', 'wheel', 'dblclick'].forEach((type) => {
      box.addEventListener(type, (e) => e.stopPropagation());
    });

    this.open = !header || this.options.open !== false;
    this.paint();

    // Hidden while the search box was shut, the list could not scroll to a
    // selection made in the meantime: catch up when the box opens.
    if (host) {
      this.onHostShow = () => this.syncSelection();
      host.addEventListener(SHOW_EVENT, this.onHostShow);
      this.$host = host;
    }
  }

  toggle() {
    if (!this.$toggle) return;
    this.open = !this.open;
    this.paint();
    // Opening catches up with whatever is selected now: a search made while the
    // panel was shut still lands on the right row.
    if (this.open) this.syncSelection();
  }

  isCollapsedOnCanvas(id) {
    try {
      return !!this.context.graph.getComboData(id)?.style?.collapsed;
    } catch (e) {
      return false;
    }
  }

  // Folded or not, remembered per group. First asked, it starts from
  // `groupsOpen` and from whether the canvas already has the group collapsed.
  isFolded(id) {
    if (!this.folded.has(id)) {
      this.folded.set(
        id,
        this.options.groupsOpen === false ||
          (this.options.followCollapse !== false && this.isCollapsedOnCanvas(id))
      );
    }
    return this.folded.get(id);
  }

  isGroupOpen(id) {
    return !this.isFolded(id);
  }

  // Collapse state of every group on the canvas, to spot a change.
  collapseKey() {
    const { graph } = this.context;
    try {
      return (graph.getComboData() || [])
        .map((d) => `${d.id}\u0001${d.style?.collapsed ? 1 : 0}`)
        .sort()
        .join('\u0002');
    } catch (e) {
      return this.lastCollapseKey ?? '';
    }
  }

  // A group collapsed or expanded on the canvas takes the panel's fold with it,
  // overriding whatever was folded here.
  followCanvasCollapse(previous) {
    const now = new Map(
      this.collapseKey()
        .split('\u0002')
        .filter(Boolean)
        .map((entry) => entry.split('\u0001'))
    );
    const before = new Map(
      (previous || '')
        .split('\u0002')
        .filter(Boolean)
        .map((entry) => entry.split('\u0001'))
    );

    now.forEach((state, id) => {
      if (before.has(id) && before.get(id) !== state) {
        this.folded.set(id, state === '1');
      }
    });
  }

  toggleGroup(id) {
    this.folded.set(id, !this.isFolded(id));
    this.paint();
  }

  // What the graph holds, whatever the panel is currently showing: folded
  // groups and collapsed combos still count, and the figure is worth having
  // while the panel is shut, which is the point of putting it on the toggle.
  totals() {
    const { graph } = this.context;
    const size = (read) => {
      try {
        return (read() || []).length;
      } catch (e) {
        return 0;
      }
    };

    return {
      node: size(() => graph.getNodeData()),
      combo: size(() => graph.getComboData())
    };
  }

  // Caret, title, then the totals as a glyph and a number per kind, in the
  // same shapes the rows use so the pair reads without a legend. The words go
  // in the accessible name, where they cost no width: a title long enough to
  // crowd the number is likelier than a spare 80px.
  toggleContent() {
    const caret = caretFor(this.open);
    caret.setAttribute('aria-hidden', 'true');

    const title = document.createElement('span');
    title.className = `${OUTLINE_CLASS}-title`;
    title.textContent = this.options.title;

    const total = document.createElement('span');
    total.className = `${OUTLINE_CLASS}-total`;
    total.setAttribute('aria-hidden', 'true');

    const totals = this.totals();
    const spoken = [];

    // A kind the graph does not have is left out rather than shown as a zero.
    ['node', 'combo'].forEach((type) => {
      const n = totals[type];
      if (!n) return;

      const tally = document.createElement('span');
      tally.className = `${OUTLINE_CLASS}-tally`;
      tally.textContent = String(n);
      total.append(glyphFor(type), tally);

      const unit = this.options.labels?.[type] || type;
      spoken.push(`${n} ${unit}${n === 1 ? '' : 's'}`);
    });

    this.$toggle.setAttribute(
      'aria-label',
      [this.options.title, ...spoken].join(', ')
    );

    return spoken.length ? [caret, title, total] : [caret, title];
  }

  paint() {
    if (!this.$element) return;

    if (this.$toggle) {
      this.$toggle.textContent = '';
      this.$toggle.append(...this.toggleContent());
      this.$toggle.setAttribute('aria-expanded', String(this.open));
    }
    this.$body.style.display = this.open ? 'block' : 'none';
    this.$body.innerHTML = '';
    this.rowsById.clear();

    if (!this.open) return;

    this.$body.appendChild(this.list(null, 0));
  }

  list(parentId, depth) {
    const ul = document.createElement('ul');
    ul.className = `${OUTLINE_CLASS}-list`;

    // Every row reserves the caret column, foldable or not: dropping it on
    // leaf rows would pull them left of the parent they belong to, and buying
    // that back with a wider indent costs exactly what the column did.
    this.inFlowOrder(this.childrenOf(parentId), parentId).forEach((entry) => {
      const li = document.createElement('li');
      li.className = `${OUTLINE_CLASS}-item`;
      li.setAttribute('role', 'treeitem');
      li.dataset.type = entry.type;
      if (entry.color) li.style.setProperty('--g6-element-color', entry.color);

      const row = document.createElement('div');
      row.className = `${OUTLINE_CLASS}-row`;
      row.style.setProperty(`--${OUTLINE_CLASS}-depth`, String(depth));
      row.dataset.id = entry.id;

      const isGroup = entry.type === 'combo';
      const openHere = isGroup && this.isGroupOpen(entry.id);

      if (isGroup) {
        const caret = caretFor(openHere);
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

      // No context column: the indentation already shows which group a row
      // belongs to, and the glyph shows what kind it is.
      const { glyph, name, typeName } = elementRow(entry, this.options.labels);
      row.appendChild(glyph);
      row.appendChild(name);

      let described = `${entry.label}, ${typeName}`;

      if (isGroup) {
        const total = this.contentCount(entry.id);
        const count = document.createElement('span');
        count.className = `${OUTLINE_CLASS}-count`;
        count.textContent = String(total);
        count.setAttribute('aria-hidden', 'true');
        row.appendChild(count);
        const unit = this.options.labels.node || 'node';
        described += `, ${total} ${unit}${total === 1 ? '' : 's'}`;
      }

      row.setAttribute('aria-label', described);
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

    await goTo(graph, entry.id, {
      expandAncestors: this.options.expandAncestors,
      select: this.options.select,
      animation: this.options.animation
    });

    this.mark(entry.id);

    if (this.options.outputId && typeof Shiny !== 'undefined') {
      Shiny.setInputValue(
        `${this.options.outputId}-outlined_element`,
        { id: entry.id, type: entry.type, label: entry.label },
        { priority: 'event' }
      );
    }

    if (typeof this.options.onSelect === 'function') {
      this.options.onSelect(entry, graph);
    }

    // Bubbles to a search box this panel hangs under, which closes on a pick.
    this.$element?.dispatchEvent(
      new CustomEvent(PICK_EVENT, {
        bubbles: true,
        detail: { id: entry.id, type: entry.type, label: entry.label }
      })
    );
  }

  mark(id) {
    this.rowsById.forEach((row, rowId) => {
      if (rowId === id) row.dataset.current = 'true';
      else delete row.dataset.current;
    });
  }

  // The one element selected on the canvas, if exactly one is. With several
  // selected there is nothing sensible to scroll to.
  selectedId() {
    const { graph } = this.context;
    let selected = [];
    try {
      selected = (graph.getElementDataByState('node', SELECTED_STATE) || [])
        .concat(graph.getElementDataByState('combo', SELECTED_STATE) || [])
        .map((d) => d.id);
    } catch (e) {
      return null;
    }
    return selected.length === 1 ? selected[0] : null;
  }

  // Bring the panel in line with the canvas: unfold the groups above the
  // selected element so its row exists, then mark it and scroll to it. Called
  // both when the canvas redraws and when the panel is opened, so a selection
  // made while it was shut is not missed.
  syncSelection() {
    if (!this.open) return;

    const id = this.selectedId();
    if (!id) return;

    if (this.openAncestors(id)) this.paint();

    const row = this.rowsById.get(id);
    if (row) {
      this.mark(id);
      row.scrollIntoView({ block: 'nearest' });
    }
  }

  // Unfold every group between the root and an element. Returns whether
  // anything changed, so the caller repaints only when it must -- repainting
  // from inside here would recurse through syncSelection().
  openAncestors(id) {
    const { graph } = this.context;
    let changed = false;

    ancestorsOf(graph, id).forEach((combo) => {
      if (this.isFolded(combo)) {
        this.unfoldSilently(combo);
        changed = true;
      }
    });

    return changed;
  }

  // What the panel is a picture of: which elements exist, what each is called,
  // and which group it sits in. Compared after every redraw so the list is
  // rebuilt when the graph gains, loses or reparents something -- and only
  // then, since repainting on every draw would fight scrolling and cost work on
  // a large graph.
  structureKey() {
    const { graph } = this.context;

    // The image is keyed by a fingerprint: its source can be a long data URI,
    // and this runs on every draw, hover and selection included.
    const describe = (data, look) =>
      (data || [])
        .map(
          (d) =>
            `${d.id}\u0001${parentOf(d) || ''}\u0001${labelOf(d)}` +
            `\u0001${look(d)}`
        )
        .sort()
        .join('\u0002');

    try {
      return [
        describe(graph.getNodeData(), (d) => fingerprint(imageOf(graph, d))),
        describe(graph.getComboData(), (d) => colorOf(graph, d) || '')
      ].join('\u0003');
    } catch (e) {
      return this.lastKey ?? '';
    }
  }

  // A redraw follows any change worth reacting to: a selection, or the graph
  // itself gaining or losing elements. Both are handled here, so the panel
  // tracks the canvas instead of drifting out of step.
  watchGraph() {
    const { graph } = this.context;

    this.lastKey = this.structureKey();
    this.lastCollapseKey = this.collapseKey();

    const onDraw = () => {
      const key = this.structureKey();
      const collapseKey = this.collapseKey();
      let repaint = false;

      if (key !== this.lastKey) {
        this.lastKey = key;
        repaint = true;
      }

      if (collapseKey !== this.lastCollapseKey) {
        if (this.options.followCollapse !== false) {
          this.followCanvasCollapse(this.lastCollapseKey);
        }
        this.lastCollapseKey = collapseKey;
        repaint = true;
      }

      if (repaint) this.paint();
      this.syncSelection();
    };

    // No dedicated event for either, so watch the redraw that follows.
    this.followHandler = () => window.setTimeout(onDraw, 0);
    try {
      graph.on('afterdraw', this.followHandler);
    } catch (e) {
      // Without the hook the panel simply does not follow the canvas.
    }
  }

  unfoldSilently(id) {
    this.folded.set(id, false);
  }

  destroy() {
    try {
      if (this.followHandler) this.context.graph.off('afterdraw', this.followHandler);
    } catch (e) {
      // Graph already gone.
    }
    if (this.$host && this.onHostShow) {
      this.$host.removeEventListener(SHOW_EVENT, this.onHostShow);
    }
    if (this.$element && this.$element.parentNode) {
      this.$element.parentNode.removeChild(this.$element);
    }
    this.$element = null;
    super.destroy();
  }
}

export { Search, Outline };
