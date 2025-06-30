test_that("g6_behaviors creates proper behavior configuration", {
  expect_snapshot(error = TRUE, {
    g6() |> g6_behaviors()
  })

  g <- g6() |>
    g6_behaviors(
      "drag-canvas",
      zoom_canvas(),
      click_select()
    )

  expect_type(g$x$behaviors, "list")
  expect_length(g$x$behaviors, 3)
  keys <- vapply(g$x$behaviors, function(x) x$key, character(1))
  expect_true("drag-canvas" %in% keys)
  expect_true("zoom-canvas" %in% keys)
  expect_true("click-select" %in% keys)
})

test_that("validate behavior works", {
  expect_snapshot(error = TRUE, {
    g6() |>
      g6_behaviors(
        "blabla"
      )

    g6() |> g6_behaviors(list(test = 1))
  })
})

test_that("individual behavior functions work correctly", {
  lapply(names(valid_behaviors), function(behavior) {
    expect_snapshot(
      {
        str(
          g6() |>
            g6_behaviors(behavior)
        )
      }
    )
  })
})
