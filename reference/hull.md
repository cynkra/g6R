# Configure Hull Plugin

Creates a configuration object for the hull plugin in G6. This plugin
creates a hull (convex or concave) that surrounds specified graph
elements.

## Usage

``` r
hull(
  members,
  key = "hull",
  concavity = Inf,
  corner = c("rounded", "smooth", "sharp"),
  padding = 10,
  label = TRUE,
  labelText = NULL,
  labelPlacement = c("bottom", "left", "right", "top", "center"),
  labelBackground = FALSE,
  labelPadding = 0,
  labelCloseToPath = TRUE,
  labelAutoRotate = TRUE,
  labelOffsetX = 0,
  labelOffsetY = 0,
  labelMaxWidth = NULL,
  ...
)
```

## Arguments

- members:

  Elements within the hull, including nodes and edges (character/numeric
  vector, required).

- key:

  Unique identifier for the plugin (string, default: NULL).

- concavity:

  Concavity parameter, larger values create less concave hulls (number,
  default: Infinity).

- corner:

  Corner type: "rounded", "smooth", or "sharp" (string, default:
  "rounded").

- padding:

  Padding around the elements (number, default: 10).

- label:

  Whether to display the label (boolean, default: TRUE).

- labelText:

  Label text content. Default to NULL.

- labelPlacement:

  Label position: "left", "right", "top", "bottom", or "center" (string,
  default: "bottom").

- labelBackground:

  Whether to display the background (boolean, default: FALSE).

- labelPadding:

  Label padding (number or numeric vector, default: 0).

- labelCloseToPath:

  Whether the label is close to the hull (boolean, default: TRUE).

- labelAutoRotate:

  Whether the label rotates with the hull, effective only when
  closeToPath is true (boolean, default: TRUE).

- labelOffsetX:

  X-axis offset (number, default: 0).

- labelOffsetY:

  Y-axis offset (number, default: 0).

- labelMaxWidth:

  Maximum width of the text, exceeding will be ellipsized (number or
  NULL, default: NULL).

- ...:

  Other options. See
  <https://g6.antv.antgroup.com/en/manual/plugin/hull>.

## Value

A list with the configuration settings for the hull plugin.

## Examples

``` r
# Basic configuration
config <- hull(members = c("node1", "node2", "node3"))

# Custom configuration for a cluster
config <- hull(
  key = "cluster-hull",
  members = c("node1", "node2", "node3", "node4"),
  concavity = 0.8,
  corner = "smooth",
  padding = 15,
  label = TRUE,
  labelPlacement = "top",
  labelBackground = TRUE,
  labelPadding = c(4, 8),
  labelMaxWidth = 100
)
```
