test_that("g6_options creates proper configuration", {
  opts <- g6() |>
    g6_options(
      autoFit = "view",
      fitView = TRUE,
      animate = TRUE
    )

  expect_true(all(c("autoFit", "fitView", "animate") %in% names(opts$x)))
})

test_that("node_options creates proper node configuration", {
  node_opts <- node_options(
    type = "circle",
    style = list(fill = "blue", stroke = "red")
  )

  expect_type(node_opts, "list")
  expect_equal(node_opts$type, "circle")
  expect_equal(node_opts$style$fill, "blue")
  expect_equal(node_opts$style$stroke, "red")
})

test_that("edge_options creates proper edge configuration", {
  edge_opts <- edge_options(
    type = "line",
    style = list(stroke = "green", lineWidth = 2)
  )

  expect_type(edge_opts, "list")
  expect_equal(edge_opts$type, "line")
  expect_equal(edge_opts$style$stroke, "green")
  expect_equal(edge_opts$style$lineWidth, 2)
})

test_that("combo_options creates proper combo configuration", {
  combo_opts <- combo_options(
    type = "rect",
    style = list(fill = "yellow", stroke = "orange")
  )

  expect_type(combo_opts, "list")
  expect_equal(combo_opts$type, "rect")
  expect_equal(combo_opts$style$fill, "yellow")
  expect_equal(combo_opts$style$stroke, "orange")
})

test_that("node_style_options creates proper style configuration", {
  style_opts <- node_style_options(
    fill = "purple",
    stroke = "black",
    lineWidth = 3,
    radius = 10
  )

  expect_type(style_opts, "list")
  expect_equal(style_opts$fill, "purple")
  expect_equal(style_opts$stroke, "black")
  expect_equal(style_opts$lineWidth, 3)
  expect_equal(style_opts$radius, 10)
})

test_that("edge_style_options creates proper style configuration", {
  style_opts <- edge_style_options(
    stroke = "cyan",
    lineWidth = 4,
    lineDash = c(5, 5)
  )

  expect_type(style_opts, "list")
  expect_equal(style_opts$stroke, "cyan")
  expect_equal(style_opts$lineWidth, 4)
  expect_equal(style_opts$lineDash, c(5, 5))
})

test_that("canvas_config creates proper canvas configuration", {
  canvas_opts <- canvas_config(
    background = "white",
    cursor = "pointer"
  )

  expect_type(canvas_opts, "list")
  expect_equal(canvas_opts$background, "white")
  expect_equal(canvas_opts$cursor, "pointer")
})

test_that("animation_config creates proper animation configuration", {
  anim_opts <- animation_config(
    duration = 1000,
    easing = "linear"
  )

  expect_type(anim_opts, "list")
  expect_equal(anim_opts$duration, 1000)
  expect_equal(anim_opts$easing, "linear")
})

test_that("auto_fit_config creates proper autoFit configuration", {
  autofit_opts <- auto_fit_config(
    type = "view",
    duration = 300,
    easing = "ease-out"
  )

  expect_type(autofit_opts, "list")
  expect_equal(autofit_opts$type, "view")
  expect_type(autofit_opts$animation, "list")
  expect_length(autofit_opts$animation, 2)
  expect_equal(autofit_opts$animation$duration, 300)
  expect_equal(autofit_opts$animation$easing, "ease-out")
})
