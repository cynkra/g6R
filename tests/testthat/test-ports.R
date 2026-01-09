library(testthat)
library(g6R)

test_that("g6_port constructs and validates a port", {
  p <- g6_port("input-1", type = "input", placement = "left")
  expect_s3_class(p, "g6_port")
  expect_equal(p$key, "input-1")
  expect_equal(p$type, "input")
})

test_that("g6_ports constructs and validates a list of ports", {
  ports <- g6_ports(
    g6_port("input-1", type = "input"),
    g6_port("output-1", type = "output")
  )
  expect_s3_class(ports, "g6_ports")
  expect_length(ports, 2)
  expect_equal(ports[[2]]$key, "output-1")
})

test_that("g6_port validation fails for missing or invalid key/type/multiple", {
  expect_snapshot(error = TRUE, {
    g6_port(key = "", type = "input")
  })
  expect_snapshot(error = TRUE, {
    g6_port(key = "x", type = "foo")
  })
  expect_snapshot(error = TRUE, {
    g6_port(key = "x", type = "input", arity = -1)
  })
})

test_that("g6_ports fails if keys are not unique or elements are not g6_port", {
  expect_snapshot(error = TRUE, {
    g6_ports(
      g6_port("a", type = "input"),
      g6_port("a", type = "output")
    )
  })
  expect_snapshot(error = TRUE, {
    g6_ports(
      g6_port("a", type = "input"),
      list(key = "b", type = "output")
    )
  })
})

test_that("is_g6_port and coercion functions work", {
  p <- g6_port("input-1", type = "input")
  expect_true(is_g6_port(p))
  expect_identical(as_g6_port(p), p)
  expect_s3_class(as_g6_port(list(key = "x", type = "input")), "g6_port")

  ports <- as_g6_ports(list(
    list(key = "a", type = "input"),
    list(key = "b", type = "output")
  ))
  expect_s3_class(ports, "g6_ports")
  expect_true(all(lgl_ply(ports, is_g6_port)))
})

test_that("validate_edges_ports allows only input-output connections", {
  nodes <- list(
    list(
      style = list(
        ports = list(
          list(key = "input-1", type = "input"),
          list(key = "output-1", type = "output")
        )
      )
    ),
    list(
      style = list(
        ports = list(
          list(key = "input-2", type = "input"),
          list(key = "output-2", type = "output")
        )
      )
    )
  )

  # Valid: input -> output
  edges_valid <- list(
    list(style = list(sourcePort = "output-1", targetPort = "input-2"))
  )
  expect_invisible(validate_edges_ports(edges_valid, nodes))

  # Invalid: input -> input
  edges_invalid <- list(
    list(style = list(sourcePort = "input-1", targetPort = "input-2"))
  )
  expect_error(
    validate_edges_ports(edges_invalid, nodes),
    "cannot connect two 'input' ports"
  )

  # Invalid: output -> output
  edges_invalid2 <- list(
    list(style = list(sourcePort = "output-1", targetPort = "output-2"))
  )
  expect_error(
    validate_edges_ports(edges_invalid2, nodes),
    "cannot connect two 'output' ports"
  )

  # Invalid: unknown port key
  edges_unknown <- list(
    list(style = list(sourcePort = "foo", targetPort = "input-2"))
  )
  expect_error(validate_edges_ports(edges_unknown, nodes), "unknown port key")
})
