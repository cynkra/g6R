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

test_that("plugin validation works correctly", {
  # Test each plugin function can be called and returns correct type
  bg1 <- background()
  expect_type(bg1, "list")

  bg2 <- background(backgroundColor = "#f0f0f0", width = "50%")
  expect_type(bg2, "list")

  # Test bubble_sets validation
  expect_error(bubble_sets())
  bubble1 <- bubble_sets(members = c("node1", "node2"))
  expect_type(bubble1, "list")

  # Test context_menu validation
  expect_error(context_menu(className = 123))
  expect_error(context_menu(trigger = "invalid"))
  expect_error(context_menu(offset = c(1)))
  cm1 <- context_menu()
  expect_type(cm1, "list")

  # Test edge_bundling validation
  expect_error(edge_bundling(bundleThreshold = -0.1))
  expect_error(edge_bundling(bundleThreshold = 1.5))
  expect_error(edge_bundling(cycles = -1))
  expect_error(edge_bundling(K = -0.1))
  eb1 <- edge_bundling()
  expect_type(eb1, "list")

  # Test edge_filter_lens validation
  expect_error(edge_filter_lens(r = -5))
  expect_error(edge_filter_lens(minR = -1))
  expect_error(edge_filter_lens(maxR = 10, r = 20))
  expect_error(edge_filter_lens(scaleRBy = "invalid"))
  expect_error(edge_filter_lens(nodeStyle = "invalid"))
  efl1 <- edge_filter_lens()
  expect_type(efl1, "list")

  # Test fish_eye validation
  expect_error(fish_eye(r = -10))
  expect_error(fish_eye(d = -1))
  expect_error(fish_eye(maxD = 2, d = 5))
  expect_error(fish_eye(scaleRBy = "invalid"))
  fe1 <- fish_eye()
  expect_type(fe1, "list")

  # Test fullscreen validation
  expect_error(fullscreen(autoFit = "true"))
  expect_error(fullscreen(trigger = "invalid"))
  fs1 <- fullscreen()
  expect_type(fs1, "list")

  # Test grid_line validation
  expect_error(grid_line(border = "true"))
  expect_error(grid_line(borderLineWidth = -1))
  expect_error(grid_line(borderStyle = "invalid"))
  expect_error(grid_line(size = -10))
  gl1 <- grid_line()
  expect_type(gl1, "list")

  # Test history validation
  expect_error(history(stackSize = -1))
  expect_error(history(stackSize = 1.5))
  h1 <- history()
  expect_type(h1, "list")

  # Test hull validation - fix the error pattern
  expect_error(hull(members = c()))
  hull1 <- hull(members = c("node1", "node2"))
  expect_type(hull1, "list")

  # Test legend validation
  expect_error(legend(width = -100))
  expect_error(legend(height = -50))
  expect_error(legend(itemSpacing = -1))
  expect_error(legend(gridCol = -1))
  expect_error(legend(gridCol = 1.5))
  l1 <- legend()
  expect_type(l1, "list")

  # Test minimap validation
  expect_error(minimap(delay = -1))
  expect_error(minimap(size = c(100)))
  expect_error(minimap(size = c(-100, 50)))
  mm1 <- minimap()
  expect_type(mm1, "list")

  # Test snapline validation
  expect_error(snapline(tolerance = -1))
  expect_error(snapline(offset = -5))
  expect_error(snapline(autoSnap = "true"))
  expect_error(snapline(shape = 123))
  sl1 <- snapline()
  expect_type(sl1, "list")

  # Test timebar validation
  expect_error(timebar(data = "invalid"))
  expect_error(timebar(data = c(1, 2, 3), width = -100))
  expect_error(timebar(data = c(1, 2, 3), height = -50))
  expect_error(timebar(data = c(1, 2, 3), loop = "false"))
  tb1 <- timebar(data = c(1609459200000, 1609545600000))
  expect_type(tb1, "list")

  # Test toolbar validation
  expect_error(toolbar(style = "invalid"))
  tb2 <- toolbar()
  expect_type(tb2, "list")

  # Test tooltips validation
  expect_error(tooltips(enable = "true"))
  expect_error(tooltips(offset = c(1)))
  expect_error(tooltips(enterable = "false"))
  expect_error(tooltips(style = "invalid"))
  tt1 <- tooltips()
  expect_type(tt1, "list")

  # Test watermark validation
  text <- "Watermark Test"
  expect_error(watermark(width = -100))
  expect_error(watermark(height = -50))
  expect_error(watermark(opacity = 1.5))
  expect_error(watermark(opacity = -0.1))
  expect_error(watermark(textFontSize = -10, text = text))
  wm1 <- watermark(text = text)
  expect_type(wm1, "list")
})

test_that("plugin match.arg validation works", {
  # Test match.arg cases for various plugins
  bubble1 <- bubble_sets(members = c("n1"), labelPlacement = "top")
  expect_type(bubble1, "list")

  edge_lens1 <- edge_filter_lens(trigger = "click", nodeType = "source")
  expect_type(edge_lens1, "list")

  fisheye1 <- fish_eye(trigger = "drag")
  expect_type(fisheye1, "list")

  hull1 <- hull(members = c("n1"), corner = "sharp")
  expect_type(hull1, "list")

  legend1 <- legend(trigger = "click", position = "top-right")
  expect_type(legend1, "list")

  timebar1 <- timebar(
    data = c(1, 2, 3),
    position = "top",
    timebarType = "chart"
  )
  expect_type(timebar1, "list")

  toolbar1 <- toolbar(position = "bottom-right")
  expect_type(toolbar1, "list")

  tooltip1 <- tooltips(position = "bottom-left", trigger = "click")
  expect_type(tooltip1, "list")

  watermark1 <- watermark(
    text = "test",
    textAlign = "right",
    textBaseline = "hanging"
  )
  expect_type(watermark1, "list")
})

test_that("plugin complex configurations work", {
  # Test complex configurations to hit more code paths
  bubble_complex <- bubble_sets(
    members = c("n1", "n2", "n3"),
    avoidMembers = c("n4", "n5"),
    labelPlacement = "top",
    labelPadding = c(2, 4),
    maxRoutingIterations = 150,
    pixelGroup = 6
  )
  expect_type(bubble_complex, "list")

  # Test edge_filter_lens with complex configuration
  lens_complex <- edge_filter_lens(
    trigger = "drag",
    r = 100,
    maxR = 200,
    minR = 10,
    nodeType = "either"
  )
  expect_type(lens_complex, "list")

  # Test fish_eye with scaling options
  fisheye_complex <- fish_eye(
    trigger = "click",
    r = 150,
    d = 2.0,
    maxD = 4.0,
    minD = 0.5,
    scaleRBy = "wheel",
    scaleDBy = "drag"
  )
  expect_type(fisheye_complex, "list")

  # Test grid_line with follow configuration
  grid_complex <- grid_line(
    follow = list(translate = TRUE, zoom = FALSE),
    borderStyle = "dashed",
    size = 30
  )
  expect_type(grid_complex, "list")

  # Test hull with all label options
  hull_complex <- hull(
    members = c("n1", "n2"),
    corner = "smooth",
    labelPlacement = "center",
    labelBackground = TRUE,
    labelPadding = c(2, 4, 6),
    labelOffsetX = 5,
    labelOffsetY = 10
  )
  expect_type(hull_complex, "list")

  # Test legend with grid layout
  legend_complex <- legend(
    orientation = "vertical",
    layout = "grid",
    gridCol = 3,
    gridRow = 2,
    showTitle = TRUE,
    titleText = "Legend"
  )
  expect_type(legend_complex, "list")

  # Test minimap with numeric position
  minimap_complex <- minimap(
    position = c(10, 20),
    size = c(300, 200),
    padding = c(5, 10)
  )
  expect_type(minimap_complex, "list")

  # Test watermark with all text options
  watermark_complex <- watermark(
    text = "DRAFT",
    textAlign = "left",
    textBaseline = "top",
    textFontWeight = "bold",
    rotate = pi / 4,
    opacity = 0.1
  )
  expect_type(watermark_complex, "list")
})
