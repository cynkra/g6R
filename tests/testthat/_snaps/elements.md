# g6_collapse_options validates placement with match.arg

    Code
      g6_collapse_options(placement = "invalid-placement")
    Condition
      Error in `match.arg()`:
      ! 'arg' should be one of "top", "right", "bottom", "left", "right-top", "right-bottom", "left-top", "left-bottom"

# g6_collapse_options validates numeric placement length

    Code
      g6_collapse_options(placement = c(0))
    Condition
      Error in `g6_collapse_options()`:
      ! Numeric placement must be a vector of length 2.

---

    Code
      g6_collapse_options(placement = c(0, 0.5, 1))
    Condition
      Error in `g6_collapse_options()`:
      ! Numeric placement must be a vector of length 2.

# g6_collapse_options validates numeric placement has at least one edge coordinate

    Code
      g6_collapse_options(placement = c(0.5, 0.5))
    Condition
      Error in `g6_collapse_options()`:
      ! Invalid collapse button placement: at least one coordinate must be 0 or 1 (i.e., on the node edge). You supplied: c(0.5, 0.5)

---

    Code
      g6_collapse_options(placement = c(0.3, 0.7))
    Condition
      Error in `g6_collapse_options()`:
      ! Invalid collapse button placement: at least one coordinate must be 0 or 1 (i.e., on the node edge). You supplied: c(0.3, 0.7)

# g6_collapse_options rejects invalid placement type

    Code
      g6_collapse_options(placement = list(0, 0.5))
    Condition
      Error in `g6_collapse_options()`:
      ! placement must be a character string or numeric vector of length 2.

---

    Code
      g6_collapse_options(placement = NULL)
    Condition
      Error in `g6_collapse_options()`:
      ! placement must be a character string or numeric vector of length 2.

# g6_node validation fails for invalid collapse

    Code
      g6_node(id = "n1", children = c("n2"), collapse = list(collapsed = TRUE,
        placement = "top"))
    Condition
      Error in `validate_element.g6_node()`:
      ! Node 'collapse' must be of class 'g6_collapse_options'.

---

    Code
      g6_node(id = "n1", children = c("n2"), collapse = "invalid")
    Condition
      Error in `validate_element.g6_node()`:
      ! Node 'collapse' must be of class 'g6_collapse_options'.

# g6_node validation fails for missing id

    Code
      g6_node(type = "rect")
    Condition
      Error in `g6_node()`:
      ! argument "id" is missing, with no default

# g6_edge validation fails for missing source/target

    Code
      g6_edge(source = NULL, target = "n2")
    Condition
      Error in `validate_element.g6_edge()`:
      ! Edge 'source' is required and must be a non-empty character string.

---

    Code
      g6_edge(source = "n1", target = NULL)
    Condition
      Error in `validate_element.g6_edge()`:
      ! Edge 'target' is required and must be a non-empty character string.

# g6_combo validation fails for missing id

    Code
      g6_combo(type = "rect")
    Condition
      Error in `g6_combo()`:
      ! argument "id" is missing, with no default

# g6_nodes fails if any element is not a g6_node

    Code
      g6_nodes(g6_node(id = "n1"), g6_edge(source = "n1", target = "n2"))
    Condition
      Error in `validate_elements.g6_nodes()`:
      ! All elements must be of class 'g6_node'.

# g6_edges fails if any element is not a g6_edge

    Code
      g6_edges(g6_edge(source = "n1", target = "n2"), g6_node(id = "n2"))
    Condition
      Error in `validate_elements.g6_edges()`:
      ! All elements must be of class 'g6_edge'.

# g6_combos fails if any element is not a g6_combo

    Code
      g6_combos(g6_combo(id = "c1"), g6_node(id = "n1"))
    Condition
      Error in `validate_elements.g6_combos()`:
      ! All elements must be of class 'g6_combo'.

# g6_nodes fails if no nodes provided

    Code
      g6_nodes()
    Condition
      Error in `validate_elements()`:
      ! length(x) > 0 is not TRUE

# g6_edges fails if no edges provided

    Code
      g6_edges()
    Condition
      Error in `validate_elements()`:
      ! length(x) > 0 is not TRUE

# g6_combos fails if no combos provided

    Code
      g6_combos()
    Condition
      Error in `validate_elements()`:
      ! length(x) > 0 is not TRUE

