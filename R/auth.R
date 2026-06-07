#' Authenticate with the COROS Training Hub API
#'
#' Logs in with an email/password pair and returns an auth object that must be
#' passed to every other `coros_*` function.  Credentials are read from
#' environment variables by default so they are never hard-coded in scripts.
#'
#' Set credentials once per session with:
#' ```r
#' Sys.setenv(COROS_EMAIL = "you@example.com", COROS_PASSWORD = "secret")
#' ```
#' or add them to your `~/.Renviron` file for persistence.
#'
#' @param email    COROS account e-mail.  Defaults to the `COROS_EMAIL`
#'   environment variable.
#' @param password COROS account password.  Defaults to `COROS_PASSWORD`.
#' @param region   API region: `"us"` (default) or `"eu"`.
#'
#' @return A named list with fields `access_token`, `user_id`, `base_url`,
#'   `region`, and `timestamp`.  Treat this object as opaque and pass it
#'   directly to other `coros_*` functions.
#'
#' @examplesIf interactive()
#' auth <- coros_login()  # reads COROS_EMAIL / COROS_PASSWORD from env
#'
#' # EU region
#' auth_eu <- coros_login(region = "eu")
#'
#' @export
coros_login <- function(
    email    = Sys.getenv("COROS_EMAIL"),
    password = Sys.getenv("COROS_PASSWORD"),
    region   = c("us", "eu")
) {
  region <- match.arg(region)

  if (!nzchar(email))    stop("No COROS email supplied. Set COROS_EMAIL.", call. = FALSE)
  if (!nzchar(password)) stop("No COROS password supplied. Set COROS_PASSWORD.", call. = FALSE)

  base_url <- switch(
    region,
    us = "https://teamapi.coros.com",
    eu = "https://teameuapi.coros.com"
  )

  pwd_hash <- digest::digest(password, algo = "md5", serialize = FALSE)

  body <- httr2::request(paste0(base_url, "/account/login")) |>
    httr2::req_headers(`User-Agent` = "Mozilla/5.0") |>
    httr2::req_body_json(list(
      account     = email,
      accountType = 2L,
      pwd         = pwd_hash
    )) |>
    httr2::req_error(is_error = \(r) FALSE) |>
    httr2::req_perform() |>
    httr2::resp_body_json(check_type = FALSE)

  if (!identical(body$result, "0000")) {
    stop("COROS login failed: ", body$message %||% "unknown error", call. = FALSE)
  }

  structure(
    list(
      access_token = body$data$accessToken,
      user_id      = body$data$userId,
      base_url     = base_url,
      region       = region,
      timestamp    = Sys.time()
    ),
    class = "coros_auth"
  )
}

#' @export
print.coros_auth <- function(x, ...) {
  cat(
    "<coros_auth>\n",
    "  region:    ", x$region, "\n",
    "  user_id:   ", x$user_id, "\n",
    "  logged in: ", format(x$timestamp, "%Y-%m-%d %H:%M:%S"), "\n",
    sep = ""
  )
  invisible(x)
}
