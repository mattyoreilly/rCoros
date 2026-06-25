# Changelog

## rCoros 0.1.0

CRAN release: 2026-06-24

- Initial release.
- [`coros_login()`](https://mattyoreilly.github.io/rCoros/reference/coros_login.md)
  authenticates with the COROS Training Hub API (US and EU regions).
- [`coros_activities()`](https://mattyoreilly.github.io/rCoros/reference/coros_activities.md)
  lists activities with automatic pagination via `n_max = Inf`.
- [`coros_activity_detail()`](https://mattyoreilly.github.io/rCoros/reference/coros_activity_detail.md)
  returns per-activity summary, lap splits, and HR zones.
- [`coros_daily_metrics()`](https://mattyoreilly.github.io/rCoros/reference/coros_daily_metrics.md)
  retrieves 28-day wellness metrics (HRV, RHR, VO2max, load).
- [`coros_hrv()`](https://mattyoreilly.github.io/rCoros/reference/coros_hrv.md)
  returns recent overnight HRV readings.
- [`coros_workouts()`](https://mattyoreilly.github.io/rCoros/reference/coros_workouts.md)
  lists structured workout programmes and their steps.
- [`coros_schedule()`](https://mattyoreilly.github.io/rCoros/reference/coros_schedule.md)
  returns the training calendar for a date window.
