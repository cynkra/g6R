# A headless Chrome session for tests that need a real browser, closed when
# the calling test ends. Skips rather than fails when there is no browser to
# be had: on CRAN, without chromote or Chrome, or when Chrome does not come up
# (a slow or locked-down CI runner). A browser that will not start says nothing
# about g6R.
local_chrome_session <- function(env = parent.frame()) {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("chromote")
  testthat::skip_if(
    is.null(tryCatch(chromote::find_chrome(), error = function(e) NULL)),
    "Chrome is not available"
  )

  # chromote waits 10 seconds for Chrome's debugging port, which a busy CI
  # runner can miss.
  withr::local_options(chromote.timeout = 60, .local_envir = env)

  chrome <- tryCatch(chromote::Chromote$new(), error = function(e) e)
  if (inherits(chrome, "error")) {
    testthat::skip(paste("Chrome did not start:", conditionMessage(chrome)))
  }
  withr::defer(chrome$close(), envir = env)

  chrome$new_session()
}

# Evaluate JavaScript in a session and return its value, failing the test on a
# JavaScript exception.
eval_js <- function(session, js) {
  res <- session$Runtime$evaluate(js, awaitPromise = TRUE, returnByValue = TRUE)
  if (!is.null(res$exceptionDetails)) {
    stop(res$exceptionDetails$exception$description, call. = FALSE)
  }
  res$result$value
}

# Poll a JavaScript condition until it holds, for up to `timeout` seconds. An
# exception counts as "not yet": the page's scripts (htmlwidgets, the widget
# bundle) may still be loading, more slowly under covr.
wait_for_js <- function(session, js, timeout = 15) {
  end <- Sys.time() + timeout
  while (Sys.time() < end) {
    ok <- tryCatch(isTRUE(eval_js(session, js)), error = function(e) FALSE)
    if (ok) return(TRUE)
    Sys.sleep(0.1)
  }
  FALSE
}
