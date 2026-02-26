# Set max collapse depth

Controls which nodes display a collapse button based on their depth in
the graph. Only nodes at depth `<= maxCollapseDepth` will show collapse
buttons. Set to `Inf` (the default) to allow all nodes with children to
be collapsible. Set to `0` to only allow root nodes to collapse. Set to
`-1` to disable collapsing entirely.

## Usage

``` r
set_g6_max_collapse_depth(val)
```

## Arguments

- val:

  A single number \>= -1. Use `Inf` for no limit, `-1` to disable all
  collapsing.

## Value

Invisibly returns `val`.
