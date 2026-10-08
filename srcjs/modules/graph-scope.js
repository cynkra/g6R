// Let plugin and behavior callbacks name the graph.
//
// htmlwidgets turns `JS()` strings into functions with `eval()` inside its own
// script, where nothing called `graph` exists, and G6 calls most plugin
// callbacks without binding `this` (the toolbar calls `onClick(value, target)`).
// So a callback written as `(value) => graph.zoomTo(1.1)`, the way the R docs
// show it, throws when it runs. Each such function is rebuilt from its source
// with a `graph` binding in scope, filled in once the widget's graph exists.
//
// Only functions whose source mentions `graph` are rebuilt, and only in plugin
// and behavior options. Element style callbacks are left alone: G6 already
// calls them with `this` set to the graph, and they run per element per draw.

const MENTIONS_GRAPH = /\bgraph\b/;

const isPlainObject = (x) => {
  if (x === null || typeof x !== 'object') return false;
  const proto = Object.getPrototypeOf(x);
  return proto === Object.prototype || proto === null;
};

// The same function, now able to see `graph`. A function whose source cannot be
// rebuilt (native, bound, a method shorthand) is returned as it was.
const rebind = (fn, setters) => {
  const source = Function.prototype.toString.call(fn);
  if (!MENTIONS_GRAPH.test(source) || /\[native code\]\s*\}$/.test(source)) {
    return fn;
  }

  try {
    // eslint-disable-next-line no-new-func
    const factory = new Function(
      '__setGraph',
      `var graph; __setGraph(function (g) { graph = g; }); return (${source});`
    );
    return factory((set) => setters.push(set));
  } catch (e) {
    return fn;
  }
};

// Walk a plugin or behavior config (or a list of them) and rebind its functions
// in place. Only plain objects and arrays are entered: anything else is a value
// G6 or the browser owns.
const walk = (value, setters) => {
  if (typeof value === 'function') return rebind(value, setters);

  if (Array.isArray(value)) {
    for (let i = 0; i < value.length; i++) value[i] = walk(value[i], setters);
    return value;
  }

  if (isPlainObject(value)) {
    Object.keys(value).forEach((key) => {
      value[key] = walk(value[key], setters);
    });
  }

  return value;
};

// Rebind the callbacks in `config.plugins` and `config.behaviors` before the
// graph is built from it. Returns a function to call with the graph once it
// exists.
const scopeGraphConfig = (config) => {
  const setters = [];
  if (config.plugins) config.plugins = walk(config.plugins, setters);
  if (config.behaviors) config.behaviors = walk(config.behaviors, setters);
  return (graph) => setters.forEach((set) => set(graph));
};

// For options arriving after the graph exists (the Shiny proxy's updates).
const scopeGraph = (options, graph) => {
  const setters = [];
  const out = walk(options, setters);
  setters.forEach((set) => set(graph));
  return out;
};

export { scopeGraphConfig, scopeGraph };
