# rCoros 0.1.0

* Initial release.
* `coros_login()` authenticates with the COROS Training Hub API (US and EU regions).
* `coros_activities()` lists activities with automatic pagination via `n_max = Inf`.
* `coros_activity_detail()` returns per-activity summary, lap splits, and HR zones.
* `coros_daily_metrics()` retrieves 28-day wellness metrics (HRV, RHR, VO2max, load).
* `coros_hrv()` returns recent overnight HRV readings.
* `coros_workouts()` lists structured workout programmes and their steps.
* `coros_schedule()` returns the training calendar for a date window.
