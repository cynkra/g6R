# Create Auto-Fit Configuration for G6 Graphs

Configures the auto-fit behavior for a G6 graph. Auto-fit automatically
adjusts the view to fit all elements or centers them within the canvas.

## Usage

``` r
auto_fit_config(
  type = c("view", "center"),
  when = c("overflow", "always"),
  direction = c("x", "y", "both"),
  duration = 1000,
  easing = c("ease-in-out", "ease", "ease-in", "ease-out", "linear", "cubic-bezier",
    "step-start", "step-end")
)
```

## Arguments

- type:

  The auto-fit mode to use. Options:

  - `"view"`: Scale and translate the graph to fit all elements within
    the view (default)

  - `"center"`: Only translate the graph to center elements without
    scaling

- when:

  When the auto-fit should be triggered. Options:

  - `"overflow"`: Trigger auto-fit only when elements overflow the
    canvas (default)

  - `"always"`: Always perform auto-fit when the graph data changes

- direction:

  The direction for auto-fit adjustment. Options:

  - `"x"`: Adjust only along the x-axis

  - `"y"`: Adjust only along the y-axis

  - `"both"`: Adjust in both x and y directions (default)

- duration:

  The duration of the auto-fit animation in milliseconds (default: 1000)

- easing:

  The animation easing function to use. Options:

  - `"ease-in-out"`: Slow at the beginning and end of the animation
    (default)

  - `"ease"`: Standard easing

  - `"ease-in"`: Slow at the beginning

  - `"ease-out"`: Slow at the end

  - `"linear"`: Constant speed throughout

  - `"cubic-bezier"`: Custom cubic-bezier curve

  - `"step-start"`: Jump immediately to the end state

  - `"step-end"`: Jump at the end to the end state

## Value

A list containing the auto-fit configuration that can be passed to
[`g6_options()`](https://cynkra.github.io/g6R/reference/g6_options.md).

## Details

The auto-fit feature helps ensure that graph elements remain visible
within the canvas. It can be configured to either fit all elements to
view or center them, and can be triggered under different conditions.

## Examples

``` r
# Basic auto-fit configuration with default settings
config <- auto_fit_config()

# Auto-fit with only centering (no scaling)
config <- auto_fit_config(type = "center")

# Auto-fit that always triggers when graph data changes
config <- auto_fit_config(when = "always")

# Auto-fit only in the x direction
config <- auto_fit_config(direction = "x")

# Auto-fit with a fast animation
config <- auto_fit_config(duration = 300, easing = "ease-out")
```
