# Fetch the training calendar

Returns a tibble of planned activities from the COROS training schedule
within the given date window.

## Usage

``` r
coros_schedule(
  auth,
  start_day = format(Sys.Date(), "%Y%m%d"),
  end_day = format(Sys.Date() + 14, "%Y%m%d")
)
```

## Arguments

- auth:

  A `coros_auth` object from
  [`coros_login()`](https://mattyoreilly.github.io/rCoros/reference/coros_login.md).

- start_day:

  Start of the window in `"YYYYMMDD"` format. Defaults to today.

- end_day:

  End of the window in `"YYYYMMDD"` format. Defaults to 14 days from
  today.

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with one row per scheduled item and columns:

- plan_id:

  Training plan identifier.

- id_in_plan:

  Item position within the plan.

- plan_program_id:

  Associated workout program identifier.

- happen_day:

  Scheduled date (`Date`).

- name:

  Workout name.

- sport_type:

  Numeric sport type code.

- sport_name:

  Human-readable sport name.

- estimated_min:

  Estimated duration in minutes.

- completed:

  Logical; `TRUE` if the workout has been completed.

## Examples

``` r
if (FALSE) { # interactive()
auth <- coros_login()

# Upcoming two weeks
schedule <- coros_schedule(auth)

# Narrower window
schedule <- coros_schedule(
  auth,
  start_day = format(Sys.Date(), "%Y%m%d"),
  end_day   = format(Sys.Date() + 7, "%Y%m%d")
)
}
```
