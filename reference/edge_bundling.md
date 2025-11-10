# Configure Edge Bundling Plugin

Creates a configuration object for the edge-bundling plugin in G6. This
plugin automatically bundles similar edges together to reduce visual
clutter.

## Usage

``` r
edge_bundling(
  key = "edge-bundling",
  bundleThreshold = 0.6,
  cycles = 6,
  divisions = 1,
  divRate = 2,
  iterations = 90,
  iterRate = 2/3,
  K = 0.1,
  lambda = 0.1,
  ...
)
```

## Arguments

- key:

  Unique identifier for the plugin (string, default: NULL).

- bundleThreshold:

  Edge compatibility threshold, determines which edges should be bundled
  together (number, default: 0.6).

- cycles:

  Number of simulation cycles (number, default: 6).

- divisions:

  Initial number of cut points (number, default: 1).

- divRate:

  Growth rate of cut points (number, default: 2).

- iterations:

  Number of iterations executed in the first cycle (number, default:
  90).

- iterRate:

  Iteration decrement rate (number, default: 2/3).

- K:

  Edge strength, affects attraction and repulsion between edges (number,
  default: 0.1).

- lambda:

  Initial step size (number, default: 0.1).

- ...:

  Extra parameters. See
  <https://g6.antv.antgroup.com/en/manual/plugin/edge-bundling>.

## Value

A list with the configuration settings for the edge-bundling plugin.

## Examples

``` r
# Basic configuration
config <- edge_bundling()

# Custom configuration
config <- edge_bundling(
  key = "my-edge-bundling",
  bundleThreshold = 0.8,
  cycles = 8,
  K = 0.2
)
```
