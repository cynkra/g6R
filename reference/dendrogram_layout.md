# Generate G6 Dendrogram layout configuration

This function creates a configuration list for G6 Dendrogram layout with
all available options as parameters.

## Usage

``` r
dendrogram_layout(
  direction = c("LR", "RL", "TB", "BT", "H", "V"),
  nodeSep = 20,
  rankSep = 200,
  radial = FALSE,
  ...
)
```

## Arguments

- direction:

  Character. Layout direction. Options: "LR", "RL", "TB", "BT", "H",
  "V". Defaults to "LR".

- nodeSep:

  Numeric. Node spacing, distance between nodes on the same level.
  Defaults to 20.

- rankSep:

  Numeric. Rank spacing, distance between different levels. Defaults to
  200.

- radial:

  Logical. Whether to enable radial layout. Defaults to FALSE.

- ...:

  Additional parameters to pass to the layout. See
  <https://g6.antv.antgroup.com/en/manual/layout/dendrogram-layout>.

## Value

A list containing the configuration for G6 dendrogram layout.
