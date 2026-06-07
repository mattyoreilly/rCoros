test_that("coros_login errors when COROS_EMAIL is unset", {
  withr::with_envvar(c(COROS_EMAIL = "", COROS_PASSWORD = "pw"), {
    expect_error(coros_login(), "No COROS email")
  })
})

test_that("coros_login errors when COROS_PASSWORD is unset", {
  withr::with_envvar(c(COROS_EMAIL = "x@x.com", COROS_PASSWORD = ""), {
    expect_error(coros_login(), "No COROS password")
  })
})

test_that("coros_login rejects unknown regions", {
  expect_error(
    coros_login(email = "x@x.com", password = "pw", region = "asia"),
    "'arg' should be one of"
  )
})

test_that("coros_login returns a coros_auth object on success", {
  mock_resp <- httr2::response_json(
    body = list(
      result  = "0000",
      data    = list(accessToken = "tok123", userId = "uid456")
    )
  )

  withr::with_envvar(c(COROS_EMAIL = "x@x.com", COROS_PASSWORD = "secret"), {
    auth <- httr2::with_mocked_responses(list(mock_resp), coros_login())
  })

  expect_s3_class(auth, "coros_auth")
  expect_equal(auth$access_token, "tok123")
  expect_equal(auth$user_id,      "uid456")
  expect_equal(auth$region,       "us")
})

test_that("coros_login points to EU base URL when region = 'eu'", {
  mock_resp <- httr2::response_json(
    body = list(
      result = "0000",
      data   = list(accessToken = "t", userId = "u")
    )
  )

  withr::with_envvar(c(COROS_EMAIL = "x@x.com", COROS_PASSWORD = "pw"), {
    auth <- httr2::with_mocked_responses(list(mock_resp), coros_login(region = "eu"))
  })

  expect_equal(auth$region,   "eu")
  expect_match(auth$base_url, "euapi")
})

test_that("coros_login stops with an informative error on API failure", {
  mock_resp <- httr2::response_json(
    body = list(result = "1001", message = "Account not found")
  )

  withr::with_envvar(c(COROS_EMAIL = "x@x.com", COROS_PASSWORD = "pw"), {
    expect_error(
      httr2::with_mocked_responses(list(mock_resp), coros_login()),
      "COROS login failed"
    )
  })
})

test_that("print.coros_auth produces readable output", {
  auth <- structure(
    list(
      access_token = "tok",
      user_id      = "123",
      base_url     = "https://teamapi.coros.com",
      region       = "us",
      timestamp    = as.POSIXct("2026-01-01 08:00:00", tz = "UTC")
    ),
    class = "coros_auth"
  )
  expect_output(print(auth), "coros_auth")
  expect_output(print(auth), "us")
  expect_output(print(auth), "123")
})
