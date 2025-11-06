test_that("g6 function creates proper htmlwidget", {
  # Test with minimal input
  g <- g6()
  expect_s3_class(g, "htmlwidget")
  expect_s3_class(g, "g6")
  expect_length(g$x$data, 0)

  expect_snapshot(error = TRUE, {
    # Test with invalid input
    g6(iconsUrl = NULL)
    g6(
      nodes = data.frame(),
      jsonUrl = "https://assets.antv.antgroup.com/g6/cluster.json"
    )
  })

  # Test with data frames
  nodes_df <- data.frame(
    id = c("node1", "node2", "node3"),
    stringsAsFactors = FALSE
  )

  edges_df <- data.frame(
    source = c("node1", "node2"),
    target = c("node2", "node3"),
    stringsAsFactors = FALSE
  )

  g <- g6(nodes = nodes_df, edges = edges_df)
  expect_s3_class(g, "htmlwidget")
  expect_length(g$x$data$nodes, 3)
  expect_length(g$x$data$edges, 2)

  # Check node structure
  expect_equal(g$x$data$nodes[[1]]$id, "node1")

  # Check edge structure
  expect_equal(g$x$data$edges[[1]]$source, "node1")
  expect_equal(g$x$data$edges[[1]]$target, "node2")
})

test_that("g6 function handles list input", {
  # Test with lists
  nodes_list <- list(
    list(id = "a"),
    list(id = "b")
  )

  edges_list <- list(
    list(source = "a", target = "b", type = "line")
  )

  g <- g6(nodes = nodes_list, edges = edges_list)
  expect_s3_class(g, "htmlwidget")
  expect_length(g$x$data$nodes, 2)
  expect_length(g$x$data$edges, 1)
  expect_equal(g$x$data$edges[[1]]$type, "line")
})

test_that("g6 function handles combos", {
  nodes_df <- data.frame(
    id = c("node1", "node2"),
    combo = c("combo1", "combo1"),
    stringsAsFactors = FALSE
  )

  combos_df <- data.frame(
    id = "combo1",
    stringsAsFactors = FALSE
  )

  g <- g6(nodes = nodes_df, combos = combos_df)
  expect_s3_class(g, "htmlwidget")
  expect_length(g$x$data$nodes, 2)
  expect_length(g$x$data$combos, 1)
  expect_equal(g$x$data$combos[[1]]$id, "combo1")
  expect_equal(g$x$data$nodes[[1]]$combo, "combo1")
})

test_that("g6 function handles dimensions", {
  g1 <- g6(width = "500px", height = "300px")
  expect_equal(g1$width, "500px")
  expect_equal(g1$height, "300px")

  g2 <- g6(width = 500, height = 300)
  expect_equal(g2$width, 500)
  expect_equal(g2$height, 300)
})

test_that("g6 function handles elementId", {
  g <- g6(elementId = "my-graph")
  expect_equal(g$elementId, "my-graph")
})
