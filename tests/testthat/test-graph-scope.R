test_that("plugin callbacks reach their own widget's graph", {
  session <- local_chrome_session()

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

  session$Page$navigate(paste0("file://", path), wait_ = TRUE)

  # The toolbars are drawn once each graph has rendered.
  expect_true(
    wait_for_js(session, "document.querySelectorAll('.g6-toolbar-item').length === 2")
  )

  hits <- eval_js(
    session,
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
