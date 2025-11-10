# Shiny bindings for g6

Output and render functions for using g6 within Shiny applications and
interactive Rmd documents.

## Usage

``` r
g6Output(outputId, width = "100%", height = "400px")

g6_output(outputId, width = "100%", height = "400px")

renderG6(expr, env = parent.frame(), quoted = FALSE)

render_g6(expr, env = parent.frame(), quoted = FALSE)
```

## Arguments

- outputId:

  output variable to read from

- width, height:

  Must be a valid CSS unit (like `'100%'`, `'400px'`, `'auto'`) or a
  number, which will be coerced to a string and have `'px'` appended.

- expr:

  An expression that generates a g6

- env:

  The environment in which to evaluate `expr`.

- quoted:

  Is `expr` a quoted expression (with
  [`quote()`](https://rdrr.io/r/base/substitute.html))? This is useful
  if you want to save an expression in a variable.

## Value

`g6Output` and `g6_output` return a Shiny output function that can be
used in the UI part of a Shiny app. `renderG6` and `render_g6` return a
Shiny render function that can be used in the server part of a Shiny app
to render a `g6` element.
