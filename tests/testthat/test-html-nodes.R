test_that("g6_node(ui = ) implies an HTML node", {
  n <- g6_node("a", ui = htmltools::div("A"))
  expect_identical(n$type, "custom-html-node")
  expect_s3_class(n$ui, "shiny.tag")

  expect_identical(
    g6_node("a", type = "custom-html-node", ui = htmltools::div())$type,
    "custom-html-node"
  )
  expect_error(
    g6_node("a", type = "custom-rect-node", ui = htmltools::div()),
    "custom-html-node"
  )
})

test_that("g6() sends node ui as markup and dependencies, not node data", {
  dep <- htmltools::htmlDependency("demo-dep", "1.0", src = c(href = "x"))
  w <- g6(
    nodes = g6_nodes(
      g6_node("a", ui = htmltools::tagList(htmltools::div("A"), dep)),
      g6_node("b")
    )
  )

  expect_null(w$x$data$nodes[[1]]$ui)
  expect_named(w$x$nodeContent, "a")
  expect_match(w$x$nodeContent$a, "<div>A</div>", fixed = TRUE)
  expect_true("demo-dep" %in% vapply(w$dependencies, `[[`, "", "name"))
})

test_that("g6() without node ui sends no node content", {
  w <- g6(nodes = g6_nodes(g6_node("a")))
  expect_null(w$x$nodeContent)
  expect_null(w$dependencies)
})

test_that("proxy additions carry node ui beside the nodes", {
  sent <- NULL
  session <- list(
    sendCustomMessage = function(type, message) sent <<- message
  )
  class(session) <- "ShinySession"
  proxy <- g6_proxy("graph", session)

  g6_add_nodes(proxy, g6_node("a", ui = htmltools::div("A")))
  expect_null(sent$el[[1]]$ui)
  expect_match(sent$content$a, "<div>A</div>", fixed = TRUE)

  g6_add_nodes(proxy, g6_node("b"))
  expect_null(sent$content)
})

test_that("an autoHeight node announces its new height", {
  session <- local_chrome_session()

  widget <- g6(
    nodes = g6_nodes(
      g6_node(
        id = "a",
        style = list(x = 150, y = 150, size = c(200, 80), autoHeight = TRUE),
        ui = htmltools::div(id = "grow", style = "height: 60px;")
      )
    ),
    width = 500,
    height = 400
  ) |>
    g6_options(animation = FALSE)

  dir <- withr::local_tempdir()
  path <- file.path(dir, "index.html")
  htmlwidgets::saveWidget(widget, path, selfcontained = FALSE)
  session$Page$navigate(paste0("file://", path), wait_ = TRUE)

  graph <- "HTMLWidgets.find('#' + document.querySelector('.g6').id).getWidget()"
  expect_true(wait_for_js(session, sprintf("!!%s?.rendered", graph)))
  expect_true(wait_for_js(session, "!!document.getElementById('grow')"))

  # whatever the first fit announced, collect only what growing announces
  Sys.sleep(0.5)
  eval_js(
    session,
    "window.__resized = [];
    document.addEventListener('g6:node-resize', (e) => window.__resized.push(e.detail));
    document.getElementById('grow').style.height = '200px';"
  )
  expect_true(wait_for_js(session, "window.__resized.length > 0"))

  detail <- eval_js(session, "window.__resized.at(-1)")
  expect_identical(detail$id, "a")
  expect_equal(detail$size[[1]], 200)
  expect_equal(detail$previous[[1]], 200)
  expect_gt(detail$size[[2]], detail$previous[[2]] + 100)
  # the node is drawn at the announced size by then
  size <- eval_js(session, sprintf("%s.getNodeData('a').style.size", graph))
  expect_equal(unlist(size), unlist(detail$size))
})
