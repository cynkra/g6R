test_that("package data objects are accessible and properly structured", {
  # Test dag data
  expect_true(exists("dag"))
  data("dag", package = "g6R")
  expect_type(dag, "list")
  expect_true("nodes" %in% names(dag))
  expect_true("edges" %in% names(dag))

  # Test lesmis data
  expect_true(exists("lesmis"))
  data("lesmis", package = "g6R")
  expect_type(lesmis, "list")
  expect_true("nodes" %in% names(lesmis))
  expect_true("edges" %in% names(lesmis))

  # Test tree data
  expect_true(exists("tree"))
  data("tree", package = "g6R")
  expect_type(tree, "list")
  expect_true("nodes" %in% names(tree))

  # Test radial data
  expect_true(exists("radial"))
  data("radial", package = "g6R")
  expect_type(radial, "list")
  expect_true("nodes" %in% names(radial))

  # Test poke data
  expect_true(exists("poke"))
  data("poke", package = "g6R")
  expect_type(poke, "list")
})

test_that("data objects have required node structure", {
  data("dag", package = "g6R")

  # Check nodes structure
  if (length(dag$nodes) > 0) {
    first_node <- dag$nodes[1, ]
    expect_true("id" %in% names(first_node))
    expect_type(first_node$id, "character")
  }

  # Check edges structure if present
  if ("edges" %in% names(dag) && length(dag$edges) > 0) {
    first_edge <- dag$edges[1, ]
    expect_true("source" %in% names(first_edge))
    expect_true("target" %in% names(first_edge))
  }
})

test_that("data objects work with g6 function", {
  data("dag", package = "g6R")

  # Should be able to create g6 visualizations with the data
  expect_no_error({
    g <- g6(nodes = dag$nodes, edges = dag$edges)
  })

  g <- g6(nodes = dag$nodes, edges = dag$edges)
  expect_s3_class(g, "htmlwidget")
  expect_s3_class(g, "g6")
})
