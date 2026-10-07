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
