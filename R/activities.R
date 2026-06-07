#' List activities
#'
#' Returns a tidy tibble of activities recorded within a date range, one row
#' per activity.
#'
#' @param auth      A `coros_auth` object from [coros_login()].
#' @param start_day Start of date range in `"YYYYMMDD"` format.  Defaults to
#'   30 days ago.
#' @param end_day   End of date range in `"YYYYMMDD"` format.  Defaults to
#'   today.
#' @param page      Page number for paginated results (default `1L`).
#' @param size      Number of results per page (default `30L`).
#' @param n_max     Maximum total activities to return.  Set to `Inf` to fetch
#'   all pages automatically (default `Inf`).
#'
#' @return A [tibble::tibble()] with columns:
#'   \describe{
#'     \item{activity_id}{Unique activity identifier (character).}
#'     \item{name}{Activity name or remark.}
#'     \item{sport_type}{Numeric sport type code.}
#'     \item{sport_name}{Human-readable sport name.}
#'     \item{date}{Date of activity (`Date`).}
#'     \item{start_time}{Start timestamp (`POSIXct`, UTC).}
#'     \item{duration_s}{Duration in seconds.}
#'     \item{duration_min}{Duration in minutes.}
#'     \item{distance_m}{Distance in metres.}
#'     \item{distance_km}{Distance in kilometres.}
#'     \item{elevation_gain}{Elevation gain in metres.}
#'     \item{avg_hr}{Average heart rate (bpm).}
#'     \item{calories}{Calories (kcal).}
#'     \item{training_load}{Training load score.}
#'     \item{avg_power}{Average power (watts).}
#'     \item{device}{Device name.}
#'   }
#'
#' @examplesIf interactive()
#' auth <- coros_login()
#'
#' # All activities in the last 30 days
#' acts <- coros_activities(auth)
#'
#' # Running and trail-running only
#' library(dplyr)
#' runs <- coros_activities(auth) |>
#'   filter(sport_type %in% c(100L, 102L))
#'
#' @export
coros_activities <- function(
    auth,
    start_day = format(Sys.Date() - 30, "%Y%m%d"),
    end_day   = format(Sys.Date(), "%Y%m%d"),
    page      = 1L,
    size      = 30L,
    n_max     = Inf
) {
  fetch_page <- function(p) {
    body <- .req(auth, "/activity/query") |>
      httr2::req_url_query(
        startDay   = start_day,
        endDay     = end_day,
        pageNumber = p,
        size       = size
      ) |>
      httr2::req_perform() |>
      httr2::resp_body_json(check_type = FALSE)

    .check(body, "activity list")
    body$data$dataList %||% body$data$list %||% list()
  }

  items <- fetch_page(page)

  # Auto-paginate if caller wants more than one page's worth
  if (is.infinite(n_max) && length(items) == size) {
    p <- page + 1L
    repeat {
      new_items <- fetch_page(p)
      items <- c(items, new_items)
      if (length(new_items) < size) break
      p <- p + 1L
    }
  }

  items |>
    lapply(\(x) {
      sport <- as.character(x$sportType %||% NA)
      tibble::tibble(
        activity_id    = as.character(x$labelId %||% NA),
        name           = x$name %||% x$remark %||% NA_character_,
        sport_type     = x$sportType %||% NA_integer_,
        sport_name     = .sport_lookup(sport, COROS_SPORT_NAMES),
        date           = as.Date(as.character(x$date %||% NA), format = "%Y%m%d"),
        start_time     = as.POSIXct(x$startTime %||% NA_real_, origin = "1970-01-01", tz = "UTC"),
        duration_s     = x$totalTime %||% NA_real_,
        duration_min   = (x$totalTime %||% NA_real_) / 60,
        distance_m     = x$distance %||% NA_real_,
        distance_km    = (x$distance %||% NA_real_) / 1000,
        elevation_gain = (x$ascent %||% NA_real_) / 100,  # cm -> m
        avg_hr         = x$avgHr %||% NA_real_,
        calories       = (x$calorie %||% NA_real_) / 1000,
        training_load  = x$trainingLoad %||% NA_real_,
        avg_power      = x$avgPower %||% NA_real_,
        device         = x$device %||% NA_character_
      )
    }) |>
    dplyr::bind_rows() |>
    dplyr::arrange(dplyr::desc(date))
}


#' Fetch detailed metrics for a single activity
#'
#' Returns a list of three tibbles — a one-row summary, per-lap splits, and
#' time-in-zone heart rate data — for the given activity.
#'
#' @param auth        A `coros_auth` object from [coros_login()].
#' @param activity_id Activity identifier (from [coros_activities()]
#'   `activity_id` column).
#' @param sport_type  Numeric sport type code (from [coros_activities()]
#'   `sport_type` column).
#'
#' @return A named list with three tibbles:
#'   \describe{
#'     \item{`summary`}{One-row tibble with overall activity metrics.}
#'     \item{`laps`}{One row per lap with splits.}
#'     \item{`hr_zones`}{Heart-rate zone breakdown (seconds and percent).}
#'   }
#'
#' @examplesIf interactive()
#' auth <- coros_login()
#' acts <- coros_activities(auth)
#'
#' # Detail for the most recent activity
#' detail <- coros_activity_detail(
#'   auth,
#'   activity_id = acts$activity_id[[1]],
#'   sport_type  = acts$sport_type[[1]]
#' )
#' detail$summary
#' detail$laps
#' detail$hr_zones
#'
#' @export
coros_activity_detail <- function(auth, activity_id, sport_type) {
  resp <- .req(auth, "/activity/detail/query") |>
    httr2::req_body_form(
      labelId   = as.character(activity_id),
      userId    = as.character(auth$user_id),
      sportType = as.character(sport_type)
    ) |>
    httr2::req_perform()

  data <- httr2::resp_body_json(resp, simplifyVector = FALSE, check_type = FALSE)

  .check(data, "activity_detail")
  d <- data$data
  s <- d$summary

  # --- Summary tibble ---
  summary <- tibble::tibble(
    activity_id    = as.character(activity_id),
    name           = s$name %||% NA_character_,
    sport_type     = s$sportType %||% NA_integer_,
    start_time     = as.POSIXct(s$startTimestamp %||% NA_real_, origin = "1970-01-01", tz = "UTC"),
    end_time       = as.POSIXct(s$endTimestamp %||% NA_real_,   origin = "1970-01-01", tz = "UTC"),
    duration_s     = s$totalTime %||% NA_real_,
    duration_min   = (s$totalTime %||% NA_real_) / 60,
    distance_m     = s$distance %||% NA_real_,
    distance_km    = (s$distance %||% NA_real_) / 1000,
    elevation_gain = (s$elevGain %||% NA_real_) / 100,      # cm -> m
    elevation_loss = (s$totalDescent %||% NA_real_) / 100,
    avg_hr         = s$avgHr %||% NA_real_,
    max_hr         = s$maxHr %||% NA_real_,
    avg_power      = s$avgPower %||% NA_real_,
    max_power      = s$maxPower %||% NA_real_,
    avg_cadence    = s$avgCadence %||% NA_real_,
    avg_pace_s_km  = s$avgSpeed %||% NA_real_,
    calories       = (s$calories %||% NA_real_) / 1000,
    training_load  = s$trainingLoad %||% NA_real_,
    aerobic_effect = s$aerobicEffect %||% NA_real_,
    vo2max         = s$currentVo2Max %||% NA_real_,
    device         = d$deviceList[[1]]$name %||% NA_character_
  )

  # --- HR zones tibble (zoneType 3 = heart rate) ---
  hr_zones <- (d$zoneList %||% list()) |>
    lapply(\(z) {
      if ((z$zoneType %||% 0L) != 3L) return(NULL)
      (z$zoneItemList %||% list()) |>
        lapply(\(zi) {
          tibble::tibble(
            zone    = zi$zoneIndex + 1L,
            hr_low  = zi$leftScope %||% NA_real_,
            hr_high = zi$rightScope %||% NA_real_,
            seconds = zi$second %||% NA_real_,
            minutes = (zi$second %||% NA_real_) / 60,
            percent = zi$percent %||% NA_real_
          )
        }) |>
        dplyr::bind_rows()
    }) |>
    purrr::compact() |>
    dplyr::bind_rows()

  # --- Laps tibble (lapList type -1 = clean user laps) ---
  laps <- (d$lapList %||% list()) |>
    lapply(\(lap) {
      if ((lap$type %||% 0L) != -1L) return(NULL)
      (lap$lapItemList %||% list()) |>
        lapply(\(l) {
          tibble::tibble(
            lap_index      = l$lapIndex %||% NA_integer_,
            start_time     = as.POSIXct((l$startTimestamp %||% NA_real_) / 100, origin = "1970-01-01", tz = "UTC"),
            end_time       = as.POSIXct((l$endTimestamp   %||% NA_real_) / 100, origin = "1970-01-01", tz = "UTC"),
            duration_s     = (l$time %||% NA_real_) / 1000,
            duration_min   = (l$time %||% NA_real_) / 60000,
            distance_km    = (l$distance %||% NA_real_) / 1e6,  # mm -> km
            elevation_gain = (l$elevGain %||% NA_real_) / 100,
            elevation_loss = (l$totalDescent %||% NA_real_) / 100,
            avg_hr         = l$avgHr %||% NA_real_,
            max_hr         = l$maxHr %||% NA_real_,
            avg_power      = l$avgPower %||% NA_real_,
            avg_cadence    = l$avgCadence %||% NA_real_,
            avg_pace_s_km  = l$avgPace %||% NA_real_,
            avg_grade      = (l$avgGrade %||% NA_real_) / 10  # tenths -> %
          )
        }) |>
        dplyr::bind_rows()
    }) |>
    purrr::compact() |>
    dplyr::bind_rows()

  list(summary = summary, laps = laps, hr_zones = hr_zones)
}
