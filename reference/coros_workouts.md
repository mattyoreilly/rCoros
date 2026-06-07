# List structured workout programs

Retrieves all workout programs stored in the COROS Training Hub,
returning a list of two tidy tibbles: a summary of each workout and its
constituent steps.

## Usage

``` r
coros_workouts(auth)
```

## Arguments

- auth:

  A `coros_auth` object from
  [`coros_login()`](https://mattyoreilly.github.io/rCoros/reference/coros_login.md).

## Value

A named list with two tibbles:

- `workouts`:

  One row per workout with columns `id`, `name`, `sport_type`,
  `sport_name`, `duration_min`, and `n_steps`.

- `steps`:

  One row per step, linked to `workouts` via `workout_id`, with columns
  `step_name`, `duration_s`, `duration_min`, `power_low_w`,
  `power_high_w`, and `sets`.

## Examples

``` r
if (FALSE) { # interactive()
auth <- coros_login()
result <- coros_workouts(auth)
result$workouts
result$steps
}
```
