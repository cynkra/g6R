test_that("each widget on a page keeps its own graph", {
  skip_on_cran()
  skip_if_not_installed("chromote")
  skip_if(
    is.null(tryCatch(chromote::find_chrome(), error = function(e) NULL)),
    "Chrome is not available"
  )

  page <- htmltools::tagList(
    g6(nodes = data.frame(id = "first"), width = 400, height = 300, elementId = "a"),
    g6(nodes = data.frame(id = "second"), width = 400, height = 300, elementId = "b")
  )

  dir <- withr::local_tempdir()
  path <- file.path(dir, "index.html")
  htmltools::save_html(page, path)

  session <- chromote::ChromoteSession$new()
  withr::defer(session$close())

  session$Page$navigate(paste0("file://", path), wait_ = TRUE)

  eval_js <- function(js) {
    res <- session$Runtime$evaluate(js, awaitPromise = TRUE, returnByValue = TRUE)
    if (!is.null(res$exceptionDetails)) {
      stop(res$exceptionDetails$exception$description)
    }
    res$result$value
  }

  wait_for <- function(js) {
    for (i in seq_len(50)) {
      if (isTRUE(eval_js(js))) return(TRUE)
      Sys.sleep(0.1)
    }
    FALSE
  }

  expect_true(
    wait_for("['a', 'b'].every((id) => !!HTMLWidgets.find('#' + id)?.getWidget())")
  )

  first_node <- "(id) => HTMLWidgets.find('#' + id).getWidget().getNodeData()[0].id"
  expect_identical(eval_js(sprintf("(%s)('a')", first_node)), "first")
  expect_identical(eval_js(sprintf("(%s)('b')", first_node)), "second")

  # Resizing the first widget's container resizes the first graph, and only it.
  eval_js("document.getElementById('a').style.width = '250px'; true")
  expect_true(
    wait_for("HTMLWidgets.find('#a').getWidget().getSize()[0] === 250")
  )
  expect_identical(
    eval_js("HTMLWidgets.find('#b').getWidget().getSize()[0]"),
    400L
  )
})
