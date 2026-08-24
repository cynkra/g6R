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

// Go to an element: open its collapsed ancestors, move the viewport, and select
// it. `previous` is the element this panel selected last time, deselected first
// so repeated picks do not pile up selections. Returns the id it selected, for
// the caller to remember.
const goTo = async (graph, id, options = {}) => {
  const { expandAncestors = true, select = true, animation, previous } = options;

  if (expandAncestors) await revealAncestors(graph, id);

  try {
    await graph.focusElement(id, animation);
  } catch (e) {
    return previous ?? null;
  }

  if (!select) return previous ?? null;

  if (previous && previous !== id) deselect(graph, previous);

  try {
    graph.setElementState({ [id]: SELECTED_STATE });
    return id;
  } catch (e) {
    // Selection is a nicety; a failed state must not break navigation.
    return previous ?? null;
  }
};

// One row of a list of elements: a glyph carrying the type by shape, the label,
// and context on the right (the group it lives in, or failing that the kind of
// thing it is, named as the consumer chose).
const elementRow = (hit, labels = {}) => {
  const glyph = document.createElement('span');
  glyph.className = 'g6-panel-glyph';
  glyph.dataset.type = hit.type;
  glyph.setAttribute('aria-hidden', 'true');

  const name = document.createElement('span');
  name.className = 'g6-panel-label';
  name.textContent = hit.label;

  const kind = document.createElement('span');
  kind.className = 'g6-panel-kind';
  kind.textContent = hit.context || labels[hit.type] || hit.type;

  return { glyph, name, kind, typeName: labels[hit.type] || hit.type };
};

export {
  SELECTED_STATE,
  labelOf,
  parentOf,
  elementDatum,
  ancestorsOf,
  revealAncestors,
  deselect,
  goTo,
  elementRow
};
