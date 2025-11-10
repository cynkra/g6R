# Create a proxy object to modify an existing g6 graph instance

This function creates a proxy object that can be used to update an
existing g6 graph instance after it has been rendered in the UI. The
proxy allows for server-side modifications of the graph without
completely re-rendering it.

## Usage

``` r
g6_proxy(id, session = shiny::getDefaultReactiveDomain())
```

## Arguments

- id:

  Character string matching the ID of the g6 graph instance to be
  modified.

- session:

  The Shiny session object within which the graph exists. By default,
  this uses the current reactive domain.

## Value

A proxy object of class "g6_proxy" that can be used with g6 proxy
methods such as
[`g6_add_nodes()`](https://cynkra.github.io/g6R/reference/g6-add.md),
[`g6_remove_nodes()`](https://cynkra.github.io/g6R/reference/g6-remove.md),
etc.
