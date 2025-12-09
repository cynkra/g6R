#' Configure Global Options for G6 Graph
#'
#' Sets up the global configuration options for a G6 graph including node, edge and
#' combo styles, layout, canvas, animation, and interactive behavior settings.
#'
#' @details
#' The `g6_options` function provides a comprehensive configuration interface for G6 graphs.
#' It allows you to control all aspects of graph rendering and behavior, from styling of
#' individual elements to global visualization settings.
#'
#' @param graph g6 graph instance.
#' @param node Node configuration. Controls the default appearance and behavior of nodes.
#'   Created with \code{node_options()}. Default: NULL.
#'
#' @param edge Edge configuration. Controls the default appearance and behavior of edges.
#'   Created with \code{edge_options()}. Default: NULL.
#'
#' @param combo Combo configuration. Controls the default appearance and behavior of combo nodes.
#'   Created with \code{combo_options()}. Default: NULL.
#'
#' @param autoFit Automatically fit the graph content to the canvas.
#'   Created with \code{auto_fit_config()}. Default: NULL.
#'
#' @param canvas Canvas configuration for the graph rendering surface.
#'   Created with \code{canvas_config()}. Default: NULL.
#'
#' @param animation Global animation configuration for graph transitions.
#'   Created with \code{animation_config()}. Default: TRUE.
#'
#' @param autoResize Whether the graph should automatically resize when the window size changes.
#'   Default: FALSE.
#'
#' @param background Background color of the graph. If not specified, the background will be transparent.
#'   Default: NULL.
#'
#' @param cursor Default mouse cursor style when hovering over the graph.
#'   Options include: "default", "pointer", "move", etc.
#'   Default: "default".
#'
#' @param devicePixelRatio Device pixel ratio for rendering on high-DPI displays. If NULL,
#'   the browser's default device pixel ratio will be used.
#'   Default: NULL.
#'
#' @param renderer Rendering engine to use. A JS function. To render
#' as svg, you can pass `() => new SVGRenderer()`.
#'   Default: NULL (G6 will choose the appropriate renderer).
#'
#' @param padding Padding around the graph content in pixels. Can be a single number for equal padding
#'   on all sides or a vector of four numbers \code{[top, right, bottom, left]}.
#'   Default: NULL.
#'
#' @param rotation Rotation angle of the entire graph in degrees.
#'   Default: 0.
#'
#' @param x X-coordinate of the graph's center relative to the container.
#'   Default: NULL (will use container center).
#'
#' @param y Y-coordinate of the graph's center relative to the container.
#'   Default: NULL (will use container center).
#'
#' @param zoom Initial zoom level of the graph. 1 represents 100% (original size).
#'   Default: 1.
#'
#' @param zoomRange Minimum and maximum allowed zoom levels, specified as a vector
#'   with two elements: c(min_zoom, max_zoom).
#'   Default: c(0.01, 10).
#'
#' @param theme Color theme for the graph. Either `light` or `dark` or a list
#' representing a custom theme:
#' see \url{https://g6.antv.antgroup.com/en/manual/theme/custom-theme}.
#' @param ... Other configuration parameters.
#'
#' @return A list containing all specified G6 graph configuration options.
#'
#' @examples
#' # Basic usage with defaults
#' opts <- g6_options(g6())
#'
#' # Customize node and edge styles
#' opts <- g6_options(
#'   g6(),
#'   node = node_options(
#'     type = "circle",
#'     style = node_style_options(
#'       fill = "#1783FF",
#'       stroke = "#0066CC"
#'     )
#'   ),
#'   edge = edge_options(
#'     type = "cubic",
#'     style = edge_style_options(
#'       stroke = "#999999",
#'       lineWidth = 1.5
#'     )
#'   )
#' )
#'
#' # Configure graph with dark theme, auto-resize, and custom background
#' opts <- g6_options(
#'   g6(),
#'   theme = "dark",
#'   autoResize = TRUE,
#'   background = "#222222",
#'   padding = 20,
#'   zoom = 0.8,
#'   zoomRange = c(0.5, 2)
#' )
#'
#' # Configure with custom animations
#' opts <- g6_options(
#'   g6(),
#'   animation = animation_config(
#'     duration = 500,
#'     easing = "easeCubic"
#'   ),
#'   autoFit = auto_fit_config(duration = 300, easing = "ease-out")
#' )
#' @export
g6_options <- function(
  graph,
  node = NULL,
  edge = NULL,
  combo = NULL,
  autoFit = NULL,
  canvas = NULL,
  animation = TRUE,
  autoResize = FALSE,
  background = NULL,
  cursor = valid_cursors,
  devicePixelRatio = NULL,
  renderer = NULL,
  padding = NULL,
  rotation = 0,
  x = NULL,
  y = NULL,
  zoom = 1,
  zoomRange = c(0.01, 10),
  theme = "light",
  ...
) {
  if (!inherits(graph, "g6")) {
    stop("g6_options must be called on a g6 instance")
  }

  if (!is.null(renderer) && !is_js(renderer)) {
    stop("'renderer' must be a JavaScript function wrapped with JS()")
  }

  if ((isTRUE(animation) || is.list(animation)) && get_g6_preserve_position()) {
    warning(
      "'g6R.preserve_elements_position' 
      only works when animation is FALSE. It will be ignored."
    )
  }

  cursor <- match.arg(cursor)

  arg_names <- names(formals())
  arg_names <- arg_names[!(arg_names %in% c("...", "graph"))]
  # Get values of only the named parameters
  config <- mget(arg_names)

  # Drop NULL elements
  graph$x <- c(graph$x, dropNulls(c(config, list(...))))
  graph
}

#' Create Auto-Fit Configuration for G6 Graphs
#'
#' Configures the auto-fit behavior for a G6 graph. Auto-fit automatically adjusts
#' the view to fit all elements or centers them within the canvas.
#'
#' @details
#' The auto-fit feature helps ensure that graph elements remain visible within the canvas.
#' It can be configured to either fit all elements to view or center them, and can be
#' triggered under different conditions.
#'
#' @param type The auto-fit mode to use. Options:
#'   \itemize{
#'     \item \code{"view"}: Scale and translate the graph to fit all elements within the view (default)
#'     \item \code{"center"}: Only translate the graph to center elements without scaling
#'   }
#'
#' @param when When the auto-fit should be triggered. Options:
#'   \itemize{
#'     \item \code{"overflow"}: Trigger auto-fit only when elements overflow the canvas (default)
#'     \item \code{"always"}: Always perform auto-fit when the graph data changes
#'   }
#'
#' @param direction The direction for auto-fit adjustment. Options:
#'   \itemize{
#'     \item \code{"x"}: Adjust only along the x-axis
#'     \item \code{"y"}: Adjust only along the y-axis
#'     \item \code{"both"}: Adjust in both x and y directions (default)
#'   }
#'
#' @param duration The duration of the auto-fit animation in milliseconds (default: 1000)
#'
#' @param easing The animation easing function to use. Options:
#'   \itemize{
#'     \item \code{"ease-in-out"}: Slow at the beginning and end of the animation (default)
#'     \item \code{"ease"}: Standard easing
#'     \item \code{"ease-in"}: Slow at the beginning
#'     \item \code{"ease-out"}: Slow at the end
#'     \item \code{"linear"}: Constant speed throughout
#'     \item \code{"cubic-bezier"}: Custom cubic-bezier curve
#'     \item \code{"step-start"}: Jump immediately to the end state
#'     \item \code{"step-end"}: Jump at the end to the end state
#'   }
#'
#' @return A list containing the auto-fit configuration that can be passed to [g6_options()].
#'
#' @export
#'
#' @examples
#' # Basic auto-fit configuration with default settings
#' config <- auto_fit_config()
#'
#' # Auto-fit with only centering (no scaling)
#' config <- auto_fit_config(type = "center")
#'
#' # Auto-fit that always triggers when graph data changes
#' config <- auto_fit_config(when = "always")
#'
#' # Auto-fit only in the x direction
#' config <- auto_fit_config(direction = "x")
#'
#' # Auto-fit with a fast animation
#' config <- auto_fit_config(duration = 300, easing = "ease-out")
auto_fit_config <- function(
  type = c("view", "center"),
  when = c("overflow", "always"),
  direction = c("x", "y", "both"),
  duration = 1000,
  easing = c(
    "ease-in-out",
    "ease",
    "ease-in",
    "ease-out",
    "linear",
    "cubic-bezier",
    "step-start",
    "step-end"
  )
) {
  # Match arguments against their possible values
  type <- match.arg(type)
  when <- match.arg(when)
  direction <- match.arg(direction)
  easing <- match.arg(easing)

  # Validate numeric parameters
  if (!is.numeric(duration) || duration < 0) {
    stop("'duration' must be a non-negative numeric value")
  }

  # Create the main structure
  list(
    type = type,
    options = list(
      when = when,
      direction = direction
    ),
    animation = list(
      duration = duration,
      easing = easing
    )
  )
}

#' Create Canvas Configuration for G6 Graphs
#'
#' Configures the canvas settings for a G6 graph. The canvas is the rendering
#' surface where the graph is drawn.
#'
#' @details
#' Canvas configuration controls how the graph is rendered, including its size,
#' scaling, background, and rendering layer settings. This function provides a
#' structured way to configure all canvas-related options.
#'
#' Note that many of these settings (container, width, height, devicePixelRatio,
#' background, cursor) can also be set directly in the main graph configuration,
#' which will be automatically converted to canvas configuration items.
#'
#' @param container The container element for the canvas. Can be a CSS selector string
#'   or an HTML element reference.
#'
#' @param devicePixelRatio The device pixel ratio to use for rendering. Higher values
#'   provide sharper rendering on high-DPI displays but may impact performance.
#'   If not specified, the device's pixel ratio will be used.
#'
#' @param width The width of the canvas in pixels.
#'
#' @param height The height of the canvas in pixels.
#'
#' @param cursor The CSS cursor style to use when hovering over the canvas.
#'   Common values include "default", "pointer", "move", etc.
#'
#' @param background The background color of the canvas. Can be any valid CSS color
#'   value (hex, rgb, rgba, named colors).
#'
#' @param renderer A function that returns a renderer for different layers.
#'   The function takes a layer parameter which can be 'background', 'main',
#'   'label', or 'transient'.
#'
#' @param enableMultiLayer Whether to enable multi-layer rendering. This is a
#'   non-dynamic parameter and is only effective during initialization.
#'   Multi-layer rendering can improve performance for complex graphs by
#'   separating elements into different rendering layers.
#'
#' @return A list containing the canvas configuration that can be passed to [g6_options()].
#'
#' @export
#'
#' @examples
#' # Basic canvas configuration
#' config <- canvas_config(
#'   container = "#graph-container",
#'   width = 800,
#'   height = 600
#' )
#'
#' # Canvas with multi-layer rendering enabled
#' config <- canvas_config(
#'   container = "#graph-container",
#'   width = 1000,
#'   height = 700,
#'   enableMultiLayer = TRUE,
#'   cursor = "grab"
#' )
canvas_config <- function(
  container = NULL,
  devicePixelRatio = NULL,
  width = NULL,
  height = NULL,
  cursor = NULL,
  background = NULL,
  renderer = NULL,
  enableMultiLayer = NULL
) {
  # Validate container
  if (!is.null(container) && !is.character(container) && !is_js(container)) {
    stop(
      "'container' must be a CSS selector string or an HTML element reference"
    )
  }

  # Validate devicePixelRatio
  if (!is.null(devicePixelRatio)) {
    if (!is.numeric(devicePixelRatio) || devicePixelRatio <= 0) {
      stop("'devicePixelRatio' must be a positive number")
    }
  }

  # Validate width
  if (!is.null(width)) {
    if (!is.numeric(width) || width <= 0) {
      stop("'width' must be a positive number")
    }
  }

  # Validate height
  if (!is.null(height)) {
    if (!is.numeric(height) || height <= 0) {
      stop("'height' must be a positive number")
    }
  }

  # Validate cursor
  if (!is.null(cursor) && !is.character(cursor)) {
    stop("'cursor' must be a string (CSS cursor value)")
  }

  # Validate background
  if (!is.null(background) && !is.character(background)) {
    stop("'background' must be a string (CSS color value)")
  }

  # Validate renderer
  if (!is.null(renderer) && !is_js(renderer)) {
    stop("'renderer' must be a JavaScript function")
  }

  # Validate enableMultiLayer
  if (!is.null(enableMultiLayer) && !is.logical(enableMultiLayer)) {
    stop("'enableMultiLayer' must be a boolean value")
  }

  # Get all argument names
  arg_names <- names(formals())
  # Create list of argument values
  dropNulls(mget(arg_names))
}

#' Create Animation Configuration for G6 Graphs
#'
#' Configures animation settings for G6 graph elements. These settings control
#' how graph elements animate when changes occur.
#'
#' @details
#' Animation configuration allows fine-tuning the timing and behavior of animations
#' in G6 graphs. This includes controlling the duration, delay, easing function,
#' direction, and other aspects of how graph elements animate.
#'
#' @param delay Animation delay time in milliseconds. The time to wait before the
#'   animation begins. Must be a non-negative numeric value.
#'
#' @param direction Animation playback direction. Options:
#'   \itemize{
#'     \item \code{"forward"}: Plays normally (default)
#'     \item \code{"alternate"}: Plays forward, then in reverse
#'     \item \code{"alternate-reverse"}: Plays in reverse, then forward
#'     \item \code{"normal"}: Same as forward
#'     \item \code{"reverse"}: Plays in reverse direction
#'   }
#'
#' @param duration Animation duration in milliseconds. The length of time the
#'   animation will take to complete one cycle. Must be a non-negative numeric value.
#'
#' @param easing Animation easing function. Controls the rate of change during
#'   the animation. Common values include "linear", "ease", "ease-in", "ease-out",
#'   "ease-in-out", or cubic-bezier values.
#'
#' @param fill Fill mode after animation ends. Options:
#'   \itemize{
#'     \item \code{"none"}: Element returns to its initial state when animation ends (default)
#'     \item \code{"auto"}: Follows the rules of the animation effect
#'     \item \code{"backwards"}: Element retains first keyframe values during delay period
#'     \item \code{"both"}: Combines forwards and backwards behavior
#'     \item \code{"forwards"}: Element retains final keyframe values after animation ends
#'   }
#'
#' @param iterations Number of times the animation should repeat. A value of
#'   \code{Inf} will cause the animation to repeat indefinitely. Must be a
#'   non-negative numeric value.
#'
#' @return A list containing animation configuration that can be passed to [g6_options()].
#'
#' @export
#'
#' @examples
#' # Basic animation with duration
#' config <- animation_config(
#'   duration = 500
#' )
#'
#' # Complex animation configuration
#' config <- animation_config(
#'   delay = 100,
#'   duration = 800,
#'   easing = "ease-in-out",
#'   direction = "alternate",
#'   fill = "forwards",
#'   iterations = 2
#' )
#'
#' # Infinite animation
#' config <- animation_config(
#'   duration = 1000,
#'   easing = "linear",
#'   iterations = Inf
#' )
animation_config <- function(
  delay = NULL,
  direction = c(
    "forward",
    "alternate",
    "alternate-reverse",
    "normal",
    "reverse"
  ),
  duration = NULL,
  easing = NULL,
  fill = c("none", "auto", "backwards", "both", "forwards"),
  iterations = NULL
) {
  direction <- match.arg(direction)
  fill <- match.arg(fill)

  # Validate numeric parameters
  if (!is.null(delay) && (!is.numeric(delay) || delay < 0)) {
    stop("'delay' must be a non-negative numeric value")
  }

  if (!is.null(duration) && (!is.numeric(duration) || duration < 0)) {
    stop("'duration' must be a non-negative numeric value")
  }

  if (!is.null(iterations)) {
    if (!is.numeric(iterations) || iterations < 0) {
      stop("'iterations' must be a non-negative numeric value")
    }

    # Convert Inf to proper JavaScript representation if needed
    if (is.infinite(iterations)) {
      iterations <- "Infinity"
    }
  }

  # Validate easing parameter
  if (!is.null(easing) && !is.character(easing)) {
    stop("'easing' must be a string value (e.g., 'linear', 'ease-in-out')")
  }

  # Get all argument names
  arg_names <- names(formals())
  # Create list of argument values
  config <- mget(arg_names)
  # Drop NULL elements
  dropNulls(config)
}

#' Create Node Options Configuration for G6 Graphs
#'
#' Configures the general options for nodes in a G6 graph. These settings control
#' the type, style, state, palette, and animation of nodes.
#'
#' @details
#' Node options allow defining how nodes appear and behave in a G6 graph. This includes
#' selecting node types, setting styles, configuring state-based appearances, defining
#' color palettes, and specifying animation effects.
#'
#' @param type Node type. Can be a built-in node type name or a custom node name.
#'   Built-in types include "circle", "rect", "ellipse", "diamond", "triangle", etc.
#'   Default: "circle".
#'
#' @param style Node style configuration. Controls the appearance of nodes including color,
#'   size, border, etc. Can be created with \code{node_style_options()}.
#'   Default: NULL.
#'
#' @param state Defines the style of the node in different states, such as hover, selected,
#'   disabled, etc. Should be a list mapping state names to style configurations.
#'   Default: NULL.
#'
#' @param palette Defines the color palette of the node, used to map colors based on different data.
#'   Default: NULL.
#'
#' @param animation Defines the animation effect of the node. Can be created with
#'   \code{animation_config()}.
#'   Default: NULL.
#'
#' @return A list containing node options configuration that can be passed to [g6_options()].
#'
#' @export
#'
#' @examples
#' # Basic node options with default circle type
#' options <- node_options()
#'
#' # Rectangle node with custom style
#' options <- node_options(
#'   type = "rect",
#'   style = node_style_options(
#'     fill = "#E8F7FF",
#'     stroke = "#1783FF",
#'     lineWidth = 2
#'   )
#' )
node_options <- function(
  type = c(
    "circle",
    "rect",
    "ellipse",
    "diamond",
    "triangle",
    "star",
    "image",
    "modelRect"
  ),
  style = node_style_options(),
  state = NULL,
  palette = NULL,
  animation = NULL
) {
  # Match type argument against possible values
  type <- match.arg(type)

  # Get all argument names
  arg_names <- names(formals())
  # Create list of argument values
  config <- mget(arg_names)
  # Drop NULL elements
  dropNulls(config)
}

#' Create Node Style Options for G6 Graphs
#'
#' Configures the styling options for nodes in a G6 graph. These settings control
#' the appearance and interaction behavior of nodes. Used in \link{node_options}.
#'
#' @details
#' Node style options allow fine-grained control over how nodes are rendered and
#' behave in a G6 graph. This includes colors, sizes, borders, shadows, visibility,
#' positioning, and interaction states.
#'
#' @param collapsed Whether the current node/group is collapsed. Default: FALSE.
#'
#' @param cursor Node mouse hover cursor style. Common values include "default",
#'   "pointer", "move", etc. Default: "default".
#'
#' @param fill Node fill color. Can be any valid CSS color value. Default: "#1783FF".
#'
#' @param fillOpacity Node fill color opacity. Value between 0 and 1. Default: 1.
#'
#' @param increasedLineWidthForHitTesting When lineWidth is small, this value increases
#'   the interactive area to make "thin lines" easier to interact with. Default: 0.
#'
#' @param lineCap Node stroke end style. Options: "round", "square", "butt". Default: "butt".
#'
#' @param lineDash Node stroke dash style. Vector of numbers specifying dash pattern.
#'
#' @param lineDashOffset Node stroke dash offset. Default: NULL.
#'
#' @param lineJoin Node stroke join style. Options: "round", "bevel", "miter". Default: "miter".
#'
#' @param lineWidth Node stroke width. Default: 1.
#'
#' @param opacity Node overall opacity. Value between 0 and 1. Default: 1.
#'
#' @param shadowBlur Node shadow blur amount. Default: NULL.
#'
#' @param shadowColor Node shadow color. Default: NULL.
#'
#' @param shadowOffsetX Node shadow offset in the x-axis direction. Default: NULL.
#'
#' @param shadowOffsetY Node shadow offset in the y-axis direction. Default: NULL.
#'
#' @param shadowType Node shadow type. Options: "inner", "outer". Default: "outer".
#'
#' @param size Node size. Can be a single number for equal width/height or a vector
#'   of two numbers \code{[width, height]}. Default: 32.
#'
#' @param stroke Node stroke (border) color. Default: "#000".
#'
#' @param strokeOpacity Node stroke color opacity. Value between 0 and 1. Default: 1.
#'
#' @param transform CSS transform attribute to rotate, scale, skew, or translate the node.
#'   Default: NULL.
#'
#' @param transformOrigin Rotation and scaling center point. Default: NULL.
#'
#' @param visibility Whether the node is visible. Options: "visible", "hidden". Default: "visible".
#'
#' @param x Node x coordinate. Default: 0.
#'
#' @param y Node y coordinate. Default: 0.
#'
#' @param z Node z coordinate (for 3D). Default: 0.
#'
#' @param zIndex Node rendering level (for layering). Default: 0.
#' @param ... Other parameters.
#'
#' @return A list containing node style options that can be passed to [node_options()].
#'
#' @export
#'
#' @examples
#' # Basic node style with blue fill and red border
#' styles <- node_style_options(
#'   fill = "#1783FF",
#'   stroke = "#FF0000",
#'   lineWidth = 2
#' )
#'
#' # Create a node with shadow effects
#' styles <- node_style_options(
#'   fill = "#FFFFFF",
#'   stroke = "#333333",
#'   lineWidth = 1,
#'   shadowBlur = 10,
#'   shadowColor = "rgba(0,0,0,0.3)",
#'   shadowOffsetX = 5,
#'   shadowOffsetY = 5
#' )
#'
#' # Custom sized node with dashed border
#' styles <- node_style_options(
#'   size = c(100, 50),
#'   fill = "#E8F7FF",
#'   stroke = "#1783FF",
#'   lineDash = c(5, 5),
#'   opacity = 0.8
#' )
node_style_options <- function(
  collapsed = FALSE,
  cursor = "default",
  fill = "#1783FF",
  fillOpacity = 1,
  increasedLineWidthForHitTesting = 0,
  lineCap = c("butt", "round", "square"),
  lineDash = NULL,
  lineDashOffset = NULL,
  lineJoin = c("miter", "round", "bevel"),
  lineWidth = 1,
  opacity = 1,
  shadowBlur = NULL,
  shadowColor = NULL,
  shadowOffsetX = NULL,
  shadowOffsetY = NULL,
  shadowType = c("outer", "inner"),
  size = 32,
  stroke = "#000",
  strokeOpacity = 1,
  transform = NULL,
  transformOrigin = NULL,
  visibility = c("visible", "hidden"),
  x = NULL,
  y = NULL,
  z = NULL,
  zIndex = NULL,
  ...
) {
  # Validate boolean parameters
  if (!is.null(collapsed) && !is.logical(collapsed)) {
    stop("'collapsed' must be a boolean value (TRUE or FALSE)")
  }

  # Validate string parameters
  string_params <- c(
    "cursor",
    "fill",
    "lineCap",
    "lineJoin",
    "shadowColor",
    "shadowType",
    "stroke",
    "transform",
    "transformOrigin",
    "visibility"
  )

  for (param in string_params) {
    value <- get(param)
    if (!is.null(value) && !is.character(value)) {
      stop(sprintf("'%s' must be a string value", param))
    }
  }

  # Validate specific enum values
  lineCap <- match.arg(lineCap)
  lineJoin <- match.arg(lineJoin)
  shadowType <- match.arg(shadowType)
  visibility <- match.arg(visibility)

  # Validate numeric parameters
  numeric_params <- c(
    "fillOpacity",
    "increasedLineWidthForHitTesting",
    "lineDashOffset",
    "lineWidth",
    "opacity",
    "shadowBlur",
    "shadowOffsetX",
    "shadowOffsetY",
    "strokeOpacity",
    "x",
    "y",
    "z",
    "zIndex"
  )

  for (param in numeric_params) {
    value <- get(param)
    if (!is.null(value) && (!is.numeric(value) || length(value) != 1)) {
      stop(sprintf("'%s' must be a single numeric value", param))
    }
  }

  # Validate opacity values
  opacity_params <- c("fillOpacity", "opacity", "strokeOpacity")

  for (param in opacity_params) {
    value <- get(param)
    if (!is.null(value) && (value < 0 || value > 1)) {
      stop(sprintf("'%s' must be a number between 0 and 1", param))
    }
  }

  # Validate lineDash
  if (!is.null(lineDash) && (!is.numeric(lineDash) || length(lineDash) < 1)) {
    stop("'lineDash' must be a numeric vector")
  }

  # Validate size
  if (!is.null(size)) {
    if (!is.numeric(size)) {
      stop("'size' must be a numeric value or vector of length 2")
    }
    if (length(size) > 2) {
      stop("'size' can only have 1 or 2 elements")
    }
  }

  # Get all argument names and values
  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Create Edge Options Configuration for G6 Graphs
#'
#' Configures the general options for edges in a G6 graph. These settings control
#' the type, style, state, palette, and animation of edges.
#'
#' @details
#' Edge options allow defining how edges appear and behave in a G6 graph. This includes
#' selecting edge types, setting styles, configuring state-based appearances, defining
#' color palettes, and specifying animation effects.
#'
#' @param type Edge type. Can be a built-in edge type name or a custom edge name.
#'   Built-in types include "line", "polyline", "arc", "quadratic", "cubic", "cubic-vertical",
#'   "cubic-horizontal", "loop", etc. Default: "line".
#'
#' @param style Edge style configuration. Controls the appearance of edges including color,
#'   width, dash patterns, etc. Can be created with \code{edge_style_options()}.
#'   Default: NULL.
#'
#' @param state Defines the style of the edge in different states, such as hover, selected,
#'   disabled, etc. Should be a list mapping state names to style configurations.
#'   Default: NULL.
#'
#' @param palette Defines the color palette of the edge, used to map colors based on different data.
#'   Default: NULL.
#'
#' @param animation Defines the animation effect of the edge. Can be created with
#'   \code{animation_config()}.
#'   Default: NULL.
#'
#' @return A list containing edge options configuration that can be passed to [g6_options()].
#'
#' @export
#'
#' @examples
#' # Basic edge options with default line type
#' options <- edge_options()
#'
#' # Curved edge with custom style
#' options <- edge_options(
#'   type = "cubic",
#'   style = edge_style_options(
#'     stroke = "#1783FF",
#'     lineWidth = 2,
#'     endArrow = TRUE
#'   )
#' )
edge_options <- function(
  type = c(
    "line",
    "polyline",
    "arc",
    "quadratic",
    "cubic",
    "cubic-vertical",
    "cubic-horizontal",
    "loop"
  ),
  style = edge_style_options(),
  state = NULL,
  palette = NULL,
  animation = NULL
) {
  # Match type argument against possible values
  type <- match.arg(type)

  # Get all argument names
  arg_names <- names(formals())
  # Create list of argument values
  config <- mget(arg_names)
  # Drop NULL elements
  dropNulls(config)
}

#' @keywords internal
valid_pointer_events <- c(
  "visible",
  "visiblepainted",
  "visiblestroke",
  "non-transparent-pixel",
  "visiblefill",
  "painted",
  "fill",
  "stroke",
  "all",
  "none",
  "auto",
  "inherit",
  "initial",
  "unset"
)

#' @keywords internal
valid_cursors <- c(
  'default',
  'auto',
  'none',
  'context-menu',
  'help',
  'pointer',
  'progress',
  'wait',
  'cell',
  'crosshair',
  'text',
  'vertical-text',
  'alias',
  'copy',
  'move',
  'no-drop',
  'not-allowed',
  'grab',
  'grabbing',
  'all-scroll',
  'col-resize',
  'row-resize',
  'n-resize',
  'e-resize',
  's-resize',
  'w-resize',
  'ne-resize',
  'nw-resize',
  'se-resize',
  'sw-resize',
  'ew-resize',
  'ns-resize',
  'nesw-resize',
  'nwse-resize',
  'zoom-in',
  'zoom-out'
)

#' Create Edge Style Options for G6 Graphs
#'
#' Configures the styling options for edges in a G6 graph. These settings control
#' the appearance and interaction behavior of edges.
#'
#' @details
#' Edge style options allow fine-grained control over how edges are rendered and
#' behave in a G6 graph. This includes colors, widths, line styles, shadows, visibility,
#' and interaction properties.
#'
#' @param class Edge class name for custom styling with CSS. Default: NULL.
#'
#' @param cursor Edge mouse hover cursor style. Common values include "default",
#'   "pointer", "move", etc. Default: "default".
#'
#' @param fill Edge area fill color (for edges with area, like loops). Default: NULL.
#'
#' @param fillRule Edge internal fill rule. Options: "nonzero", "evenodd". Default: NULL.
#'
#' @param filter Edge shadow filter effect. Default: NULL.
#'
#' @param increasedLineWidthForHitTesting When the edge width is too small, this value increases
#'   the interaction area to make edges easier to interact with. Default: NULL.
#'
#' @param isBillboard Effective in 3D scenes, always facing the screen so the line width
#'   is not affected by perspective projection. Default: TRUE.
#'
#' @param lineDash Edge dashed line style. Numeric vector specifying dash pattern. Default: 0.
#'
#' @param lineDashOffset Edge dashed line offset. Default: 0.
#'
#' @param lineWidth Edge width in pixels. Default: 1.
#'
#' @param opacity Overall opacity of the edge. Value between 0 and 1. Default: 1.
#'
#' @param pointerEvents Whether the edge responds to pointer events. Default: NULL.
#'
#' @param shadowBlur Edge shadow blur effect amount. Default: NULL.
#'
#' @param shadowColor Edge shadow color. Default: NULL.
#'
#' @param shadowOffsetX Edge shadow X-axis offset. Default: NULL.
#'
#' @param shadowOffsetY Edge shadow Y-axis offset. Default: NULL.
#'
#' @param shadowType Edge shadow type. Options: "inner", "outer", "both". Default: NULL.
#'
#' @param sourcePort Source port of the edge connection. Default: NULL.
#'
#' @param stroke Edge color. Default: "#000".
#'
#' @param strokeOpacity Edge color opacity. Value between 0 and 1. Default: 1.
#'
#' @param targetPort Target port of the edge connection. Default: NULL.
#'
#' @param transform CSS transform attribute to rotate, scale, skew, or translate the edge.
#'   Default: NULL.
#'
#' @param transformOrigin Rotation and scaling center point. Default: NULL.
#'
#' @param visibility Whether the edge is visible. Options: "visible", "hidden". Default: "visible".
#'
#' @param zIndex Edge rendering level (for layering). Default: 1.
#' @param ... Extra parameters.
#'
#' @return A list containing edge style options that can be passed to [edge_options()].
#'
#' @export
edge_style_options <- function(
  class = NULL,
  cursor = valid_cursors,
  fill = NULL,
  fillRule = c("nonzero", "evenodd"),
  filter = NULL,
  increasedLineWidthForHitTesting = NULL,
  isBillboard = TRUE,
  lineDash = 0,
  lineDashOffset = 0,
  lineWidth = 1,
  opacity = 1,
  pointerEvents = NULL,
  shadowBlur = NULL,
  shadowColor = NULL,
  shadowOffsetX = NULL,
  shadowOffsetY = NULL,
  shadowType = NULL,
  sourcePort = NULL,
  stroke = "#000",
  strokeOpacity = 1,
  targetPort = NULL,
  transform = NULL,
  transformOrigin = NULL,
  visibility = c("visible", "hidden"),
  zIndex = -1e4,
  ...
) {
  # Validate parameters
  cursor <- match.arg(cursor)
  fillRule <- match.arg(fillRule)

  if (!is.null(shadowType) && !(shadowType %in% c("inner", "outer", "both"))) {
    stop("'shadowType' must be one of: 'inner', 'outer', 'both'")
  }

  visibility <- match.arg(visibility)

  if (!is.null(pointerEvents) && !(pointerEvents %in% valid_pointer_events)) {
    stop(
      sprintf("'pointerEvents' must be one of: %s"),
      valid_pointer_events
    )
  }

  if (!is.logical(isBillboard)) {
    stop("'isBillboard' must be a boolean value (TRUE or FALSE)")
  }

  # Get all argument names
  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Create Combo Options Configuration for G6 Graphs
#'
#' Configures the general options for combos in a G6 graph. These settings control
#' the type, style, state, palette, and animation of combos.
#'
#' @details
#' Combo options allow defining how combos (node groupings) appear and behave in a G6 graph.
#' This includes selecting combo types, setting styles, configuring state-based appearances,
#' defining color palettes, and specifying animation effects.
#'
#' @param type Combo type. Can be a built-in combo type name or a custom combo name.
#'   Built-in types include "circle", "rect", "polygon", etc. Default: "circle".
#'
#' @param style Combo style configuration. Controls the appearance of combos including color,
#'   size, border, etc.
#'   Default: NULL.
#'
#' @param state Defines the style of the combo in different states, such as hover, selected,
#'   disabled, etc. Should be a list mapping state names to style configurations.
#'   Default: NULL.
#'
#' @param palette Defines the color palette of the combo, used to map colors based on different data.
#'   Default: NULL.
#'
#' @param animation Defines the animation effect of the combo. Can be created with
#'   \code{animation_config()}.
#'   Default: NULL.
#'
#' @return A list containing combo options configuration that can be passed to [g6_options()].
#'
#' @export
#'
#' @examples
#' # Basic combo options with default circle type
#' options <- combo_options()
#'
#' # Rectangle combo with custom style
#' options <- combo_options(
#'   type = "rect",
#'   style = list(
#'     fill = "#F6F6F6",
#'     stroke = "#CCCCCC",
#'     lineWidth = 1
#'   )
#' )
combo_options <- function(
  type = "circle",
  style = NULL,
  state = NULL,
  palette = NULL,
  animation = NULL
) {
  # Validate type parameter
  if (!is.character(type) || length(type) != 1) {
    stop("'type' must be a single string value")
  }

  # Validate style parameter
  if (!is.null(style) && !is.list(style)) {
    stop(
      "'style' must be a list, preferably created with combo_style_options()"
    )
  }

  # Validate state parameter
  if (!is.null(state)) {
    if (!is.list(state)) {
      stop("'state' must be a list mapping state names to style configurations")
    }
    for (state_name in names(state)) {
      if (!is.list(state[[state_name]])) {
        stop(sprintf(
          "State '%s' must be a list of style properties",
          state_name
        ))
      }
    }
  }

  # Validate palette parameter
  if (!is.null(palette) && !is.list(palette)) {
    stop("'palette' must be a list defining color mappings")
  }

  # Validate animation parameter
  if (!is.null(animation) && !is.list(animation)) {
    stop(
      "'animation' must be a list, preferably created with animation_config()"
    )
  }

  # Get all argument names
  arg_names <- names(formals())

  # Create list of argument values
  config <- mget(arg_names)

  # Drop NULL elements
  dropNulls(config)
}
