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


test_that("behavior functions work with valid parameters", {
  # Test auto_adapt_label with various parameters
  expect_no_error(auto_adapt_label())
  expect_no_error(auto_adapt_label(throttle = 200, padding = 5))
  expect_no_error(auto_adapt_label(sortNode = list(type = "betweenness")))
  expect_no_error(auto_adapt_label(sortNode = list(type = "closeness")))
  expect_no_error(auto_adapt_label(sortNode = list(type = "eigenvector")))
  expect_no_error(auto_adapt_label(sortNode = list(type = "pagerank")))
  expect_no_error(auto_adapt_label(enable = FALSE))
  expect_no_error(auto_adapt_label(enable = JS("() => true")))
  expect_no_error(auto_adapt_label(sort = JS("(a, b) => a.id - b.id")))
  expect_no_error(auto_adapt_label(
    sortEdge = JS("(a, b) => a.weight - b.weight")
  ))
  expect_no_error(auto_adapt_label(sortCombo = JS("(a, b) => a.size - b.size")))

  # Test brush_select with various parameters
  expect_no_error(brush_select())
  expect_no_error(brush_select(animation = TRUE))
  expect_no_error(brush_select(enableElements = c("node", "edge")))
  expect_no_error(brush_select(enableElements = c("node", "edge", "combo")))
  expect_no_error(brush_select(mode = "union"))
  expect_no_error(brush_select(mode = "intersect"))
  expect_no_error(brush_select(mode = "diff"))
  expect_no_error(brush_select(state = "active"))
  expect_no_error(brush_select(state = "highlight"))
  expect_no_error(brush_select(immediately = TRUE))
  expect_no_error(brush_select(enable = FALSE))
  expect_no_error(brush_select(enable = JS("() => true")))
  expect_no_error(brush_select(onSelect = JS("(states) => states")))

  # Test click_select with various parameters
  expect_no_error(click_select())
  expect_no_error(click_select(animation = FALSE))
  expect_no_error(click_select(degree = 1))
  expect_no_error(click_select(degree = JS("() => 2")))
  expect_no_error(click_select(multiple = TRUE))
  expect_no_error(click_select(state = "active"))
  expect_no_error(click_select(neighborState = "highlight"))
  expect_no_error(click_select(unselectedState = "inactive"))
  expect_no_error(click_select(enable = FALSE))
  expect_no_error(click_select(enable = JS("() => true")))
  expect_no_error(click_select(onClick = JS("(event) => {}")))

  # Test collapse_expand with various parameters
  expect_no_error(collapse_expand())
  expect_no_error(collapse_expand(animation = FALSE))
  expect_no_error(collapse_expand(trigger = "click"))
  expect_no_error(collapse_expand(align = FALSE))
  expect_no_error(collapse_expand(enable = FALSE))
  expect_no_error(collapse_expand(enable = JS("() => true")))
  expect_no_error(collapse_expand(onCollapse = JS("() => {}")))
  expect_no_error(collapse_expand(onExpand = JS("() => {}")))

  # Test create_edge with various parameters
  expect_no_error(create_edge())
  expect_no_error(create_edge(trigger = "click"))
  expect_no_error(create_edge(enable = TRUE))
  expect_no_error(create_edge(enable = JS("() => true")))
  expect_no_error(create_edge(notify = TRUE))
  expect_no_error(create_edge(onCreate = JS("() => {}")))
  expect_no_error(create_edge(onFinish = JS("() => {}")))
  expect_no_error(create_edge(style = list(stroke = "red")))

  # Test drag_canvas with various parameters
  expect_no_error(drag_canvas())
  expect_no_error(drag_canvas(direction = "x"))
  expect_no_error(drag_canvas(direction = "y"))
  expect_no_error(drag_canvas(range = c(-100, 100)))
  expect_no_error(drag_canvas(range = 50))
  expect_no_error(drag_canvas(sensitivity = 5))
  expect_no_error(drag_canvas(enable = FALSE))
  expect_no_error(drag_canvas(enable = JS("() => true")))
  expect_no_error(drag_canvas(animation = list(duration = 300)))
  expect_no_error(drag_canvas(trigger = list(up = "w", down = "s")))
  expect_no_error(drag_canvas(onFinish = JS("() => {}")))

  # Test drag_element with various parameters
  expect_no_error(drag_element())
  expect_no_error(drag_element(animation = FALSE))
  expect_no_error(drag_element(dropEffect = "link"))
  expect_no_error(drag_element(dropEffect = "none"))
  expect_no_error(drag_element(hideEdge = "out"))
  expect_no_error(drag_element(hideEdge = "in"))
  expect_no_error(drag_element(hideEdge = "both"))
  expect_no_error(drag_element(hideEdge = "all"))
  expect_no_error(drag_element(shadow = TRUE))
  expect_no_error(drag_element(enable = FALSE))
  expect_no_error(drag_element(enable = JS("() => true")))
  expect_no_error(drag_element(
    cursor = list(default = "default", grab = "grab")
  ))

  # Test drag_element_force with various parameters
  expect_no_error(drag_element_force())
  expect_no_error(drag_element_force(fixed = TRUE))
  expect_no_error(drag_element_force(hideEdge = "out"))
  expect_no_error(drag_element_force(hideEdge = "in"))
  expect_no_error(drag_element_force(hideEdge = "both"))
  expect_no_error(drag_element_force(hideEdge = "all"))
  expect_no_error(drag_element_force(enable = FALSE))
  expect_no_error(drag_element_force(enable = JS("() => true")))
  expect_no_error(drag_element_force(cursor = list(default = "default")))

  # Test fix_element_size with various parameters
  expect_no_error(fix_element_size())
  expect_no_error(fix_element_size(reset = TRUE))
  expect_no_error(fix_element_size(state = "active"))
  expect_no_error(fix_element_size(enable = FALSE))
  expect_no_error(fix_element_size(enable = JS("() => true")))
  expect_no_error(fix_element_size(
    node = list(list(shape = "circle", fields = c("r")))
  ))
  expect_no_error(fix_element_size(nodeFilter = JS("() => false")))
  expect_no_error(fix_element_size(
    edge = list(list(shape = "line", fields = c("lineWidth")))
  ))
  expect_no_error(fix_element_size(edgeFilter = JS("() => false")))
  expect_no_error(fix_element_size(
    combo = list(list(shape = "rect", fields = c("width")))
  ))
  expect_no_error(fix_element_size(comboFilter = JS("() => false")))

  # Test focus_element with various parameters
  expect_no_error(focus_element())
  expect_no_error(focus_element(animation = list(duration = 1000)))
  expect_no_error(focus_element(animation = list(easing = "ease-out")))
  expect_no_error(focus_element(animation = list(easing = "ease-in-out")))
  expect_no_error(focus_element(animation = list(easing = "linear")))
  expect_no_error(focus_element(enable = FALSE))
  expect_no_error(focus_element(enable = JS("() => true")))

  # Test hover_activate with various parameters
  expect_no_error(hover_activate())
  expect_no_error(hover_activate(animation = FALSE))
  expect_no_error(hover_activate(degree = 1))
  expect_no_error(hover_activate(degree = JS("() => 2")))
  expect_no_error(hover_activate(direction = "in"))
  expect_no_error(hover_activate(direction = "out"))
  expect_no_error(hover_activate(state = "highlight"))
  expect_no_error(hover_activate(inactiveState = "inactive"))
  expect_no_error(hover_activate(enable = FALSE))
  expect_no_error(hover_activate(enable = JS("() => true")))
  expect_no_error(hover_activate(onHover = JS("() => {}")))
  expect_no_error(hover_activate(onHoverEnd = JS("() => {}")))

  # Test lasso_select with various parameters
  expect_no_error(lasso_select())
  expect_no_error(lasso_select(animation = TRUE))
  expect_no_error(lasso_select(enableElements = c("node", "combo")))
  expect_no_error(lasso_select(enableElements = c("node", "edge", "combo")))
  expect_no_error(lasso_select(immediately = TRUE))
  expect_no_error(lasso_select(mode = "union"))
  expect_no_error(lasso_select(mode = "intersect"))
  expect_no_error(lasso_select(mode = "diff"))
  expect_no_error(lasso_select(state = "highlight"))
  expect_no_error(lasso_select(enable = FALSE))
  expect_no_error(lasso_select(enable = JS("() => true")))
  expect_no_error(lasso_select(onSelect = JS("() => {}")))
  expect_no_error(lasso_select(style = list(stroke = "blue")))
  expect_no_error(lasso_select(trigger = c("control")))

  # Test optimize_viewport_transform with various parameters
  expect_no_error(optimize_viewport_transform())
  expect_no_error(optimize_viewport_transform(debounce = 500))
  expect_no_error(optimize_viewport_transform(enable = FALSE))
  expect_no_error(optimize_viewport_transform(enable = JS("() => true")))
  expect_no_error(optimize_viewport_transform(shapes = JS("() => false")))

  # Test scroll_canvas with various parameters
  expect_no_error(scroll_canvas())
  expect_no_error(scroll_canvas(direction = "x"))
  expect_no_error(scroll_canvas(direction = "y"))
  expect_no_error(scroll_canvas(range = c(-2, 2)))
  expect_no_error(scroll_canvas(range = 2))
  expect_no_error(scroll_canvas(sensitivity = 1.5))
  expect_no_error(scroll_canvas(preventDefault = FALSE))
  expect_no_error(scroll_canvas(enable = FALSE))
  expect_no_error(scroll_canvas(enable = JS("() => true")))
  expect_no_error(scroll_canvas(trigger = list(up = "w")))
  expect_no_error(scroll_canvas(onFinish = JS("() => {}")))

  # Test zoom_canvas with various parameters
  expect_no_error(zoom_canvas())
  expect_no_error(zoom_canvas(animation = list(duration = 300)))
  expect_no_error(zoom_canvas(origin = list(x = 0, y = 0)))
  expect_no_error(zoom_canvas(sensitivity = 1.5))
  expect_no_error(zoom_canvas(preventDefault = FALSE))
  expect_no_error(zoom_canvas(enable = FALSE))
  expect_no_error(zoom_canvas(enable = JS("() => true")))
  expect_no_error(zoom_canvas(trigger = list(zoomIn = "+")))
  expect_no_error(zoom_canvas(onFinish = JS("() => {}")))
})

test_that("behavior functions handle invalid parameters correctly", {
  # Test auto_adapt_label error conditions
  expect_error(
    auto_adapt_label(enable = "invalid"),
    "must be a logical value or a JavaScript function"
  )
  expect_error(
    auto_adapt_label(throttle = -1),
    "must be a single non-negative numeric value"
  )
  expect_error(
    auto_adapt_label(throttle = c(1, 2)),
    "must be a single non-negative numeric value"
  )
  expect_error(auto_adapt_label(padding = "invalid"), "must be a numeric value")
  expect_error(
    auto_adapt_label(sort = "invalid"),
    "must be NULL or a JavaScript function"
  )
  expect_error(auto_adapt_label(sortNode = "invalid"), "must be NULL, a list")
  expect_error(
    auto_adapt_label(sortNode = list(type = "invalid")),
    "must be one of:"
  )
  expect_error(
    auto_adapt_label(sortEdge = "invalid"),
    "must be NULL or a JavaScript function"
  )
  expect_error(
    auto_adapt_label(sortCombo = "invalid"),
    "must be NULL or a JavaScript function"
  )

  # Test brush_select error conditions
  expect_error(brush_select(animation = "invalid"), "should be a boolean value")
  expect_error(brush_select(enable = "invalid"), "should be a boolean or JS")
  expect_error(brush_select(enableElements = "invalid"), "should only contain:")
  expect_error(
    brush_select(immediately = "invalid"),
    "should be a boolean value"
  )
  expect_error(brush_select(onSelect = "invalid"), "should be a JS function")

  # Test click_select error conditions
  expect_error(click_select(animation = "invalid"), "should be a boolean value")
  expect_error(
    click_select(degree = "invalid"),
    "should be a number or a JS function"
  )
  expect_error(
    click_select(enable = "invalid"),
    "should be a boolean or a JS function"
  )
  expect_error(click_select(multiple = "invalid"), "should be a boolean value")
  expect_error(click_select(unselectedState = 123), "should be one of")
  expect_error(click_select(onClick = "invalid"), "should be a JS function")

  # Test collapse_expand error conditions
  expect_error(
    collapse_expand(animation = "invalid"),
    "should be a boolean value"
  )
  expect_error(
    collapse_expand(enable = "invalid"),
    "should be a boolean or a JS function"
  )
  expect_error(collapse_expand(trigger = "invalid"), "should be one of")
  expect_error(collapse_expand(align = "invalid"), "should be a boolean value")
  expect_error(
    collapse_expand(onCollapse = "invalid"),
    "should be a JS function"
  )
  expect_error(collapse_expand(onExpand = "invalid"), "should be a JS function")

  # Test create_edge error conditions
  expect_error(create_edge(trigger = "invalid"), "should be one of")
  expect_error(
    create_edge(enable = "invalid"),
    "should be a boolean or a JS function"
  )
  expect_error(create_edge(onCreate = "invalid"), "should be a JS function")
  expect_error(create_edge(onFinish = "invalid"), "should be a JS function")
  expect_error(create_edge(style = "invalid"), "should be a list")

  # Test drag_canvas error conditions
  expect_error(
    drag_canvas(enable = "invalid"),
    "should be a boolean or a function"
  )
  expect_error(drag_canvas(animation = "invalid"), "should be a list")
  expect_error(drag_canvas(range = "invalid"), "should be a number")
  expect_error(drag_canvas(sensitivity = -1), "should be a positive number")
  expect_error(drag_canvas(sensitivity = 0), "should be a positive number")
  expect_error(drag_canvas(trigger = "invalid"), "should be a list")
  expect_error(drag_canvas(onFinish = "invalid"), "should be a JS function")

  # Test drag_element error conditions
  expect_error(
    drag_element(enable = "invalid"),
    "should be a boolean or a JS function"
  )
  expect_error(drag_element(animation = "invalid"), "should be a boolean value")
  expect_error(drag_element(state = 123), "should be a string")
  expect_error(drag_element(shadow = "invalid"), "should be a boolean value")
  expect_error(drag_element(cursor = "invalid"), "should be a list")

  # Test drag_element_force error conditions
  expect_error(
    drag_element_force(fixed = "invalid"),
    "should be a boolean value"
  )
  expect_error(
    drag_element_force(enable = "invalid"),
    "should be a boolean or a JavaScript function"
  )
  expect_error(drag_element_force(state = 123), "should be a string")
  expect_error(drag_element_force(cursor = "invalid"), "should be a list")

  # Test fix_element_size error conditions
  expect_error(
    fix_element_size(enable = "invalid"),
    "should be a boolean or a JavaScript function"
  )
  expect_error(fix_element_size(reset = "invalid"), "should be a boolean value")
  expect_error(fix_element_size(state = 123), "should be a string")
  expect_error(fix_element_size(node = "invalid"), "should be a list")
  expect_error(
    fix_element_size(nodeFilter = "invalid"),
    "should be a JavaScript function"
  )
  expect_error(fix_element_size(edge = "invalid"), "should be a list")
  expect_error(
    fix_element_size(edgeFilter = "invalid"),
    "should be a JavaScript function"
  )
  expect_error(fix_element_size(combo = "invalid"), "should be a list")
  expect_error(
    fix_element_size(comboFilter = "invalid"),
    "should be a JavaScript function"
  )

  # Test focus_element error conditions
  expect_error(focus_element(animation = "invalid"), "should be a list")
  expect_error(
    focus_element(animation = list(duration = "invalid")),
    "should be a number"
  )
  expect_error(
    focus_element(animation = list(easing = 123)),
    "should be a string"
  )
  expect_error(
    focus_element(animation = list(easing = "invalid")),
    "should be one of:"
  )
  expect_error(
    focus_element(enable = "invalid"),
    "should be a boolean or a JavaScript function"
  )

  # Test hover_activate error conditions
  expect_error(
    hover_activate(animation = "invalid"),
    "should be a boolean value"
  )
  expect_error(
    hover_activate(enable = "invalid"),
    "should be a boolean or a JavaScript function"
  )
  expect_error(
    hover_activate(degree = "invalid"),
    "should be a number or a JavaScript function"
  )
  expect_error(hover_activate(state = 123), "should be a string")
  expect_error(hover_activate(inactiveState = 123), "should be a string")
  expect_error(
    hover_activate(onHover = "invalid"),
    "should be a JavaScript function"
  )
  expect_error(
    hover_activate(onHoverEnd = "invalid"),
    "should be a JavaScript function"
  )

  # Test lasso_select error conditions
  expect_error(lasso_select(key = 123), "should be a string")
  expect_error(lasso_select(animation = "invalid"), "should be a boolean value")
  expect_error(
    lasso_select(enable = "invalid"),
    "should be a boolean or a JavaScript function"
  )
  expect_error(lasso_select(enableElements = "invalid"), "should only contain:")
  expect_error(
    lasso_select(immediately = "invalid"),
    "should be a boolean value"
  )
  expect_error(
    lasso_select(onSelect = "invalid"),
    "should be a JavaScript function"
  )
  expect_error(lasso_select(state = 123), "should be a string")
  expect_error(lasso_select(style = "invalid"), "should be a list")

  # Test optimize_viewport_transform error conditions
  expect_error(
    optimize_viewport_transform(enable = "invalid"),
    "should be a boolean or a JavaScript function"
  )
  expect_error(
    optimize_viewport_transform(debounce = -1),
    "should be a non-negative number"
  )
  expect_error(
    optimize_viewport_transform(shapes = "invalid"),
    "should be a JavaScript function"
  )

  # Test scroll_canvas error conditions
  expect_error(
    scroll_canvas(enable = "invalid"),
    "should be a boolean or a JavaScript function"
  )
  expect_error(scroll_canvas(direction = "invalid"), "should be one of:")
  expect_error(scroll_canvas(range = "invalid"), "should be a number")
  expect_error(scroll_canvas(sensitivity = -1), "should be a positive number")
  expect_error(scroll_canvas(sensitivity = 0), "should be a positive number")
  expect_error(scroll_canvas(trigger = "invalid"), "should be a list")
  expect_error(
    scroll_canvas(onFinish = "invalid"),
    "should be a JavaScript function"
  )
  expect_error(
    scroll_canvas(preventDefault = "invalid"),
    "should be a boolean value"
  )

  # Test zoom_canvas error conditions
  expect_error(zoom_canvas(key = 123), "should be a string")
  expect_error(zoom_canvas(animation = "invalid"), "should be a list")
  expect_error(
    zoom_canvas(animation = list(duration = -1)),
    "should be a non-negative number"
  )
  expect_error(
    zoom_canvas(enable = "invalid"),
    "should be a boolean or a JavaScript function"
  )
  expect_error(zoom_canvas(origin = "invalid"), "should be a list")
  expect_error(
    zoom_canvas(onFinish = "invalid"),
    "should be a JavaScript function"
  )
  expect_error(
    zoom_canvas(preventDefault = "invalid"),
    "should be a boolean value"
  )
  expect_error(zoom_canvas(sensitivity = -1), "should be a positive number")
  expect_error(zoom_canvas(sensitivity = 0), "should be a positive number")
  expect_error(zoom_canvas(trigger = "invalid"), "should be a list")
})
