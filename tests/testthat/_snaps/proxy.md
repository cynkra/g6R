# g6_data handles inputs correctly

    Code
      g6_data(list(), test_df, "add", "Node")
    Condition
      Error in `g6_data()`:
      ! Can't use g6_add_* with g6 object. Only within shiny and using g6_proxy.

# g6_fit_center works correctly

    Code
      g6_fit_center(proxy, "invalid")
    Condition
      Error in `g6_fit_center()`:
      ! is.list(animation) is not TRUE

