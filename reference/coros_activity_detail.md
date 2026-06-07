# Fetch detailed metrics for a single activity

Returns a list of three tibbles — a one-row summary, per-lap splits, and
time-in-zone heart rate data — for the given activity.

## Usage

``` r
coros_activity_detail(auth, activity_id, sport_type)
```

## Arguments

- auth:

  A `coros_auth` object from
  [`coros_login()`](https://mattyoreilly.github.io/rCoros/reference/coros_login.md).

- activity_id:

  Activity identifier (from
  [`coros_activities()`](https://mattyoreilly.github.io/rCoros/reference/coros_activities.md)
  `activity_id` column).

- sport_type:

  Numeric sport type code (from
  [`coros_activities()`](https://mattyoreilly.github.io/rCoros/reference/coros_activities.md)
  `sport_type` column).

## Value

A named list with three tibbles:

- `summary`:

  One-row tibble with overall activity metrics.

- `laps`:

  One row per lap with splits.

- `hr_zones`:

  Heart-rate zone breakdown (seconds and percent).

## Examples

``` r
if (FALSE) { # interactive()
auth <- coros_login()
acts <- coros_activities(auth)

# Detail for the most recent activity
detail <- coros_activity_detail(
  auth,
  activity_id = acts$activity_id[[1]],
  sport_type  = acts$sport_type[[1]]
)
detail$summary
detail$laps
detail$hr_zones
}
```
