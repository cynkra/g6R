# Create a G6 Graph from an igraph Object

Converts an `igraph` graph object into the format required by the
[`g6()`](https://cynkra.github.io/g6R/reference/g6.md) function and
creates an interactive G6 graph visualization. This is a convenience
wrapper around [`g6()`](https://cynkra.github.io/g6R/reference/g6.md)
that allows you to work directly with `igraph` objects.

## Usage

``` r
g6_igraph(
  graph,
  combos = NULL,
  width = "100%",
  height = NULL,
  elementId = NULL
)
```

## Arguments

- graph:

  An object of class
  [`igraph::igraph`](https://r.igraph.org/reference/aaa-igraph-package.html)
  containing the graph to visualize.

- combos:

  A data frame or list of combo groups in the graph. Each combo should
  have at least an "id" field. Nodes can be assigned to combos using
  their "combo" field. See 'Data Structure' section for more details.
  Default: NULL.

- width:

  Width of the graph container in pixels or as a valid CSS unit.
  Default: NULL (automatic sizing).

- height:

  Height of the graph container in pixels or as a valid CSS unit.
  Default: NULL (automatic sizing).

- elementId:

  A unique ID for the graph HTML element. Default: NULL (automatically
  generated).

## Value

An htmlwidget object that can be rendered in R Markdown, Shiny apps, or
the R console.

## Details

This function extracts the node and edge data from an `igraph` object,
converts them into the appropriate format for G6, and passes them to
[`g6()`](https://cynkra.github.io/g6R/reference/g6.md). Node styling is
derived from vertex attributes, and edge styling from edge attributes.

If the graph is directed, edges will automatically be rendered with
arrows.

## See also

[`g6()`](https://cynkra.github.io/g6R/reference/g6.md) for more
information about node, edge, and combo structure.

## Examples

``` r
if (require(igraph)) {
  g <- igraph::make_ring(5)
  g6_igraph(g)
}
#> Loading required package: igraph
#> 
#> Attaching package: ‘igraph’
#> The following objects are masked from ‘package:stats’:
#> 
#>     decompose, spectrum
#> The following object is masked from ‘package:base’:
#> 
#>     union

{"x":{"data":{"nodes":[{"id":"1","style":{"collapsed":false,"cursor":"default","fill":"#1783FF","fillOpacity":1,"increasedLineWidthForHitTesting":0,"lineCap":"butt","lineJoin":"miter","lineWidth":1,"opacity":1,"shadowType":"outer","size":32,"stroke":"#000","strokeOpacity":1,"visibility":"visible"}},{"id":"2","style":{"collapsed":false,"cursor":"default","fill":"#1783FF","fillOpacity":1,"increasedLineWidthForHitTesting":0,"lineCap":"butt","lineJoin":"miter","lineWidth":1,"opacity":1,"shadowType":"outer","size":32,"stroke":"#000","strokeOpacity":1,"visibility":"visible"}},{"id":"3","style":{"collapsed":false,"cursor":"default","fill":"#1783FF","fillOpacity":1,"increasedLineWidthForHitTesting":0,"lineCap":"butt","lineJoin":"miter","lineWidth":1,"opacity":1,"shadowType":"outer","size":32,"stroke":"#000","strokeOpacity":1,"visibility":"visible"}},{"id":"4","style":{"collapsed":false,"cursor":"default","fill":"#1783FF","fillOpacity":1,"increasedLineWidthForHitTesting":0,"lineCap":"butt","lineJoin":"miter","lineWidth":1,"opacity":1,"shadowType":"outer","size":32,"stroke":"#000","strokeOpacity":1,"visibility":"visible"}},{"id":"5","style":{"collapsed":false,"cursor":"default","fill":"#1783FF","fillOpacity":1,"increasedLineWidthForHitTesting":0,"lineCap":"butt","lineJoin":"miter","lineWidth":1,"opacity":1,"shadowType":"outer","size":32,"stroke":"#000","strokeOpacity":1,"visibility":"visible"}}],"edges":[{"source":"1","target":"2","id":"1-2","style":{"cursor":"default","fillRule":"nonzero","isBillboard":true,"lineDash":0,"lineDashOffset":0,"lineWidth":1,"opacity":1,"stroke":"#000","strokeOpacity":1,"visibility":"visible","zIndex":-10000}},{"source":"2","target":"3","id":"2-3","style":{"cursor":"default","fillRule":"nonzero","isBillboard":true,"lineDash":0,"lineDashOffset":0,"lineWidth":1,"opacity":1,"stroke":"#000","strokeOpacity":1,"visibility":"visible","zIndex":-10000}},{"source":"3","target":"4","id":"3-4","style":{"cursor":"default","fillRule":"nonzero","isBillboard":true,"lineDash":0,"lineDashOffset":0,"lineWidth":1,"opacity":1,"stroke":"#000","strokeOpacity":1,"visibility":"visible","zIndex":-10000}},{"source":"4","target":"5","id":"4-5","style":{"cursor":"default","fillRule":"nonzero","isBillboard":true,"lineDash":0,"lineDashOffset":0,"lineWidth":1,"opacity":1,"stroke":"#000","strokeOpacity":1,"visibility":"visible","zIndex":-10000}},{"source":"1","target":"5","id":"1-5","style":{"cursor":"default","fillRule":"nonzero","isBillboard":true,"lineDash":0,"lineDashOffset":0,"lineWidth":1,"opacity":1,"stroke":"#000","strokeOpacity":1,"visibility":"visible","zIndex":-10000}}]},"jsonUrl":null,"iconsUrl":"//at.alicdn.com/t/font_2678727_za4qjydwkkh.js","mode":"prod","preservePosition":false},"evals":[],"jsHooks":[]}
```
