# Configure Hover Activate Behavior

Creates a configuration object for the hover-activate behavior in G6.
This behavior activates elements when the mouse hovers over them.

## Usage

``` r
hover_activate(
  key = "hover-activate",
  animation = TRUE,
  enable = TRUE,
  degree = 0,
  direction = c("both", "in", "out"),
  state = "active",
  inactiveState = NULL,
  onHover = NULL,
  onHoverEnd = NULL,
  ...
)
```

## Arguments

- key:

  Unique identifier for the behavior (string, default:
  "hover-activate").

- animation:

  Whether to enable animation (boolean, default: TRUE).

- enable:

  Whether to enable hover feature (boolean or JS function, default:
  TRUE).

- degree:

  Degree of relationship to activate elements (number or JS function,
  default: 0).

- direction:

  Specify edge direction: "both", "in", or "out" (string, default:
  "both").

- state:

  State of activated elements (string, default: "active").

- inactiveState:

  State of inactive elements (string, default: NULL).

- onHover:

  Callback when element is hovered (JS function, default: NULL).

- onHoverEnd:

  Callback when hover ends (JS function, default: NULL).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/behavior/hover-activate>.

## Value

A list with the configuration settings for the hover-activate behavior.

## Examples

``` r
# Basic configuration
config <- hover_activate()

# Custom configuration
config <- hover_activate(
  key = "my-hover-behavior",
  animation = FALSE,
  degree = 1,
  direction = "out",
  state = "highlight",
  inactiveState = "inactive",
  onHover = JS("(event) => { console.log('Hover on:', event.target.id); }")
)
```
