# Configure Fullscreen Plugin

Creates a configuration object for the fullscreen plugin in G6. This
plugin enables fullscreen mode for the graph.

## Usage

``` r
fullscreen(
  key = "fullscreen",
  autoFit = TRUE,
  trigger = NULL,
  onEnter = NULL,
  onExit = NULL,
  ...
)
```

## Arguments

- key:

  Unique identifier for the plugin (string, default: NULL).

- autoFit:

  Whether to auto-fit the canvas size to the screen when in fullscreen
  mode (boolean, default: TRUE).

- trigger:

  Methods to trigger fullscreen, e.g., list(request = "button", exit =
  "escape") (list, default: NULL).

- onEnter:

  Callback function after entering fullscreen mode (JS function,
  default: NULL).

- onExit:

  Callback function after exiting fullscreen mode (JS function, default:
  NULL).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/plugin/fullscreen>.

## Value

A list with the configuration settings for the fullscreen plugin.

## Examples

``` r
# Basic configuration
config <- fullscreen()

# Custom configuration
config <- fullscreen(
  key = "my-fullscreen",
  autoFit = TRUE,
  trigger = list(
    request = "F",
    exit = "Esc"
  ),
  onEnter = JS("() => {
    console.log('Entered fullscreen mode');
  }"),
  onExit = JS("() => {
    console.log('Exited fullscreen mode');
  }")
)
```
