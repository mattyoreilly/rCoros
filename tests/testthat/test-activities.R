test_that("coros_activities returns a tibble with expected columns", {
  skip_on_old_curl()
  mock_resp <- httr2::response_json(
    body = list(
      result = "0000",
      data   = list(
        dataList = list(
          list(
            labelId      = "111",
            name         = "Morning Run",
            sportType    = 100L,
            date         = 20260101L,
            startTime    = 1735725600,
            totalTime    = 3600,
            distance     = 10000,
            ascent       = 5000,    # cm -> 50 m
            avgHr        = 148,
            calorie      = 2500000, # /1000 -> 2500 kcal
            trainingLoad = 85,
            avgPower     = NULL,
            device       = "VERTIX 2S"
          )
        )
      )
    )
  )

  result <- httr2::with_mocked_responses(list(mock_resp), coros_activities(fake_auth))

  expect_s3_class(result, "tbl_df")
  expect_named(result, c(
    "activity_id", "name", "sport_type", "sport_name", "date",
    "start_time", "duration_s", "duration_min", "distance_m",
    "distance_km", "elevation_gain", "avg_hr", "calories",
    "training_load", "avg_power", "device"
  ))
  expect_equal(nrow(result), 1L)
  expect_equal(result$activity_id,    "111")
  expect_equal(result$sport_name,     "Running")
  expect_equal(result$distance_km,    10)
  expect_equal(result$elevation_gain, 50)   # cm -> m
  expect_equal(result$calories,       2500) # /1000
  expect_s3_class(result$date,        "Date")
  expect_s3_class(result$start_time,  "POSIXct")
})

test_that("coros_activities handles missing optional fields gracefully", {
  skip_on_old_curl()
  mock_resp <- httr2::response_json(
    body = list(
      result = "0000",
      data   = list(
        dataList = list(
          list(labelId = "222", sportType = 900L, date = 20260102L)
        )
      )
    )
  )

  result <- httr2::with_mocked_responses(list(mock_resp), coros_activities(fake_auth))

  expect_equal(nrow(result), 1L)
  expect_true(is.na(result$avg_hr))
  expect_true(is.na(result$distance_m))
  expect_equal(result$sport_name, "Walking")
})

test_that("coros_activities stops on API error", {
  skip_on_old_curl()
  mock_resp <- httr2::response_json(
    body = list(result = "1001", message = "Session expired")
  )

  expect_error(
    httr2::with_mocked_responses(list(mock_resp), coros_activities(fake_auth)),
    "activity list error: Session expired"
  )
})

test_that("coros_activity_detail returns summary, laps, and hr_zones", {
  mock_resp <- httr2::response_json(
    body = list(
      result = "0000",
      data   = list(
        summary    = list(
          name            = "Trail Run",
          sportType       = 102L,
          startTimestamp  = 1735725600,
          endTimestamp    = 1735729200,
          totalTime       = 3600,
          distance        = 12000,
          elevGain        = 80000,  # cm -> 800 m
          totalDescent    = 75000,
          avgHr           = 155,
          maxHr           = 178,
          avgPower        = NULL,
          maxPower        = NULL,
          avgCadence      = 172,
          avgSpeed        = 360,
          calories        = 1800000,
          trainingLoad    = 112,
          aerobicEffect   = 3.8,
          currentVo2Max   = 54
        ),
        deviceList = list(list(name = "VERTIX 2S")),
        zoneList   = list(
          list(
            zoneType     = 3L,
            zoneItemList = list(
              list(zoneIndex = 0L, leftScope = 100, rightScope = 135, second = 600,  percent = 10),
              list(zoneIndex = 1L, leftScope = 135, rightScope = 152, second = 1200, percent = 25),
              list(zoneIndex = 2L, leftScope = 152, rightScope = 162, second = 1500, percent = 40),
              list(zoneIndex = 3L, leftScope = 162, rightScope = 170, second = 600,  percent = 20),
              list(zoneIndex = 4L, leftScope = 170, rightScope = 220, second = 300,  percent = 5)
            )
          )
        ),
        lapList = list(
          list(
            type        = -1L,
            lapItemList = list(
              list(
                lapIndex       = 0L,
                startTimestamp = 173572560000,
                endTimestamp   = 173572920000,
                time           = 3600000,
                distance       = 12000000,
                elevGain       = 80000,
                totalDescent   = 75000,
                avgHr          = 155,
                maxHr          = 178,
                avgPower       = NULL,
                avgCadence     = 172,
                avgPace        = 360,
                avgGrade       = 70
              )
            )
          )
        )
      )
    )
  )

  result <- httr2::with_mocked_responses(
    list(mock_resp),
    coros_activity_detail(fake_auth, "999", sport_type = 102L)
  )

  # Structure
  expect_named(result, c("summary", "laps", "hr_zones"))

  # Summary
  s <- result$summary
  expect_equal(nrow(s), 1L)
  expect_equal(s$distance_km,    12)
  expect_equal(s$elevation_gain, 800)  # cm -> m
  expect_equal(s$calories,       1800) # /1000
  expect_equal(s$device,         "VERTIX 2S")

  # HR zones
  hz <- result$hr_zones
  expect_equal(nrow(hz), 5L)
  expect_equal(hz$zone, 1:5)
  expect_equal(sum(hz$percent), 100)

  # Laps
  laps <- result$laps
  expect_equal(nrow(laps), 1L)
  expect_equal(laps$distance_km,  12)    # mm -> km
  expect_equal(laps$avg_grade,    7)     # tenths -> %
  expect_equal(laps$duration_s,   3600)
})
