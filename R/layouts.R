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
g6_layout <- function(graph, layout = d3_force_layout()) {
  graph$x$layout <- validate_layout(layout)
  graph
}

#' @keywords internal
valid_layouts <- c(
  # N = 20
  "antv-dagre",
  "circular",
  "combo-combined",
  "concentric",
  "d3-force",
  "d3-force-3d",
  "dagre",
  "fishbone",
  "force",
  "force-atlas2",
  "fruchterman",
  "grid",
  "mds",
  "radial",
  "random",
  "snake",
  "compact-box",
  "dendrogram",
  "mindmap",
  "indented"
)

#' @keywords internal
validate_layout <- function(x) {
  if (!(x[["type"]] %in% valid_layouts)) {
    stop(
      sprintf(
        "Current layout '%s' is not a valid. Valid layouts are: %s.",
        x[["type"]],
        paste(valid_layouts, collapse = ", ")
      )
    )
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
  c(config, named_params, extra_params)
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
  c(config, named_params, extra_params)
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
#'   direction is "H". Function format: function(node) { return "left" or "right" }
#' @param getId Callback function for generating node IDs. Function format: function(node) { return string }
#' @param getWidth Function to calculate the width of each node. Function format: function(node) { return number }
#' @param getHeight Function to calculate the height of each node. Function format: function(node) { return number }
#' @param getHGap Function to calculate the horizontal gap for each node. Function format: function(node) { return number }
#' @param getVGap Function to calculate the vertical gap for each node. Function format: function(node) { return number }
#' @param radial Whether to enable radial layout
#' @param ... Additional parameters to pass to the layout
#'
#' @return A list containing the configuration for G6 AntV Compact Box layout
#' @export
#'
#' @examples
#' # Basic compact box layout
#' box_config <- compact_box_layout()
#'
#' # Vertical compact box layout
#' box_config <- compact_box_layout(
#'   direction = "TB",
#'   getHGap = function(node) {
#'     if(node$depth == 1) return(80)
#'     else return(40)
#'   }
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

  # Get all named parameters as a list
  # Use dropNulls function to remove NULL elements
  # Assuming dropNulls is defined elsewhere in your package
  named_params <- dropNulls(mget(
    setdiff(names(formals()), "..."),
    environment()
  ))

  # Collect additional parameters from ellipsis
  extra_params <- list(...)

  # Add type parameter (internal)
  config <- list(type = "compact-box")

  # Merge with named parameters and additional parameters
  c(config, named_params, extra_params)
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
  c(config, named_params, extra_params)
}

#' Generate G6 AntV Concentric layout configuration
#'
#' This function creates a configuration list for G6 AntV Concentric layout
#' with all available options as parameters. The Concentric layout places nodes in
#' concentric circles based on a centrality measure.
#'
#' @param center The center position of the circular layout [x, y] or [x, y, z].
#'   By default, it's the center position of the current container.
#' @param clockwise Whether nodes are arranged in clockwise order
#' @param equidistant Whether the distances between rings are equal
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
#'   Can be a number, a 2-element vector [width, height], or a function that returns a number.
#' @param nodeSpacing Minimum distance between rings, used to adjust the radius.
#'   Can be a number, a vector of numbers, or a function that returns a number.
#' @param preventOverlap Whether to prevent node overlap. Must be coordinated with the nodeSize
#'   attribute or the data.size attribute in the node data. Only when data.size is set in the
#'   data or the nodeSize value that is the same as the current graph node size is configured
#'   in the layout, can node overlap collision detection be performed.
#' @param startAngle The arc at which to start layout of nodes (in radians)
#' @param sweep If the radian difference between the first and last nodes in the same layer
#'   is undefined, it will be set to 2 * Math.PI * (1 - 1 / |level.nodes|), where level.nodes
#'   is the number of nodes in each layer calculated by the algorithm, and |level.nodes| is
#'   the number of nodes in the layer.
#' @param ... Additional parameters to pass to the layout
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

  # Get all named parameters as a list
  # Use dropNulls function to remove NULL elements
  # Assuming dropNulls is defined elsewhere in your package
  named_params <- dropNulls(mget(
    setdiff(names(formals()), "..."),
    environment()
  ))

  # Collect additional parameters from ellipsis
  extra_params <- list(...)

  # Add type parameter (internal)
  config <- list(type = "concentric")

  # Merge with named parameters and additional parameters
  c(config, named_params, extra_params)
}

#' Generate G6 AntV Dagre layout configuration
#'
#' This function creates a configuration list for G6 AntV Dagre layout
#' with all available options as parameters. The Dagre layout is designed
#' for directed graphs, creating hierarchical layouts with nodes arranged in layers.
#'
#' @param rankdir Layout direction: "TB" (top to bottom), "BT" (bottom to top),
#'   "LR" (left to right), or "RL" (right to left)
#' @param align Node alignment: "UL" (upper left), "UR" (upper right),
#'   "DL" (down left), or "DR" (down right)
#' @param nodesep Node spacing (px). When rankdir is "TB" or "BT", it's the horizontal
#'   spacing of nodes; when rankdir is "LR" or "RL", it's the vertical spacing of nodes.
#' @param ranksep Interlayer spacing (px). When rankdir is "TB" or "BT", it's the
#'   spacing between adjacent layers in the vertical direction; when rankdir is "LR" or "RL",
#'   it represents the spacing between adjacent layers in the horizontal direction.
#' @param ranker The algorithm for assigning a level to each node: "network-simplex" (the network
#'   simplex algorithm), "tight-tree" (the compact tree algorithm), or "longest-path"
#'   (the longest path algorithm)
#' @param nodeSize G6 custom attribute to specify the node size uniformly or for each node.
#'   Can be a single number (same width/height), an array [width, height],
#'   or a function that returns either.
#' @param controlPoints Whether to keep the control points of the edge
#' @param ... Additional parameters to pass to the layout
#'
#' @return A list containing the configuration for G6 AntV Dagre layout
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

  # Get all named parameters as a list
  # Use dropNulls function to remove NULL elements
  # Assuming dropNulls is defined elsewhere in your package
  named_params <- dropNulls(mget(
    setdiff(names(formals()), "..."),
    environment()
  ))

  # Collect additional parameters from ellipsis
  extra_params <- list(...)

  # Add type parameter (internal)
  config <- list(type = "dagre")

  # Merge with named parameters and additional parameters
  c(config, named_params, extra_params)
}
