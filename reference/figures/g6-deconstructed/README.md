# g6R, deconstructed — animation source

Source for the README animation `man/figures/g6R-deconstructed.gif`. Walks the
`g6()` pipe one call at a time, exploding a small graph into five stacked
snapshot cards: data, layout, options, behaviors, plugins. Adapted from
[EmilHvitfeldt/tidy-animations](https://github.com/EmilHvitfeldt/tidy-animations)
(`ggplot2-deconstructed`).

This folder is `.Rbuildignore`d: it ships nowhere, it only regenerates the GIF.

## Files

- `g6-deconstructed.qmd` — the Quarto RevealJS deck (one animated slide).
- `js/infra.html` — shared `TM` gating helpers (verbatim from tidy-animations).
- `js/g6-deconstructed.html` — the animation module: builds the cards as SVG
  planes and drives the explode/focus/collapse via `TM.gate`.
- `css/demos.css` — the `g6d-*` styles (perspective, cards, code listing).
- `record.R` — drives the deck headlessly via `{chromote}` DevTools screencast
  and assembles timestamped frames into the GIF with `ffmpeg`.

## Regenerate

```sh
quarto render g6-deconstructed.qmd
Rscript record.R          # writes .frames/ + concat.txt
# the ffmpeg step (see record.R header / project notes) writes the GIF:
ffmpeg -y -f concat -safe 0 -i .frames/concat.txt \
  -vf "crop=1260:600:10:50,fps=15,scale=860:-1:flags=lanczos,palettegen=max_colors=128:stats_mode=diff" .palette.png
ffmpeg -y -f concat -safe 0 -i .frames/concat.txt -i .palette.png \
  -lavfi "crop=1260:600:10:50,fps=15,scale=860:-1:flags=lanczos[x];[x][1:p]paletteuse=dither=bayer:bayer_scale=3" \
  ../g6R-deconstructed.gif
```

Needs `quarto`, `ffmpeg`, and R packages `chromote`, `later`, `base64enc`.
