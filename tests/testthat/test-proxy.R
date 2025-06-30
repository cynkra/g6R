library(testthat)
library(shiny)

# Test g6_proxy function
test_that("g6_proxy creation works correctly", {
  # Mock a shiny session
  session <- list()
  class(session) <- "ShinySession"

  # Test valid proxy creation
  proxy <- g6_proxy("test_id", session)
  expect_s3_class(proxy, "g6_proxy")
  expect_equal(proxy$id, "test_id")
  expect_equal(proxy$session, session)

  # Test error when no session provided
  expect_error(
    g6_proxy("test_id", NULL),
    "g6_proxy must be called from the server function of a Shiny app"
  )
})

# Test g6_data internal function
test_that("g6_data handles inputs correctly", {
  # Mock a shiny session with sendCustomMessage
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"

  # Create a test proxy
  proxy <- g6_proxy("test_id", session)

  # Test with data frame input
  test_df <- data.frame(
    id = c("1", "2"),
    label = c("Node 1", "Node 2")
  )

  # Should not error
  expect_error(
    g6_data(proxy, test_df, "add", "Node"),
    NA
  )

  # Test with non-proxy object
  expect_snapshot(error = TRUE, {
    g6_data(list(), test_df, "add", "Node")
  })
})

# Test g6_add_nodes function
test_that("g6_add_nodes works correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)

  # Test with data frame
  nodes_df <- data.frame(
    id = c("1", "2"),
    label = c("Node 1", "Node 2")
  )

  expect_error(g6_add_nodes(proxy, nodes_df), NA)

  # Test with list
  nodes_list <- list(
    list(id = "1", label = "Node 1"),
    list(id = "2", label = "Node 2")
  )

  expect_error(g6_add_nodes(proxy, nodes_list), NA)
})

# Test g6_remove_nodes function
test_that("g6_remove_nodes works correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)

  # Test with single ID
  expect_error(g6_remove_nodes(proxy, "node1"), NA)

  # Test with multiple IDs
  expect_error(g6_remove_nodes(proxy, c("node1", "node2")), NA)
})

# Test g6_update_nodes function
test_that("g6_update_nodes works correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)

  # Test with data frame update
  update_df <- data.frame(
    id = "1",
    label = "Updated Node"
  )

  expect_error(g6_update_nodes(proxy, update_df), NA)
})

# Test g6_canvas_resize function
test_that("g6_canvas_resize works correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)

  expect_error(g6_canvas_resize(proxy, 800, 600), NA)
  expect_error(
    g6_canvas_resize(list(), 800, 600),
    "Can't use g6_canvas_resize with g6 object"
  )
})

# Test g6_fit_center function
test_that("g6_fit_center works correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)

  # Test without animation
  expect_error(g6_fit_center(proxy), NA)

  # Test with animation
  animation <- list(duration = 300, easing = "ease-out")
  expect_error(g6_fit_center(proxy, animation), NA)

  # Test with invalid animation parameter
  expect_snapshot(error = TRUE, {
    g6_fit_center(proxy, "invalid")
  })
})

# Test g6_focus_elements function
test_that("g6_focus_elements works correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)

  # Test with single ID
  expect_error(g6_focus_elements(proxy, "node1"), NA)

  # Test with multiple IDs
  expect_error(g6_focus_elements(proxy, c("node1", "node2")), NA)

  # Test with animation
  animation <- list(duration = 300, easing = "ease-out")
  expect_error(g6_focus_elements(proxy, "node1", animation), NA)
})

# Test hide/show elements functions
test_that("g6_hide_elements and g6_show_elements work correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)

  # Test hide elements
  expect_error(g6_hide_elements(proxy, c("node1", "node2")), NA)

  # Test show elements
  expect_error(g6_show_elements(proxy, c("node1", "node2")), NA)
})

# Test combo action functions
test_that("g6_collapse_combo and g6_expand_combo work correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)

  # Test collapse combo
  expect_error(g6_collapse_combo(proxy, "combo1"), NA)

  # Test expand combo
  expect_error(g6_expand_combo(proxy, "combo1"), NA)

  # Test with options
  options <- list(animate = TRUE, align = TRUE)
  expect_error(g6_collapse_combo(proxy, "combo1", options), NA)
  expect_error(g6_expand_combo(proxy, "combo1", options), NA)
})

# Test g6_set_options function
test_that("g6_set_options works correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)

  # Test with various options
  expect_error(
    g6_set_options(
      proxy,
      fitView = TRUE,
      animate = TRUE,
      modes = list(default = list(type = "drag-canvas"))
    ),
    NA
  )
})

# Test plugin functions
test_that("g6_add_plugin and g6_update_plugin work correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)

  # Test add plugin
  expect_error(
    g6_add_plugin(
      proxy,
      minimap = list(size = list(width = 100, height = 100))
    ),
    NA
  )

  # Test update plugin
  expect_error(
    g6_update_plugin(
      proxy,
      "minimap",
      size = list(width = 150, height = 150)
    ),
    NA
  )
})

# Test g6_update_behavior function
test_that("g6_update_behavior works correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)

  # Test updating behavior
  expect_error(
    g6_update_behavior(
      proxy,
      "drag-canvas",
      enableOptimize = TRUE
    ),
    NA
  )
})
