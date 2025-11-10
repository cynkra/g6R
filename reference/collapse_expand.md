# Configure Collapse Expand Behavior

Creates a configuration object for the collapse-expand behavior in G6.
This allows users to collapse or expand nodes/combos with child
elements.

## Usage

``` r
collapse_expand(
  key = "collapse-expand",
  animation = TRUE,
  enable = TRUE,
  trigger = "dblclick",
  onCollapse = NULL,
  onExpand = NULL,
  align = TRUE,
  ...
)
```

## Arguments

- key:

  Behavior unique identifier. Useful to modify this behavior from JS
  side.

- animation:

  Enable expand/collapse animation effects (boolean, default: TRUE).

- enable:

  Enable expand/collapse functionality (boolean or function, default:
  TRUE).

- trigger:

  Trigger method: "click" or "dblclick" (string, default: "dblclick").

- onCollapse:

  Callback function when collapse is completed (function, default:
  NULL).

- onExpand:

  Callback function when expand is completed (function, default: NULL).

- align:

  Align with the target element to avoid view offset (boolean, default:
  TRUE).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/behavior/collapse-expand>.

## Value

A list with the configuration settings for the collapse-expand behavior.

## Examples

``` r
# Basic configuration
config <- collapse_expand()
```
