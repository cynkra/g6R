# Configure Background Plugin for G6

Creates a configuration object for the background plugin in G6. This
plugin adds a customizable background to the graph canvas.

## Usage

``` r
background(
  key = NULL,
  width = "100%",
  height = "100%",
  backgroundColor = NULL,
  backgroundImage = NULL,
  backgroundSize = "cover",
  backgroundPosition = NULL,
  backgroundRepeat = NULL,
  opacity = NULL,
  transition = "background 0.5s",
  zIndex = "-1",
  ...
)
```

## Arguments

- key:

  Unique identifier for updates (string, default: NULL).

- width:

  Background width (string, default: "100%").

- height:

  Background height (string, default: "100%").

- backgroundColor:

  Background color (string, default: NULL).

- backgroundImage:

  Background image URL (string, default: NULL).

- backgroundSize:

  Background size (string, default: "cover").

- backgroundPosition:

  Background position (string, default: NULL).

- backgroundRepeat:

  Background repeat (string, default: NULL).

- opacity:

  Background opacity (string, default: NULL).

- transition:

  Transition animation (string, default: "background 0.5s").

- zIndex:

  Stacking order (string, default: "-1").

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/plugin/background>.

## Value

A list with the configuration settings for the background plugin.

## Examples

``` r
# Basic background color
bg <- background(backgroundColor = "#f0f0f0")

# Background with image
bg <- background(
  backgroundImage = "https://example.com/background.jpg",
  backgroundSize = "contain",
  backgroundRepeat = "no-repeat",
  backgroundPosition = "center"
)

# Semi-transparent background with transition
bg <- background(
  backgroundColor = "#000000",
  opacity = "0.3",
  transition = "all 1s ease-in-out"
)
```
