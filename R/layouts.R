#' Set the layout algorithm for a g6 graph
#'
#' This function configures the layout algorithm used to position nodes in a g6 graph.
#' G6 provides various layout algorithms such as 'force', 'radial', 'circular', 'grid',
#' 'concentric', 'dagre', and more. Each layout has its own set of configurable parameters.
#'
#' @param graph A g6 graph object created with \code{g6()}.
#' @param layout An existing layout function like \link{circular_layout}.
#'   At minimum, this can be a list that should contain a \code{type} element specifying the layout algorithm.
#'   Additional parameters depend on the layout type chosen, for instance \code{list(type = "force")}.
#'
#' @return The modified g6 graph object with the specified layout, allowing for method chaining.
#'
#' @details
#' G6 provides several layout algorithms, each suitable for different graph structures:
#'
#' \itemize{
#'   \item \strong{force}: Force-directed layout using physical simulation of forces
#'   \item \strong{random}: Random layout placing nodes randomly
#'   \item \strong{circular}: Arranges nodes on a circle
#'   \item \strong{radial}: Radial layout with nodes arranged outward from a central node
#'   \item \strong{grid}: Arranges nodes in a grid pattern
#'   \item \strong{concentric}: Concentric circles with important nodes in the center
#'   \item \strong{dagre}: Hierarchical layout for directed acyclic graphs
#'   \item \strong{fruchterman}: Force-directed layout based on the Fruchterman-Reingold algorithm
#'   \item \strong{mds}: Multidimensional scaling layout
#'   \item \strong{comboForce}: Force-directed layout specially designed for combo graphs
#' }
#'
#' Each layout algorithm has specific configuration options. See the G6 documentation
#' for detailed information on each layout and its parameters:
#' \url{https://g6.antv.antgroup.com/en/manual/layout/overview}
#'
#' @seealso \code{\link{g6}}
#' @export
g6_layout <- function(graph, layout = list(type = "force")) {
  graph$x$layout <- validate_layout(layout)
  graph
}

#' @keywords internal
validate_layout <- function(x) {
  if (!inherits(x, "g6-layout")) {
    stop("Current layout is not a valid")
  }
  x
}

#' Generate G6 AntV Dagre layout configuration
#'
#' This function creates a configuration list for G6 AntV Dagre layout
#' with all available options as parameters.
#'
#' @param rankdir Layout direction: "TB" (top to bottom), "BT" (bottom to top),
#'   "LR" (left to right), or "RL" (right to left)
#' @param align Node alignment: "UL" (upper left), "UR" (upper right),
#'   "DL" (down left), or "DR" (down right)
#' @param nodesep Node spacing (px). When rankdir is "TB" or "BT", it's the horizontal
#'   spacing of nodes; when rankdir is "LR" or "RL", it's the vertical spacing of nodes
#' @param nodesepFunc Function to customize node spacing for different nodes,
#'   in the form of function(node) that returns a number. Has higher priority than nodesep
#' @param ranksep Layer spacing (px). When rankdir is "TB" or "BT", it's the vertical spacing
#'   between adjacent layers; when rankdir is "LR" or "RL", it's the horizontal spacing
#' @param ranksepFunc Function to customize layer spacing, in the form of function(node)
#'   that returns a number. Has higher priority than ranksep
#' @param ranker Algorithm for assigning ranks to nodes: "network-simplex", "tight-tree",
#'   or "longest-path"
#' @param nodeSize Node size for collision detection. Can be a single number (same width/height),
#'   an array [width, height], or a function that returns either
#' @param controlPoints Whether to retain edge control points
#' @param begin Alignment position of the upper left corner of the layout. Can be [x, y] or [x, y, z]
#' @param sortByCombo Whether to sort nodes on the same layer by parentId to prevent combo overlap
#' @param edgeLabelSpace Whether to leave space for edge labels
#' @param nodeOrder Reference array of node order on the same layer, containing node id values
#' @param radial Whether to perform a radial layout based on dagre
#' @param focusNode Focused node (only used when radial=TRUE). Can be a node ID or node object
#' @param preset Node positions to reference during layout calculation
#' @param ... Additional parameters to pass to the layout
#'
#' @return A list containing the configuration for G6 AntV Dagre layout with class "g6-layout"
#' @export
#'
#' @examples
#' # Basic dagre layout
#' dagre_config <- antv_dagre_layout()
#'
#' # Horizontal layout with custom spacing
#' dagre_config <- antv_dagre_layout(
#'   rankdir = "LR",
#'   align = "UL",
#'   nodesep = 80,
#'   ranksep = 150
#' )
#'
#' # Radial layout with focus node
#' dagre_config <- antv_dagre_layout(
#'   radial = TRUE,
#'   focusNode = "node1",
#'   ranker = "tight-tree"
#' )
antv_dagre_layout <- function(
  rankdir = c("TB", "BT", "LR", "RL"),
  align = c("UL", "UR", "DL", "DR"),
  nodesep = 50,
  nodesepFunc = NULL,
  ranksep = 100,
  ranksepFunc = NULL,
  ranker = c("network-simplex", "tight-tree", "longest-path"),
  nodeSize = NULL,
  controlPoints = FALSE,
  begin = NULL,
  sortByCombo = FALSE,
  edgeLabelSpace = TRUE,
  nodeOrder = NULL,
  radial = FALSE,
  focusNode = NULL,
  preset = NULL,
  ...
) {
  # Validate rankdir
  rankdir <- match.arg(rankdir)
  # Validate align
  align <- match.arg(align)

  # Validate nodesep
  if (!is.numeric(nodesep) || nodesep < 0) {
    stop("nodesep must be a non-negative number")
  }

  # Validate nodesepFunc
  if (!is.null(nodesepFunc) && !is_js(nodesepFunc)) {
    stop("nodesepFunc must be a JS function")
  }

  # Validate ranksep
  if (!is.numeric(ranksep) || ranksep < 0) {
    stop("ranksep must be a non-negative number")
  }

  # Validate ranksepFunc
  if (!is.null(ranksepFunc) && !is_js(ranksepFunc)) {
    stop("ranksepFunc must be a JS function")
  }

  # Validate ranker
  ranker <- match.arg(ranker)

  # Validate nodeSize
  if (!is.null(nodeSize)) {
    if (!is.numeric(nodeSize) && !is.function(nodeSize)) {
      if (is.numeric(nodeSize) && !is.vector(nodeSize)) {
        if (length(nodeSize) != 2) {
          stop(
            "nodeSize as a vector must have exactly 2 elements [width, height]"
          )
        }
      } else {
        stop(
          "nodeSize must be a number, a 2-element vector [width, height], or a function"
        )
      }
    }
  }

  # Validate controlPoints
  if (!is.logical(controlPoints)) {
    stop("controlPoints must be a logical value (TRUE or FALSE)")
  }

  # Validate begin
  if (!is.null(begin)) {
    if (!is.numeric(begin) || !(length(begin) == 2 || length(begin) == 3)) {
      stop("begin must be a numeric vector with 2 or 3 elements")
    }
  }

  # Validate sortByCombo
  if (!is.logical(sortByCombo)) {
    stop("sortByCombo must be a logical value (TRUE or FALSE)")
  }

  # Validate edgeLabelSpace
  if (!is.logical(edgeLabelSpace)) {
    stop("edgeLabelSpace must be a logical value (TRUE or FALSE)")
  }

  # Validate nodeOrder
  if (!is.null(nodeOrder) && !is.character(nodeOrder)) {
    stop("nodeOrder must be a character vector of node IDs")
  }

  # Validate radial
  if (!is.logical(radial)) {
    stop("radial must be a logical value (TRUE or FALSE)")
  }

  # Validate focusNode
  if (!is.null(focusNode) && radial == FALSE) {
    warning("focusNode is only effective when radial is TRUE")
  }

  # Use dropNulls function to remove NULL elements
  # Assuming dropNulls is defined elsewhere in your package
  named_params <- dropNulls(mget(
    setdiff(names(formals()), "..."),
    environment()
  ))

  # Collect additional parameters from ellipsis
  extra_params <- list(...)

  # Add type parameter (internal)
  config <- list(type = "antv-dagre")

  # Merge with named parameters and additional parameters
  structure(c(config, named_params, extra_params), class = "g6-layout")
}

#' Generate G6 D3 Force layout configuration
#'
#' This function creates a configuration list for G6 D3 Force layout
#' with all available options as parameters.
#'
#' @param link A list specifying force parameters for links (edges), with components:
#'   \describe{
#'     \item{id}{Edge id generation function, format: \code{function(edge, index, edges) { return string }}. Default is \code{function(e) e.id}}
#'     \item{distance}{Ideal edge length that edges will tend toward. Can be a number or a function
#'       \code{function(edge, index, edges) { return number }}. Default is 30}
#'     \item{strength}{The strength of the force. Higher values make edge lengths closer to the ideal length.
#'       Can be a number or a function \code{function(edge, index, edges) { return number }}. Default is 1}
#'     \item{iterations}{Number of iterations of link force. Default is 1}
#'   }
#' @param collide A list specifying collision force parameters for nodes, with components:
#'   \describe{
#'     \item{radius}{Collision radius. Nodes closer than this distance will experience a repulsive force.
#'       Can be a number or a function \code{function(node, index, nodes) { return number }}. Default is 10}
#'     \item{strength}{The strength of the repulsive force. Higher values produce more obvious repulsion. Default is 1}
#'     \item{iterations}{The number of iterations for collision detection. Default is 1}
#'   }
#' @param ... Additional parameters to pass to the layout.
#' See \url{https://g6.antv.antgroup.com/manual/layout/build-in/d3-force}.
#'
#' @return A list containing the configuration for G6 AntV D3 Force layout with class "g6-layout"
#' @export
#'
#' @examples
#' # Basic D3 force layout
#' d3_force_config <- d3_force_layout()
#'
#' # Custom link distance and collision radius
#' d3_force_config <- d3_force_layout(
#'   link = list(
#'     distance = 150,
#'     strength = 0.5,
#'     iterations = 3
#'   ),
#'   collide = list(
#'     radius = 30,
#'     strength = 0.8
#'   )
#' )
d3_force_layout <- function(
  link = list(
    distance = 100,
    strength = 2
  ),
  collide = list(radius = 40),
  ...
) {
  # Validate link parameter
  if (!is.null(link)) {
    if (!is.list(link)) {
      stop("The 'link' parameter must be a list")
    }

    if (!is.null(link$id) && !is_js(link$id)) {
      stop("link$id must be a JS function that generates edge IDs")
    }

    if (!is.null(link$distance)) {
      if (!is.numeric(link$distance) && !is_js(link$distance)) {
        stop("link$distance must be a number or a JS function")
      }
      if (is.numeric(link$distance) && link$distance < 0) {
        stop("link$distance must be a positive number")
      }
    }

    if (!is.null(link$strength)) {
      if (!is.numeric(link$strength) && !is_js(link$strength)) {
        stop("link$strength must be a number or a JS function")
      }
      if (is.numeric(link$strength) && link$strength < 0) {
        stop("link$strength must be a positive number")
      }
    }

    if (!is.null(link$iterations)) {
      if (
        !is.numeric(link$iterations) ||
          !is.integer(as.integer(link$iterations)) ||
          link$iterations < 1
      ) {
        stop("link$iterations must be a positive integer")
      }
    }
  }

  # Validate collide parameter
  if (!is.null(collide)) {
    if (!is.list(collide)) {
      stop("The 'collide' parameter must be a list")
    }

    if (!is.null(collide$radius)) {
      if (!is.numeric(collide$radius) && !is_js(collide$radius)) {
        stop("collide$radius must be a number or a JS function")
      }
      if (is.numeric(collide$radius) && collide$radius < 0) {
        stop("collide$radius must be a positive number")
      }
    }

    if (!is.null(collide$strength)) {
      if (!is.numeric(collide$strength)) {
        stop("collide$strength must be a number")
      }
      if (collide$strength < 0 || collide$strength > 1) {
        stop("collide$strength should be between 0 and 1")
      }
    }

    if (!is.null(collide$iterations)) {
      if (
        !is.numeric(collide$iterations) ||
          !is.integer(as.integer(collide$iterations)) ||
          collide$iterations < 1
      ) {
        stop("collide$iterations must be a positive integer")
      }
    }
  }

  named_params <- dropNulls(mget(
    setdiff(names(formals()), "..."),
    environment()
  ))
  # Collect additional parameters from ellipsis
  extra_params <- list(...)
  # Add type parameter (internal)
  config <- list(type = "d3-force")
  # Merge with named parameters and additional parameters
  structure(c(config, named_params, extra_params), class = "g6-layout")
}

#' Generate G6 AntV circular layout configuration
#'
#' This function creates a configuration list for G6 AntV circular layout
#' with all available options as parameters.
#'
#' @param angleRatio How many 2*PI are there between the first node and the last node?
#' @param center Center of layout as vector c(x, y) or c(x, y, z)
#' @param clockwise Is it arranged clockwise?
#' @param divisions Number of segments that nodes are placed on the ring
#' @param nodeSize Node size (diameter) for collision detection
#' @param nodeSpacing Minimum distance between rings
#' @param ordering Basis for sorting nodes ("topology", "topology-directed", or "degree")
#' @param radius Radius of the circle (overrides startRadius and endRadius)
#' @param startAngle Starting angle of the layout
#' @param endAngle End angle of the layout
#' @param startRadius Starting radius of the spiral layout
#' @param endRadius End radius of the spiral layout
#' @param width Width of layout
#' @param height Height of layout
#' @param ... Additional parameters to pass to the layout.
#' See \url{https://g6.antv.antgroup.com/manual/layout/build-in/circular-layout}.
#'
#' @return A list containing the configuration for G6 AntV circular layout
#' @export
#'
#' @examples
#' circular_config <- circular_layout(
#'   radius = 200,
#'   startAngle = 0,
#'   endAngle = pi,
#'   clockwise = FALSE
#' )
circular_layout <- function(
  angleRatio = 1,
  center = NULL,
  clockwise = TRUE,
  divisions = 1,
  nodeSize = 10,
  nodeSpacing = 10,
  ordering = NULL,
  radius = NULL,
  startAngle = 0,
  endAngle = 2 * pi,
  startRadius = NULL,
  endRadius = NULL,
  width = NULL,
  height = NULL,
  ...
) {
  # Validation checks
  if (!is.numeric(angleRatio) || angleRatio <= 0) {
    stop("angleRatio must be a positive number")
  }

  if (!is.null(center)) {
    if (!(is.numeric(center) && (length(center) == 2 || length(center) == 3))) {
      stop("center must be a numeric vector of length 2 or 3")
    }
  }

  if (!is.logical(clockwise)) {
    stop("clockwise must be a logical value (TRUE or FALSE)")
  }

  if (!is.numeric(divisions) || divisions < 1) {
    stop("divisions must be a positive integer")
  }

  if (!is.numeric(nodeSize) && !is_js(nodeSize) && !is.null(nodeSize)) {
    stop(
      "nodeSize must be a number, a JavaScript function wrapped by JS, or NULL"
    )
  }

  if (
    !is.numeric(nodeSpacing) &&
      !is_js(nodeSpacing) &&
      !is.null(nodeSpacing)
  ) {
    stop(
      "nodeSpacing must be a number, a JavaScript function wrapped by JS, or NULL"
    )
  }

  if (!is.null(ordering)) {
    valid_ordering <- c("topology", "topology-directed", "degree")
    if (!(ordering %in% valid_ordering)) {
      stop(paste(
        "ordering must be one of:",
        paste(valid_ordering, collapse = ", ")
      ))
    }
  }

  if (!is.null(radius) && !is.numeric(radius)) {
    stop("radius must be a numeric value")
  }

  if (!is.numeric(startAngle)) {
    stop("startAngle must be a numeric value")
  }

  if (!is.numeric(endAngle)) {
    stop("endAngle must be a numeric value")
  }

  if (!is.null(startRadius) && !is.numeric(startRadius)) {
    stop("startRadius must be a numeric value")
  }

  if (!is.null(endRadius) && !is.numeric(endRadius)) {
    stop("endRadius must be a numeric value")
  }

  if (!is.null(width) && (!is.numeric(width) || width <= 0)) {
    stop("width must be a positive numeric value")
  }

  if (!is.null(height) && (!is.numeric(height) || height <= 0)) {
    stop("height must be a positive numeric value")
  }

  # Get all named parameters as a list
  named_params <- dropNulls(mget(
    setdiff(names(formals()), "..."),
    environment()
  ))
  # Collect additional parameters from ellipsis
  extra_params <- list(...)
  # Add type parameter (internal)
  config <- list(type = "circular")
  # Merge with named parameters and additional parameters
  structure(c(config, named_params, extra_params), class = "g6-layout")
}
