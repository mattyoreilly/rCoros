# Fetch daily health and training metrics

Returns a tidy tibble of per-day wellness metrics from the COROS
`/analyse/dayDetail/query` endpoint, including HRV, resting heart rate,
training load, VO2max, and stamina.

## Usage

``` r
coros_daily_metrics(
  auth,
  start_day = format(Sys.Date() - 28, "%Y%m%d"),
  end_day = format(Sys.Date(), "%Y%m%d")
)
```

## Arguments

- auth:

  A `coros_auth` object from
  [`coros_login()`](https://mattyoreilly.github.io/rCoros/reference/coros_login.md).

- start_day:

  Start of date range in `"YYYYMMDD"` format. Defaults to 28 days ago.

- end_day:

  End of date range in `"YYYYMMDD"` format. Defaults to today.

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
sorted by `date` with columns:

- date:

  Calendar date (`Date`).

- hrv:

  Average overnight HRV (ms).

- hrv_baseline:

  Personal HRV baseline (ms).

- rhr:

  Resting heart rate (bpm).

- training_load:

  Daily training load.

- load_ratio:

  Training load ratio (acute:chronic).

- tired_rate:

  Fatigue rate.

- ati:

  Acute training impulse.

- cti:

  Chronic training impulse.

- t7d:

  7-day training load.

- t28d:

  28-day training load.

- vo2max:

  Estimated VO2max (mL/kg/min).

- lthr:

  Lactate threshold heart rate (bpm).

- ltsp:

  Lactate threshold speed.

- stamina:

  Current stamina level.

- stamina_7d:

  7-day stamina level.

- performance:

  Performance score.

- tib:

  Time in bed (minutes).

## Examples

``` r
if (FALSE) { # interactive()
auth <- coros_login()

# Last 28 days (default)
metrics <- coros_daily_metrics(auth)

# Custom range
metrics <- coros_daily_metrics(auth, start_day = "20240101", end_day = "20240131")
}
```
