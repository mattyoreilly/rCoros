#' Fetch daily health and training metrics
#'
#' Returns a tidy tibble of per-day wellness metrics from the COROS
#' `/analyse/dayDetail/query` endpoint, including HRV, resting heart rate,
#' training load, VO2max, and stamina.
#'
#' @param auth      A `coros_auth` object from [coros_login()].
#' @param start_day Start of date range in `"YYYYMMDD"` format.  Defaults to
#'   28 days ago.
#' @param end_day   End of date range in `"YYYYMMDD"` format.  Defaults to
#'   today.
#'
#' @return A [tibble::tibble()] sorted by `date` with columns:
#'   \describe{
#'     \item{date}{Calendar date (`Date`).}
#'     \item{hrv}{Average overnight HRV (ms).}
#'     \item{hrv_baseline}{Personal HRV baseline (ms).}
#'     \item{rhr}{Resting heart rate (bpm).}
#'     \item{training_load}{Daily training load.}
#'     \item{load_ratio}{Training load ratio (acute:chronic).}
#'     \item{tired_rate}{Fatigue rate.}
#'     \item{ati}{Acute training impulse.}
#'     \item{cti}{Chronic training impulse.}
#'     \item{t7d}{7-day training load.}
#'     \item{t28d}{28-day training load.}
#'     \item{vo2max}{Estimated VO2max (mL/kg/min).}
#'     \item{lthr}{Lactate threshold heart rate (bpm).}
#'     \item{ltsp}{Lactate threshold speed.}
#'     \item{stamina}{Current stamina level.}
#'     \item{stamina_7d}{7-day stamina level.}
#'     \item{performance}{Performance score.}
#'     \item{tib}{Time in bed (minutes).}
#'   }
#'
#' @examplesIf interactive()
#' auth <- coros_login()
#'
#' # Last 28 days (default)
#' metrics <- coros_daily_metrics(auth)
#'
#' # Custom range
#' metrics <- coros_daily_metrics(auth, start_day = "20240101", end_day = "20240131")
#'
#' @export
coros_daily_metrics <- function(
    auth,
    start_day = format(Sys.Date() - 28, "%Y%m%d"),
    end_day   = format(Sys.Date(), "%Y%m%d")
) {
  body <- .req(auth, "/analyse/dayDetail/query") |>
    httr2::req_url_query(startDay = start_day, endDay = end_day) |>
    httr2::req_perform() |>
    httr2::resp_body_json(check_type = FALSE)

  .check(body, "dayDetail")

  body$data$dayList |>
    lapply(\(x) {
      tibble::tibble(
        date          = as.Date(as.character(x$happenDay), format = "%Y%m%d"),
        hrv           = x$avgSleepHrv %||% NA_real_,
        hrv_baseline  = x$sleepHrvBase %||% NA_real_,
        rhr           = x$rhr %||% NA_real_,
        training_load = x$trainingLoad %||% NA_real_,
        load_ratio    = x$trainingLoadRatio %||% NA_real_,
        tired_rate    = x$tiredRateNew %||% NA_real_,
        ati           = x$ati %||% NA_real_,
        cti           = x$cti %||% NA_real_,
        t7d           = x$t7d %||% NA_real_,
        t28d          = x$t28d %||% NA_real_,
        vo2max        = x$vo2max %||% NA_real_,
        lthr          = x$lthr %||% NA_real_,
        ltsp          = x$ltsp %||% NA_real_,
        stamina       = x$staminaLevel %||% NA_real_,
        stamina_7d    = x$staminaLevel7d %||% NA_real_,
        performance   = x$performance %||% NA_real_,
        tib           = x$tib %||% NA_real_
      )
    }) |>
    dplyr::bind_rows() |>
    dplyr::arrange(date)
}


#' Fetch recent HRV readings
#'
#' Retrieves the last ~7 days of overnight HRV data from the COROS dashboard
#' endpoint.
#'
#' @param auth A `coros_auth` object from [coros_login()].
#'
#' @return A [tibble::tibble()] sorted by `date` with columns:
#'   \describe{
#'     \item{date}{Calendar date (`Date`).}
#'     \item{hrv}{Average overnight HRV (ms).}
#'     \item{baseline}{Personal HRV baseline (ms).}
#'     \item{hrv_sd}{Standard deviation of overnight HRV (ms).}
#'   }
#'
#' @seealso [coros_daily_metrics()] for a longer historical HRV series.
#'
#' @examplesIf interactive()
#' auth <- coros_login()
#' coros_hrv(auth)
#'
#' @export
coros_hrv <- function(auth) {
  body <- .req(auth, "/dashboard/query") |>
    httr2::req_perform() |>
    httr2::resp_body_json(check_type = FALSE)

  .check(body, "hrv")

  hrv_data <- body$data$summaryInfo$sleepHrvData %||% list()

  records <- (hrv_data$sleepHrvList %||% list()) |>
    lapply(\(x) {
      tibble::tibble(
        date     = as.Date(as.character(x$happenDay %||% NA), format = "%Y%m%d"),
        hrv      = x$avgSleepHrv %||% NA_real_,
        baseline = x$sleepHrvBase %||% NA_real_,
        hrv_sd   = x$sleepHrvSd %||% NA_real_
      )
    }) |>
    dplyr::bind_rows()

  # Include today's reading if not already present in the list
  today_day <- hrv_data$happenDay
  if (!is.null(today_day)) {
    today_date <- as.Date(as.character(today_day), format = "%Y%m%d")
    if (!today_date %in% records$date) {
      records <- dplyr::bind_rows(
        records,
        tibble::tibble(
          date     = today_date,
          hrv      = hrv_data$avgSleepHrv %||% NA_real_,
          baseline = hrv_data$sleepHrvBase %||% NA_real_,
          hrv_sd   = hrv_data$sleepHrvSd %||% NA_real_
        )
      )
    }
  }

  dplyr::arrange(records, date)
}
