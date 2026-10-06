// Shared between the DOM plugins that navigate a graph (search, outline): how
// to read an element's label, how to draw a row for it, and what "go to this
// element" means. Kept in one place so the two never drift apart.

// Matches `click_select()`'s default, so an element reached from a panel reads
// as selected to anything already listening for selection.
const SELECTED_STATE = 'selected';

// Where a readable name can come from. Ids are stable but ugly (`node-s01_b2`);
// the label is what a reader actually sees.
const labelOf = (datum) =>
  datum?.style?.labelText ??
  datum?.data?.label ??
  datum?.label ??
  String(datum?.id ?? '');

// How an element looks on the canvas, so a panel row can look the same: a node
// drawn as an image shows that image, and a combo carries its fill colour for
// the consumer's stylesheet (as `--g6-element-color`).
const imageOf = (datum) => datum?.style?.src ?? null;

const colorOf = (datum) => datum?.style?.fill ?? null;

const parentOf = (datum) => datum?.combo ?? datum?.data?.combo ?? null;

const elementDatum = (graph, id) => {
  try {
    return graph.getElementType(id) === 'combo'
      ? graph.getComboData(id)
      : graph.getNodeData(id);
  } catch (e) {
    return null;
  }
};

// Combo ancestry of an element, innermost first.
const ancestorsOf = (graph, id) => {
  const chain = [];
  const seen = new Set();
  let current = id;

  while (current && !seen.has(current)) {
    seen.add(current);
    const parent = parentOf(elementDatum(graph, current));
    if (!parent) break;
    chain.push(parent);
    current = parent;
  }

  return chain;
};

// A node inside a collapsed combo has no place on screen to focus, so open
// whatever is closed on the way to it. Collapse lives in `style.collapsed`
// (G6's own `isCollapsed()` reads that), not in the element's state. Expand
// outermost first: an inner combo cannot open while its parent is still shut.
const revealAncestors = async (graph, id) => {
  for (const combo of ancestorsOf(graph, id).reverse()) {
    try {
      if (graph.getComboData(combo)?.style?.collapsed) {
        await graph.expandElement(combo, false);
      }
    } catch (e) {
      // Not expandable, or already open: focusing still does the right thing.
    }
  }
};

// Drop the selected state from an element without touching its other states, so
// a hover's `active` (or anything else) survives.
const deselect = (graph, id) => {
  if (!id) return;
  try {
    const keep = (graph.getElementState(id) || []).filter(
      (state) => state !== SELECTED_STATE
    );
    graph.setElementState({ [id]: keep });
  } catch (e) {
    // The element may be gone; nothing to clear then.
  }
};

// The element a panel last sent us to, per graph. Shared, not per plugin: with
// a search box and an outline over the same graph, picking in one must clear
// what the other selected, or selections accumulate across the two.
const lastPickByGraph = new WeakMap();

// Go to an element: open its collapsed ancestors, move the viewport, and select
// it. Whatever a panel selected last is deselected first, so repeated picks --
// from either panel -- do not pile up selections.
const goTo = async (graph, id, options = {}) => {
  const { expandAncestors = true, select = true, animation } = options;
  const previous = lastPickByGraph.get(graph) ?? null;

  if (expandAncestors) await revealAncestors(graph, id);

  try {
    await graph.focusElement(id, animation);
  } catch (e) {
    return previous ?? null;
  }

  if (!select) return previous;

  if (previous && previous !== id) deselect(graph, previous);

  try {
    graph.setElementState({ [id]: SELECTED_STATE });
    lastPickByGraph.set(graph, id);
    return id;
  } catch (e) {
    // Selection is a nicety; a failed state must not break navigation.
    return previous;
  }
};

// Glyph shapes, drawn rather than approximated with a styled box: a dot for a
// single element, a folder for a container, a rule for a connection. At this
// size a bordered box just reads as another node, so a container needs an
// outline nobody has to decode. Static markup, no interpolation.
const GLYPH_SHAPES = {
  node: '<circle cx="8" cy="8" r="4"/>',
  combo:
    '<path d="M2 13.2V4.8c0-.44.36-.8.8-.8h3.05c.27 0 .52.13.67.36' +
    'l.83 1.24H13.2c.44 0 .8.36.8.8v6.8c0 .44-.36.8-.8.8H2.8' +
    'a.8.8 0 0 1-.8-.8Z"/>',
  edge: '<rect x="1.5" y="7.25" width="13" height="1.5" rx=".75"/>'
};

const glyphFor = (type, image = null) => {
  if (image) {
    const img = document.createElement('img');
    img.className = 'g6-panel-glyph';
    img.dataset.type = type;
    img.dataset.image = 'true';
    img.alt = '';
    img.src = image;
    return img;
  }

  const glyph = document.createElement('span');
  glyph.className = 'g6-panel-glyph';
  glyph.dataset.type = type;
  glyph.setAttribute('aria-hidden', 'true');
  glyph.innerHTML = `<svg viewBox="0 0 16 16" focusable="false">${
    GLYPH_SHAPES[type] || GLYPH_SHAPES.node
  }</svg>`;
  return glyph;
};

// One row of a list of elements: a glyph carrying the type by shape, the label,
// and context on the right (the group it lives in, or failing that the kind of
// thing it is, named as the consumer chose).
const elementRow = (hit, labels = {}) => {
  const glyph = glyphFor(hit.type, hit.image);

  const name = document.createElement('span');
  name.className = 'g6-panel-label';
  name.textContent = hit.label;

  const kind = document.createElement('span');
  kind.className = 'g6-panel-kind';
  kind.textContent = hit.context || labels[hit.type] || hit.type;

  return { glyph, name, kind, typeName: labels[hit.type] || hit.type };
};

// A disclosure chevron, drawn rather than typed (a typed triangle sits on the
// text baseline and changes with the font). It points down; a closed fold
// turns it right through `data-open="false"` in the stylesheet.
const caretFor = (open) => {
  const caret = document.createElement('span');
  caret.className = 'g6-outline-caret';
  caret.dataset.open = String(!!open);
  caret.innerHTML =
    '<svg viewBox="0 0 12 12" focusable="false" aria-hidden="true">' +
    '<path d="M3 4.5l3 3 3-3"/></svg>';
  return caret;
};

export {
  SELECTED_STATE,
  glyphFor,
  caretFor,
  imageOf,
  colorOf,
  labelOf,
  parentOf,
  elementDatum,
  ancestorsOf,
  revealAncestors,
  deselect,
  goTo,
  elementRow
};
