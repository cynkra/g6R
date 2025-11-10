# Configure Watermark Plugin

Creates a configuration object for the watermark plugin in G6. This
plugin adds a watermark to the graph canvas.

## Usage

``` r
watermark(
  key = "watermark",
  width = 200,
  height = 100,
  opacity = 0.2,
  rotate = pi/12,
  imageURL = NULL,
  text = NULL,
  textFill = "#000",
  textFontSize = 16,
  textFontFamily = NULL,
  textFontWeight = NULL,
  textFontVariant = NULL,
  textAlign = c("center", "end", "left", "right", "start"),
  textBaseline = c("alphabetic", "bottom", "hanging", "ideographic", "middle", "top"),
  backgroundRepeat = "repeat",
  backgroundAttachment = NULL,
  backgroundBlendMode = NULL,
  backgroundClip = NULL,
  backgroundColor = NULL,
  backgroundImage = NULL,
  backgroundOrigin = NULL,
  backgroundPosition = NULL,
  backgroundPositionX = NULL,
  backgroundPositionY = NULL,
  backgroundSize = NULL,
  ...
)
```

## Arguments

- key:

  Unique identifier for the plugin (string, default: NULL).

- width:

  Width of a single watermark (number, default: 200).

- height:

  Height of a single watermark (number, default: 100).

- opacity:

  Opacity of the watermark (number, default: 0.2).

- rotate:

  Rotation angle of the watermark in radians (number, default: pi/12).

- imageURL:

  Image watermark URL, higher priority than text watermark (string,
  default: NULL).

- text:

  Watermark text content (string, default: NULL).

- textFill:

  Color of the text watermark (string, default: "#000").

- textFontSize:

  Font size of the text watermark (number, default: 16).

- textFontFamily:

  Font of the text watermark (string, default: NULL).

- textFontWeight:

  Font weight of the text watermark (string, default: NULL).

- textFontVariant:

  Font variant of the text watermark (string, default: NULL).

- textAlign:

  Text alignment of the watermark (string, default: "center").

- textBaseline:

  Baseline alignment of the text watermark (string, default: "middle").

- backgroundRepeat:

  Repeat mode of the watermark (string, default: "repeat").

- backgroundAttachment:

  Background attachment behavior of the watermark (string, default:
  NULL).

- backgroundBlendMode:

  Background blend mode of the watermark (string, default: NULL).

- backgroundClip:

  Background clip of the watermark (string, default: NULL).

- backgroundColor:

  Background color of the watermark (string, default: NULL).

- backgroundImage:

  Background image of the watermark (string, default: NULL).

- backgroundOrigin:

  Background origin of the watermark (string, default: NULL).

- backgroundPosition:

  Background position of the watermark (string, default: NULL).

- backgroundPositionX:

  Horizontal position of the watermark background (string, default:
  NULL).

- backgroundPositionY:

  Vertical position of the watermark background (string, default: NULL).

- backgroundSize:

  Background size of the watermark (string, default: NULL).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/plugin/watermark>.

## Value

A list with the configuration settings for the watermark plugin.

## Examples

``` r
# Basic text watermark
config <- watermark(
  text = "G6 Graph",
  opacity = 0.1
)

# Image watermark
config <- watermark(
  imageURL = "https://gw.alipayobjects.com/os/s/prod/antv/assets/image/logo-with-text-73b8a.svg",
  width = 150,
  height = 75,
  opacity = 0.15,
  rotate = 0
)

# Customized text watermark
config <- watermark(
  text = "CONFIDENTIAL",
  textFill = "#ff0000",
  textFontSize = 24,
  textFontWeight = "bold",
  opacity = 0.08,
  rotate = pi/6,
  backgroundRepeat = "repeat-x"
)

# Watermark with background styling
config <- watermark(
  text = "Draft Document",
  textFill = "#333",
  backgroundColor = "#f9f9f9",
  backgroundClip = "content-box",
  backgroundSize = "cover"
)
```
