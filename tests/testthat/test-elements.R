library(testthat)
library(g6R)

test_that("g6_node constructs and validates a node", {
  node <- g6_node(
    id = "n1",
    type = "rect",
    data = list(label = "Node 1"),
    style = list(color = "red"),
    states = list("selected"),
    combo = NULL,
    children = c("n2", "n3")
  )
  expect_s3_class(node, "g6_node")
  expect_s3_class(node, "g6_element")
  expect_equal(node$id, "n1")
  expect_equal(node$type, "rect")
  expect_equal(node$data$label, "Node 1")
})

test_that("g6_edge constructs and validates an edge", {
  edge <- g6_edge(
    source = "n1",
    target = "n2",
    type = "line",
    style = list(width = 2)
  )
  expect_s3_class(edge, "g6_edge")
  expect_s3_class(edge, "g6_element")
  expect_equal(edge$source, "n1")
  expect_equal(edge$target, "n2")
  expect_equal(edge$type, "line")
})

test_that("g6_combo constructs and validates a combo", {
  combo <- g6_combo(
    id = "combo1",
    type = "rect",
    data = list(label = "Combo 1"),
    style = list(border = "dashed"),
    states = list("active"),
    combo = NULL
  )
  expect_s3_class(combo, "g6_combo")
  expect_s3_class(combo, "g6_element")
  expect_equal(combo$id, "combo1")
  expect_equal(combo$type, "rect")
  expect_equal(combo$data$label, "Combo 1")
})

test_that("g6_node validation fails for missing id", {
  expect_snapshot(error = TRUE, {
    g6_node(type = "rect")
  })
})

test_that("g6_edge validation fails for missing source/target", {
  expect_snapshot(error = TRUE, {
    g6_edge(source = NULL, target = "n2")
  })
  expect_snapshot(error = TRUE, {
    g6_edge(source = "n1", target = NULL)
  })
})

test_that("g6_combo validation fails for missing id", {
  expect_snapshot(error = TRUE, {
    g6_combo(type = "rect")
  })
})

test_that("g6_nodes constructs and validates a list of nodes", {
  nodes <- g6_nodes(
    g6_node(id = "n1"),
    g6_node(id = "n2")
  )
  expect_s3_class(nodes, "g6_nodes")
  expect_length(nodes, 2)
  expect_s3_class(nodes[[1]], "g6_node")
  expect_equal(nodes[[1]]$id, "n1")
})

test_that("g6_edges constructs and validates a list of edges", {
  edges <- g6_edges(
    g6_edge(source = "n1", target = "n2"),
    g6_edge(source = "n2", target = "n3")
  )
  expect_s3_class(edges, "g6_edges")
  expect_length(edges, 2)
  expect_s3_class(edges[[2]], "g6_edge")
  expect_equal(edges[[2]]$source, "n2")
  expect_equal(edges[[2]]$target, "n3")
})

test_that("g6_combos constructs and validates a list of combos", {
  combos <- g6_combos(
    g6_combo(id = "c1"),
    g6_combo(id = "c2")
  )
  expect_s3_class(combos, "g6_combos")
  expect_length(combos, 2)
  expect_s3_class(combos[[1]], "g6_combo")
  expect_equal(combos[[2]]$id, "c2")
})

test_that("g6_nodes fails if any element is not a g6_node", {
  expect_snapshot(error = TRUE, {
    g6_nodes(g6_node(id = "n1"), g6_edge(source = "n1", target = "n2"))
  })
})

test_that("g6_edges fails if any element is not a g6_edge", {
  expect_snapshot(error = TRUE, {
    g6_edges(g6_edge(source = "n1", target = "n2"), g6_node(id = "n2"))
  })
})

test_that("g6_combos fails if any element is not a g6_combo", {
  expect_snapshot(error = TRUE, {
    g6_combos(g6_combo(id = "c1"), g6_node(id = "n1"))
  })
})

test_that("g6_nodes fails if no nodes provided", {
  expect_snapshot(error = TRUE, {
    g6_nodes()
  })
})

test_that("g6_edges fails if no edges provided", {
  expect_snapshot(error = TRUE, {
    g6_edges()
  })
})

test_that("g6_combos fails if no combos provided", {
  expect_snapshot(error = TRUE, {
    g6_combos()
  })
})
