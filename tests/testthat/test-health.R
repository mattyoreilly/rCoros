test_that("coros_daily_metrics returns a sorted tibble with expected columns", {
  skip_on_old_curl()
  mock_resp <- httr2::response_json(
    body = list(
      result = "0000",
      data   = list(
        dayList = list(
          list(
            happenDay        = 20260103L,
            avgSleepHrv      = 62.4,
            sleepHrvBase     = 58.1,
            rhr              = 42,
            trainingLoad     = 88,
            trainingLoadRatio = 1.1,
            tiredRateNew     = 0.3,
            ati              = 72,
            cti              = 65,
            t7d              = 420,
            t28d             = 1650,
            vo2max           = 56,
            lthr             = 162,
            ltsp             = NULL,
            staminaLevel     = 72,
            staminaLevel7d   = 68,
            performance      = 78,
            tib              = 450
          ),
          list(
            happenDay    = 20260101L,
            avgSleepHrv  = 58.0,
            rhr          = 44
          )
        )
      )
    )
  )

  result <- httr2::with_mocked_responses(list(mock_resp), coros_daily_metrics(fake_auth))

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2L)

  # Sorted ascending by date
  expect_true(result$date[[1]] < result$date[[2]])

  # First row (older date) has NAs for fields not in API response
  expect_true(is.na(result$training_load[[1]]))

  # Second row has full data
  expect_equal(result$hrv[[2]],          62.4)
  expect_equal(result$hrv_baseline[[2]], 58.1)
  expect_equal(result$rhr[[2]],          42)
  expect_equal(result$vo2max[[2]],       56)
  expect_true(is.na(result$ltsp[[2]]))
})

test_that("coros_daily_metrics stops on API error", {
  skip_on_old_curl()
  mock_resp <- httr2::response_json(
    body = list(result = "4001", message = "Date range too large")
  )

  expect_error(
    httr2::with_mocked_responses(list(mock_resp), coros_daily_metrics(fake_auth)),
    "dayDetail error"
  )
})

test_that("coros_hrv returns a sorted tibble of HRV readings", {
  mock_resp <- httr2::response_json(
    body = list(
      result = "0000",
      data   = list(
        summaryInfo = list(
          sleepHrvData = list(
            happenDay    = 20260105L,
            avgSleepHrv  = 64.2,
            sleepHrvBase = 60.0,
            sleepHrvSd   = 4.1,
            sleepHrvList = list(
              list(happenDay = 20260103L, avgSleepHrv = 61.0, sleepHrvBase = 59.5, sleepHrvSd = 3.8),
              list(happenDay = 20260104L, avgSleepHrv = 63.5, sleepHrvBase = 59.8, sleepHrvSd = 4.0)
            )
          )
        )
      )
    )
  )

  result <- httr2::with_mocked_responses(list(mock_resp), coros_hrv(fake_auth))

  # 2 historical + today = 3 rows
  expect_equal(nrow(result), 3L)
  expect_s3_class(result$date, "Date")

  # Sorted ascending
  expect_true(all(diff(as.integer(result$date)) > 0))

  # Today's row appended correctly
  today_row <- result[result$date == as.Date("2026-01-05"), ]
  expect_equal(today_row$hrv,      64.2)
  expect_equal(today_row$baseline, 60.0)
})

test_that("coros_hrv does not duplicate today if already in list", {
  mock_resp <- httr2::response_json(
    body = list(
      result = "0000",
      data   = list(
        summaryInfo = list(
          sleepHrvData = list(
            happenDay    = 20260103L,  # same date as in the list
            avgSleepHrv  = 61.0,
            sleepHrvBase = 59.5,
            sleepHrvSd   = 3.8,
            sleepHrvList = list(
              list(happenDay = 20260103L, avgSleepHrv = 61.0, sleepHrvBase = 59.5, sleepHrvSd = 3.8)
            )
          )
        )
      )
    )
  )

  result <- httr2::with_mocked_responses(list(mock_resp), coros_hrv(fake_auth))

  # Should not be duplicated
  expect_equal(nrow(result), 1L)
})
