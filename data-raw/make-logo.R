# data-raw/make-logo.R
# Regenerate man/figures/logo.png using hexSticker.
# Run once from the package root:
#   source("data-raw/make-logo.R")
#
# Requires:
#   install.packages(c("hexSticker", "ggplot2", "showtext"))

library(ggplot2)
library(hexSticker)   # provides sticker() and theme_transparent()
library(showtext)

# --------------------------------------------------------------------------- #
# Colours
# --------------------------------------------------------------------------- #
COROS_RED <- "#D4172D"
DARK      <- "#1A0A0A"   # near-black centre — ensures white R always readable

# --------------------------------------------------------------------------- #
# Hexagon vertex helper
#
# Pointy-top, start_deg = 90 → vertex indices (1-based):
#   1 = top        2 = upper-left   3 = lower-left
#   4 = bottom     5 = lower-right  6 = upper-right
# --------------------------------------------------------------------------- #
hex_v <- function(r, start_deg = 90) {
  a <- (start_deg + seq(0, 300, by = 60)) * pi / 180
  data.frame(x = r * cos(a), y = r * sin(a))
}

# Linear blend between two single-row data frames
blerp <- function(a, b, t)
  data.frame(x = a$x + (b$x - a$x) * t,
             y = a$y + (b$y - a$y) * t)

outer_v <- hex_v(1.00)
inner_v <- hex_v(0.58)

o3 <- outer_v[3, ];  o4 <- outer_v[4, ]
i3 <- inner_v[3, ];  i4 <- inner_v[4, ]

# COROS-style diagonal cut: white wedge biting into the lower-left of the ring
cut_pts <- rbind(
  o3,
  blerp(o3, o4, 0.62),
  blerp(i3, i4, 0.75),
  i3
)

# COROS re-entry tab: small red wedge that creates the "flowing / interlocked" look
tab_pts <- rbind(
  i3,
  data.frame(x = i3$x - 0.14, y = i3$y - 0.10),
  blerp(i4, i3, 0.18) + data.frame(x = -0.01, y = -0.06),
  blerp(i4, i3, 0.12)
)

# --------------------------------------------------------------------------- #
# Subplot ggplot
# --------------------------------------------------------------------------- #
p <- ggplot() +
  # Red outer hexagon
  geom_polygon(aes(x, y), data = outer_v, fill = COROS_RED, colour = NA) +
  # Dark inner hexagon (the "lens" that the R sits on)
  geom_polygon(aes(x, y), data = inner_v, fill = DARK,      colour = NA) +
  # White diagonal cut
  geom_polygon(aes(x, y), data = cut_pts, fill = "white",   colour = NA) +
  # Red re-entry tab
  geom_polygon(aes(x, y), data = tab_pts, fill = COROS_RED, colour = NA) +
  # Bold white R — fontface = "bold" renders the correct R letterform
  annotate("text",
           x        = 0.06,
           y        = 0.03,
           label    = "R",
           colour   = "white",
           size     = 18,
           fontface = "bold") +
  coord_equal(xlim = c(-1.15, 1.15), ylim = c(-1.15, 1.15)) +
  theme_void() +
  theme_transparent()   # from hexSticker — transparent panel/plot background

# --------------------------------------------------------------------------- #
# Render hex sticker
# --------------------------------------------------------------------------- #
sticker(
  subplot  = p,
  package  = "rCoros",
  p_size   = 20,
  p_color  = "#1A1A1A",
  p_y      = 1.55,
  s_x      = 1.00,
  s_y      = 0.87,
  s_width  = 1.50,
  s_height = 1.50,
  h_fill   = "white",
  h_color  = COROS_RED,
  h_size   = 1.5,
  filename = "man/figures/logo.png",
  dpi      = 320
)

message("Logo saved to man/figures/logo.png")
message("Now run: usethis::use_logo('man/figures/logo.png')")
