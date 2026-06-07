#' List structured workout programs
#'
#' Retrieves all workout programs stored in the COROS Training Hub, returning
#' a list of two tidy tibbles: a summary of each workout and its constituent
#' steps.
#'
#' @param auth A `coros_auth` object from [coros_login()].
#'
#' @return A named list with two tibbles:
#'   \describe{
#'     \item{`workouts`}{One row per workout with columns `id`, `name`,
#'       `sport_type`, `sport_name`, `duration_min`, and `n_steps`.}
#'     \item{`steps`}{One row per step, linked to `workouts` via `workout_id`,
#'       with columns `step_name`, `duration_s`, `duration_min`,
#'       `power_low_w`, `power_high_w`, and `sets`.}
#'   }
#'
#' @examplesIf interactive()
#' auth <- coros_login()
#' result <- coros_workouts(auth)
#' result$workouts
#' result$steps
#'
#' @export
coros_workouts <- function(auth) {
  body <- .req(auth, "/training/program/query") |>
    httr2::req_body_json(list()) |>
    httr2::req_perform() |>
    httr2::resp_body_json(check_type = FALSE)

  .check(body, "workouts")

  workout_sport_names <- c(
    "2"   = "Indoor Cycling",
    "4"   = "Strength",
    "100" = "Running",
    "200" = "Road Bike"
  )

  items <- body$data %||% list()

  workouts <- items |>
    lapply(\(w) {
      sport <- as.character(w$sportType %||% NA)
      tibble::tibble(
        id           = as.character(w$id %||% NA),
        name         = w$name %||% NA_character_,
        sport_type   = w$sportType %||% NA_integer_,
        sport_name   = .sport_lookup(sport, workout_sport_names),
        duration_min = (w$estimatedTime %||% NA_real_) / 60,
        n_steps      = w$exerciseNum %||% NA_integer_
      )
    }) |>
    dplyr::bind_rows()

  steps <- items |>
    lapply(\(w) {
      wid <- as.character(w$id %||% NA)
      (w$exercises %||% list()) |>
        lapply(\(e) {
          tibble::tibble(
            workout_id    = wid,
            step_name     = e$name %||% NA_character_,
            duration_s    = e$targetValue %||% NA_real_,
            duration_min  = (e$targetValue %||% NA_real_) / 60,
            power_low_w   = e$intensityValue %||% NA_real_,
            power_high_w  = e$intensityValueExtend %||% NA_real_,
            sets          = e$sets %||% 1L
          )
        }) |>
        dplyr::bind_rows()
    }) |>
    dplyr::bind_rows()

  list(workouts = workouts, steps = steps)
}


#' Fetch the training calendar
#'
#' Returns a tibble of planned activities from the COROS training schedule
#' within the given date window.
#'
#' @param auth      A `coros_auth` object from [coros_login()].
#' @param start_day Start of the window in `"YYYYMMDD"` format.  Defaults to
#'   today.
#' @param end_day   End of the window in `"YYYYMMDD"` format.  Defaults to
#'   14 days from today.
#'
#' @return A [tibble::tibble()] with one row per scheduled item and columns:
#'   \describe{
#'     \item{plan_id}{Training plan identifier.}
#'     \item{id_in_plan}{Item position within the plan.}
#'     \item{plan_program_id}{Associated workout program identifier.}
#'     \item{happen_day}{Scheduled date (`Date`).}
#'     \item{name}{Workout name.}
#'     \item{sport_type}{Numeric sport type code.}
#'     \item{sport_name}{Human-readable sport name.}
#'     \item{estimated_min}{Estimated duration in minutes.}
#'     \item{completed}{Logical; `TRUE` if the workout has been completed.}
#'   }
#'
#' @examplesIf interactive()
#' auth <- coros_login()
#'
#' # Upcoming two weeks
#' schedule <- coros_schedule(auth)
#'
#' # Narrower window
#' schedule <- coros_schedule(
#'   auth,
#'   start_day = format(Sys.Date(), "%Y%m%d"),
#'   end_day   = format(Sys.Date() + 7, "%Y%m%d")
#' )
#'
#' @export
coros_schedule <- function(
    auth,
    start_day = format(Sys.Date(), "%Y%m%d"),
    end_day   = format(Sys.Date() + 14, "%Y%m%d")
) {
  body <- .req(auth, "/training/schedule/query") |>
    httr2::req_url_query(
      startDate            = start_day,
      endDate              = end_day,
      supportRestExercise  = 1L
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json(check_type = FALSE)

  .check(body, "schedule")

  (body$data$entities %||% list()) |>
    lapply(\(e) {
      tibble::tibble(
        plan_id         = as.character(e$planId %||% NA),
        id_in_plan      = as.character(e$idInPlan %||% NA),
        plan_program_id = as.character(e$planProgramId %||% NA),
        happen_day      = as.Date(as.character(e$happenDay %||% NA), format = "%Y%m%d"),
        name            = e$name %||% NA_character_,
        sport_type      = e$sportType %||% NA_integer_,
        sport_name      = .sport_lookup(as.character(e$sportType %||% NA), COROS_SPORT_NAMES),
        estimated_min   = (e$estimatedTime %||% NA_real_) / 60,
        completed       = isTRUE(e$completed)
      )
    }) |>
    dplyr::bind_rows()
}
