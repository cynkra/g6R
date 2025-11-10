# Configure Fish Eye Plugin

Creates a configuration object for the fisheye plugin in G6. This plugin
creates a fisheye lens effect that magnifies elements within a specific
area.

## Usage

``` r
fish_eye(
  key = "fish-eye",
  trigger = c("pointermove", "click", "drag"),
  r = 120,
  maxR = NULL,
  minR = 0,
  d = 1.5,
  maxD = 5,
  minD = 0,
  scaleRBy = NULL,
  scaleDBy = NULL,
  showDPercent = TRUE,
  style = NULL,
  nodeStyle = list(label = TRUE),
  preventDefault = TRUE,
  ...
)
```

## Arguments

- key:

  Unique identifier for the plugin (string, default: NULL).

- trigger:

  Method to move the fisheye: "pointermove", "click", or "drag" (string,
  default: "pointermove").

- r:

  Radius of the fisheye (number, default: 120).

- maxR:

  Maximum adjustable radius of the fisheye (number, default: NULL - half
  of the smaller canvas dimension).

- minR:

  Minimum adjustable radius of the fisheye (number, default: 0).

- d:

  Distortion factor (number, default: 1.5).

- maxD:

  Maximum adjustable distortion factor (number, default: 5).

- minD:

  Minimum adjustable distortion factor (number, default: 0).

- scaleRBy:

  Method to adjust the fisheye radius: "wheel" or "drag" (string,
  default: NULL).

- scaleDBy:

  Method to adjust the fisheye distortion factor: "wheel" or "drag"
  (string, default: NULL).

- showDPercent:

  Whether to show the distortion factor value in the fisheye (boolean,
  default: TRUE).

- style:

  Style of the fisheye (list, default: NULL).

- nodeStyle:

  Style of nodes in the fisheye (list or JS function, default:
  list(label = TRUE)).

- preventDefault:

  Whether to prevent default events (boolean, default: TRUE).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/fisheye>.

## Value

A list with the configuration settings for the fisheye plugin.

## Examples

``` r
# Basic configuration
config <- fish_eye()

# Custom configuration
config <- fish_eye(
  key = "my-fisheye",
  trigger = "drag",
  r = 200,
  d = 2.5,
  scaleRBy = "wheel",
  scaleDBy = "drag",
  style = list(
    stroke = "#1890ff",
    fill = "rgba(24, 144, 255, 0.1)",
    lineWidth = 2
  ),
  nodeStyle = JS("(datum) => {
    return {
      label: true,
      labelCfg: {
        style: {
          fill: '#003a8c',
          fontSize: 14
        }
      }
    };
  }")
)
```
