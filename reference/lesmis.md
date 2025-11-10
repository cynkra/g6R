# Character network from "Les miserables" novel

A dataset containing Les Misérables characters network, encoding
interactions between characters of Victor Hugo's novel. Two characters
are connected whenever they appear in the same chapter. This dataset was
first created by Donald Knuth as part of the Stanford Graph Base.
(https://people.sc.fsu.edu/~jburkardt/datasets/sgb/sgb.html). It
contains 77 nodes corresponding to characters of the novel, and 254
edges.

## Usage

``` r
data(lesmis)
```

## Format

A list with 2 data frames:

- nodes:

  data frame with 77 rows for the nodes. Contains node labels and x/y
  coordinates.

- edges:

  data frame with 254 rows for the edges. Contains souyrce/target and
  the number of times the interaction happened.

## Source

<https://networks.skewed.de/net/lesmis>
