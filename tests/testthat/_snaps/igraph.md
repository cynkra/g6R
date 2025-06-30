# g6_igraph errors for non-igraph objects

    Code
      g6_igraph("not an igraph")
    Condition
      Error in `ensure_igraph()`:
      ! Must provide a graph object (provided wrong object type).
    Code
      g6_igraph(list())
    Condition
      Error in `ensure_igraph()`:
      ! Must provide a graph object (provided wrong object type).
    Code
      g6_igraph(123)
    Condition
      Error in `ensure_igraph()`:
      ! Must provide a graph object (provided wrong object type).

