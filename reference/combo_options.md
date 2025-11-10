# Create Combo Options Configuration for G6 Graphs

Configures the general options for combos in a G6 graph. These settings
control the type, style, state, palette, and animation of combos.

## Usage

``` r
combo_options(
  type = "circle",
  style = NULL,
  state = NULL,
  palette = NULL,
  animation = NULL
)
```

## Arguments

- type:

  Combo type. Can be a built-in combo type name or a custom combo name.
  Built-in types include "circle", "rect", "polygon", etc. Default:
  "circle".

- style:

  Combo style configuration. Controls the appearance of combos including
  color, size, border, etc. Default: NULL.

- state:

  Defines the style of the combo in different states, such as hover,
  selected, disabled, etc. Should be a list mapping state names to style
  configurations. Default: NULL.

- palette:

  Defines the color palette of the combo, used to map colors based on
  different data. Default: NULL.

- animation:

  Defines the animation effect of the combo. Can be created with
  [`animation_config()`](https://cynkra.github.io/g6R/reference/animation_config.md).
  Default: NULL.

## Value

A list containing combo options configuration that can be passed to
[`g6_options()`](https://cynkra.github.io/g6R/reference/g6_options.md).

## Details

Combo options allow defining how combos (node groupings) appear and
behave in a G6 graph. This includes selecting combo types, setting
styles, configuring state-based appearances, defining color palettes,
and specifying animation effects.

## Examples

``` r
# Basic combo options with default circle type
options <- combo_options()

# Rectangle combo with custom style
options <- combo_options(
  type = "rect",
  style = list(
    fill = "#F6F6F6",
    stroke = "#CCCCCC",
    lineWidth = 1
  )
)
```
