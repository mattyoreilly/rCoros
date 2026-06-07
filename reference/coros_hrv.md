# Fetch recent HRV readings

Retrieves the last ~7 days of overnight HRV data from the COROS
dashboard endpoint.

## Usage

``` r
coros_hrv(auth)
```

## Arguments

- auth:

  A `coros_auth` object from
  [`coros_login()`](https://mattyoreilly.github.io/rCoros/reference/coros_login.md).

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
sorted by `date` with columns:

- date:

  Calendar date (`Date`).

- hrv:

  Average overnight HRV (ms).

- baseline:

  Personal HRV baseline (ms).

- hrv_sd:

  Standard deviation of overnight HRV (ms).

## See also

[`coros_daily_metrics()`](https://mattyoreilly.github.io/rCoros/reference/coros_daily_metrics.md)
for a longer historical HRV series.

## Examples

``` r
if (FALSE) { # interactive()
auth <- coros_login()
coros_hrv(auth)
}
```
