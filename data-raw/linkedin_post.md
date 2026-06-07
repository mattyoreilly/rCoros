Excited to share my first R package: rCoros 🏃

I've been wearing a COROS watch for a while now and the training data it collects is genuinely rich — HRV, resting heart rate, VO2max trends, training load, lap splits, HR zones. But accessing it meant logging into an app and manually exporting, which made any kind of longitudinal analysis a pain.

So I built rCoros: a tidy R interface to the COROS Training Hub API.

Authenticate once, then pull everything into tibbles ready for dplyr and ggplot2:

```r
library(rCoros)

auth    <- coros_login()                  # reads from ~/.Renviron
acts    <- coros_activities(auth)         # every workout, auto-paginated
metrics <- coros_daily_metrics(auth)      # HRV, RHR, VO2max, load — daily
detail  <- coros_activity_detail(auth,
             activity_id = acts$activity_id[[1]],
             sport_type  = acts$sport_type[[1]])  # laps + HR zones per activity
```

From there it's just R. Plot your HRV trend against training load, look at how recovery scores correlate with performance, build your own dashboard — whatever you'd do with any tidy data frame.

The package is on CRAN and fully documented at mattyoreilly.github.io/rCoros

If you're a COROS athlete who uses R (or knows someone who is), give it a try. And if you spot a missing feature or a sport type I haven't mapped yet, PRs are very welcome.

#rstats #datascience #running #sportsscience #opensource #COROS
