test_that("coros_workouts returns workouts and steps tibbles", {
  mock_resp <- httr2::response_json(
    body = list(
      result = "0000",
      data   = list(
        list(
          id            = "w1",
          name          = "Threshold Intervals",
          sportType     = 100L,
          estimatedTime = 3600,
          exerciseNum   = 3L,
          exercises     = list(
            list(
              name                 = "Warm-up",
              targetValue          = 600,
              intensityValue       = 180,
              intensityValueExtend = 220,
              sets                 = 1L
            ),
            list(
              name                 = "5 x 1km @ threshold",
              targetValue          = 2400,
              intensityValue       = 280,
              intensityValueExtend = 320,
              sets                 = 5L
            ),
            list(
              name                 = "Cool-down",
              targetValue          = 600,
              intensityValue       = 150,
              intensityValueExtend = 180,
              sets                 = 1L
            )
          )
        )
      )
    )
  )

  result <- httr2::with_mocked_responses(list(mock_resp), coros_workouts(fake_auth))

  expect_named(result, c("workouts", "steps"))

  # Workouts tibble
  w <- result$workouts
  expect_equal(nrow(w), 1L)
  expect_equal(w$name,         "Threshold Intervals")
  expect_equal(w$sport_name,   "Running")
  expect_equal(w$duration_min, 60)
  expect_equal(w$n_steps,      3L)

  # Steps tibble
  s <- result$steps
  expect_equal(nrow(s), 3L)
  expect_true(all(s$workout_id == "w1"))
  expect_equal(s$step_name[[2]],    "5 x 1km @ threshold")
  expect_equal(s$sets[[2]],         5L)
  expect_equal(s$power_low_w[[2]],  280)
})

test_that("coros_schedule returns a tibble of planned items", {
  skip_on_old_curl()
  mock_resp <- httr2::response_json(
    body = list(
      result = "0000",
      data   = list(
        entities = list(
          list(
            planId         = "p1",
            idInPlan       = "1",
            planProgramId  = "pp1",
            happenDay      = 20260110L,
            name           = "Long Run",
            sportType      = 100L,
            estimatedTime  = 5400,
            completed      = FALSE
          ),
          list(
            planId         = "p1",
            idInPlan       = "2",
            planProgramId  = "pp2",
            happenDay      = 20260112L,
            name           = "Recovery Run",
            sportType      = 100L,
            estimatedTime  = 2400,
            completed      = TRUE
          )
        )
      )
    )
  )

  result <- httr2::with_mocked_responses(list(mock_resp), coros_schedule(fake_auth))

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2L)
  expect_s3_class(result$happen_day, "Date")
  expect_equal(result$name[[1]],          "Long Run")
  expect_equal(result$sport_name[[1]],    "Running")
  expect_equal(result$estimated_min[[1]], 90)
  expect_false(result$completed[[1]])
  expect_true(result$completed[[2]])
})

test_that("coros_schedule returns zero-row tibble when no entities", {
  skip_on_old_curl()
  mock_resp <- httr2::response_json(
    body = list(result = "0000", data = list(entities = list()))
  )

  result <- httr2::with_mocked_responses(list(mock_resp), coros_schedule(fake_auth))

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0L)
})
