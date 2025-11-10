# Configure Auto Adapt Label Behavior

Creates a configuration object for the auto-adapt-label behavior in G6.
This behavior automatically adjusts label positions to reduce
overlapping and improve readability in the graph visualization.

## Usage

``` r
auto_adapt_label(
  key = "auto-adapt-label",
  enable = TRUE,
  throttle = 100,
  padding = 0,
  sort = NULL,
  sortNode = list(type = "degree"),
  sortEdge = NULL,
  sortCombo = NULL,
  ...
)
```

## Arguments

- key:

  Unique identifier for the behavior (string, default:
  "auto-adapt-label").

- enable:

  Whether to enable this behavior (JS function, default: returns TRUE
  for all events).

- throttle:

  Throttle time in milliseconds to optimize performance (numeric,
  default: 100).

- padding:

  Padding space around labels in pixels (numeric, default: 0).

- sort:

  Global sorting rule for all element types (list or JS function,
  default: NULL).

- sortNode:

  Sorting rule specifically for node labels (list, default: list(type =
  "degree")).

- sortEdge:

  Sorting rule specifically for edge labels (list, default: NULL).

- sortCombo:

  Sorting rule specifically for combo labels (list, default: NULL).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/behavior/auto-adapt-label>.

  Sorting parameters determine which labels take priority when space is
  limited:

  - When `sort` is provided, it applies to all element types and
    overrides type-specific settings

  - Type-specific sorting (`sortNode`, `sortEdge`, `sortCombo`) only
    applies when `sort` is NULL

  - The default sorting for nodes is by degree (higher degree nodes'
    labels are shown first)

## Value

A list with the configuration settings for the auto-adapt-label
behavior.

## Examples

``` r
# Basic configuration with defaults
config <- auto_adapt_label()

# Custom configuration with more padding and custom throttle
config <- auto_adapt_label(
  key = "my-label-adapter",
  throttle = 200,
  padding = 5
)


# Using a custom enable function
config <- auto_adapt_label(
  enable = JS("(e) => e.targetType === 'node'")
)
```
