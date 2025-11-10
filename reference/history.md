# Configure History Plugin

Creates a configuration object for the history plugin in G6. This plugin
enables undo/redo functionality for graph operations.

## Usage

``` r
history(
  key = "history",
  afterAddCommand = NULL,
  beforeAddCommand = NULL,
  executeCommand = NULL,
  stackSize = 0,
  ...
)
```

## Arguments

- key:

  Unique identifier for the plugin (string, default: NULL).

- afterAddCommand:

  Callback function called after a command is added to the undo/redo
  queue (JS function, default: NULL).

- beforeAddCommand:

  Callback function called before a command is added to the undo/redo
  queue (JS function, default: NULL).

- executeCommand:

  Callback function called when executing a command (JS function,
  default: NULL).

- stackSize:

  Maximum length of history records to be recorded, 0 means unlimited
  (number, default: 0).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/plugin/history>.

## Value

A list with the configuration settings for the history plugin.

## Examples

``` r
# Basic configuration
config <- history()

# Custom configuration
config <- history(
  key = "my-history",
  stackSize = 50,
  beforeAddCommand = JS("function(cmd, revert) {
    console.log('Before adding command:', cmd);
    // Only allow certain operations to be recorded
    return cmd.method !== 'update';
  }"),
  afterAddCommand = JS("function(cmd, revert) {
    console.log('Command added to ' + (revert ? 'undo' : 'redo') + ' stack');
  }"),
  executeCommand = JS("function(cmd) {
    console.log('Executing command:', cmd);
  }")
)
```
