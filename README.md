
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shinyG6

<!-- badges: start -->

[![R-CMD-check](https://github.com/cynkra/shinyG6/actions/workflows/R-CMD-check.yaml/badge.svghttps://github.com/cynkra/shinyG6/actions/workflows/R-CMD-check.yaml/badge.svghttps://github.com/cynkra/shinyG6/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/cynkra/shinyG6/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

`{shinyG6}` provides R bindings to the G6 graph
[library](https://g6.antv.antgroup.com/en).

## Installation

You can install the development version of shinyG6 from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("cynkra/shinyG6")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(shiny)
shinyAppDir(system.file("demo", package = "shinyG6"))
```
