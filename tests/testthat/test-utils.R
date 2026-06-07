test_that("%||% returns y when x is NULL", {
  expect_equal(NULL %||% "default", "default")
})

test_that("%||% returns y when x has length 0", {
  expect_equal(character(0) %||% "default", "default")
  expect_equal(integer(0)   %||% 42L,        42L)
})

test_that("%||% returns x when x is non-NULL and non-empty", {
  expect_equal("value" %||% "default", "value")
  expect_equal(0L      %||% 99L,       0L)
  expect_equal(FALSE   %||% TRUE,      FALSE)
})

test_that(".check passes silently on result '0000'", {
  body <- list(result = "0000", data = list())
  expect_silent(.check(body, "test"))
})

test_that(".check stops with an informative error on non-0000 result", {
  body <- list(result = "1001", message = "invalid token")
  expect_error(.check(body, "login"), "login error: invalid token")
})

test_that(".check falls back to 'unknown' when message is absent", {
  body <- list(result = "9999")
  expect_error(.check(body, "ctx"), "ctx error: unknown")
})

test_that("COROS_SPORT_NAMES is a named character vector covering key sports", {
  expect_type(COROS_SPORT_NAMES, "character")
  expect_equal(COROS_SPORT_NAMES[["100"]], "Running")
  expect_equal(COROS_SPORT_NAMES[["102"]], "Trail Running")
  expect_equal(COROS_SPORT_NAMES[["200"]], "Road Bike")
})
