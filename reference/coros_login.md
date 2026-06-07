# Authenticate with the COROS Training Hub API

Logs in with an email/password pair and returns an auth object that must
be passed to every other `coros_*` function. Credentials are read from
environment variables by default so they are never hard-coded in
scripts.

## Usage

``` r
coros_login(
  email = Sys.getenv("COROS_EMAIL"),
  password = Sys.getenv("COROS_PASSWORD"),
  region = c("us", "eu")
)
```

## Arguments

- email:

  COROS account e-mail. Defaults to the `COROS_EMAIL` environment
  variable.

- password:

  COROS account password. Defaults to `COROS_PASSWORD`.

- region:

  API region: `"us"` (default) or `"eu"`.

## Value

A named list with fields `access_token`, `user_id`, `base_url`,
`region`, and `timestamp`. Treat this object as opaque and pass it
directly to other `coros_*` functions.

## Details

Set credentials once per session with:

    Sys.setenv(COROS_EMAIL = "you@example.com", COROS_PASSWORD = "secret")

or add them to your `~/.Renviron` file for persistence.

## Examples

``` r
if (FALSE) { # interactive()
auth <- coros_login()  # reads COROS_EMAIL / COROS_PASSWORD from env

# EU region
auth_eu <- coros_login(region = "eu")
}
```
