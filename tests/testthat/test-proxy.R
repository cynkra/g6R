library(testthat)
library(shiny)

test_that("g6_proxy creation works correctly", {
  session <- list()
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)
  expect_s3_class(proxy, "g6_proxy")
  expect_equal(proxy$id, "test_id")
  expect_equal(proxy$session, session)
  expect_error(
    g6_proxy("test_id", NULL),
    "g6_proxy must be called from the server function of a Shiny app"
  )
})

test_that("g6_data_proxy handles inputs correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)
  test_df <- data.frame(id = c("1", "2"), label = c("Node 1", "Node 2"))
  expect_error(g6_data_proxy(proxy, test_df, "add", "Node"), NA)
  expect_snapshot(error = TRUE, {
    g6_data_proxy(list(), test_df, "add", "Node")
  })
})

test_that("g6_add_nodes handles various input forms and flattening", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)
  nodes_df <- data.frame(id = c("1", "2"))
  expect_error(g6_add_nodes(proxy, nodes_df), NA)
  nodes_list <- list(list(id = "3"), list(id = "4"))
  expect_error(g6_add_nodes(proxy, nodes_list), NA)
  expect_error(g6_add_nodes(proxy, list(id = "5"), list(id = "6")), NA)
  expect_error(
    g6_add_nodes(proxy, list(list(list(id = "7")))),
    "Input is too deeply nested"
  )
  expect_error(
    g6_add_nodes(proxy, g6_nodes(g6_node(id = "8"), g6_node(id = "9"))),
    NA
  )
  expect_error(g6_add_nodes(proxy, g6_node(id = "10"), g6_node(id = "11")), NA)
})

test_that("g6_remove_nodes works correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)
  expect_error(g6_remove_nodes(proxy, c("node1", "node2")), NA)
})

test_that("g6_update_nodes works correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)
  update_df <- data.frame(id = "1")
  expect_error(g6_update_nodes(proxy, update_df), NA)
})

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

test_that("g6_fit_center works correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)
  expect_error(g6_fit_center(proxy), NA)
  animation <- list(duration = 300, easing = "ease-out")
  expect_error(g6_fit_center(proxy, animation), NA)
  expect_snapshot(error = TRUE, {
    g6_fit_center(proxy, "invalid")
  })
})

test_that("g6_focus_elements works correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)
  expect_error(g6_focus_elements(proxy, "node1"), NA)
  expect_error(g6_focus_elements(proxy, c("node1", "node2")), NA)
  animation <- list(duration = 300, easing = "ease-out")
  expect_error(g6_focus_elements(proxy, "node1", animation), NA)
})

test_that("g6_hide_elements and g6_show_elements work correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)
  expect_error(g6_hide_elements(proxy, c("node1", "node2")), NA)
  expect_error(g6_show_elements(proxy, c("node1", "node2")), NA)
})

test_that("g6_collapse_combo and g6_expand_combo work correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)
  expect_error(g6_collapse_combo(proxy, "combo1"), NA)
  expect_error(g6_expand_combo(proxy, "combo1"), NA)
  options <- list(animate = TRUE, align = TRUE)
  expect_error(g6_collapse_combo(proxy, "combo1", options), NA)
  expect_error(g6_expand_combo(proxy, "combo1", options), NA)
})

test_that("g6_set_options works correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)
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

test_that("g6_add_plugin and g6_update_plugin work correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)
  expect_error(
    g6_add_plugin(
      proxy,
      minimap = list(size = list(width = 100, height = 100))
    ),
    NA
  )
  expect_error(
    g6_update_plugin(
      proxy,
      "minimap",
      size = list(width = 150, height = 150)
    ),
    NA
  )
})

test_that("g6_update_behavior works correctly", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)
  expect_error(
    g6_update_behavior(
      proxy,
      "drag-canvas",
      enableOptimize = TRUE
    ),
    NA
  )
})

test_that("g6_add_edges enforces source/target for creation", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)
  expect_error(g6_add_edges(proxy, list(source = "1", target = "2")), NA)
  edges_df <- data.frame(source = "1", target = "2")
  expect_error(g6_add_edges(proxy, edges_df), NA)
})

test_that("as_g6_elements flattens any level of nesting and errors on excessive nesting", {
  expect_equal(
    flatten_g6_elements(list(list(source = 1, target = 2))),
    list(list(source = 1, target = 2))
  )
  expect_equal(
    flatten_g6_elements(list(list(list(source = 1, target = 2)))),
    list(list(source = 1, target = 2))
  )
  expect_error(
    as_g6_elements(list(list(list(list(id = "7")))), coerc_func = as_g6_nodes),
    "Input is too deeply nested"
  )
})

test_that("g6_update_layout proxy call works and errors on invalid proxy", {
  session <- list(
    sendCustomMessage = function(type, message) {
      list(type = type, message = message)
    }
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("test_id", session)

  # should not error for a valid proxy
  expect_error(g6_update_layout(proxy, type = "grid"), NA)

  # invalid proxy (not a g6_proxy) should error
  expect_error(g6_update_layout(list(), type = "grid"))
})
