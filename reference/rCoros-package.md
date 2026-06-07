# rCoros: Access COROS Training Hub Fitness Data in R

rCoros provides a tidy interface to the COROS Training Hub API.
Authenticate once with
[`coros_login()`](https://mattyoreilly.github.io/rCoros/reference/coros_login.md),
then pull activities, daily wellness metrics, HRV, structured workouts,
and training schedules — all returned as tibbles ready for analysis with
dplyr and ggplot2.

## Typical workflow

    library(rCoros)
    library(dplyr)

    # 1. Store credentials (once, in ~/.Renviron)
    # COROS_EMAIL=you@example.com
    # COROS_PASSWORD=secret

    # 2. Authenticate
    auth <- coros_login()

    # 3. Pull data
    acts    <- coros_activities(auth)
    metrics <- coros_daily_metrics(auth)
    hrv     <- coros_hrv(auth)
    sched   <- coros_schedule(auth)
    wkts    <- coros_workouts(auth)

    # 4. Drill into an activity
    detail <- coros_activity_detail(
      auth,
      activity_id = acts$activity_id[[1]],
      sport_type  = acts$sport_type[[1]]
    )

## API regions

COROS operates separate endpoints for US and EU accounts. Pass
`region = "eu"` to
[`coros_login()`](https://mattyoreilly.github.io/rCoros/reference/coros_login.md)
if your account was created in Europe.

## Credentials

Never hard-code passwords in scripts. Set `COROS_EMAIL` and
`COROS_PASSWORD` environment variables, ideally in `~/.Renviron`.

## See also

Useful links:

- <https://github.com/mattyoreilly/rCoros>

- <https://mattyoreilly.github.io/rCoros/>

- Report bugs at <https://github.com/mattyoreilly/rCoros/issues>

## Author

**Maintainer**: Matt O'Reilly <fermoymatt@gmail.com>

Authors:

- Matt O'Reilly <fermoymatt@gmail.com>
