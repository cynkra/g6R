test_that("each widget on a page keeps its own graph", {
  session <- local_chrome_session()

  page <- htmltools::tagList(
    g6(nodes = data.frame(id = "first"), width = 400, height = 300, elementId = "a"),
    g6(nodes = data.frame(id = "second"), width = 400, height = 300, elementId = "b")
  )

  dir <- withr::local_tempdir()
  path <- file.path(dir, "index.html")
  htmltools::save_html(page, path)

  session$Page$navigate(paste0("file://", path), wait_ = TRUE)

  expect_true(
    wait_for_js(
      session,
      "['a', 'b'].every((id) => !!HTMLWidgets.find('#' + id)?.getWidget())"
    )
  )

  first_node <- "(id) => HTMLWidgets.find('#' + id).getWidget().getNodeData()[0].id"
  expect_identical(eval_js(session, sprintf("(%s)('a')", first_node)), "first")
  expect_identical(eval_js(session, sprintf("(%s)('b')", first_node)), "second")

  # Resizing the first widget's container resizes the first graph, and only it.
  eval_js(session, "document.getElementById('a').style.width = '250px'; true")
  expect_true(
    wait_for_js(session, "HTMLWidgets.find('#a').getWidget().getSize()[0] === 250")
  )
  expect_identical(
    eval_js(session, "HTMLWidgets.find('#b').getWidget().getSize()[0]"),
    400L
  )
})
