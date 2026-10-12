test_that("spanning_tree_layout() builds a spanning-tree layout", {
  expect_identical(
    spanning_tree_layout(),
    list(type = "spanning-tree", base = "indented")
  )
  expect_identical(
    spanning_tree_layout("compact-box", direction = "TB"),
    list(type = "spanning-tree", base = "compact-box", direction = "TB")
  )
  expect_error(spanning_tree_layout("fishbone"))
})

# Render widgets on one page in headless Chrome and return the session plus
# a JS expression reaching the graph of the widget with element id `id`.
local_widgets_page <- function(widgets, env = parent.frame()) {
  session <- local_chrome_session(env)

  dir <- withr::local_tempdir(.local_envir = env)
  path <- file.path(dir, "index.html")
  htmltools::save_html(htmltools::tagList(widgets), path, libdir = "lib")
  session$Page$navigate(paste0("file://", path), wait_ = TRUE)

  session
}

graph_js <- function(id) {
  sprintf("HTMLWidgets.find('#%s').getWidget()", id)
}

positions_js <- function(id) {
  sprintf(
    "Object.fromEntries(%s.getNodeData().map((n) => [n.id, [n.style.x, n.style.y]]))",
    graph_js(id)
  )
}

# a -> b, c; b, c -> d -> e; a second source x; e, x -> m
multi_parent <- function(id, layout) {
  g6(
    nodes = data.frame(id = c("a", "b", "c", "d", "e", "x", "m")),
    edges = data.frame(
      source = c("a", "a", "b", "c", "d", "x", "e"),
      target = c("b", "c", "d", "d", "e", "m", "m")
    ),
    width = 600,
    height = 600,
    elementId = id
  ) |>
    g6_options(animation = FALSE) |>
    g6_layout(layout)
}

test_that("a spanning tree places every node of a non-forest on its own", {
  session <- local_widgets_page(list(
    multi_parent("native", indented_layout()),
    multi_parent("spanning", spanning_tree_layout("indented"))
  ))

  for (id in c("native", "spanning")) {
    expect_true(wait_for_js(session, sprintf("!!%s?.rendered", graph_js(id))))
  }

  key <- function(p) vapply(p, function(xy) paste(round(unlist(xy)), collapse = ","), "")

  # G6's own indented layout stacks the second root on the first.
  native <- eval_js(session, positions_js("native"))
  expect_identical(key(native)[["x"]], key(native)[["a"]])

  spanning <- eval_js(session, positions_js("spanning"))
  expect_length(unique(key(spanning)), 7L)

  # `d` hangs under `b`, its first input, one level below it.
  expect_gt(spanning$d[[1]], spanning$b[[1]])
  # The second root sits beside the first tree, not on top of it.
  expect_false(identical(key(spanning)[["x"]], key(spanning)[["a"]]))
})

test_that("treeParent picks which input a node hangs under", {
  widget <- g6(
    nodes = g6_nodes(
      g6_node("a"),
      g6_node("b"),
      g6_node("c"),
      g6_node("d", data = list(treeParent = "c"))
    ),
    edges = data.frame(source = c("a", "a", "b", "c"), target = c("b", "c", "d", "d")),
    width = 600,
    height = 600,
    elementId = "hint"
  ) |>
    g6_options(animation = FALSE) |>
    g6_layout(spanning_tree_layout("compact-box", direction = "TB"))

  session <- local_widgets_page(list(widget))
  expect_true(wait_for_js(session, sprintf("!!%s?.rendered", graph_js("hint"))))

  pos <- eval_js(session, positions_js("hint"))
  # Under `c` rather than `b`, its first input: aligned with `c`.
  expect_equal(pos$d[[1]], pos$c[[1]])
  expect_false(isTRUE(all.equal(pos$d[[1]], pos$b[[1]])))
})

test_that("a cycle does not stop the layout", {
  widget <- g6(
    nodes = data.frame(id = c("a", "b", "c")),
    edges = data.frame(source = c("a", "b", "c"), target = c("b", "c", "a")),
    width = 600,
    height = 600,
    elementId = "cycle"
  ) |>
    g6_options(animation = FALSE) |>
    g6_layout(spanning_tree_layout("indented"))

  session <- local_widgets_page(list(widget))
  expect_true(wait_for_js(session, sprintf("!!%s?.rendered", graph_js("cycle"))))

  pos <- eval_js(session, positions_js("cycle"))
  expect_true(all(is.finite(unlist(pos))))
  expect_length(unique(vapply(pos, function(xy) paste(round(unlist(xy)), collapse = ","), "")), 3L)
})

test_that("a layout that fails puts the last good one back", {
  widget <- multi_parent("fallback", spanning_tree_layout("compact-box"))

  session <- local_widgets_page(list(widget))
  expect_true(wait_for_js(session, sprintf("!!%s?.rendered", graph_js("fallback"))))

  before <- eval_js(session, positions_js("fallback"))

  eval_js(session, sprintf(
    "(async () => {
      const g = %s;
      g.setLayout({ type: 'spanning-tree', base: 'nope' });
      await g.layout();
    })()",
    graph_js("fallback")
  ))

  expect_equal(eval_js(session, positions_js("fallback")), before)
  expect_identical(
    eval_js(session, sprintf("%s.getOptions().layout.base", graph_js("fallback"))),
    "compact-box"
  )
})

test_that("every exposed layout runs in the browser", {
  # A tree with `children`, which fishbone reads; snake only takes a chain.
  tree <- g6_nodes(
    g6_node("r", children = c("s", "t")),
    g6_node("s", children = c("u", "v")),
    g6_node("t", children = "w"),
    g6_node("u"), g6_node("v"), g6_node("w")
  )
  tree_edges <- data.frame(source = c("r", "r", "s", "s", "t"), target = c("s", "t", "u", "v", "w"))
  chain <- data.frame(id = letters[1:5])
  chain_edges <- data.frame(source = letters[1:4], target = letters[2:5])

  types <- names(valid_layouts)
  widgets <- lapply(types, function(type) {
    is_snake <- type == "snake"
    g6(
      nodes = if (is_snake) chain else tree,
      edges = if (is_snake) chain_edges else tree_edges,
      width = 400,
      height = 300,
      elementId = paste0("w_", gsub("-", "_", type))
    ) |>
      g6_options(animation = FALSE) |>
      g6_layout(type)
  })

  session <- local_widgets_page(widgets)

  for (type in types) {
    id <- paste0("w_", gsub("-", "_", type))
    expect_true(wait_for_js(session, sprintf("!!%s?.rendered", graph_js(id))), info = type)
    pos <- eval_js(session, positions_js(id))
    expect_true(all(is.finite(unlist(pos))), info = type)
  }
})

test_that("nodes of different sizes line up on their centres", {
  # A small parent over a large child, top to bottom: their centres share x.
  widget <- g6(
    nodes = g6_nodes(
      g6_node("p", style = list(size = 20)),
      g6_node("c", style = list(size = 120))
    ),
    edges = data.frame(source = "p", target = "c"),
    width = 600,
    height = 600,
    elementId = "sizes"
  ) |>
    g6_options(animation = FALSE) |>
    g6_layout(spanning_tree_layout("compact-box", direction = "TB"))

  session <- local_widgets_page(list(widget))
  expect_true(wait_for_js(session, sprintf("!!%s?.rendered", graph_js("sizes"))))

  pos <- eval_js(session, positions_js("sizes"))
  expect_equal(pos$p[[1]], pos$c[[1]])
  # And the child sits below the parent, clear of it.
  expect_gt(pos$c[[2]] - 60, pos$p[[2]] + 10)
})
