# Create Animation Configuration for G6 Graphs

Configures animation settings for G6 graph elements. These settings
control how graph elements animate when changes occur.

## Usage

``` r
animation_config(
  delay = NULL,
  direction = c("forward", "alternate", "alternate-reverse", "normal", "reverse"),
  duration = NULL,
  easing = NULL,
  fill = c("none", "auto", "backwards", "both", "forwards"),
  iterations = NULL
)
```

## Arguments

- delay:

  Animation delay time in milliseconds. The time to wait before the
  animation begins. Must be a non-negative numeric value.

- direction:

  Animation playback direction. Options:

  - `"forward"`: Plays normally (default)

  - `"alternate"`: Plays forward, then in reverse

  - `"alternate-reverse"`: Plays in reverse, then forward

  - `"normal"`: Same as forward

  - `"reverse"`: Plays in reverse direction

- duration:

  Animation duration in milliseconds. The length of time the animation
  will take to complete one cycle. Must be a non-negative numeric value.

- easing:

  Animation easing function. Controls the rate of change during the
  animation. Common values include "linear", "ease", "ease-in",
  "ease-out", "ease-in-out", or cubic-bezier values.

- fill:

  Fill mode after animation ends. Options:

  - `"none"`: Element returns to its initial state when animation ends
    (default)

  - `"auto"`: Follows the rules of the animation effect

  - `"backwards"`: Element retains first keyframe values during delay
    period

  - `"both"`: Combines forwards and backwards behavior

  - `"forwards"`: Element retains final keyframe values after animation
    ends

- iterations:

  Number of times the animation should repeat. A value of `Inf` will
  cause the animation to repeat indefinitely. Must be a non-negative
  numeric value.

## Value

A list containing animation configuration that can be passed to
[`g6_options()`](https://cynkra.github.io/g6R/reference/g6_options.md).

## Details

Animation configuration allows fine-tuning the timing and behavior of
animations in G6 graphs. This includes controlling the duration, delay,
easing function, direction, and other aspects of how graph elements
animate.

## Examples

``` r
# Basic animation with duration
config <- animation_config(
  duration = 500
)

# Complex animation configuration
config <- animation_config(
  delay = 100,
  duration = 800,
  easing = "ease-in-out",
  direction = "alternate",
  fill = "forwards",
  iterations = 2
)

# Infinite animation
config <- animation_config(
  duration = 1000,
  easing = "linear",
  iterations = Inf
)
```
