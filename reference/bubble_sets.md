# Configure Bubble Sets Plugin for G6

Creates a configuration object for the bubble-sets plugin in G6. This
plugin creates bubble-like contours around groups of specified elements.

## Usage

``` r
bubble_sets(
  members,
  key = "bubble-sets",
  avoidMembers = NULL,
  label = TRUE,
  labelPlacement = c("bottom", "left", "right", "top", "center"),
  labelBackground = FALSE,
  labelPadding = 0,
  labelCloseToPath = TRUE,
  labelAutoRotate = TRUE,
  labelOffsetX = 0,
  labelOffsetY = 0,
  labelMaxWidth = NULL,
  maxRoutingIterations = 100,
  maxMarchingIterations = 20,
  pixelGroup = 4,
  edgeR0 = NULL,
  edgeR1 = NULL,
  nodeR0 = NULL,
  nodeR1 = NULL,
  morphBuffer = NULL,
  threshold = NULL,
  memberInfluenceFactor = NULL,
  edgeInfluenceFactor = NULL,
  nonMemberInfluenceFactor = NULL,
  virtualEdges = NULL,
  ...
)
```

## Arguments

- members:

  Member elements, including nodes and edges (character/numeric vector,
  required).

- key:

  Unique identifier for updates (string, default: NULL).

- avoidMembers:

  Elements to avoid when drawing contours (character/numeric vector,
  default: NULL).

- label:

  Whether to display labels (boolean, default: TRUE).

- labelPlacement:

  Label position (string, default: "bottom").

- labelBackground:

  Whether to display background (boolean, default: FALSE).

- labelPadding:

  Label padding (numeric or numeric vector, default: 0).

- labelCloseToPath:

  Whether the label is close to the contour (boolean, default: TRUE).

- labelAutoRotate:

  Whether the label rotates with the contour (boolean, default: TRUE).

- labelOffsetX:

  Label x-axis offset (numeric, default: 0).

- labelOffsetY:

  Label y-axis offset (numeric, default: 0).

- labelMaxWidth:

  Maximum width of the text (numeric, default: NULL).

- maxRoutingIterations:

  Maximum iterations for path calculation (numeric, default: 100).

- maxMarchingIterations:

  Maximum iterations for contour calculation (numeric, default: 20).

- pixelGroup:

  Number of pixels per potential area group (numeric, default: 4).

- edgeR0:

  Edge radius parameter R0 (numeric, default: NULL).

- edgeR1:

  Edge radius parameter R1 (numeric, default: NULL).

- nodeR0:

  Node radius parameter R0 (numeric, default: NULL).

- nodeR1:

  Node radius parameter R1 (numeric, default: NULL).

- morphBuffer:

  Morph buffer size (numeric, default: NULL).

- threshold:

  Threshold (numeric, default: NULL).

- memberInfluenceFactor:

  Member influence factor (numeric, default: NULL).

- edgeInfluenceFactor:

  Edge influence factor (numeric, default: NULL).

- nonMemberInfluenceFactor:

  Non-member influence factor (numeric, default: NULL).

- virtualEdges:

  Whether to use virtual edges (boolean, default: NULL).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/plugin/bubble-sets>.

## Value

A list with the configuration settings for the bubble-sets plugin.

## Examples

``` r
# Basic bubble set around specific nodes
bubble <- bubble_sets(
  members = c("node1", "node2", "node3"),
  label = TRUE
)

# More customized bubble set
bubble <- bubble_sets(
  key = "team-a",
  members = c("node1", "node2", "node3", "edge1", "edge2"),
  avoidMembers = c("node4", "node5"),
  labelPlacement = "top",
  labelBackground = TRUE,
  labelPadding = c(4, 2),
  maxRoutingIterations = 150
)

# Bubble set with advanced parameters
bubble <- bubble_sets(
  members = c("node1", "node2", "node3"),
  pixelGroup = 6,
  edgeR0 = 10,
  nodeR0 = 5,
  memberInfluenceFactor = 0.8,
  edgeInfluenceFactor = 0.5,
  nonMemberInfluenceFactor = 0.3,
  virtualEdges = TRUE
)
```
