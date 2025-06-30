test_that("validate layout works", {
  expect_snapshot(error = TRUE, {
    g6() |>
      g6_layout(NULL)
    g6() |>
      g6_layout(
        "blabla"
      )

    g6() |> g6_layout(list(test = 1))
  })
})

test_that("individual layout functions work correctly", {
  lapply(names(valid_layouts), function(layout) {
    expect_snapshot(
      {
        str(
          g6() |>
            g6_layout(layout)
        )
      }
    )
  })
})
