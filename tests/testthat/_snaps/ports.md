# g6_port validation fails for missing or invalid key/type/multiple

    Code
      g6_port(key = "", type = "input")
    Condition
      Error in `validate_port.g6_port()`:
      ! 'key' must be a non-empty character string.

---

    Code
      g6_port(key = "x", type = "foo")
    Condition
      Error in `validate_port.g6_port()`:
      ! 'type' must be either 'input' or 'output'.

---

    Code
      g6_port(key = "x", type = "input", multiple = "yes")
    Condition
      Error in `validate_port.g6_port()`:
      ! 'multiple' must be a single logical value.

# g6_ports fails if keys are not unique or elements are not g6_port

    Code
      g6_ports(g6_port("a", type = "input"), g6_port("a", type = "output"))
    Condition
      Error in `validate_ports.list()`:
      ! All port 'key' values must be unique. Duplicates: a

---

    Code
      g6_ports(g6_port("a", type = "input"), list(key = "b", type = "output"))
    Condition
      Error in `validate_ports.list()`:
      ! All elements must be of class 'g6_port'.

