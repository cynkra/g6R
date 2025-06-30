test_that("dropNulls removes NULL elements", {
  input_list <- list(a = 1, b = NULL, c = 3, d = NULL)
  result <- dropNulls(input_list)
  expected <- list(a = 1, c = 3)
  expect_equal(result, expected)

  # Test with no NULLs
  no_null <- list(a = 1, b = 2)
  result_same <- dropNulls(no_null)
  expect_equal(result_same, no_null)
})

test_that("JS function creates JS_EVAL objects", {
  js_code <- "function() { return true; }"
  result <- JS(js_code)
  expect_s3_class(result, "JS_EVAL")
  expect_equal(as.character(result), js_code)

  # Test with multiple arguments
  js_multi <- JS("var a = 1;", "var b = 2;")
  expect_s3_class(js_multi, "JS_EVAL")
  expect_equal(as.character(js_multi), "var a = 1;\nvar b = 2;")
})

test_that("JS function handles edge cases", {
  # Test with NULL
  expect_null(JS(NULL))

  # Test with empty string
  result_empty <- JS("")
  expect_s3_class(result_empty, "JS_EVAL")
  expect_equal(as.character(result_empty), "")

  # Test error with non-character input
  expect_error(JS(123), "must be a character vector")
  expect_error(JS(list(a = 1)), "must be a character vector")
})

test_that("is_js identifies JS_EVAL objects", {
  js_obj <- JS("test")
  regular_string <- "test"

  expect_true(is_js(js_obj))
  expect_false(is_js(regular_string))
  expect_false(is_js(123))
  expect_false(is_js(NULL))
})
