# Shared test fixture: a fake auth object that avoids real HTTP calls.

# Skip guard for tests that call req_url_query().
# httr2 >= 1.1.0 delegates URL parsing to curl::curl_parse_url(), which was
# added in curl 5.2.3.  R-devel on Windows may have a newer httr2 paired with
# an older curl, causing those tests to error with
# "'curl_parse_url' is not an exported object from 'namespace:curl'".
skip_on_old_curl <- function() {
  testthat::skip_if(
    !exists("curl_parse_url", envir = asNamespace("curl"), inherits = FALSE),
    "Skipping: curl version does not export curl_parse_url (httr2/curl mismatch)"
  )
}

fake_auth <- structure(
  list(
    access_token = "test-token",
    user_id      = "99999",
    base_url     = "https://teamapi.coros.com",
    region       = "us",
    timestamp    = as.POSIXct("2026-01-01", tz = "UTC")
  ),
  class = "coros_auth"
)
