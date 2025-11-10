# Configure Context Menu Behavior

Creates a configuration object for the context-menu behavior in G6. This
allows users to display a context menu when right-clicking or clicking
on graph elements.

## Usage

``` r
context_menu(
  key = "contextmenu",
  className = "g6-contextmenu",
  trigger = "contextmenu",
  offset = c(4, 4),
  onClick = NULL,
  getItems = NULL,
  getContent = NULL,
  loadingContent = NULL,
  enable = JS("(e) => e.targetType === 'node'"),
  ...
)
```

## Arguments

- key:

  Unique identifier for the behavior, used for subsequent operations
  (string, default: "context-menu").

- className:

  Additional class name for the menu DOM (string, default:
  "g6-contextmenu").

- trigger:

  How to trigger the menu: "contextmenu" for right-click, "click" for
  click (string, default: "contextmenu").

- offset:

  Offset of the menu display in X and Y directions (numeric vector,
  default: c(4, 4)).

- onClick:

  Callback method triggered after menu item is clicked (JS function).
  Our default allows to create edge or either remove the current node.

- getItems:

  Returns the list of menu items, supports Promise (JS function,
  default: NULL).

- getContent:

  Returns the content of the menu, supports Promise (JS function,
  default: NULL).

- loadingContent:

  Menu content used when getContent returns a Promise (string or HTML
  element, default: NULL).

- enable:

  Whether the context menu is available (boolean or JS function,
  default: TRUE).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/plugin/contextmenu>.

## Value

A list with the configuration settings for the context menu plugin.

## Examples

``` r
# Basic configuration
config <- context_menu()

# Custom configuration with JavaScript functions
config <- context_menu(
  key = "my-context-menu",
  className = "my-context-menu",
  trigger = "click",
  offset = c(10, 10),
  getItems = JS("(event) => {
    const type = event.itemType;
    const isNode = type === 'node';
    return [
      { key: 'delete', text: 'Delete' },
      { key: 'edit', text: 'Edit' },
      { key: 'details', text: 'View Details', disabled: !isNode }
    ];
  }"),
  onClick = JS("(value, target, current) => {
    if (value === 'delete') {
      // do stuff
  }")
)
```
