# Internal helpers — not exported
#
# `%||%`          NULL / zero-length coalescing
# .req()          Build an authenticated httr2 request
# .check()        Assert a successful Coros API result code
# COROS_SPORT_NAMES  Named character vector of sport type codes

# ---------------------------------------------------------------------------
# NULL-coalescing operator
# Returns y if x is NULL or has length 0, otherwise x.
# ---------------------------------------------------------------------------
`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L) y else x

# ---------------------------------------------------------------------------
# Build an authenticated GET request
# ---------------------------------------------------------------------------
.req <- function(auth, path) {
  httr2::request(paste0(auth$base_url, path)) |>
    httr2::req_headers(
      accessToken = auth$access_token,
      yfheader    = paste0('{"userId":"', auth$user_id, '"}'),
      `User-Agent` = "Mozilla/5.0"
    ) |>
    httr2::req_error(is_error = \(r) FALSE)
}

# ---------------------------------------------------------------------------
# Assert a successful result code ("0000") from a parsed JSON body
# ---------------------------------------------------------------------------
.check <- function(body, context) {
  if (!identical(body$result, "0000")) {
    stop(context, " error: ", body$message %||% "unknown", call. = FALSE)
  }
  invisible(body)
}

# ---------------------------------------------------------------------------
# Safe sport-type lookup
#
# Uses single-bracket [ (not [[) so an unknown code returns NA rather than
# throwing "subscript out of bounds" (the [[]] error on named vectors).
# ---------------------------------------------------------------------------
.sport_lookup <- function(code, table) {
  if (is.na(code)) return(NA_character_)
  nm <- unname(table[as.character(code)])
  if (is.na(nm)) paste("Sport", code) else nm
}

# ---------------------------------------------------------------------------
# Sport type lookup table
# ---------------------------------------------------------------------------
COROS_SPORT_NAMES <- c(
  "100" = "Running",
  "102" = "Trail Running",
  "103" = "Track",
  "104" = "Hiking",
  "200" = "Road Bike",
  "201" = "Indoor Cycling",
  "203" = "Gravel",
  "204" = "MTB",
  "400" = "Cardio",
  "402" = "Strength",
  "900" = "Walking"
)
