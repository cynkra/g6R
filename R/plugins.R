#' Create a List of G6 Plugins
#'
#' Combines multiple G6 plugins into a list that can be passed to a G6 graph configuration.
#' G6 plugins extend the functionality of the base graph visualization with additional features.
#'
#' @details
#' G6 plugins provide extended functionality beyond the core graph visualization capabilities.
#' Plugins are divided into several categories:
#'
#' \subsection{Visual Style Enhancement}{
#'   \itemize{
#'     \item \strong{Grid Line (grid-line):} Displays grid reference lines on the canvas
#'     \item \strong{Background (background):} Adds background images or colors to the canvas
#'     \item \strong{Watermark (watermark):} Adds a watermark to the canvas to protect copyright
#'     \item \strong{Hull (hull):} Creates an outline for a specified set of nodes
#'     \item \strong{Bubble Sets (bubble-sets):} Creates smooth bubble-like element outlines
#'     \item \strong{Snapline (snapline):} Displays alignment reference lines when dragging elements
#'   }
#' }
#'
#' \subsection{Navigation and Overview}{
#'   \itemize{
#'     \item \strong{Minimap (minimap):} Displays a thumbnail preview of the graph, supporting navigation
#'     \item \strong{Fullscreen (fullscreen):} Supports full-screen display and exit for charts
#'     \item \strong{Timebar (timebar):} Provides filtering and playback control for temporal data
#'   }
#' }
#'
#' \subsection{Interactive Controls}{
#'   \itemize{
#'     \item \strong{Toolbar (toolbar):} Provides a collection of common operation buttons
#'     \item \strong{Context Menu (contextmenu):} Displays a menu of selectable operations on right-click
#'     \item \strong{Tooltip (tooltip):} Displays detailed information about elements on hover
#'     \item \strong{Legend (legend):} Displays categories and corresponding style descriptions of chart data
#'   }
#' }
#'
#' \subsection{Data Exploration}{
#'   \itemize{
#'     \item \strong{Fisheye (fisheye):} Provides a focus + context exploration experience
#'     \item \strong{Edge Filter Lens (edge-filter-lens):} Filters and displays edges within a specified area
#'     \item \strong{Edge Bundling (edge-bundling):} Bundles edges with similar paths together to reduce visual clutter
#'   }
#' }
#'
#' \subsection{Advanced Features}{
#'   \itemize{
#'     \item \strong{History (history):} Supports undo/redo operations
#'     \item \strong{Camera Setting (camera-setting):} Configures camera parameters in a 3D scene
#'   }
#' }
#'
#' @param graph G6 graph instance.
#' @param ... G6 plugin configuration objects created with plugin-specific functions
#' @note You can also build your own plugins as described at
#' \url{https://g6.antv.antgroup.com/en/manual/plugin/custom-plugin}.
#'
#' @return A list of G6 plugin configurations that can be passed to a G6 graph.
#'
#' @export
#'
#' @examples
#' # Create a configuration with multiple plugins
#' plugins <- g6_plugins(
#'   g6(),
#'   minimap(),
#'   grid_line(),
#'   tooltips(
#'     getContent = JS("(e, items) => {
#'       return `<div>${items[0].id}</div>`;
#'     }")
#'   )
#' )
#'
#' # Add a context menu and toolbar
#' plugins <- g6_plugins(
#'   g6(),
#'   context_menu(
#'     key = "my-context-menu",
#'     className = "my-context-menu",
#'     trigger = "click",
#'     offset = c(10, 10),
#'     getItems = JS("(event) => {
#'       const type = event.itemType;
#'       const isNode = type === 'node';
#'       return [
#'         { key: 'delete', text: 'Delete' },
#'         { key: 'edit', text: 'Edit' },
#'         { key: 'details', text: 'View Details', disabled: !isNode }
#'       ];
#'     }"),
#'     onClick = JS("(value, target, current) => {
#'       if (value === 'delete') {
#'         // do stuff
#'     }")
#'   ),
#'   toolbar(
#'     position = "top-right",
#'     getItems = JS("() => [
#'       { id: 'zoom-in', value: 'zoom-in' },
#'       { id: 'zoom-out', value: 'zoom-out' },
#'       { id: 'fit', value: 'fit' }
#'     ]"),
#'     onClick = JS("(value) => {
#'       if (value === 'zoom-in') graph.zoomTo(1.1);
#'       else if (value === 'zoom-out') graph.zoomTo(0.9);
#'       else if (value === 'fit') graph.fitView();
#'     }")
#'   )
#' )
g6_plugins <- function(graph, ...) {
  plugins <- list(...)
  if (length(plugins)) {
    graph$x$plugins <- lapply(plugins, validate_plugin)
  } else {
    stop("You must provide at least one plugin configuration.")
  }
  graph
}

#' @keywords internal
validate_plugin <- function(x) {
  validate_component(x, "plugin")
}

#' Configure Background Plugin for G6
#'
#' Creates a configuration object for the background plugin in G6.
#' This plugin adds a customizable background to the graph canvas.
#'
#' @param key Unique identifier for updates (string, default: NULL).
#' @param width Background width (string, default: "100%").
#' @param height Background height (string, default: "100%").
#' @param backgroundColor Background color (string, default: NULL).
#' @param backgroundImage Background image URL (string, default: NULL).
#' @param backgroundSize Background size (string, default: "cover").
#' @param backgroundPosition Background position (string, default: NULL).
#' @param backgroundRepeat Background repeat (string, default: NULL).
#' @param opacity Background opacity (string, default: NULL).
#' @param transition Transition animation (string, default: "background 0.5s").
#' @param zIndex Stacking order (string, default: "-1").
#' @param ... Extra parameters.
#' See \url{https://g6.antv.antgroup.com/en/manual/plugin/background}.
#'
#' @return A list with the configuration settings for the background plugin.
#' @export
#'
#' @examples
#' # Basic background color
#' bg <- background(backgroundColor = "#f0f0f0")
#'
#' # Background with image
#' bg <- background(
#'   backgroundImage = "https://example.com/background.jpg",
#'   backgroundSize = "contain",
#'   backgroundRepeat = "no-repeat",
#'   backgroundPosition = "center"
#' )
#'
#' # Semi-transparent background with transition
#' bg <- background(
#'   backgroundColor = "#000000",
#'   opacity = "0.3",
#'   transition = "all 1s ease-in-out"
#' )
background <- function(
  key = NULL,
  width = "100%",
  height = "100%",
  backgroundColor = NULL,
  backgroundImage = NULL,
  backgroundSize = "cover",
  backgroundPosition = NULL,
  backgroundRepeat = NULL,
  opacity = NULL,
  transition = "background 0.5s",
  zIndex = "-1",
  ...
) {
  # Create the configuration list with required type
  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "background"

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Configure Bubble Sets Plugin for G6
#'
#' Creates a configuration object for the bubble-sets plugin in G6.
#' This plugin creates bubble-like contours around groups of specified elements.
#'
#' @param members Member elements, including nodes and edges (character vector, required).
#' @param key Unique identifier for updates (string, default: NULL).
#' @param avoidMembers Elements to avoid when drawing contours (character vector, default: NULL).
#' @param label Whether to display labels (boolean, default: TRUE).
#' @param labelPlacement Label position (string, default: "bottom").
#' @param labelBackground Whether to display background (boolean, default: FALSE).
#' @param labelPadding Label padding (numeric or numeric vector, default: 0).
#' @param labelCloseToPath Whether the label is close to the contour (boolean, default: TRUE).
#' @param labelAutoRotate Whether the label rotates with the contour (boolean, default: TRUE).
#' @param labelOffsetX Label x-axis offset (numeric, default: 0).
#' @param labelOffsetY Label y-axis offset (numeric, default: 0).
#' @param labelMaxWidth Maximum width of the text (numeric, default: NULL).
#' @param maxRoutingIterations Maximum iterations for path calculation (numeric, default: 100).
#' @param maxMarchingIterations Maximum iterations for contour calculation (numeric, default: 20).
#' @param pixelGroup Number of pixels per potential area group (numeric, default: 4).
#' @param edgeR0 Edge radius parameter R0 (numeric, default: NULL).
#' @param edgeR1 Edge radius parameter R1 (numeric, default: NULL).
#' @param nodeR0 Node radius parameter R0 (numeric, default: NULL).
#' @param nodeR1 Node radius parameter R1 (numeric, default: NULL).
#' @param morphBuffer Morph buffer size (numeric, default: NULL).
#' @param threshold Threshold (numeric, default: NULL).
#' @param memberInfluenceFactor Member influence factor (numeric, default: NULL).
#' @param edgeInfluenceFactor Edge influence factor (numeric, default: NULL).
#' @param nonMemberInfluenceFactor Non-member influence factor (numeric, default: NULL).
#' @param virtualEdges Whether to use virtual edges (boolean, default: NULL).
#' @param ... Extra parameters.
#' See \url{https://g6.antv.antgroup.com/en/manual/plugin/bubble-sets}.
#'
#' @return A list with the configuration settings for the bubble-sets plugin.
#' @export
#'
#' @examples
#' # Basic bubble set around specific nodes
#' bubble <- bubble_sets(
#'   members = c("node1", "node2", "node3"),
#'   label = TRUE
#' )
#'
#' # More customized bubble set
#' bubble <- bubble_sets(
#'   key = "team-a",
#'   members = c("node1", "node2", "node3", "edge1", "edge2"),
#'   avoidMembers = c("node4", "node5"),
#'   labelPlacement = "top",
#'   labelBackground = TRUE,
#'   labelPadding = c(4, 2),
#'   maxRoutingIterations = 150
#' )
#'
#' # Bubble set with advanced parameters
#' bubble <- bubble_sets(
#'   members = c("node1", "node2", "node3"),
#'   pixelGroup = 6,
#'   edgeR0 = 10,
#'   nodeR0 = 5,
#'   memberInfluenceFactor = 0.8,
#'   edgeInfluenceFactor = 0.5,
#'   nonMemberInfluenceFactor = 0.3,
#'   virtualEdges = TRUE
#' )
bubble_sets <- function(
  members,
  key = "bubble-sets",
  avoidMembers = NULL,
  label = TRUE,
  labelPlacement = c("bottom", "left", "right", "top", "center"),
  labelBackground = FALSE,
  labelPadding = 0,
  labelCloseToPath = TRUE,
  labelAutoRotate = TRUE,
  labelOffsetX = 0,
  labelOffsetY = 0,
  labelMaxWidth = NULL,
  maxRoutingIterations = 100,
  maxMarchingIterations = 20,
  pixelGroup = 4,
  edgeR0 = NULL,
  edgeR1 = NULL,
  nodeR0 = NULL,
  nodeR1 = NULL,
  morphBuffer = NULL,
  threshold = NULL,
  memberInfluenceFactor = NULL,
  edgeInfluenceFactor = NULL,
  nonMemberInfluenceFactor = NULL,
  virtualEdges = NULL,
  ...
) {
  # TBD: validate members to it validate real node ids who exist.
  if (label) {
    labelPlacement <- match.arg(labelPlacement)
  }
  # Check for required parameters
  if (missing(members) || is.null(members) || length(members) == 0) {
    stop("'members' is required and must contain at least one element ID")
  }

  # Get argument names
  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "bubble-sets"

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Configure Context Menu Behavior
#'
#' Creates a configuration object for the context-menu behavior in G6.
#' This allows users to display a context menu when right-clicking or clicking on graph elements.
#'
#' @param key Unique identifier for the behavior, used for
#' subsequent operations (string, default: "context-menu").
#' @param className Additional class name for the menu DOM (string, default: "g6-contextmenu").
#' @param trigger How to trigger the menu: "contextmenu" for right-click,
#' "click" for click (string, default: "contextmenu").
#' @param offset Offset of the menu display in X and Y directions (numeric vector, default: c(4, 4)).
#' @param onClick Callback method triggered after menu item is clicked (JS function). Our default allows
#' to create edge or either remove the current node.
#' @param getItems Returns the list of menu items, supports Promise (JS function, default: NULL).
#' @param getContent Returns the content of the menu, supports Promise (JS function, default: NULL).
#' @param loadingContent Menu content used when getContent returns a
#' Promise (string or HTML element, default: NULL).
#' @param enable Whether the context menu is available (boolean or JS function, default: TRUE).
#' @param ... Extra parameters.
#' See \url{https://g6.antv.antgroup.com/en/manual/plugin/contextmenu}.
#'
#' @return A list with the configuration settings for the context menu plugin.
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- context_menu()
#'
#' # Custom configuration with JavaScript functions
#' config <- context_menu(
#'   key = "my-context-menu",
#'   className = "my-context-menu",
#'   trigger = "click",
#'   offset = c(10, 10),
#'   getItems = JS("(event) => {
#'     const type = event.itemType;
#'     const isNode = type === 'node';
#'     return [
#'       { key: 'delete', text: 'Delete' },
#'       { key: 'edit', text: 'Edit' },
#'       { key: 'details', text: 'View Details', disabled: !isNode }
#'     ];
#'   }"),
#'   onClick = JS("(value, target, current) => {
#'     if (value === 'delete') {
#'       // do stuff
#'   }")
#' )
context_menu <- function(
  key = "contextmenu",
  className = "g6-contextmenu",
  trigger = "contextmenu",
  offset = c(4, 4),
  onClick = NULL,
  getItems = NULL,
  getContent = NULL,
  loadingContent = NULL,
  enable = JS("(e) => e.targetType === 'node'"),
  ...
) {
  # Validate inputs
  if (!is.character(className)) {
    stop("'className' should be a string")
  }

  valid_triggers <- c("contextmenu", "click")
  if (!trigger %in% valid_triggers) {
    stop("'trigger' should be one of 'contextmenu' or 'click'")
  }

  if (!is.numeric(offset) || length(offset) != 2) {
    stop("'offset' should be a numeric vector of length 2")
  }

  # Validate JS functions (no conversion)
  if (!is.null(onClick) && !is_js(onClick)) {
    stop(
      "'onClick' must be a JavaScript function wrapped with JS()"
    )
  }

  if (!is.null(getItems) && !is_js(getItems)) {
    stop(
      "'getItems' must be a JavaScript function wrapped with JS()"
    )
  }

  if (!is.null(getContent) && !is_js(getContent)) {
    stop(
      "'getContent' must be a JavaScript function wrapped with JS()"
    )
  }

  if (!is.logical(enable) && !is_js(enable)) {
    stop(
      "'enable' must be a boolean or a JavaScript function wrapped with JS()"
    )
  }

  if (
    !is.null(loadingContent) &&
      !is.character(loadingContent) &&
      !is_js(loadingContent)
  ) {
    stop("'loadingContent' must be a string or JavaScript expression")
  }

  # Get all function argument names
  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "contextmenu"

  # Provide default for onSelect for Shiny context
  if (is.null(config$onClick)) {
    config$onClick <- JS(
      "(value, target, current) => {
        const graph = HTMLWidgets
          .find(`#${target.closest('.g6').id}`)
          .getWidget();
        if (current.id === undefined) return;
        if (value === 'create_edge') {
          graph.updateBehavior({
            key: 'create-edge', // Specify the behavior to update
            enable: true,
          });
          // Select node
          graph.setElementState(current.id, 'selected');
          // Disable drag node as it is incompatible with edge creation
          graph.updateBehavior({ key: 'drag-element', enable: false });
          graph.updateBehavior({ key: 'drag-element-force', enable: false });
        } else if (value === 'remove_node') {
          graph.removeNodeData([current.id]);
          graph.draw();
        }
      }
    "
    )
  }

  if (is.null(config$getItems)) {
    config$getItems <- JS(
      "() => {
        return [
          { name: 'Create edge', value: 'create_edge' },
          { name: 'Remove node', value: 'remove_node' }
        ];
      }"
    )
  }

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Configure Edge Bundling Plugin
#'
#' Creates a configuration object for the edge-bundling plugin in G6.
#' This plugin automatically bundles similar edges together to reduce visual clutter.
#'
#' @param key Unique identifier for the plugin (string, default: NULL).
#' @param bundleThreshold Edge compatibility threshold, determines which edges
#' should be bundled together (number, default: 0.6).
#' @param cycles Number of simulation cycles (number, default: 6).
#' @param divisions Initial number of cut points (number, default: 1).
#' @param divRate Growth rate of cut points (number, default: 2).
#' @param iterations Number of iterations executed in the first cycle (number, default: 90).
#' @param iterRate Iteration decrement rate (number, default: 2/3).
#' @param K Edge strength, affects attraction and repulsion between edges (number, default: 0.1).
#' @param lambda Initial step size (number, default: 0.1).
#' @param ... Extra parameters.
#' See \url{https://g6.antv.antgroup.com/en/manual/plugin/edge-bundling}.
#'
#' @return A list with the configuration settings for the edge-bundling plugin.
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- edge_bundling()
#'
#' # Custom configuration
#' config <- edge_bundling(
#'   key = "my-edge-bundling",
#'   bundleThreshold = 0.8,
#'   cycles = 8,
#'   K = 0.2
#' )
edge_bundling <- function(
  key = "edge-bundling",
  bundleThreshold = 0.6,
  cycles = 6,
  divisions = 1,
  divRate = 2,
  iterations = 90,
  iterRate = 2 / 3,
  K = 0.1,
  lambda = 0.1,
  ...
) {
  # Validate inputs
  if (
    !is.numeric(bundleThreshold) || bundleThreshold < 0 || bundleThreshold > 1
  ) {
    stop("'bundleThreshold' must be a number between 0 and 1")
  }

  if (!is.numeric(cycles) || cycles <= 0) {
    stop("'cycles' must be a positive number")
  }

  if (!is.numeric(divisions) || divisions <= 0) {
    stop("'divisions' must be a positive number")
  }

  if (!is.numeric(divRate) || divRate <= 0) {
    stop("'divRate' must be a positive number")
  }

  if (!is.numeric(iterations) || iterations <= 0) {
    stop("'iterations' must be a positive number")
  }

  if (!is.numeric(iterRate) || iterRate <= 0) {
    stop("'iterRate' must be a positive number")
  }

  if (!is.numeric(K) || K <= 0) {
    stop("'K' must be a positive number")
  }

  if (!is.numeric(lambda) || lambda <= 0) {
    stop("'lambda' must be a positive number")
  }

  # Get all function argument names
  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "edge-bundling"

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Configure Edge Filter Lens Plugin
#'
#' Creates a configuration object for the edge-filter-lens plugin in G6.
#' This plugin creates a lens that filters and displays edges within a specific area.
#'
#' @param key Unique identifier for the plugin (string, default: NULL).
#' @param trigger Method to move the lens: "pointermove", "click", or "drag" (string, default: "pointermove").
#' @param r Radius of the lens (number, default: 60).
#' @param maxR Maximum radius of the lens (number, default: NULL - half of the smaller canvas dimension).
#' @param minR Minimum radius of the lens (number, default: 0).
#' @param scaleRBy Method to scale the lens radius (string, default: "wheel").
#' @param nodeType Edge display condition: "both", "source", "target", or "either" (string, default: "both").
#' @param filter Filter out elements that are never displayed in the lens (JS function, default: NULL).
#' @param style Style of the lens (list, default: NULL).
#' @param nodeStyle Style of nodes in the lens (list or JS function, default: list(label = FALSE)).
#' @param edgeStyle Style of edges in the lens (list or JS function, default: list(label = TRUE)).
#' @param preventDefault Whether to prevent default events (boolean, default: TRUE).
#' @param ... Extra parameters.
#' See \url{https://g6.antv.antgroup.com/en/manual/plugin/edge-filter-lens}.
#'
#' @return A list with the configuration settings for the edge-filter-lens plugin.
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- edge_filter_lens()
#'
#' # Custom configuration
#' config <- edge_filter_lens(
#'   key = "my-edge-lens",
#'   trigger = "drag",
#'   r = 100,
#'   nodeType = "either",
#'   style = list(
#'     fill = "rgba(200, 200, 200, 0.3)",
#'     stroke = "#999",
#'     lineWidth = 2
#'   ),
#'   filter = JS("(id, type) => {
#'     // Only display edges connected to specific nodes
#'     if (type === 'edge') {
#'       const edge = graph.getEdgeData(id);
#'       return edge.source === 'node1' || edge.target === 'node1';
#'     }
#'     return true;
#'   }")
#' )
edge_filter_lens <- function(
  key = "edge-filter-lens",
  trigger = c("pointermove", "click", "drag"),
  r = 60,
  maxR = NULL, # TBD check the default
  minR = 0,
  scaleRBy = "wheel",
  nodeType = c("both", "source", "target", "either"),
  filter = NULL,
  style = NULL,
  nodeStyle = list(label = FALSE),
  edgeStyle = list(label = TRUE),
  preventDefault = TRUE,
  ...
) {
  # Validate inputs
  trigger <- match.arg(trigger)

  if (!is.numeric(r) || r < 0) {
    stop("'r' must be a non-negative number")
  }

  if (!is.null(maxR) && (!is.numeric(maxR) || maxR < r)) {
    stop("'maxR' must be a number greater than or equal to 'r'")
  }

  if (!is.numeric(minR) || minR < 0 || minR > r) {
    stop("'minR' must be a non-negative number less than or equal to 'r'")
  }

  if (!is.character(scaleRBy) || scaleRBy != "wheel") {
    stop("'scaleRBy' must be 'wheel'")
  }

  nodeType <- match.arg(nodeType)

  if (!is.null(filter) && !is_js(filter)) {
    stop(
      "'filter' must be a JavaScript function wrapped with JS()"
    )
  }

  if (!is.null(style) && !is.list(style)) {
    stop("'style' must be a list")
  }

  if (!is.null(nodeStyle) && !is.list(nodeStyle)) {
    stop(
      "'nodeStyle' must be a list"
    )
  }

  if (!is.null(edgeStyle) && !is.list(edgeStyle)) {
    stop(
      "'edgeStyle' must be a list"
    )
  }

  if (!is.logical(preventDefault)) {
    stop("'preventDefault' must be a boolean value")
  }

  # Get all function argument names
  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "edge-filter-lens"

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Configure Fish Eye Plugin
#'
#' Creates a configuration object for the fisheye plugin in G6.
#' This plugin creates a fisheye lens effect that magnifies elements within a specific area.
#'
#' @param key Unique identifier for the plugin (string, default: NULL).
#' @param trigger Method to move the fisheye: "pointermove", "click", or "drag" (string, default: "pointermove").
#' @param r Radius of the fisheye (number, default: 120).
#' @param maxR Maximum adjustable radius of the fisheye
#' (number, default: NULL - half of the smaller canvas dimension).
#' @param minR Minimum adjustable radius of the fisheye (number, default: 0).
#' @param d Distortion factor (number, default: 1.5).
#' @param maxD Maximum adjustable distortion factor (number, default: 5).
#' @param minD Minimum adjustable distortion factor (number, default: 0).
#' @param scaleRBy Method to adjust the fisheye radius: "wheel" or "drag" (string, default: NULL).
#' @param scaleDBy Method to adjust the fisheye distortion factor: "wheel" or "drag" (string, default: NULL).
#' @param showDPercent Whether to show the distortion factor value in the fisheye (boolean, default: TRUE).
#' @param style Style of the fisheye (list, default: NULL).
#' @param nodeStyle Style of nodes in the fisheye (list or JS function, default: list(label = TRUE)).
#' @param preventDefault Whether to prevent default events (boolean, default: TRUE).
#' @param ... Extra parameters.
#' See \url{https://g6.antv.antgroup.com/en/manual/fisheye}.
#'
#' @return A list with the configuration settings for the fisheye plugin.
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- fish_eye()
#'
#' # Custom configuration
#' config <- fish_eye(
#'   key = "my-fisheye",
#'   trigger = "drag",
#'   r = 200,
#'   d = 2.5,
#'   scaleRBy = "wheel",
#'   scaleDBy = "drag",
#'   style = list(
#'     stroke = "#1890ff",
#'     fill = "rgba(24, 144, 255, 0.1)",
#'     lineWidth = 2
#'   ),
#'   nodeStyle = JS("(datum) => {
#'     return {
#'       label: true,
#'       labelCfg: {
#'         style: {
#'           fill: '#003a8c',
#'           fontSize: 14
#'         }
#'       }
#'     };
#'   }")
#' )
fish_eye <- function(
  key = "fish-eye",
  trigger = c("pointermove", "click", "drag"),
  r = 120,
  maxR = NULL,
  minR = 0,
  d = 1.5,
  maxD = 5,
  minD = 0,
  scaleRBy = NULL,
  scaleDBy = NULL,
  showDPercent = TRUE,
  style = NULL,
  nodeStyle = list(label = TRUE),
  preventDefault = TRUE,
  ...
) {
  # Validate inputs
  trigger <- match.arg(trigger)

  if (!is.numeric(r) || r < 0) {
    stop("'r' must be a non-negative number")
  }

  if (!is.null(maxR) && (!is.numeric(maxR) || maxR < r)) {
    stop("'maxR' must be a number greater than or equal to 'r'")
  }

  if (!is.numeric(minR) || minR < 0 || minR > r) {
    stop("'minR' must be a non-negative number less than or equal to 'r'")
  }

  if (!is.numeric(d) || d < 0) {
    stop("'d' must be a non-negative number")
  }

  if (!is.numeric(maxD) || maxD < d) {
    stop("'maxD' must be a number greater than or equal to 'd'")
  }

  if (!is.numeric(minD) || minD < 0 || minD > d) {
    stop("'minD' must be a non-negative number less than or equal to 'd'")
  }

  valid_scale_methods <- c("wheel", "drag")
  if (!is.null(scaleRBy) && !scaleRBy %in% valid_scale_methods) {
    stop("'scaleRBy' must be one of 'wheel' or 'drag'")
  }

  if (!is.null(scaleDBy) && !scaleDBy %in% valid_scale_methods) {
    stop("'scaleDBy' must be one of 'wheel' or 'drag'")
  }

  if (!is.logical(showDPercent)) {
    stop("'showDPercent' must be a boolean value")
  }

  if (!is.null(style) && !is.list(style)) {
    stop("'style' must be a list")
  }

  if (!is.null(nodeStyle) && !is.list(nodeStyle) && !is_js(nodeStyle)) {
    stop(
      "'nodeStyle' must be a list or a JS function returning style properties."
    )
  }

  if (!is.logical(preventDefault)) {
    stop("'preventDefault' must be a boolean value")
  }

  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "fisheye"

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Configure Fullscreen Plugin
#'
#' Creates a configuration object for the fullscreen plugin in G6.
#' This plugin enables fullscreen mode for the graph.
#'
#' @param key Unique identifier for the plugin (string, default: NULL).
#' @param autoFit Whether to auto-fit the canvas size to the screen when in
#' fullscreen mode (boolean, default: TRUE).
#' @param trigger Methods to trigger fullscreen, e.g.,
#' list(request = "button", exit = "escape") (list, default: NULL).
#' @param onEnter Callback function after entering fullscreen mode (JS function, default: NULL).
#' @param onExit Callback function after exiting fullscreen mode (JS function, default: NULL).
#' @param ... Extra parameters.
#' See \url{https://g6.antv.antgroup.com/en/manual/plugin/fullscreen}.
#'
#' @return A list with the configuration settings for the fullscreen plugin.
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- fullscreen()
#'
#' # Custom configuration
#' config <- fullscreen(
#'   key = "my-fullscreen",
#'   autoFit = TRUE,
#'   trigger = list(
#'     request = "F",
#'     exit = "Esc"
#'   ),
#'   onEnter = JS("() => {
#'     console.log('Entered fullscreen mode');
#'   }"),
#'   onExit = JS("() => {
#'     console.log('Exited fullscreen mode');
#'   }")
#' )
fullscreen <- function(
  key = "fullscreen",
  autoFit = TRUE,
  trigger = NULL,
  onEnter = NULL,
  onExit = NULL,
  ...
) {
  # Validate inputs
  if (!is.logical(autoFit)) {
    stop("'autoFit' must be a boolean value")
  }

  if (!is.null(trigger) && !is.list(trigger)) {
    stop("'trigger' must be a list with 'request' and/or 'exit' properties")
  }

  if (!is.null(trigger)) {
    if (!is.null(trigger$request) && !is.character(trigger$request)) {
      stop("'trigger$request' must be a string")
    }
    if (!is.null(trigger$exit) && !is.character(trigger$exit)) {
      stop("'trigger$exit' must be a string")
    }
  }

  if (!is.null(onEnter) && !is_js(onEnter)) {
    stop(
      "'onEnter' must be a JavaScript function wrapped with JS()"
    )
  }

  if (!is.null(onExit) && !is_js(onExit)) {
    stop(
      "'onExit' must be a JavaScript function wrapped with JS()"
    )
  }

  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "fullscreen"

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Configure Grid Line Plugin
#'
#' Creates a configuration object for the grid-line plugin in G6.
#' This plugin adds a background grid to the graph canvas.
#'
#' @param key Unique identifier for the plugin (string, default: NULL).
#' @param border Whether to display the border (boolean, default: TRUE).
#' @param borderLineWidth Border line width (number, default: 1).
#' @param borderStroke Border color (string, default: "#eee").
#' @param borderStyle Border style (string, default: "solid").
#' @param follow Whether the grid follows canvas movements (boolean or list, default: FALSE).
#' @param lineWidth Grid line width (number or string, default: 1).
#' @param size Grid unit size in pixels (number, default: 20).
#' @param stroke Grid line color (string, default: "#eee").
#' @param ... Extra parameters.
#' See \url{https://g6.antv.antgroup.com/en/manual/plugin/grid-line}.
#'
#' @return A list with the configuration settings for the grid-line plugin.
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- grid_line()
#'
#' # Custom configuration
#' config <- grid_line(
#'   key = "my-grid",
#'   border = TRUE,
#'   borderLineWidth = 2,
#'   borderStroke = "#ccc",
#'   borderStyle = "dashed",
#'   follow = list(
#'     translate = TRUE,
#'     zoom = FALSE
#'   ),
#'   lineWidth = 0.5,
#'   size = 30,
#'   stroke = "#e0e0e0"
#' )
grid_line <- function(
  key = "grid-line",
  border = TRUE,
  borderLineWidth = 1,
  borderStroke = "#eee",
  borderStyle = "solid",
  follow = FALSE,
  lineWidth = 1,
  size = 20,
  stroke = "#eee",
  ...
) {
  # Validate inputs
  if (!is.logical(border)) {
    stop("'border' must be a boolean value")
  }

  if (!is.numeric(borderLineWidth) || borderLineWidth < 0) {
    stop("'borderLineWidth' must be a non-negative number")
  }

  if (!is.character(borderStroke)) {
    stop("'borderStroke' must be a string representing a color")
  }

  valid_border_styles <- c(
    "solid",
    "dashed",
    "dotted",
    "double",
    "groove",
    "ridge",
    "inset",
    "outset",
    "none",
    "hidden"
  )
  if (!is.character(borderStyle) || !borderStyle %in% valid_border_styles) {
    stop("'borderStyle' must be a valid CSS border style")
  }

  if (!is.logical(follow) && !is.list(follow)) {
    stop(
      "'follow' must be a boolean or a list with 'translate' and/or 'zoom' properties"
    )
  }

  if (is.list(follow)) {
    if (!is.null(follow$translate) && !is.logical(follow$translate)) {
      stop("'follow$translate' must be a boolean")
    }
    if (!is.null(follow$zoom) && !is.logical(follow$zoom)) {
      stop("'follow$zoom' must be a boolean")
    }
  }

  if (!is.numeric(lineWidth) && !is.character(lineWidth)) {
    stop("'lineWidth' must be a number or string")
  }

  if (is.numeric(lineWidth) && lineWidth < 0) {
    stop("'lineWidth' as a number must be non-negative")
  }

  if (!is.numeric(size) || size <= 0) {
    stop("'size' must be a positive number")
  }

  if (!is.character(stroke)) {
    stop("'stroke' must be a string representing a color")
  }

  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "grid-line"

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Configure History Plugin
#'
#' Creates a configuration object for the history plugin in G6.
#' This plugin enables undo/redo functionality for graph operations.
#'
#' @param key Unique identifier for the plugin (string, default: NULL).
#' @param afterAddCommand Callback function called after a command is added to
#' the undo/redo queue (JS function, default: NULL).
#' @param beforeAddCommand Callback function called before a command is added to
#' the undo/redo queue (JS function, default: NULL).
#' @param executeCommand Callback function called when executing a command (JS function, default: NULL).
#' @param stackSize Maximum length of history records to be recorded, 0 means unlimited (number, default: 0).
#' @param ... Extra parameters.
#' See \url{https://g6.antv.antgroup.com/en/manual/plugin/history}.
#'
#' @return A list with the configuration settings for the history plugin.
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- history()
#'
#' # Custom configuration
#' config <- history(
#'   key = "my-history",
#'   stackSize = 50,
#'   beforeAddCommand = JS("function(cmd, revert) {
#'     console.log('Before adding command:', cmd);
#'     // Only allow certain operations to be recorded
#'     return cmd.method !== 'update';
#'   }"),
#'   afterAddCommand = JS("function(cmd, revert) {
#'     console.log('Command added to ' + (revert ? 'undo' : 'redo') + ' stack');
#'   }"),
#'   executeCommand = JS("function(cmd) {
#'     console.log('Executing command:', cmd);
#'   }")
#' )
history <- function(
  key = "history",
  afterAddCommand = NULL,
  beforeAddCommand = NULL,
  executeCommand = NULL,
  stackSize = 0,
  ...
) {
  # Validate inputs
  if (!is.null(afterAddCommand) && !is_js(afterAddCommand)) {
    stop(
      "'afterAddCommand' must be a JavaScript function wrapped with JS()"
    )
  }

  if (!is.null(beforeAddCommand) && !is_js(beforeAddCommand)) {
    stop(
      "'beforeAddCommand' must be a JavaScript function wrapped with JS()"
    )
  }

  if (!is.null(executeCommand) && !is_js(executeCommand)) {
    stop(
      "'executeCommand' must be a JavaScript function wrapped with JS()"
    )
  }

  if (
    !is.numeric(stackSize) || stackSize < 0 || stackSize != round(stackSize)
  ) {
    stop("'stackSize' must be a non-negative integer")
  }

  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "history"

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Configure Hull Plugin
#'
#' Creates a configuration object for the hull plugin in G6.
#' This plugin creates a hull (convex or concave) that surrounds specified graph elements.
#'
#' @param members Elements within the hull, including nodes and edges (character vector, required).
#' @param key Unique identifier for the plugin (string, default: NULL).
#' @param concavity Concavity parameter, larger values create less concave hulls (number, default: Infinity).
#' @param corner Corner type: "rounded", "smooth", or "sharp" (string, default: "rounded").
#' @param padding Padding around the elements (number, default: 10).
#' @param label Whether to display the label (boolean, default: TRUE).
#' @param labelText Label text content. Default to NULL.
#' @param labelPlacement Label position: "left", "right", "top", "bottom", or "center" (string, default: "bottom").
#' @param labelBackground Whether to display the background (boolean, default: FALSE).
#' @param labelPadding Label padding (number or numeric vector, default: 0).
#' @param labelCloseToPath Whether the label is close to the hull (boolean, default: TRUE).
#' @param labelAutoRotate Whether the label rotates with the hull, effective only when
#' closeToPath is true (boolean, default: TRUE).
#' @param labelOffsetX X-axis offset (number, default: 0).
#' @param labelOffsetY Y-axis offset (number, default: 0).
#' @param labelMaxWidth Maximum width of the text, exceeding will be ellipsized (number, default: 0).
#' @param ... Other options.
#' See \url{https://g6.antv.antgroup.com/en/manual/plugin/hull}.
#'
#' @return A list with the configuration settings for the hull plugin.
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- hull(members = c("node1", "node2", "node3"))
#'
#' # Custom configuration for a cluster
#' config <- hull(
#'   key = "cluster-hull",
#'   members = c("node1", "node2", "node3", "node4"),
#'   concavity = 0.8,
#'   corner = "smooth",
#'   padding = 15,
#'   label = TRUE,
#'   labelPlacement = "top",
#'   labelBackground = TRUE,
#'   labelPadding = c(4, 8),
#'   labelMaxWidth = 100
#' )
hull <- function(
  members,
  key = "hull",
  concavity = Inf,
  corner = c("rounded", "smooth", "sharp"),
  padding = 10,
  label = TRUE,
  labelText = NULL,
  labelPlacement = c("bottom", "left", "right", "top", "center"),
  labelBackground = FALSE,
  labelPadding = 0,
  labelCloseToPath = TRUE,
  labelAutoRotate = TRUE,
  labelOffsetX = 0,
  labelOffsetY = 0,
  labelMaxWidth = 0,
  ...
) {
  # Validate inputs
  if (!is.character(members) || length(members) == 0) {
    stop("'members' must be a non-empty character vector")
  }

  if (!is.numeric(concavity) || concavity <= 0) {
    stop("'concavity' must be a positive number or Infinity")
  }

  corner <- match.arg(corner)

  if (!is.numeric(padding) || padding < 0) {
    stop("'padding' must be a non-negative number")
  }

  if (!is.logical(label)) {
    stop("'label' must be a boolean value")
  }

  labelPlacement <- match.arg(labelPlacement)

  if (!is.logical(labelBackground)) {
    stop("'labelBackground' must be a boolean value")
  }

  # Check if labelPadding is a number or numeric vector
  if (!is.numeric(labelPadding)) {
    stop("'labelPadding' must be a number or numeric vector")
  }

  if (!is.logical(labelCloseToPath)) {
    stop("'labelCloseToPath' must be a boolean value")
  }

  if (!is.logical(labelAutoRotate)) {
    stop("'labelAutoRotate' must be a boolean value")
  }

  if (!is.numeric(labelOffsetX)) {
    stop("'labelOffsetX' must be a number")
  }

  if (!is.numeric(labelOffsetY)) {
    stop("'labelOffsetY' must be a number")
  }

  if (!is.numeric(labelMaxWidth) || labelMaxWidth < 0) {
    stop("'labelMaxWidth' must be a non-negative number")
  }

  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "hull"

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Configure Legend Plugin
#'
#' Creates a configuration object for the legend plugin in G6.
#' This plugin adds a legend to the graph, allowing users to identify and interact with
#' different categories of elements.
#'
#' @param key Unique identifier for the plugin (string, default: NULL).
#' @param trigger How legend items trigger highlighting: "hover" or "click" (string, default: "hover").
#' @param position Relative position of the legend on the canvas (string, default: "bottom").
#' @param container Container to which the legend is mounted (HTML element or string, default: NULL).
#' @param className Legend canvas class name (string, default: NULL).
#' @param containerStyle Style of the legend container (list or JS object, default: NULL).
#' @param nodeField Node classification identifier (string or JS function, default: NULL).
#' @param edgeField Edge classification identifier (string or JS function, default: NULL).
#' @param comboField Combo classification identifier (string or JS function, default: NULL).
#' @param orientation Layout direction: "horizontal" or "vertical" (string, default: "horizontal").
#' @param layout Layout method: "flex" or "grid" (string, default: "flex").
#' @param showTitle Whether to display the title (boolean, default: FALSE).
#' @param titleText Title content (string, default: "").
#' @param x Relative horizontal position (number, default: NULL).
#' @param y Relative vertical position (number, default: NULL).
#' @param width Width of the legend (number, default: 240).
#' @param height Height of the legend (number, default: 160).
#' @param itemSpacing Spacing between text and marker (number, default: 4).
#' @param rowPadding Spacing between rows (number, default: 10).
#' @param colPadding Spacing between columns (number, default: 10).
#' @param itemMarkerSize Size of the legend item marker (number, default: 16).
#' @param itemLabelFontSize Font size of the legend item text (number, default: 16).
#' @param gridCol Maximum number of columns for grid layout (number, default: NULL).
#' @param gridRow Maximum number of rows for grid layout (number, default: NULL).
#' @param ... Extra parameters.
#' See \url{https://g6.antv.antgroup.com/en/manual/plugin/legend}.
#'
#' @return A list with the configuration settings for the legend plugin.
#' @export
#'
#' @examples
#' # Basic configuration for node categories
#' config <- legend(
#'   nodeField = "category"
#' )
#'
#' # Advanced configuration
#' config <- legend(
#'   key = "my-legend",
#'   position = "top-right",
#'   nodeField = "type",
#'   edgeField = "relation",
#'   orientation = "vertical",
#'   layout = "grid",
#'   showTitle = TRUE,
#'   titleText = "Graph Elements",
#'   width = 300,
#'   height = 200,
#'   gridCol = 2,
#'   containerStyle = list(
#'     background = "#f9f9f9",
#'     border = "1px solid #ddd",
#'     borderRadius = "4px",
#'     padding = "8px"
#'   )
#' )
#'
#' # Using a function for classification
#' config <- legend(
#'   nodeField = JS("(item) => {
#'     return item.data.importance > 0.5 ? 'Important' : 'Regular';
#'   }")
#' )
legend <- function(
  key = "legend",
  trigger = c("hover", "click"),
  position = c(
    "bottom",
    "top",
    "left",
    "right",
    "top-left",
    "top-right",
    "bottom-left",
    "bottom-right"
  ),
  container = NULL,
  className = NULL,
  containerStyle = NULL,
  nodeField = NULL,
  edgeField = NULL,
  comboField = NULL,
  orientation = c("horizontal", "vertical"),
  layout = c("flex", "grid"),
  showTitle = FALSE,
  titleText = "",
  x = NULL,
  y = NULL,
  width = 240,
  height = 160,
  itemSpacing = 4,
  rowPadding = 10,
  colPadding = 10,
  itemMarkerSize = 16,
  itemLabelFontSize = 16,
  gridCol = NULL,
  gridRow = NULL,
  ...
) {
  # Validate inputs
  trigger <- match.arg(trigger)

  position <- match.arg(position)

  if (
    !is.null(container) &&
      !is.character(container) &&
      !inherits(container, "JS_EVAL")
  ) {
    stop(
      "'container' must be a string selector or HTMLElement reference wrapped with JS()"
    )
  }

  if (!is.null(className) && !is.character(className)) {
    stop("'className' must be a string")
  }

  if (
    !is.null(containerStyle) &&
      !is.list(containerStyle) &&
      !inherits(containerStyle, "JS_EVAL")
  ) {
    stop(
      "'containerStyle' must be a list or a JavaScript object wrapped with JS()"
    )
  }

  if (
    !is.null(nodeField) &&
      !is.character(nodeField) &&
      !is_js(nodeField)
  ) {
    stop(
      "'nodeField' must be a string or a JavaScript function wrapped with JS()"
    )
  }

  if (
    !is.null(edgeField) &&
      !is.character(edgeField) &&
      !is_js(edgeField)
  ) {
    stop(
      "'edgeField' must be a string or a JavaScript function wrapped with JS()"
    )
  }

  if (
    !is.null(comboField) &&
      !is.character(comboField) &&
      !is_js(comboField)
  ) {
    stop(
      "'comboField' must be a string or a JavaScript function wrapped with JS()"
    )
  }

  orientation <- match.arg(orientation)

  layout <- match.arg(layout)

  if (!is.logical(showTitle)) {
    stop("'showTitle' must be a boolean value")
  }

  if (!is.character(titleText)) {
    stop("'titleText' must be a string")
  }

  if (!is.null(x) && (!is.numeric(x) || length(x) != 1)) {
    stop("'x' must be a single numeric value")
  }

  if (!is.null(y) && (!is.numeric(y) || length(y) != 1)) {
    stop("'y' must be a single numeric value")
  }

  if (!is.numeric(width) || width <= 0) {
    stop("'width' must be a positive number")
  }

  if (!is.numeric(height) || height <= 0) {
    stop("'height' must be a positive number")
  }

  if (!is.numeric(itemSpacing) || itemSpacing < 0) {
    stop("'itemSpacing' must be a non-negative number")
  }

  if (!is.numeric(rowPadding) || rowPadding < 0) {
    stop("'rowPadding' must be a non-negative number")
  }

  if (!is.numeric(colPadding) || colPadding < 0) {
    stop("'colPadding' must be a non-negative number")
  }

  if (!is.numeric(itemMarkerSize) || itemMarkerSize <= 0) {
    stop("'itemMarkerSize' must be a positive number")
  }

  if (!is.numeric(itemLabelFontSize) || itemLabelFontSize <= 0) {
    stop("'itemLabelFontSize' must be a positive number")
  }

  if (
    !is.null(gridCol) &&
      (!is.numeric(gridCol) || gridCol <= 0 || gridCol != as.integer(gridCol))
  ) {
    stop("'gridCol' must be a positive integer")
  }

  if (
    !is.null(gridRow) &&
      (!is.numeric(gridRow) || gridRow <= 0 || gridRow != as.integer(gridRow))
  ) {
    stop("'gridRow' must be a positive integer")
  }

  # Get all function argument names
  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "legend"

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Configure Minimap Plugin
#'
#' Creates a configuration object for the minimap plugin in G6.
#' This plugin adds a minimap/thumbnail view of the entire graph.
#'
#' @param key Unique identifier for the plugin (string, default: NULL).
#' @param className Class name of the thumbnail canvas (string, default: NULL).
#' @param container Container to which the thumbnail is mounted (HTML element or string, default: NULL).
#' @param containerStyle Style of the thumbnail container (list or JS object, default: NULL).
#' @param delay Delay update time in milliseconds for performance optimization (number, default: 128).
#' @param filter Function to filter elements to display in minimap (JS function, default: NULL).
#' @param maskStyle Style of the mask (list or JS object, default: NULL).
#' @param padding Padding around the minimap (number or numeric vector, default: 10).
#' @param position Position of the thumbnail relative to the canvas
#' (string or numeric vector, default: "right-bottom").
#' @param renderer Custom renderer (JS object, default: NULL).
#' @param shape Method for generating element thumbnails (string or JS function, default: "key").
#' @param size Width and height of the minimap \code{[width, height]} (numeric vector, default: c(240, 160)).
#' @param ... Extra parameters.
#' See \url{https://g6.antv.antgroup.com/en/manual/plugin/minimap}.
#'
#' @return A list with the configuration settings for the minimap plugin.
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- minimap()
#'
#' # Custom configuration
#' config <- minimap(
#'   key = "my-minimap",
#'   position = "left-top",
#'   size = c(200, 150),
#'   padding = 15,
#'   containerStyle = list(
#'     border = "1px solid #ddd",
#'     borderRadius = "4px",
#'     boxShadow = "0 0 8px rgba(0,0,0,0.1)"
#'   ),
#'   maskStyle = list(
#'     stroke = "#1890ff",
#'     strokeWidth = 2,
#'     fill = "rgba(24, 144, 255, 0.1)"
#'   )
#' )
#'
#' # With custom filtering function
#' config <- minimap(
#'   filter = JS("(id, elementType) => {
#'     // Only show nodes and important edges in the minimap
#'     if (elementType === 'node') return true;
#'     if (elementType === 'edge') {
#'       // Assuming edges have an 'important' attribute
#'       const edge = graph.findById(id);
#'       return edge.getModel().important === true;
#'     }
#'     return false;
#'   }")
#' )
minimap <- function(
  key = "minimap",
  className = NULL,
  container = NULL,
  containerStyle = NULL,
  delay = 128,
  filter = NULL,
  maskStyle = NULL,
  padding = 10,
  position = "right-bottom",
  renderer = NULL,
  shape = "key",
  size = c(240, 160),
  ...
) {
  # Validate inputs
  if (!is.null(className) && !is.character(className)) {
    stop("'className' must be a string")
  }

  if (
    !is.null(container) &&
      !is.character(container) &&
      !is_js(container)
  ) {
    stop(
      "'container' must be a string selector or HTMLElement reference wrapped with JS()"
    )
  }

  if (
    !is.null(containerStyle) &&
      !is.list(containerStyle) &&
      !is_js(containerStyle)
  ) {
    stop(
      "'containerStyle' must be a list or a JavaScript object wrapped with JS()"
    )
  }

  if (!is.numeric(delay) || delay < 0) {
    stop("'delay' must be a non-negative number")
  }

  if (!is.null(filter) && !is_js(filter)) {
    stop(
      "'filter' must be a JavaScript function wrapped with JS()"
    )
  }

  if (
    !is.null(maskStyle) &&
      !is.list(maskStyle) &&
      !is_js(maskStyle)
  ) {
    stop(
      "'maskStyle' must be a list or a JavaScript object wrapped with JS()"
    )
  }

  # Check if padding is a number or numeric vector
  if (!is.numeric(padding)) {
    stop("'padding' must be a number or numeric vector")
  }

  valid_positions <- c(
    "left",
    "right",
    "top",
    "bottom",
    "left-top",
    "left-bottom",
    "right-top",
    "right-bottom",
    "top-left",
    "top-right",
    "bottom-left",
    "bottom-right",
    "center"
  )
  if (!is.character(position) && !is.numeric(position)) {
    stop("'position' must be a string or numeric vector [x, y]")
  }

  if (is.character(position) && !position %in% valid_positions) {
    stop("'position' as string must be one of the valid position values")
  }

  if (is.numeric(position) && length(position) != 2) {
    stop("'position' as numeric vector must have exactly 2 elements [x, y]")
  }

  if (!is.null(renderer) && !is_js(renderer)) {
    stop(
      "'renderer' must be a JavaScript object wrapped with JS()"
    )
  }

  if (!is.character(shape) && !is_js(shape)) {
    stop(
      "'shape' must be a string or a JavaScript function wrapped with JS()"
    )
  }

  if (!is.numeric(size) || length(size) != 2 || any(size <= 0)) {
    stop("'size' must be a numeric vector of length 2 with positive values")
  }

  # Get all function argument names
  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "minimap"

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Configure Snapline Plugin
#'
#' Creates a configuration object for the snapline plugin in G6.
#' This plugin provides alignment guidelines when moving nodes.
#'
#' @param key Unique identifier for the plugin (string, default: NULL).
#' @param tolerance The alignment accuracy in pixels (number, default: 5).
#' @param offset The extension distance of the snapline (number, default: 20).
#' @param autoSnap Whether to enable automatic snapping (boolean, default: TRUE).
#' @param shape Specifies which shape to use as reference: "key" or a function
#' (string or JS function, default: "key").
#' @param verticalLineStyle Vertical snapline style (list or JS object, default: list(stroke = "#1783FF")).
#' @param horizontalLineStyle Horizontal snapline style (list or JS object, default: list(stroke = "#1783FF")).
#' @param filter Function to filter nodes that don't participate in alignment (JS function, default: NULL).
#' @param ... Extra parameters.
#' See \url{https://g6.antv.antgroup.com/en/manual/plugin/snapline}.
#'
#' @return A list with the configuration settings for the snapline plugin.
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- snapline()
#'
#' # Custom configuration
#' config <- snapline(
#'   key = "my-snapline",
#'   tolerance = 8,
#'   offset = 30,
#'   verticalLineStyle = list(
#'     stroke = "#f00",
#'     strokeWidth = 1.5,
#'     lineDash = c(5, 2)
#'   ),
#'   horizontalLineStyle = list(
#'     stroke = "#00f",
#'     strokeWidth = 1.5,
#'     lineDash = c(5, 2)
#'   )
#' )
#'
#' # With custom filter function
#' config <- snapline(
#'   filter = JS("(node) => {
#'     // Only allow regular nodes to participate in alignment
#'     // Exclude special nodes like 'start' or 'end'
#'     const model = node.getModel();
#'     return model.type !== 'start' && model.type !== 'end';
#'   }")
#' )
snapline <- function(
  key = "snapline",
  tolerance = 5,
  offset = 20,
  autoSnap = TRUE,
  shape = "key",
  verticalLineStyle = list(stroke = "#1783FF"),
  horizontalLineStyle = list(stroke = "#1783FF"),
  filter = NULL,
  ...
) {
  # Validate inputs
  if (!is.numeric(tolerance) || tolerance < 0) {
    stop("'tolerance' must be a non-negative number")
  }

  if (!is.numeric(offset) || offset < 0) {
    stop("'offset' must be a non-negative number")
  }

  if (!is.logical(autoSnap)) {
    stop("'autoSnap' must be a boolean value")
  }

  if (!is.character(shape) && !is_js(shape)) {
    stop(
      "'shape' must be a string or a JavaScript function wrapped with JS()"
    )
  }

  if (is.character(shape) && shape != "key") {
    stop("'shape' as string must be 'key'")
  }

  if (!is.null(verticalLineStyle) && !is.list(verticalLineStyle)) {
    stop(
      "'verticalLineStyle' must be a list"
    )
  }

  if (!is.null(horizontalLineStyle) && !is.list(horizontalLineStyle)) {
    stop(
      "'horizontalLineStyle' must be a list"
    )
  }

  if (!is.null(filter) && !is_js(filter)) {
    stop(
      "'filter' must be a JavaScript function wrapped with JS()"
    )
  }

  # Get all function argument names
  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "snapline"

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Configure Timebar Plugin
#'
#' Creates a configuration object for the timebar plugin in G6.
#' This plugin adds a timeline or chart-based control for time-related data visualization.
#'
#' @param data Time data, either a vector of timestamps or a list of objects with time and value (required).
#' @param key Unique identifier for the plugin (string, default: NULL).
#' @param className Additional class name for the timebar DOM (string, default: "g6-timebar").
#' @param x X position, will be ignored if position is set (number, default: NULL).
#' @param y Y position, will be ignored if position is set (number, default: NULL).
#' @param width Timebar width (number, default: 450).
#' @param height Timebar height (number, default: 60).
#' @param position Timebar position: "bottom" or "top" (string, default: "bottom").
#' @param padding Padding around the timebar (number or numeric vector, default: 10).
#' @param timebarType Display type: "time" or "chart" (string, default: "time").
#' @param elementTypes Filter element types: vector of "node", "edge", and/or "combo"
#' (character vector, default: c("node")).
#' @param mode Control element filtering method: "modify" or "visibility" (string, default: "modify").
#' @param values Current time value (number, vector of two numbers, Date, or vector of two Dates, default: NULL).
#' @param loop Whether to loop playback (boolean, default: FALSE).
#' @param getTime Method to get element time (JS function, default: NULL).
#' @param labelFormatter Custom time formatting in chart mode (JS function, default: NULL).
#' @param onChange Callback when time interval changes (JS function, default: NULL).
#' @param onReset Callback when reset (JS function, default: NULL).
#' @param onSpeedChange Callback when playback speed changes (JS function, default: NULL).
#' @param onPlay Callback when playback starts (JS function, default: NULL).
#' @param onPause Callback when paused (JS function, default: NULL).
#' @param onBackward Callback when moving backward (JS function, default: NULL).
#' @param onForward Callback when moving forward (JS function, default: NULL).
#' @param ... Extra parameters.
#' See \url{https://g6.antv.antgroup.com/en/manual/plugin/timebar}.
#'
#' @return A list with the configuration settings for the timebar plugin.
#' @export
#'
#' @examples
#' # Basic timebar with array of timestamps
#' config <- timebar(
#'   data = c(1609459200000, 1609545600000, 1609632000000)  # Jan 1-3, 2021 in milliseconds
#' )
#'
#' # Chart-type timebar with time-value pairs
#' config <- timebar(
#'   data = list(
#'     list(time = 1609459200000, value = 10),
#'     list(time = 1609545600000, value = 25),
#'     list(time = 1609632000000, value = 15)
#'   ),
#'   timebarType = "chart",
#'   width = 600,
#'   height = 100,
#'   position = "top"
#' )
#'
#' # With custom callbacks
#' config <- timebar(
#'   data = c(1609459200000, 1609545600000, 1609632000000),
#'   onChange = JS("(values) => {
#'     console.log('Time changed:', values);
#'   }"),
#'   onPlay = JS("() => {
#'     console.log('Playback started');
#'   }")
#' )
#'
#' # With custom time getter function for elements
#' config <- timebar(
#'   data = c(1609459200000, 1609545600000, 1609632000000),
#'   getTime = JS("(datum) => {
#'     return datum.created_at; // Get time from created_at property
#'   }")
#' )
timebar <- function(
  data,
  key = "timebar",
  className = "g6-timebar",
  x = NULL,
  y = NULL,
  width = 450,
  height = 60,
  position = c("bottom", "top"),
  padding = 10,
  timebarType = c("time", "chart"),
  elementTypes = c("node", "edge", "combo"),
  mode = c("modify", "visibility"),
  values = NULL,
  loop = FALSE,
  getTime = NULL,
  labelFormatter = NULL,
  onChange = NULL,
  onReset = NULL,
  onSpeedChange = NULL,
  onPlay = NULL,
  onPause = NULL,
  onBackward = NULL,
  onForward = NULL,
  ...
) {
  # Validate inputs
  if (!is.null(x) && !is.numeric(x)) {
    stop("'x' must be a number")
  }

  if (!is.null(y) && !is.numeric(y)) {
    stop("'y' must be a number")
  }

  if (!is.numeric(width) || width <= 0) {
    stop("'width' must be a positive number")
  }

  if (!is.numeric(height) || height <= 0) {
    stop("'height' must be a positive number")
  }

  position <- match.arg(position)

  if (
    !is.numeric(padding) &&
      !is.null(padding) &&
      !is.vector(padding, mode = "numeric")
  ) {
    stop("'padding' must be a number or a numeric vector")
  }

  # Check if data is a numeric vector or a list of objects with time and value properties
  if (!is.numeric(data) && !is.list(data)) {
    stop(
      "'data' must be either a numeric vector or a list of objects with time and value properties"
    )
  }

  timebarType <- match.arg(timebarType)
  elementTypes <- match.arg(elementTypes)
  mode <- match.arg(mode)

  if (
    !is.null(values) &&
      !is.numeric(values) &&
      !inherits(values, "Date") &&
      !(is.vector(values) &&
        length(values) == 2 &&
        (all(sapply(values, is.numeric)) ||
          all(sapply(values, function(x) inherits(x, "Date")))))
  ) {
    stop("'values' must be a number, a Date, or a vector of two numbers/Dates")
  }

  if (!is.logical(loop)) {
    stop("'loop' must be a boolean value")
  }

  callback_params <- c(
    "getTime",
    "labelFormatter",
    "onChange",
    "onReset",
    "onSpeedChange",
    "onPlay",
    "onPause",
    "onBackward",
    "onForward"
  )

  for (param in callback_params) {
    param_value <- get(param)
    if (!is.null(param_value) && !is_js(param_value)) {
      stop(paste0(
        "'",
        param,
        "' must be a JavaScript function wrapped with JS()"
      ))
    }
  }

  # Get all function argument names
  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "timebar"

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Configure Toolbar Plugin
#'
#' Creates a configuration object for the toolbar plugin in G6.
#' This plugin adds a customizable toolbar with items for graph operations.
#'
#' @param getItems Function that returns the list of toolbar items (JS function, required).
#' @param key Unique identifier for the plugin (string, default: NULL).
#' @param className Additional CSS class name for the toolbar DOM element (string, default: NULL).
#' @param position Toolbar position relative to the canvas (string, default: "top-left").
#' @param style Custom style for the toolbar DOM element (list or JS object, default: NULL).
#' @param onClick Callback function after a toolbar item is clicked (JS function, default: NULL).
#' @param ... Extra parameters.
#' See \url{https://g6.antv.antgroup.com/en/manual/plugin/toolbar}.
#'
#' @return A list with the configuration settings for the toolbar plugin.
#' @export
#'
#' @examples
#' # Basic toolbar with zoom controls
#' config <- toolbar(
#'   position = "top-right",
#'   getItems = JS("() => [
#'     { id: 'zoom-in', value: 'zoom-in' },
#'     { id: 'zoom-out', value: 'zoom-out' },
#'     { id: 'undo', value: 'undo' },
#'     { id: 'redo', value: 'redo' },
#'     { id: 'auto-fit', value: 'fit' }
#'   ]"),
#'   onClick = JS("(value) => {
#'     // redo, undo need to be used with the history plugin
#'     const history = graph.getPluginInstance('history');
#'     switch (value) {
#'       case 'zoom-in':
#'         graph.zoomTo(1.1);
#'         break;
#'       case 'zoom-out':
#'         graph.zoomTo(0.9);
#'         break;
#'       case 'undo':
#'         history?.undo();
#'         break;
#'       case 'redo':
#'         history?.redo();
#'         break;
#'       case 'fit':
#'         graph.fitView();
#'         break;
#'       default:
#'         break;
#'     }
#'   }")
#' )
toolbar <- function(
  getItems = NULL,
  key = "toolbar",
  className = NULL,
  position = c(
    "top-left",
    "top",
    "top-right",
    "right",
    "bottom-right",
    "bottom",
    "bottom-left",
    "left"
  ),
  style = NULL,
  onClick = NULL,
  ...
) {
  # Check if required parameter is provided
  if (!is.null(className) && !is.character(className)) {
    stop("'className' must be a string")
  }

  position <- match.arg(position)

  if (!is.null(style) && !is.list(style)) {
    stop("'style' must be a list")
  }

  if (!is.null(getItems) && !is_js(getItems)) {
    stop(
      "'getItems' must be a JavaScript function wrapped with JS()"
    )
  }

  if (!is.null(onClick) && !is_js(onClick)) {
    stop(
      "'onClick' must be a JavaScript function wrapped with JS()"
    )
  }

  # Get all function argument names
  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "toolbar"

  # Default
  if (is.null(config$getItems)) {
    config$getItems <- JS(
      "( ) => [
        { id : 'zoom-in' , value : 'zoom-in' },
        { id : 'zoom-out' , value : 'zoom-out' },
        { id : 'auto-fit' , value : 'auto-fit' },
        { id: 'delete', value: 'delete' },
        { id: 'request-fullscreen', value: 'request-fullscreen' },
        { id: 'exit-fullscreen', value: 'exit-fullscreen' },
      ]"
    )
  }

  if (is.null(config$onClick)) {
    config$onClick <- JS(
      "( value, target, current ) => {   
        // Handle button click events
        const graph = HTMLWidgets
          .find(`#${target.closest('.g6').id}`)
          .getWidget();
        const fullScreen = graph.getPluginInstance('fullscreen');
        const zoomLevel = graph.getZoom();
        if ( value === 'zoom-in' ) {   
          graph.zoomTo (graph.getZoom() + 0.25);
        } else if ( value === 'zoom-out' ) {     
          graph.zoomTo (graph.getZoom() - 0.25);
        } else if ( value === 'auto-fit' ) {     
          graph.fitView ( ) ;
        } else if (value === 'delete') {
          const selectedNodes = graph
            .getElementDataByState('node', 'selected')
            .map((node) => {
              return node.id
            }
          );
          graph.removeNodeData(selectedNodes);
          graph.draw();
        } else if (value === 'request-fullscreen') {
          if (fullScreen !== undefined) {
            fullScreen.request();
          }
        } else if (value === 'exit-fullscreen') {
          if (fullScreen !== undefined) {
            fullScreen.exit();
          }
        }
      }
    "
    )
  }

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Configure Tooltip Plugin
#'
#' Creates a configuration object for the tooltip plugin in G6.
#' This plugin displays tooltips when interacting with graph elements.
#'
#' @param key Unique identifier for the plugin (string, default: NULL).
#' @param position Tooltip position relative to the element (string, default: "top-right").
#' @param enable Whether the plugin is enabled (boolean or function, default: TRUE).
#' @param getContent Function to generate custom tooltip content (JS function, default: NULL).
#' @param onOpenChange Callback for tooltip show/hide events (JS function, default: NULL).
#' @param trigger Trigger behavior: "hover" or "click" (string, default: "hover").
#' @param container Custom rendering container for tooltip (string or HTML element, default: NULL).
#' @param offset Offset distance as a vector of two numbers \code{[x, y]} (numeric vector, default: c(10, 10)).
#' @param enterable Whether the pointer can enter the tooltip (boolean, default: FALSE).
#' @param title Title for the tooltip (string, default: NULL).
#' @param style Custom style for the tooltip (list or JS object, default: list(".tooltip" = list(visibility = "hidden"))).
#' @param ... Extra parameters.
#' See \url{https://g6.antv.antgroup.com/en/manual/plugin/tooltip}.
#'
#' @return A list with the configuration settings for the tooltip plugin.
#' @export
#'
#' @examples
#' # Basic tooltip
#' config <- tooltips()
#'
#' # Tooltip with custom position and content
#' config <- tooltips(
#'   position = "bottom",
#'   getContent = JS("(event, items) => {
#'     let result = `<h4>Custom Content</h4>`;
#'     items.forEach((item) => {
#'       result += `<p>Type: ${item.data.description}</p>`;
#'     });
#'     return result;
#'   }")
#' )
#'
#' # Click-triggered tooltip with custom style
#' config <- tooltips(
#'   trigger = "click",
#'   position = "bottom-left",
#'   offset = c(15, 20),
#'   style = list(
#'     ".tooltip" = list(
#'       backgroundColor = "#fff",
#'       border = "1px solid #ccc",
#'       borderRadius = "4px",
#'       boxShadow = "0 2px 6px rgba(0,0,0,0.1)",
#'       padding = "10px",
#'       maxWidth = "300px"
#'     )
#'   )
#' )
#'
#' # Conditional tooltip based on node type
#' config <- tooltips(
#'   enable = JS("(event, items) => {
#'     // Only show tooltip for nodes with type 'important'
#'     const item = items[0];
#'     return item.type === 'important';
#'   }"),
#'   enterable = TRUE,
#'   onOpenChange = JS("(open) => {
#'     console.log('Tooltip visibility changed:', open);
#'   }")
#' )
tooltips <- function(
  key = "tooltip",
  position = c(
    "top-right",
    "top",
    "bottom",
    "left",
    "right",
    "top-left",
    "bottom-left",
    "bottom-right"
  ),
  enable = TRUE,
  getContent = NULL,
  onOpenChange = NULL,
  trigger = c("hover", "click"),
  container = NULL,
  offset = c(10, 10),
  enterable = FALSE,
  title = NULL,
  style = NULL,
  ...
) {
  position <- match.arg(position)

  if (!is.logical(enable) && !is_js(enable)) {
    stop("'enable' must be a boolean or a JavaScript function")
  }

  if (!is.null(getContent) && !is_js(getContent)) {
    stop("'getContent' must be a JavaScript function")
  }

  if (!is.null(onOpenChange) && !is_js(onOpenChange)) {
    stop("'onOpenChange' must be a JavaScript function")
  }

  trigger <- match.arg(trigger)

  if (!is.null(container) && !is.character(container)) {
    stop("'container' must be a string selector or an HTML element")
  }

  if (!is.numeric(offset) || length(offset) != 2) {
    stop("'offset' must be a numeric vector of length 2 [x, y]")
  }

  if (!is.logical(enterable)) {
    stop("'enterable' must be a boolean value")
  }

  if (!is.null(title) && !is.character(title)) {
    stop("'title' must be a string")
  }

  if (!is.null(style) && !is.list(style)) {
    stop("'style' must be a list")
  }

  # Get all function argument names
  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "tooltip"

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' Configure Watermark Plugin
#'
#' Creates a configuration object for the watermark plugin in G6.
#' This plugin adds a watermark to the graph canvas.
#'
#' @param key Unique identifier for the plugin (string, default: NULL).
#' @param width Width of a single watermark (number, default: 200).
#' @param height Height of a single watermark (number, default: 100).
#' @param opacity Opacity of the watermark (number, default: 0.2).
#' @param rotate Rotation angle of the watermark in radians (number, default: pi/12).
#' @param imageURL Image watermark URL, higher priority than text watermark (string, default: NULL).
#' @param text Watermark text content (string, default: NULL).
#' @param textFill Color of the text watermark (string, default: "#000").
#' @param textFontSize Font size of the text watermark (number, default: 16).
#' @param textFontFamily Font of the text watermark (string, default: NULL).
#' @param textFontWeight Font weight of the text watermark (string, default: NULL).
#' @param textFontVariant Font variant of the text watermark (string, default: NULL).
#' @param textAlign Text alignment of the watermark (string, default: "center").
#' @param textBaseline Baseline alignment of the text watermark (string, default: "middle").
#' @param backgroundRepeat Repeat mode of the watermark (string, default: "repeat").
#' @param backgroundAttachment Background attachment behavior of the watermark (string, default: NULL).
#' @param backgroundBlendMode Background blend mode of the watermark (string, default: NULL).
#' @param backgroundClip Background clip of the watermark (string, default: NULL).
#' @param backgroundColor Background color of the watermark (string, default: NULL).
#' @param backgroundImage Background image of the watermark (string, default: NULL).
#' @param backgroundOrigin Background origin of the watermark (string, default: NULL).
#' @param backgroundPosition Background position of the watermark (string, default: NULL).
#' @param backgroundPositionX Horizontal position of the watermark background (string, default: NULL).
#' @param backgroundPositionY Vertical position of the watermark background (string, default: NULL).
#' @param backgroundSize Background size of the watermark (string, default: NULL).
#' @param ... Extra parameters.
#' See \url{https://g6.antv.antgroup.com/en/manual/plugin/watermark}.
#'
#' @return A list with the configuration settings for the watermark plugin.
#' @export
#'
#' @examples
#' # Basic text watermark
#' config <- watermark(
#'   text = "G6 Graph",
#'   opacity = 0.1
#' )
#'
#' # Image watermark
#' config <- watermark(
#'   imageURL = "https://gw.alipayobjects.com/os/s/prod/antv/assets/image/logo-with-text-73b8a.svg",
#'   width = 150,
#'   height = 75,
#'   opacity = 0.15,
#'   rotate = 0
#' )
#'
#' # Customized text watermark
#' config <- watermark(
#'   text = "CONFIDENTIAL",
#'   textFill = "#ff0000",
#'   textFontSize = 24,
#'   textFontWeight = "bold",
#'   opacity = 0.08,
#'   rotate = pi/6,
#'   backgroundRepeat = "repeat-x"
#' )
#'
#' # Watermark with background styling
#' config <- watermark(
#'   text = "Draft Document",
#'   textFill = "#333",
#'   backgroundColor = "#f9f9f9",
#'   backgroundClip = "content-box",
#'   backgroundSize = "cover"
#' )
watermark <- function(
  key = "watermark",
  width = 200,
  height = 100,
  opacity = 0.2,
  rotate = pi / 12,
  imageURL = NULL,
  text = NULL,
  textFill = "#000",
  textFontSize = 16,
  textFontFamily = NULL,
  textFontWeight = NULL,
  textFontVariant = NULL,
  textAlign = c("center", "end", "left", "right", "start"),
  textBaseline = c(
    "alphabetic",
    "bottom",
    "hanging",
    "ideographic",
    "middle",
    "top"
  ),
  backgroundRepeat = "repeat",
  backgroundAttachment = NULL,
  backgroundBlendMode = NULL,
  backgroundClip = NULL,
  backgroundColor = NULL,
  backgroundImage = NULL,
  backgroundOrigin = NULL,
  backgroundPosition = NULL,
  backgroundPositionX = NULL,
  backgroundPositionY = NULL,
  backgroundSize = NULL,
  ...
) {
  # Validate inputs
  if (!is.numeric(width) || width <= 0) {
    stop("'width' must be a positive number")
  }

  if (!is.numeric(height) || height <= 0) {
    stop("'height' must be a positive number")
  }

  if (!is.numeric(opacity) || opacity < 0 || opacity > 1) {
    stop("'opacity' must be a number between 0 and 1")
  }

  if (!is.numeric(rotate)) {
    stop("'rotate' must be a number (angle in radians)")
  }

  if (!is.null(imageURL) && !is.character(imageURL)) {
    stop("'imageURL' must be a string")
  }

  if (!is.null(text) && !is.character(text)) {
    stop("'text' must be a string")
  }

  if (is.null(imageURL) && is.null(text)) {
    warning(
      "Neither 'imageURL' nor 'text' is provided; watermark may not be visible"
    )
  }

  if (!is.character(textFill)) {
    stop("'textFill' must be a string (color value)")
  }

  if (!is.numeric(textFontSize) || textFontSize <= 0) {
    stop("'textFontSize' must be a positive number")
  }

  if (!is.null(textFontFamily) && !is.character(textFontFamily)) {
    stop("'textFontFamily' must be a string")
  }

  if (!is.null(textFontWeight) && !is.character(textFontWeight)) {
    stop("'textFontWeight' must be a string")
  }

  if (!is.null(textFontVariant) && !is.character(textFontVariant)) {
    stop("'textFontVariant' must be a string")
  }

  textAlign <- match.arg(textAlign)
  textBaseline <- match.arg(textBaseline)

  if (!is.character(backgroundRepeat)) {
    stop("'backgroundRepeat' must be a string")
  }

  # Check background properties are strings if provided
  bg_props <- c(
    "backgroundAttachment",
    "backgroundBlendMode",
    "backgroundClip",
    "backgroundColor",
    "backgroundImage",
    "backgroundOrigin",
    "backgroundPosition",
    "backgroundPositionX",
    "backgroundPositionY",
    "backgroundSize"
  )

  for (prop in bg_props) {
    value <- get(prop)
    if (!is.null(value) && !is.character(value)) {
      stop(paste0("'", prop, "' must be a string"))
    }
  }

  # Get all function argument names
  arg_names <- names(formals())
  arg_names <- arg_names[arg_names != "..."]
  # Get values of only the named parameters
  config <- mget(arg_names)
  config$type <- "watermark"

  # Drop NULL elements
  dropNulls(c(config, list(...)))
}

#' @keywords internal
valid_plugins <- c(
  "background" = background,
  "bubble-sets" = bubble_sets,
  "contextmenu" = context_menu,
  "edge-bundling" = edge_bundling,
  "edge-filter-lens" = edge_filter_lens,
  "fisheye" = fish_eye,
  "fullscreen" = fullscreen,
  "grid-line" = grid_line,
  "history" = history,
  "hull" = hull,
  "legend" = legend,
  "minimap" = minimap,
  "snapline" = snapline,
  "timebar" = timebar,
  "toolbar" = toolbar,
  "tooltip" = tooltips,
  "watermark" = watermark
)
