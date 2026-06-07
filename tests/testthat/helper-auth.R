# Shared test fixture: a fake auth object that avoids real HTTP calls.
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
