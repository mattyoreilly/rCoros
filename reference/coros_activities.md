# List activities

Returns a tidy tibble of activities recorded within a date range, one
row per activity.

## Usage

``` r
coros_activities(
  auth,
  start_day = format(Sys.Date() - 30, "%Y%m%d"),
  end_day = format(Sys.Date(), "%Y%m%d"),
  page = 1L,
  size = 30L,
  n_max = Inf
)
```

## Arguments

- auth:

  A `coros_auth` object from
  [`coros_login()`](https://mattyoreilly.github.io/rCoros/reference/coros_login.md).

- start_day:

  Start of date range in `"YYYYMMDD"` format. Defaults to 30 days ago.

- end_day:

  End of date range in `"YYYYMMDD"` format. Defaults to today.

- page:

  Page number for paginated results (default `1L`).

- size:

  Number of results per page (default `30L`).

- n_max:

  Maximum total activities to return. Set to `Inf` to fetch all pages
  automatically (default `Inf`).

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with columns:

- activity_id:

  Unique activity identifier (character).

- name:

  Activity name or remark.

- sport_type:

  Numeric sport type code.

- sport_name:

  Human-readable sport name.

- date:

  Date of activity (`Date`).

- start_time:

  Start timestamp (`POSIXct`, UTC).

- duration_s:

  Duration in seconds.

- duration_min:

  Duration in minutes.

- distance_m:

  Distance in metres.

- distance_km:

  Distance in kilometres.

- elevation_gain:

  Elevation gain in metres.

- avg_hr:

  Average heart rate (bpm).

- calories:

  Calories (kcal).

- training_load:

  Training load score.

- avg_power:

  Average power (watts).

- device:

  Device name.

## Examples

``` r
if (FALSE) { # interactive()
auth <- coros_login()

# All activities in the last 30 days
acts <- coros_activities(auth)

# Running and trail-running only
library(dplyr)
runs <- coros_activities(auth) |>
  filter(sport_type %in% c(100L, 102L))
}
```
