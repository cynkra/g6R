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
