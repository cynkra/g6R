// Colours of the collapse button on nodes and combos. Whatever the caller
// leaves unset follows the graph's theme, and the +/- icon (or the "+ N"
// count) is picked to contrast with the fill the button ends up with, so a
// consumer that themes only the disc still gets a legible icon.

const ICON_ON_LIGHT = '#4b5563';
const ICON_ON_DARK = '#d1d5db';

// Any CSS colour the canvas understands, as [r, g, b]: the 2D context
// normalises names, hex and rgb()/hsl() for us. A colour it cannot read (a
// `var()`, a typo) gives null.
let ctx = null;
const parsed = new Map();

const toRgb = (color) => {
  if (typeof color !== 'string' || !color) return null;
  if (parsed.has(color)) return parsed.get(color);

  ctx = ctx || document.createElement('canvas').getContext('2d');
  let rgb = null;
  if (ctx) {
    ctx.fillStyle = '#010203';
    ctx.fillStyle = color;
    const out = ctx.fillStyle;
    if (out !== '#010203' || color.replace(/\s/g, '') === '#010203') {
      if (out.startsWith('#')) {
        rgb = [1, 3, 5].map((i) => parseInt(out.slice(i, i + 2), 16));
      } else {
        const m = out.match(/[\d.]+/g);
        rgb = m && m.length >= 3 ? m.slice(0, 3).map(Number) : null;
      }
    }
  }

  parsed.set(color, rgb);
  return rgb;
};

const luminance = ([r, g, b]) => {
  const lin = (c) => {
    const s = c / 255;
    return s <= 0.03928 ? s / 12.92 : ((s + 0.055) / 1.055) ** 2.4;
  };
  return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);
};

const contrast = (a, b) => {
  const [hi, lo] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return (hi + 0.05) / (lo + 0.05);
};

// The icon colour that reads best on `fill`, or null when the fill cannot be
// read (the caller then falls back on the theme).
const iconFor = (fill) => {
  const rgb = toRgb(fill);
  if (!rgb) return null;
  return contrast(rgb, toRgb(ICON_ON_LIGHT)) >= contrast(rgb, toRgb(ICON_ON_DARK))
    ? ICON_ON_LIGHT
    : ICON_ON_DARK;
};

// `config` is a node's or combo's `collapse` style, `graph` the G6 graph.
const collapseColors = (config = {}, graph) => {
  const options = graph?.options || {};
  const isDark = options.theme === 'dark';

  const fill = config.fill || (isDark ? options.background || '#1b1b1b' : '#fff');
  const stroke = config.stroke || (isDark ? '#4b5563' : '#9cabd4');
  const iconStroke =
    config.iconStroke || iconFor(fill) || (isDark ? ICON_ON_DARK : ICON_ON_LIGHT);

  return { fill, stroke, iconStroke };
};

export { collapseColors };
