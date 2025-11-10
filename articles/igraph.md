# igraph support

``` r
library(g6R)
library(igraph)
```

`g6R` supports igraph objects via the function
[`g6_igraph()`](https://cynkra.github.io/g6R/reference/g6_igraph.md).
Instead of a nodes and edges data frame, it accepts an igraph object as
input.

``` r
kite <- make_graph("Krackhardt kite")
g6_igraph(kite) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(drag_element_force())
```

The philosophy of plotting networks with igraph is that mapping styles
is done via node attributes. So a node attribute “color” defines the
color of each node explicitly. The function
[`g6_igraph()`](https://cynkra.github.io/g6R/reference/g6_igraph.md)
implements this philosophy so that adding node (or edge) attributes that
correspond to style arguments in g6 are recognized.

``` r
set.seed(123)
V(kite)$fill <- sample(
  c("red", "green", "blue"),
  vcount(kite),
  replace = TRUE
)
E(kite)$stroke <- sample(
  c("red", "green", "blue"),
  ecount(kite),
  replace = TRUE
)
E(kite)$lineWidth <- 3

g6_igraph(kite) |>
  g6_layout(d3_force_layout()) |>
  g6_behaviors(drag_element_force())
```
