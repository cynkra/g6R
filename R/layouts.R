#' Set the layout algorithm for a g6 graph
#'
#' This function configures the layout algorithm used to position nodes in a g6 graph.
#'
#' @param graph A g6 graph object created with \code{g6()}.
#' @param layout An existing layout function like \link{circular_layout} or a string like `circular-layout`.
#'   At minimum, this can be a list that should contain a \code{type} element specifying the layout algorithm.
#'   Additional parameters depend on the layout type chosen, for instance \code{list(type = "force")}.
#'
#' @return The modified g6 graph object with the specified layout, allowing for method chaining.
#'
#' @details
#' G6 provides several layout algorithms, each suitable for different graph structures:
#'
#' \itemize{
#'   \item \strong{force}: Force-directed layout using physical simulation of forces.
#'   \item \strong{random}: Random layout placing nodes randomly.
#'   \item \strong{circular}: Arranges nodes on a circle.
#'   \item \strong{radial}: Radial layout with nodes arranged outward from a central node.
#'   \item \strong{grid}: Arranges nodes in a grid pattern.
#'   \item \strong{concentric}: Concentric circles with important nodes in the center.
#'   \item \strong{dagre}: Hierarchical layout for directed acyclic graphs.
#'   \item \strong{fruchterman}: Force-directed layout based on the Fruchterman-Reingold algorithm.
#'   \item \strong{mds}: Multidimensional scaling layout.
#'   \item \strong{comboForce}: Force-directed layout specially designed for combo graphs.
#' }
#'
#' Each layout algorithm has specific configuration options. See the G6 documentation
#' for detailed information on each layout and its parameters:
#' \url{https://g6.antv.antgroup.com/en/manual/layout/overview}.
#'
#' @seealso [g6()]
#' @export
g6_layout <- function(graph, layout = d3_force_layout()) {
  if (is.null(layout)) {
    stop("layout must be specified.")
  }
  graph$x$layout <- validate_layout(layout)
  graph
}

#' @keywords internal
validate_layout <- function(x) {
  validate_component(x, "layout")
}

#' @keywords internal
build_layout <- function(type, ...) {
  # Which function called build_layout?
  caller_fun <- sys.function(sys.parent())
  caller_env <- parent.frame()

  #Get formal argument names from caller function
  caller_formals <- setdiff(names(formals(caller_fun)), "...")

  named_params <- mget(
    caller_formals,
    envir = caller_env,
    ifnotfound = list(NULL)
  )

  named_params <- dropNulls(named_params)
  extra_params <- list(...)
  c(list(type = type), named_params, extra_params)
}

#' Generate G6 AntV Dagre layout configuration
#'
#' This function creates a configuration list for G6 AntV Dagre layout
#' with all available options as parameters.
#'
#' @param rankdir Layout direction: "TB" (top to bottom), "BT" (bottom to top),
#'   "LR" (left to right), or "RL" (right to left).
#' @param align Node alignment: "UL" (upper left), "UR" (upper right),
#'   "DL" (down left), or "DR" (down right).
#' @param nodesep Node spacing (px). When rankdir is "TB" or "BT", it's the horizontal.
#'   spacing of nodes; when rankdir is "LR" or "RL", it's the vertical spacing of nodes.
#' @param nodesepFunc Function to customize node spacing for different nodes,
#'   in the form of function(node) that returns a number. Has higher priority than nodesep.
#' @param ranksep Layer spacing (px). When rankdir is "TB" or "BT", it's the vertical spacing
#'   between adjacent layers; when rankdir is "LR" or "RL", it's the horizontal spacing.
#' @param ranksepFunc Function to customize layer spacing, in the form of function(node)
#'   that returns a number. Has higher priority than ranksep.
#' @param ranker Algorithm for assigning ranks to nodes: "network-simplex", "tight-tree",
#'   or "longest-path".
#' @param nodeSize Node size for collision detection. Can be a single number (same width/height),
#'   an array \code{[width, height]}, or a function that returns either.
#' @param controlPoints Whether to retain edge control points.
#' @param begin Alignment position of the upper left corner of the layout.
#' Can be \code{[x, y]} or \code{[x, y, z]}.
#' @param sortByCombo Whether to sort nodes on the same layer by parentId to prevent combo overlap.
#' @param edgeLabelSpace Whether to leave space for edge labels.
#' @param nodeOrder Reference array of node order on the same layer, containing node id values.
#' @param radial Whether to perform a radial layout based on dagre.
#' @param focusNode Focused node (only used when radial=TRUE). Can be a node ID or node object.
#' @param preset Node positions to reference during layout calculation.
#' @param ... Additional parameters to pass to the layout.
#'
#' @return A list containing the configuration for G6 AntV Dagre layout.
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
  build_layout("antv-dagre", ...)
}

#' Generate G6 AntV circular layout configuration
#'
#' This function creates a configuration list for G6 AntV circular layout
#' with all available options as parameters.
#'
#' @param angleRatio How many `2*PI` are there between the first node and the last node.
#' @param center Center of layout as vector `c(x, y)` or `c(x, y, z)`.
#' @param clockwise Is it arranged clockwise?
#' @param divisions Number of segments that nodes are placed on the ring.
#' @param nodeSize Node size (diameter) for collision detection.
#' @param nodeSpacing Minimum distance between rings.
#' @param ordering Basis for sorting nodes ("topology", "topology-directed", or "degree").
#' @param radius Radius of the circle (overrides startRadius and endRadius).
#' @param startAngle Starting angle of the layout.
#' @param endAngle End angle of the layout.
#' @param startRadius Starting radius of the spiral layout.
#' @param endRadius End radius of the spiral layout.
#' @param width Width of layout.
#' @param height Height of layout.
#' @param ... Additional parameters to pass to the layout.
#' See \url{https://g6.antv.antgroup.com/en/manual/layout/circular-layout}.
#'
#' @return A list containing the configuration for G6 AntV circular layout.
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

  build_layout("circular", ...)
}

#' Generate G6 AntV Compact Box layout configuration
#'
#' This function creates a configuration list for G6 AntV Compact Box layout
#' with all available options as parameters. The Compact Box layout is designed
#' for efficiently laying out trees and hierarchical structures.
#'
#' @param direction Layout direction: "LR" (left to right), "RL" (right to left),
#'   "TB" (top to bottom), "BT" (bottom to top), "H" (horizontal), or "V" (vertical)
#' @param getSide Function to set the nodes to be arranged on the left/right side
#'   of the root node. If not set, the algorithm automatically assigns the nodes
#'   to the left/right side. Note: This parameter is only effective when the layout
#'   direction is "H". Function format: \code{function(node) { return "left" or "right" }}
#' @param getId Callback function for generating node IDs.
#' Function format: \code{function(node) { return string }}
#' @param getWidth Function to calculate the width of each node.
#' Function format: \code{function(node) { return number }}
#' @param getHeight Function to calculate the height of each node.
#' Function format: \code{function(node) { return number }}
#' @param getHGap Function to calculate the horizontal gap for each node.
#' Function format: \code{function(node) { return number }}
#' @param getVGap Function to calculate the vertical gap for each node.
#' Function format: \code{function(node) { return number }}
#' @param radial Whether to enable radial layout
#' @param ... Additional parameters to pass to the layout.
#' See \url{https://g6.antv.antgroup.com/en/manual/layout/compact-box-layout}.
#'
#' @return A list containing the configuration for G6 AntV Compact Box layout.
#' @export
#'
#' @examples
#' # Basic compact box layout
#' box_config <- compact_box_layout()
#'
#' # Vertical compact box layout
#' box_config <- compact_box_layout(
#'   direction = "TB"
#' )
#'
#' # Radial layout
#' box_config <- compact_box_layout(
#'   radial = TRUE
#' )
compact_box_layout <- function(
  direction = c("LR", "RL", "TB", "BT", "H", "V"),
  getSide = NULL,
  getId = NULL,
  getWidth = NULL,
  getHeight = NULL,
  getHGap = NULL,
  getVGap = NULL,
  radial = FALSE,
  ...
) {
  # Validate direction
  direction <- match.arg(direction)

  # Validate getSide
  if (!is.null(getSide)) {
    if (!is.function(getSide)) {
      stop("getSide must be a function that returns 'left' or 'right'")
    }
    if (direction != "H") {
      warning("getSide is only effective when direction is 'H'")
    }
  }

  # Validate getId
  if (!is.null(getId) && !is_js(getId)) {
    stop("getId must be a JS function that returns a string")
  }

  # Validate getWidth
  if (!is.null(getWidth) && !is_js(getWidth)) {
    stop("getWidth must be a JS function that returns a number")
  }

  # Validate getHeight
  if (!is.null(getHeight) && !is_js(getHeight)) {
    stop("getHeight must be a JS function that returns a number")
  }

  # Validate getHGap
  if (!is.null(getHGap) && !is_js(getHGap)) {
    stop("getHGap must be a JS function that returns a number")
  }

  # Validate getVGap
  if (!is.null(getVGap) && !is_js(getVGap)) {
    stop("getVGap must be a JS function that returns a number")
  }

  # Validate radial
  if (!is.logical(radial)) {
    stop("radial must be a logical value (TRUE or FALSE)")
  }

  build_layout("compact-box", ...)
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
#' See \url{https://g6.antv.antgroup.com/en/manual/layout/d3-force}.
#'
#' @return A list containing the configuration for G6 AntV D3 Force layout.
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
  build_layout("d3-force", ...)
}

#' Generate G6 AntV Concentric layout configuration
#'
#' This function creates a configuration list for G6 AntV Concentric layout
#' with all available options as parameters. The Concentric layout places nodes in
#' concentric circles based on a centrality measure.
#'
#' @param center The center position of the circular layout \code{[x, y]} or \code{[x, y, z]}.
#'   By default, it's the center position of the current container.
#' @param clockwise Whether nodes are arranged in clockwise order.
#' @param equidistant Whether the distances between rings are equal.
#' @param width The width of the layout. By default, the container width is used.
#' @param height The height of the layout. By default, the container height is used.
#' @param sortBy Specify the sorting basis (node attribute name). The higher the value,
#'   the more central the node will be placed. If it is "degree", the degree of the node
#'   will be calculated. The higher the degree, the more central the node will be placed.
#' @param maxLevelDiff If the maximum attribute difference of nodes in the same layer
#'   is undefined, it will be set to maxValue / 4, where maxValue is the maximum
#'   attribute value of the sorting basis. For example, if sortBy is 'degree', then
#'   maxValue is the degree of the node with the largest degree among all nodes.
#' @param nodeSize Node size (diameter). Used to prevent collision detection when nodes overlap.
#'   Can be a number, a 2-element vector \code{[width, height]}, or a function that returns a number.
#' @param nodeSpacing Minimum distance between rings, used to adjust the radius.
#'   Can be a number, a vector of numbers, or a function that returns a number.
#' @param preventOverlap Whether to prevent node overlap. Must be coordinated with the nodeSize
#'   attribute or the data.size attribute in the node data. Only when data.size is set in the
#'   data or the nodeSize value that is the same as the current graph node size is configured
#'   in the layout, can node overlap collision detection be performed.
#' @param startAngle The arc at which to start layout of nodes (in radians)
#' @param sweep If the radian difference between the first and last nodes in the same layer
#'   is undefined, it will be set to \code{2 * Math.PI * (1 - 1 / |level.nodes|)}, where level.nodes
#'   is the number of nodes in each layer calculated by the algorithm, and |level.nodes| is
#'   the number of nodes in the layer.
#' @param ... Additional parameters to pass to the layout.
#' See \url{https://g6.antv.antgroup.com/en/manual/layout/concentric-layout}.
#'
#' @return A list containing the configuration for G6 AntV Concentric layout
#' @export
#'
#' @examples
#' # Basic concentric layout
#' concentric_config <- concentric_layout()
#'
#' # Custom concentric layout with degree-based sorting and overlap prevention
#' concentric_config <- concentric_layout(
#'   clockwise = TRUE,
#'   sortBy = "degree",
#'   preventOverlap = TRUE,
#'   nodeSize = 30,
#'   nodeSpacing = 20
#' )
#'
#' # Custom concentric layout with specific center and dimensions
#' concentric_config <- concentric_layout(
#'   center = c(300, 300),
#'   width = 600,
#'   height = 600,
#'   equidistant = TRUE,
#'   startAngle = pi
#' )
concentric_layout <- function(
  center = NULL,
  clockwise = FALSE,
  equidistant = FALSE,
  width = NULL,
  height = NULL,
  sortBy = "degree",
  maxLevelDiff = NULL,
  nodeSize = 30,
  nodeSpacing = 10,
  preventOverlap = FALSE,
  startAngle = 3 / 2 * pi,
  sweep = NULL,
  ...
) {
  # Validate center
  if (!is.null(center)) {
    if (!is.numeric(center) || !(length(center) == 2 || length(center) == 3)) {
      stop("center must be a numeric vector with 2 or 3 elements")
    }
  }

  # Validate clockwise
  if (!is.logical(clockwise)) {
    stop("clockwise must be a logical value (TRUE or FALSE)")
  }

  # Validate equidistant
  if (!is.logical(equidistant)) {
    stop("equidistant must be a logical value (TRUE or FALSE)")
  }

  # Validate width
  if (!is.null(width)) {
    if (!is.numeric(width) || width <= 0) {
      stop("width must be a positive number")
    }
  }

  # Validate height
  if (!is.null(height)) {
    if (!is.numeric(height) || height <= 0) {
      stop("height must be a positive number")
    }
  }

  # Validate sortBy
  if (!is.character(sortBy)) {
    stop("sortBy must be a character string")
  }

  # Validate maxLevelDiff
  if (!is.null(maxLevelDiff)) {
    if (!is.numeric(maxLevelDiff) || maxLevelDiff <= 0) {
      stop("maxLevelDiff must be a positive number")
    }
  }

  # Validate nodeSize
  if (!is.null(nodeSize)) {
    if (!is.numeric(nodeSize) && !is_js(nodeSize)) {
      if (is.numeric(nodeSize) && is.vector(nodeSize)) {
        if (length(nodeSize) != 2) {
          stop(
            "nodeSize as a vector must have exactly 2 elements [width, height]"
          )
        }
      } else {
        stop(
          "nodeSize must be a number, a 2-element vector [width, height], or a JS function"
        )
      }
    }
    if (is.numeric(nodeSize) && !is.vector(nodeSize) && nodeSize <= 0) {
      stop("nodeSize as a single number must be positive")
    }
  }

  # Validate nodeSpacing
  if (!is.null(nodeSpacing)) {
    if (!is.numeric(nodeSpacing) && !is_js(nodeSpacing)) {
      if (is.numeric(nodeSpacing) && is.vector(nodeSpacing)) {
        # It's a vector of numbers, which is allowed
      } else {
        stop("nodeSpacing must be a number, a numeric vector, or a JS function")
      }
    }
    if (is.numeric(nodeSpacing) && !is.vector(nodeSpacing) && nodeSpacing < 0) {
      stop("nodeSpacing as a single number must be non-negative")
    }
  }

  # Validate preventOverlap
  if (!is.logical(preventOverlap)) {
    stop("preventOverlap must be a logical value (TRUE or FALSE)")
  }

  # Validate startAngle
  if (!is.numeric(startAngle)) {
    stop("startAngle must be a number")
  }

  # Validate sweep
  if (!is.null(sweep)) {
    if (!is.numeric(sweep)) {
      stop("sweep must be a number")
    }
  }
  build_layout("concentric", ...)
}

#' Generate G6 AntV Dagre layout configuration
#'
#' This function creates a configuration list for G6 AntV Dagre layout
#' with all available options as parameters. The Dagre layout is designed
#' for directed graphs, creating hierarchical layouts with nodes arranged in layers.
#'
#' @param rankdir Layout direction: "TB" (top to bottom), "BT" (bottom to top),
#'   "LR" (left to right), or "RL" (right to left).
#' @param align Node alignment: "UL" (upper left), "UR" (upper right),
#'   "DL" (down left), or "DR" (down right).
#' @param nodesep Node spacing (px). When rankdir is "TB" or "BT", it's the horizontal
#'   spacing of nodes; when rankdir is "LR" or "RL", it's the vertical spacing of nodes.
#' @param ranksep Interlayer spacing (px). When rankdir is "TB" or "BT", it's the
#'   spacing between adjacent layers in the vertical direction; when rankdir is "LR" or "RL",
#'   it represents the spacing between adjacent layers in the horizontal direction.
#' @param ranker The algorithm for assigning a level to each node: "network-simplex" (the network
#'   simplex algorithm), "tight-tree" (the compact tree algorithm), or "longest-path"
#'   (the longest path algorithm).
#' @param nodeSize G6 custom attribute to specify the node size uniformly or for each node.
#'   Can be a single number (same width/height), an array \code{[width, height]},
#'   or a function that returns either.
#' @param controlPoints Whether to keep the control points of the edge.
#' @param ... Additional parameters to pass to the layout. See
#' \url{https://g6.antv.antgroup.com/en/manual/layout/dagre-layout}.
#'
#' @return A list containing the configuration for G6 AntV Dagre layout.
#' @export
#'
#' @examples
#' # Basic dagre layout
#' dagre_config <- dagre_layout()
#'
#' # Custom dagre layout with horizontal flow
#' dagre_config <- dagre_layout(
#'   rankdir = "LR",
#'   nodesep = 80,
#'   ranksep = 150,
#'   ranker = "tight-tree"
#' )
#'
#' # Custom dagre layout with specific node size
#' dagre_config <- dagre_layout(
#'   nodeSize = 40,
#'   controlPoints = TRUE
#' )
dagre_layout <- function(
  rankdir = c("TB", "BT", "LR", "RL"),
  align = c("UL", "UR", "DL", "DR"),
  nodesep = 50,
  ranksep = 100,
  ranker = c("network-simplex", "tight-tree", "longest-path"),
  nodeSize = NULL,
  controlPoints = FALSE,
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

  # Validate ranksep
  if (!is.numeric(ranksep) || ranksep < 0) {
    stop("ranksep must be a non-negative number")
  }

  # Validate ranker
  ranker <- match.arg(ranker)

  # Validate nodeSize
  if (!is.null(nodeSize)) {
    if (!is.numeric(nodeSize) && !is_js(nodeSize)) {
      if (is.numeric(nodeSize) && is.vector(nodeSize)) {
        if (length(nodeSize) != 2) {
          stop(
            "nodeSize as a vector must have exactly 2 elements [width, height]"
          )
        }
      } else {
        stop(
          "nodeSize must be a number, a 2-element vector [width, height], or a JS function"
        )
      }
    }
  }

  # Validate controlPoints
  if (!is.logical(controlPoints)) {
    stop("controlPoints must be a logical value (TRUE or FALSE)")
  }
  build_layout("dagre", ...)
}


#' Generate G6 Force Atlas2 layout configuration
#'
#' This function creates a configuration list for G6 Force Atlas2 layout
#' with all available options as parameters.
#'
#' @param barnesHut Logical. Whether to enable quadtree acceleration.
#' When enabled, improves performance for large graphs but may affect layout quality.
#' By default, enabled if node count > 250.
#' @param dissuadeHubs Logical. Whether to enable hub mode.
#' If TRUE, nodes with higher in-degree are more likely to be placed at the center
#' than those with high out-degree. Defaults to FALSE.
#' @param height Numeric. Layout height. Defaults to container height.
#' @param kg Numeric. Gravity coefficient. The larger the value,
#' the more concentrated the layout is at the center. Defaults to 1.
#' @param kr Numeric. Repulsion coefficient. Adjusts the compactness of the layout.
#' The larger the value, the looser the layout. Defaults to 5.
#' @param ks Numeric. Controls the speed of node movement during iteration. Defaults to 0.1.
#' @param ksmax Numeric. Maximum node movement speed during iteration. Defaults to 10.
#' @param mode Character. Clustering mode.
#' Options are "normal" or "linlog". In "linlog" mode, clusters are more compact.
#' Defaults to "normal".
#' @param nodeSize Numeric or function. Node size (diameter).
#' Used for repulsion calculation when preventOverlap is enabled.
#'
#' If not set, uses data.size in node data.
#' @param preventOverlap Logical. Whether to prevent node overlap.
#' When enabled, layout considers node size to avoid overlap.
#' Node size is specified by \code{nodeSize} or \code{data.size} in node data. Defaults to FALSE.
#' @param prune Logical. Whether to enable auto-pruning.
#' By default, enabled if node count > 100. Pruning speeds up
#' convergence but may reduce layout quality. Set to FALSE to disable auto-activation.
#' @param tao Numeric. Tolerance for stopping oscillation when layout is near convergence. Defaults to 0.1.
#' @param width Numeric. Layout width. Defaults to container width.
#' @param center Numeric vector of length 2. Layout center in the form \code{[x, y]}.
#' Each node is attracted to this point, with gravity controlled by \code{kg}.
#' If not set, uses canvas center.
#' @param ... Additional parameters to pass to the layout.
#' See \url{https://g6.antv.antgroup.com/en/manual/layout/force-atlas2-layout}.
#'
#' @return A list containing the configuration for G6 force atlas2 layout.
#' @export
#'
#' @examples
#' if (interactive()) {
#'   g6(lesmis$nodes, lesmis$edges) |>
#'     g6_layout(force_atlas2_layout(
#'       kr = 20,
#'       preventOverlap = TRUE,
#'       center = c(250, 250))) |>
#'     g6_options(autoResize = TRUE) |>
#'     g6_behaviors(
#'       "zoom-canvas",
#'       drag_element()
#'     )
#' }
force_atlas2_layout <- function(
  barnesHut = NULL,
  dissuadeHubs = FALSE,
  height = NULL,
  kg = 1,
  kr = 5,
  ks = 0.1,
  ksmax = 10,
  mode = "normal",
  nodeSize = NULL,
  preventOverlap = FALSE,
  prune = NULL,
  tao = 0.1,
  width = NULL,
  center = NULL,
  ...
) {
  if (!is.null(barnesHut) && !is.logical(barnesHut)) {
    stop("'barnesHut' must be NULL or logical (TRUE/FALSE)")
  }

  if (!is.logical(dissuadeHubs)) {
    stop("'dissuadeHubs' must be logical (TRUE/FALSE)")
  }

  if (
    !is.null(height) &&
      (!is.numeric(height) || length(height) != 1 || height < 0)
  ) {
    stop("'height' must be a single non-negative number or NULL")
  }

  if (!is.numeric(kg) || length(kg) != 1 || kg < 0) {
    stop("'kg' must be a single non-negative number")
  }

  if (!is.numeric(kr) || length(kr) != 1 || kr < 0) {
    stop("'kr' must be a single non-negative number")
  }

  if (!is.numeric(ks) || length(ks) != 1 || ks < 0) {
    stop("'ks' must be a single non-negative number")
  }

  if (!is.numeric(ksmax) || length(ksmax) != 1 || ksmax < 0) {
    stop("'ksmax' must be a single non-negative number")
  }

  if (!is.character(mode) || !(mode %in% c("normal", "linlog"))) {
    stop("'mode' must be one of 'normal' or 'linlog'")
  }

  if (!is.null(nodeSize) && !is.numeric(nodeSize) && !is_js(nodeSize)) {
    stop("'nodeSize' must be a numeric value, a function, or NULL")
  }

  if (!is.logical(preventOverlap)) {
    stop("'preventOverlap' must be logical (TRUE/FALSE)")
  }

  if (!is.null(prune) && !is.logical(prune)) {
    stop("'prune' must be logical (TRUE/FALSE) or NULL")
  }

  if (!is.numeric(tao) || length(tao) != 1 || tao < 0) {
    stop("'tao' must be a single non-negative number")
  }

  if (
    !is.null(width) && (!is.numeric(width) || length(width) != 1 || width < 0)
  ) {
    stop("'width' must be a single non-negative number or NULL")
  }

  if (!is.null(center)) {
    if (!is.numeric(center) || length(center) != 2) {
      stop("'center' must be a numeric vector of length 2 or NULL")
    }
  }
  build_layout("force-atlas2", ...)
}

#' Generate G6 Fruchterman layout configuration
#'
#' This function creates a configuration list for G6 Fruchterman layout
#' with all available options as parameters.
#' @param height Numeric. Layout height. Defaults to container height.
#' @param width Numeric. Layout width. Defaults to container width.
#' @param gravity Numeric. Central force attracting nodes to the center.
#' Larger values make the layout more compact. Defaults to 10.
#' @param speed Numeric. Node movement speed per iteration. Higher values may cause oscillation. Defaults to 5.
#' @param ... Additional parameters to pass to the layout.
#' See \url{https://g6.antv.antgroup.com/en/manual/layout/fruchterman-layout}.
#'
#' @return A list containing the configuration for G6 fruchterman layout.
#' @export
#' @examples
#' if (interactive()) {
#'   g6(lesmis$nodes, lesmis$edges) |>
#'    g6_layout(fruchterman_layout(
#'      gravity = 5,
#'      speed = 5
#'    )) |>
#'    g6_behaviors(
#'      "zoom-canvas",
#'      drag_element()
#'    )
#' }
#'
fruchterman_layout <- function(
  height = NULL,
  width = NULL,
  gravity = 10,
  speed = 5,
  ...
) {
  if (
    !is.null(height) &&
      (!is.numeric(height) || length(height) != 1 || height < 0)
  ) {
    stop("'height' must be a single non-negative number or NULL")
  }

  if (
    !is.null(width) && (!is.numeric(width) || length(width) != 1 || width < 0)
  ) {
    stop("'width' must be a single non-negative number or NULL")
  }

  if (!is.numeric(gravity) || length(gravity) != 1 || gravity < 0) {
    stop("'gravity' must be a single non-negative number")
  }

  if (!is.numeric(speed) || length(speed) != 1 || speed < 0) {
    stop("'speed' must be a single non-negative number")
  }
  build_layout("fruchterman", ...)
}

#' Generate G6 Radial layout configuration
#'
#' This function creates a configuration list for G6 Radial layout
#' with all available options as parameters.
#'
#' @param center Numeric vector of length 2. Center coordinates.
#' @param focusNode Character, list (Node), or NULL. Radiating center node. Defaults to NULL.
#' @param height Numeric. Canvas height.
#' @param width Numeric. Canvas width.
#' @param nodeSize Numeric. Node size (diameter).
#' @param nodeSpacing Numeric or function. Minimum node spacing (effective when preventing overlap). Defaults to 10.
#' @param linkDistance Numeric. Edge length. Defaults to 50.
#' @param unitRadius Numeric or NULL. Radius per circle. Defaults to 100.
#' @param maxIteration Numeric. Maximum number of iterations. Defaults to 1000.
#' @param maxPreventOverlapIteration Numeric. Max iterations for overlap prevention. Defaults to 200.
#' @param preventOverlap Logical. Whether to prevent node overlap. Defaults to FALSE.
#' @param sortBy Character. Field for sorting nodes in the same layer.
#' @param sortStrength Numeric. Sorting strength for nodes in the same layer. Defaults to 10.
#' @param strictRadial Logical. Strictly place nodes in the same layer on the same ring. Defaults to TRUE.
#' @param ... Additional parameters to pass to the layout.
#' See \url{https://g6.antv.antgroup.com/en/manual/layout/radial-layout}.
#'
#' @return A list containing the configuration for G6 radial layout.
#' @export
#' @examples
#' if (interactive()) {
#'   g6(jsonUrl = "https://assets.antv.antgroup.com/g6/radial.json") |>
#'     g6_layout(
#'       radial_layout(
#'         unitRadius = 100,
#'         linkDistance = 200
#'       )
#'     ) |>
#'     g6_behaviors(
#'       "zoom-canvas",
#'       drag_element()
#'     )
#' }
#'
radial_layout <- function(
  center = NULL,
  focusNode = NULL,
  height = NULL,
  width = NULL,
  nodeSize = NULL,
  nodeSpacing = 10,
  linkDistance = 50,
  unitRadius = 100,
  maxIteration = 1000,
  maxPreventOverlapIteration = 200,
  preventOverlap = FALSE,
  sortBy = NULL,
  sortStrength = 10,
  strictRadial = TRUE,
  ...
) {
  if (!is.null(center)) {
    if (!is.numeric(center) || length(center) != 2) {
      stop("'center' must be a numeric vector of length 2 or NULL")
    }
  }

  if (!is.null(focusNode) && !(is.character(focusNode) || is.list(focusNode))) {
    stop("'focusNode' must be a character string, a list (Node), or NULL")
  }

  if (
    !is.null(height) &&
      (!is.numeric(height) || length(height) != 1 || height < 0)
  ) {
    stop("'height' must be a single non-negative number or NULL")
  }

  if (
    !is.null(width) && (!is.numeric(width) || length(width) != 1 || width < 0)
  ) {
    stop("'width' must be a single non-negative number or NULL")
  }

  if (
    !is.null(nodeSize) &&
      (!is.numeric(nodeSize) || length(nodeSize) != 1 || nodeSize < 0)
  ) {
    stop("'nodeSize' must be a single non-negative number or NULL")
  }

  if (!is.numeric(nodeSpacing) && !is.function(nodeSpacing)) {
    stop("'nodeSpacing' must be a number or a function")
  }

  if (
    !is.numeric(linkDistance) || length(linkDistance) != 1 || linkDistance < 0
  ) {
    stop("'linkDistance' must be a single non-negative number")
  }

  if (
    !is.null(unitRadius) &&
      (!is.numeric(unitRadius) || length(unitRadius) != 1 || unitRadius < 0)
  ) {
    stop("'unitRadius' must be a single non-negative number or NULL")
  }

  if (
    !is.numeric(maxIteration) || length(maxIteration) != 1 || maxIteration < 1
  ) {
    stop("'maxIteration' must be a positive number")
  }

  if (
    !is.numeric(maxPreventOverlapIteration) ||
      length(maxPreventOverlapIteration) != 1 ||
      maxPreventOverlapIteration < 1
  ) {
    stop("'maxPreventOverlapIteration' must be a positive number")
  }

  if (!is.logical(preventOverlap) || length(preventOverlap) != 1) {
    stop("'preventOverlap' must be a logical value")
  }

  if (!is.null(sortBy) && (!is.character(sortBy) || length(sortBy) != 1)) {
    stop("'sortBy' must be a character string or NULL")
  }

  if (
    !is.numeric(sortStrength) || length(sortStrength) != 1 || sortStrength < 0
  ) {
    stop("'sortStrength' must be a single non-negative number")
  }

  if (!is.logical(strictRadial) || length(strictRadial) != 1) {
    stop("'strictRadial' must be a logical value")
  }

  build_layout("radial", ...)
}

#' Generate G6 Dendrogram layout configuration
#'
#' This function creates a configuration list for G6 Dendrogram layout
#' with all available options as parameters.
#'
#' @param direction Character. Layout direction. Options: "LR", "RL", "TB", "BT", "H", "V". Defaults to "LR".
#' @param nodeSep Numeric. Node spacing, distance between nodes on the same level. Defaults to 20.
#' @param rankSep Numeric. Rank spacing, distance between different levels. Defaults to 200.
#' @param radial Logical. Whether to enable radial layout. Defaults to FALSE.
#' @param ... Additional parameters to pass to the layout.
#' See \url{https://g6.antv.antgroup.com/en/manual/layout/dendrogram-layout}.
#'
#' @return A list containing the configuration for G6 dendrogram layout.
#' @export
dendrogram_layout <- function(
  direction = c("LR", "RL", "TB", "BT", "H", "V"),
  nodeSep = 20,
  rankSep = 200,
  radial = FALSE,
  ...
) {
  directions <- match.arg(direction)

  if (!is.numeric(nodeSep) || length(nodeSep) != 1 || nodeSep < 0) {
    stop("'nodeSep' must be a single non-negative number")
  }

  if (!is.numeric(rankSep) || length(rankSep) != 1 || rankSep < 0) {
    stop("'rankSep' must be a single non-negative number")
  }

  if (!is.logical(radial) || length(radial) != 1) {
    stop("'radial' must be a logical value")
  }
  build_layout("dendrogram", ...)
}

#' Create an AntV Combo Combined Layout
#'
#' Creates a combo combined layout configuration for G6 graphs. This layout
#' algorithm combines different layout strategies for elements inside combos
#' and the outermost layer, providing hierarchical organization of graph elements.
#'
#' @param center Layout center coordinates. A numeric vector of length 2 \code{[x, y]}.
#'   If NULL, uses the graph center. Default is NULL.
#' @param comboPadding Padding value inside the combo, used only for force
#'   calculation, not for rendering. It is recommended to set the same value
#'   as the visual padding. Can be a number, numeric vector, function, or
#'   JS function. Default is 10.
#' @param innerLayout Layout algorithm for elements inside the combo. Should be
#'   a Layout object or function. If NULL, uses ConcentricLayout as default.
#' @param nodeSize Node size (diameter), used for collision detection. If not
#'   specified, it is calculated from the node's size property. Can be a number,
#'   numeric vector, function, or JS function. Default is 10.
#' @param outerLayout Layout algorithm for the outermost layer. Should be a
#'   Layout object or function. If NULL, uses ForceLayout as default.
#' @param spacing Minimum spacing between node/combo edges when preventNodeOverlap
#'   or preventOverlap is true. Can be a number, function, or JS function for
#'   different nodes. Default is NULL.
#' @param treeKey Tree key identifier as a character string. Default is NULL.
#' @param ... Additional parameters passed to the layout configuration.
#' See \url{https://g6.antv.antgroup.com/en/manual/layout/combo-combined-layout}.
#'
#' @return A layout configuration object for use with G6 graphs.
#'
#' @details
#' The combo combined layout is particularly useful for graphs with hierarchical
#' structures where you want different layout algorithms for different levels
#' of the hierarchy. The inner layout handles elements within combos, while
#' the outer layout manages the overall arrangement.
#'
#' @examples
#' # Basic combo combined layout
#' layout <- combo_combined_layout()
#'
#' # Custom configuration with specific center and padding
#' layout <- combo_combined_layout(
#'   comboPadding = 20,
#'   nodeSize = 15,
#'   spacing = 10
#' )
#'
#' @seealso \code{\link{antv_dagre_layout}} for dagre layout configuration
#'
#' @export
combo_combined_layout <- function(
  center = NULL,
  comboPadding = 10,
  innerLayout = NULL,
  nodeSize = 10,
  outerLayout = NULL,
  spacing = NULL,
  treeKey = NULL,
  ...
) {
  # Validate center
  if (!is.null(center)) {
    if (!is.numeric(center) || length(center) != 2) {
      stop("center must be a numeric vector with 2 elements [x, y]")
    }
  }

  # Validate comboPadding
  if (!is.null(comboPadding)) {
    if (is.numeric(comboPadding)) {
      if (is.vector(comboPadding) && length(comboPadding) > 1) {
        # Allow numeric vector
      } else if (length(comboPadding) == 1 && comboPadding < 0) {
        stop("comboPadding must be a non-negative number")
      }
    } else if (!is_js(comboPadding)) {
      stop(
        "comboPadding must be a number, numeric vector, JS function, or JS function"
      )
    }
  }

  # Validate innerLayout
  if (!is.null(innerLayout)) {
    if (!is.list(innerLayout) && !is_js(innerLayout)) {
      stop("innerLayout must be a Layout object or JS function")
    }
  }

  # Validate nodeSize
  if (!is.null(nodeSize)) {
    if (is.numeric(nodeSize)) {
      if (is.vector(nodeSize) && length(nodeSize) > 1) {
        # Allow numeric vector
      } else if (length(nodeSize) == 1 && nodeSize <= 0) {
        stop("nodeSize must be a positive number")
      }
    } else if (!is_js(nodeSize)) {
      stop(
        "nodeSize must be a number, numeric vector, function, or JS function"
      )
    }
  }

  # Validate outerLayout
  if (!is.null(outerLayout)) {
    if (!is.list(outerLayout) && !is_js(outerLayout)) {
      stop("outerLayout must be a Layout object or JS function")
    }
  }

  # Validate spacing
  if (!is.null(spacing)) {
    if (is.numeric(spacing)) {
      if (spacing < 0) {
        stop("spacing must be a non-negative number")
      }
    } else if (is.function(spacing)) {
      # Allow function
    } else if (!is_js(spacing)) {
      stop("spacing must be a number, function, or JS function")
    }
  }

  # Validate treeKey
  if (!is.null(treeKey)) {
    if (!is.character(treeKey) || length(treeKey) != 1) {
      stop("treeKey must be a single character string")
    }
  }

  build_layout("combo-combined", ...)
}

#' @keywords internal
valid_layouts <- c(
  # N = 20
  "antv-dagre" = antv_dagre_layout,
  "circular" = circular_layout,
  "combo-combined" = combo_combined_layout,
  "concentric" = concentric_layout,
  "d3-force" = d3_force_layout,
  #"d3-force-3d" = d3_force_3d_layout,
  #"dagre" = dagre_layout,
  #"fishbone" = fishbone_layout,
  #"force",
  "force-atlas2" = force_atlas2_layout,
  "fruchterman" = fruchterman_layout,
  #"grid" = grid_layout,
  #"mds" = mds_layout,
  "radial" = radial_layout,
  #"random",
  #"snake",
  "compact-box" = compact_box_layout,
  "dendrogram" = dendrogram_layout #,
  #"mindmap",
  #"indented"
)
