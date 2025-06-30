test_that("g6_plugins creates proper plugin configuration", {
  expect_snapshot(error = TRUE, {
    g6() |> g6_plugins()
  })

  g <- g6() |>
    g6_plugins(
      "minimap",
      grid_line()
    )

  expect_type(g$x$plugins, "list")
  expect_length(g$x$plugins, 2)
  keys <- vapply(g$x$plugins, function(x) x$key, character(1))
  expect_true("minimap" %in% keys)
  expect_true("grid-line" %in% keys)
})

test_that("validate plugins works", {
  expect_snapshot(error = TRUE, {
    g6() |>
      g6_plugins(
        "blabla"
      )

    g6() |> g6_plugins(list(test = 1))
  })
})

test_that("individual plugin functions work correctly", {
  lapply(names(valid_plugins), function(plugin) {
    print(plugin)
    expect_snapshot(
      {
        str(
          g6() |>
            g6_plugins(plugin)
        )
      },
      # Some plugins need default values
      error = if (plugin %in% c("bubble-sets", "hull", "timebar")) {
        TRUE
      } else {
        FALSE
      }
    )
  })
})
