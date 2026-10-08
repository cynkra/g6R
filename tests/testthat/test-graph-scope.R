test_that("plugin callbacks reach their own widget's graph", {
  skip_on_cran()
  skip_if_not_installed("chromote")
  skip_if(
    is.null(tryCatch(chromote::find_chrome(), error = function(e) NULL)),
    "Chrome is not available"
  )

  widget <- function(first) {
    g6(
      nodes = data.frame(id = c(first, "z")),
      edges = data.frame(source = first, target = "z"),
      width = 400,
      height = 300
    ) |>
      g6_plugins(
        toolbar(
          getItems = JS("() => [{ id: 'zoom-in', value: 'zoom-in' }]"),
          onClick = JS(
            "(value) => {
              (window.__hits = window.__hits || []).push(graph.getNodeData()[0].id);
            }"
          )
        )
      )
  }

  dir <- withr::local_tempdir()
  path <- file.path(dir, "index.html")
  htmltools::save_html(htmltools::tagList(widget("first"), widget("second")), path)

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

  # The toolbars are drawn once each graph has rendered.
  ready <- FALSE
  for (i in seq_len(50)) {
    ready <- eval_js("document.querySelectorAll('.g6-toolbar-item').length === 2")
    if (isTRUE(ready)) break
    Sys.sleep(0.1)
  }
  expect_true(ready)

  hits <- eval_js(
    "(() => {
      window.__hits = [];
      document.querySelectorAll('.g6-toolbar-item').forEach((item) =>
        item.dispatchEvent(new MouseEvent('click', { bubbles: true }))
      );
      return window.__hits.join(',');
    })()"
  )

  expect_identical(hits, "first,second")
})
