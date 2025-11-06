test_that("g6_igraph works with igraph objects", {
  skip_if_not_installed("igraph")

  # Create a simple igraph object
  library(igraph)
  g_igraph <- make_graph(c("A", "B", "B", "C", "C", "A"))

  # Convert to g6
  g6_graph <- g6_igraph(g_igraph)

  expect_s3_class(g6_graph, "htmlwidget")
  expect_s3_class(g6_graph, "g6")
  expect_true("nodes" %in% names(g6_graph$x$data))
  expect_true("edges" %in% names(g6_graph$x$data))

  # Check that nodes have proper structure
  expect_length(g6_graph$x$data$nodes, 3) # A, B, C
  expect_length(g6_graph$x$data$edges, 3) # 3 edges

  # Check node IDs are characters
  node_ids <- sapply(g6_graph$x$data$nodes, function(x) x$id)
  expect_type(node_ids, "character")
})

test_that("g6_igraph handles vertex and edge attributes", {
  skip_if_not_installed("igraph")

  library(igraph)

  # Create igraph with attributes
  g_igraph <- make_graph(c("A", "B", "B", "C"))
  V(g_igraph)$name <- c("Node A", "Node B", "Node C")
  V(g_igraph)$color <- c("red", "blue", "green")
  E(g_igraph)$weight <- c(1.5, 2.0)
  E(g_igraph)$type <- c("solid", "dashed")

  g6_graph <- g6_igraph(g_igraph)

  # Check that attributes are preserved
  expect_true(any(sapply(g6_graph$x$data$nodes, function(x) {
    !is.null(x$style$name)
  })))
  expect_true(any(sapply(g6_graph$x$data$nodes, function(x) {
    !is.null(x$style$color)
  })))
  expect_true(any(sapply(g6_graph$x$data$edges, function(x) {
    !is.null(x$style$weight)
  })))
})

test_that("g6_igraph handles graphs with isolated vertices", {
  skip_if_not_installed("igraph")

  library(igraph)

  # Create graph with isolated vertices
  g_igraph <- make_graph(c("A", "B")) # Only one edge
  g_igraph <- add_vertices(g_igraph, 1, name = "C") # Add isolated vertex

  g6_graph <- g6_igraph(g_igraph)

  expect_length(g6_graph$x$data$nodes, 3) # A, B, C
  expect_length(g6_graph$x$data$edges, 1) # Only A-B edge
})

test_that("g6_igraph errors for non-igraph objects", {
  skip_if_not_installed("igraph")
  expect_snapshot(
    {
      g6_igraph("not an igraph")
      g6_igraph(list())
      g6_igraph(123)
    },
    error = TRUE
  )
})
