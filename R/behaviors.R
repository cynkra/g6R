#' Create G6 Graph Behaviors Configuration
#'
#' Configures interaction behaviors for a G6 graph visualization.
#' This function collects and combines multiple behavior configurations
#' into a list that can be passed to graph initialization functions.
#'
#' @param ... Behavior configuration objects created by behavior-specific functions.
#'   These can include any of the following behaviors:
#'
#'   \strong{Navigation behaviors:}
#'   \itemize{
#'     \item \code{drag_canvas()} - Drag the entire canvas view
#'     \item \code{zoom_canvas()} - Zoom the canvas view
#'     \item \code{scroll_canvas()} - Scroll the canvas using the wheel
#'     \item \code{optimize_viewport_transform()} - Optimize view transform performance
#'   }
#'
#'   \strong{Selection behaviors:}
#'   \itemize{
#'     \item \code{click_select()} - Click to select graph elements
#'     \item \code{brush_select()} - Select elements by dragging a rectangular area
#'     \item \code{lasso_select()} - Freely draw an area to select elements
#'   }
#'
#'   \strong{Editing behaviors:}
#'   \itemize{
#'     \item \code{create_edge()} - Interactively create new edges
#'     \item \code{drag_element()} - Drag nodes or combos
#'     \item \code{drag_element_force()} - Drag nodes in force-directed layout
#'   }
#'
#'   \strong{Data Exploration behaviors:}
#'   \itemize{
#'     \item \code{collapse_expand()} - Expand or collapse subtree nodes
#'     \item \code{focus_element()} - Focus on specific elements and automatically adjust the view
#'     \item \code{hover_activate()} - Highlight elements when hovering
#'   }
#'
#'   \strong{Visual Optimization behaviors:}
#'   \itemize{
#'     \item \code{fix_element_size()} - Fix the element size to a specified value
#'     \item \code{auto_adapt_label()} - Automatically adjust label position
#'   }
#'
#' @return A list of behavior configuration objects that can be passed to G6 graph initialization
#'
#' @note You can create custom behaviors from JavaScript and use them on the R side. See more
#' at \url{https://g6.antv.antgroup.com/en/manual/behavior/custom-behavior}.
#' @examples
#' # Create a basic set of behaviors
#' behaviors <- g6_behaviors(
#'   drag_canvas(),
#'   zoom_canvas(),
#'   click_select()
#' )
#'
#' # Create a more customized set of behaviors
#' behaviors <- g6_behaviors(
#'   drag_canvas(enableOptimize = TRUE),
#'   zoom_canvas(sensitivity = 1.5),
#'   hover_activate(state = "highlight"),
#'   fix_element_size(
#'     node = list(
#'       list(shape = "circle", fields = c("r", "lineWidth"))
#'     )
#'   )
#' )
#'
#' @export
g6_behaviors <- function(...) {
  # Maybe todo: provide more infra to define behaviors and validate them
  # structure(class = "behavior"), validate_behavior ...
  list(
    #auto_adapt_label(),
    #brush_select(),
    #click_select(),
    #collapse_expand(),
    #create_edge(),
    #drag_canvas(),
    #drag_element(),
    #drag_element_force(),
    #fix_element_size(),
    #focus_element(),
    #hover_activate(),
    #lasso_select(),
    #optimize_viewport_transform(),
    #scroll_canvas(),
    #zoom_canvas(),
    ...
  )
}

#' @keywords internal
valid_states <- c("selected", "active", "inactive", "disabled", "highlight")

#' Configure Auto Adapt Label Behavior
#'
#' Creates a configuration object for the auto-adapt-label behavior in G6.
#' This behavior automatically adjusts label positions to reduce overlapping and
#' improve readability in the graph visualization.
#'
#' @param key Unique identifier for the behavior (string, default: "auto-adapt-label")
#' @param enable Whether to enable this behavior (JS function, default: returns TRUE for all events)
#' @param throttle Throttle time in milliseconds to optimize performance (numeric, default: 100)
#' @param padding Padding space around labels in pixels (numeric, default: 0)
#' @param sort Global sorting rule for all element types (list or JS function, default: NULL)
#' @param sortNode Sorting rule specifically for node labels (list, default: list(type = "degree"))
#' @param sortEdge Sorting rule specifically for edge labels (list, default: NULL)
#' @param sortCombo Sorting rule specifically for combo labels (list, default: NULL)
#'
#' @details
#' The auto-adapt-label behavior helps prevent label overlap by automatically adjusting
#' label positions based on specified rules. It can selectively hide labels when there's
#' not enough space to display all of them.
#'
#' Sorting parameters determine which labels take priority when space is limited:
#' \itemize{
#'   \item When \code{sort} is provided, it applies to all element types and overrides type-specific settings
#'   \item Type-specific sorting (\code{sortNode}, \code{sortEdge}, \code{sortCombo}) only applies when \code{sort} is NULL
#'   \item The default sorting for nodes is by degree (higher degree nodes' labels are shown first)
#' }
#'
#' @return A list with the configuration settings for the auto-adapt-label behavior
#' @export
#'
#' @examples
#' # Basic configuration with defaults
#' config <- auto_adapt_label()
#'
#' # Custom configuration with more padding and custom throttle
#' config <- auto_adapt_label(
#'   key = "my-label-adapter",
#'   throttle = 200,
#'   padding = 5
#' )
#'
#' # Custom configuration with specific sorting rules
#' config <- auto_adapt_label(
#'   sortNode = list(type = "property", field = "importance", order = "desc"),
#'   sortEdge = list(type = "property", field = "weight", order = "desc"),
#'   sortCombo = list(type = "degree")
#' )
#'
#' # Using a custom enable function
#' config <- auto_adapt_label(
#'   enable = htmlwidgets::JS("(e) => e.targetType === 'node'")
#' )
auto_adapt_label <- function(
  key = "auto-adapt-label",
  enable = JS(
    "(e) => {
      return true
    }"
  ),
  throttle = 100,
  padding = 0,
  sort = NULL,
  sortNode = list(type = "degree"),
  sortEdge = NULL,
  sortCombo = NULL
) {
  # Create the configuration list
  config <- list(
    type = "auto-adapt-label",
    key = key,
    enable = enable,
    throttle = throttle,
    padding = padding
  )

  # Add optional parameters if provided
  if (!is.null(sort)) {
    config$sort <- sort
  }

  if (!is.null(sortNode) && is.null(sort)) {
    config$sortNode <- sortNode
  }

  if (!is.null(sortEdge) && is.null(sort)) {
    config$sortEdge <- sortEdge
  }

  if (!is.null(sortCombo) && is.null(sort)) {
    config$sortCombo <- sortCombo
  }

  config
}

#' Configure Brush Selection Interaction
#'
#' Creates a configuration object for brush selection interaction in graph visualizations.
#' This function configures how elements are selected when using a brush selection tool.
#'
#' @param key Behavior unique identifier. Useful to modify this behavior from JS side.
#' @param animation Whether to enable animation (boolean, default: FALSE)
#' @param enable Whether to enable brush select functionality (boolean or function, default: TRUE)
#' @param enableElements Types of elements that can be selected (character vector, default: c("node", "combo", "edge"))
#' @param immediately Whether to select immediately in default mode (boolean, default: FALSE)
#' @param mode Selection mode: "union", "intersect", "diff", or "default" (string, default: "default")
#' @param onSelect Callback for selected element state (function)
#' @param state State to switch to when selected (string, default: "selected")
#' @param style Style specification for the selection box (list).
#' See \url{https://g6.antv.antgroup.com/en/manual/behavior/build-in/brush-select#style}.
#' @param trigger Shortcut keys for selection (character vector)
#'
#' @return A list with the configuration settings
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- brush_select()
#'
#' # Custom configuration
#' config <- brush_select(
#'   animation = TRUE,
#'   enableElements = c("node", "edge"),
#'   mode = "union",
#'   state = "highlight",
#'   style = list(
#'     fill = "rgba(0, 0, 255, 0.1)",
#'     stroke = "blue",
#'     lineWidth = 2
#'   ),
#'   trigger = c("Shift")
#' )
brush_select <- function(
  key = "brush-select",
  animation = FALSE,
  enable = JS(
    "(e) => {
      return true
    }"
  ),
  enableElements = c("node", "edge", "combo"),
  immediately = FALSE,
  mode = "default",
  onSelect = NULL,
  state = "selected",
  style = list(),
  trigger = "shift"
) {
  # Validate inputs
  if (!is.logical(animation)) {
    stop("'animation' should be a boolean value")
  }

  if (!is.logical(enable) && !is_js(enable)) {
    stop("'enable' should be a boolean or JS function")
  }

  valid_elements <- c("node", "combo", "edge")
  if (!all(enableElements %in% valid_elements)) {
    stop("'enableElements' should contain only 'node', 'combo', or 'edge'")
  }

  if (!is.logical(immediately)) {
    stop("'immediately' should be a boolean value")
  }

  valid_modes <- c("union", "intersect", "diff", "default")
  if (!mode %in% valid_modes) {
    stop(
      "'mode' should be one of 'union', 'intersect', 'diff', or 'default'"
    )
  }

  if (!is.null(onSelect) && !is_js(onSelect)) {
    stop("'onSelect' should be a JS function")
  }

  if (
    !is.character(state) || (length(state) == 1 && !state %in% valid_states)
  ) {
    stop(
      "'state' should be one of 'selected', 'active', 'inactive', 'disabled', 'highlight', or a custom string"
    )
  }

  # Create the configuration list
  config <- list(
    type = "brush-select",
    key = key,
    animation = animation,
    enable = enable,
    enableElements = enableElements,
    immediately = immediately,
    mode = mode,
    state = state
  )

  # Add optional parameters if provided
  if (!is.null(onSelect)) {
    config$onSelect <- onSelect
  }

  if (!is.null(style)) {
    config$style <- style
  }

  if (!is.null(trigger)) {
    # Check if trigger contains 'drag' which conflicts with drag-canvas
    if (trigger == "drag") {
      warning(
        "Setting trigger to include 'drag' will cause the drag-canvas behavior to fail. 
        The two cannot be configured simultaneously."
      )
    }
    config$trigger <- trigger
  }

  config
}

#' Configure Click Select Behavior
#'
#' Creates a configuration object for the click-select behavior in G6.
#' This allows users to select graph elements by clicking.
#'
#' @param key Behavior unique identifier. Useful to modify this behavior from JS side.
#' @param animation Whether to enable animation effects when switching element states (boolean, default: TRUE)
#' @param degree Controls the highlight spread range (number or function, default: 0)
#' @param enable Whether to enable the click element function (boolean or function, default: TRUE)
#' @param multiple Whether to allow multiple selections (boolean, default: FALSE)
#' @param state The state applied when an element is selected (string, default: "selected")
#' @param neighborState The state applied to elements with n-degree relationships (string, default: "selected")
#' @param unselectedState The state applied to all other elements (string, default: NULL)
#' @param onClick Callback when an element is clicked (function, default: NULL)
#' @param trigger Keys for multi-selection (character vector, default: c("shift"))
#'
#' @return A list with the configuration settings
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- click_select()
#'
#' # Custom configuration
#' config <- click_select(
#'   animation = FALSE,
#'   degree = 1,
#'   multiple = TRUE,
#'   state = "active",
#'   neighborState = "highlight",
#'   unselectedState = "inactive",
#'   trigger = c("Control")
#' )
click_select <- function(
  key = "click-select",
  animation = TRUE,
  degree = 0,
  enable = TRUE,
  multiple = FALSE,
  state = "selected",
  neighborState = "selected",
  unselectedState = NULL,
  onClick = NULL,
  trigger = c("shift")
) {
  # Validate inputs
  valid_states <- c("selected", "active", "inactive", "disabled", "highlight")

  if (!is.logical(animation)) {
    stop("'animation' should be a boolean value")
  }

  if (!is.numeric(degree) && !is_js(degree)) {
    stop("'degree' should be a number or a JS function")
  }

  if (!is.logical(enable) && !is_js(enable)) {
    stop("'enable' should be a boolean or a JS function")
  }

  if (!is.logical(multiple)) {
    stop("'multiple' should be a boolean value")
  }

  if (
    !is.character(state) || (length(state) == 1 && !state %in% valid_states)
  ) {
    stop(
      "'state' should be one of 'selected', 'active', 'inactive', 'disabled', 'highlight', or a custom string"
    )
  }

  if (
    !is.null(neighborState) &&
      (!is.character(neighborState) ||
        (length(neighborState) == 1 && !neighborState %in% valid_states))
  ) {
    stop(
      "'neighborState' should be one of 'selected', 'active', 'inactive', 'disabled', 'highlight', or a custom string"
    )
  }

  if (
    !is.null(unselectedState) &&
      (!is.character(unselectedState) ||
        (length(unselectedState) == 1 && !unselectedState %in% valid_states))
  ) {
    stop(
      "'unselectedState' should be one of 'selected', 'active', 'inactive', 'disabled', 'highlight', or a custom string"
    )
  }

  if (!is.null(onClick) && !is_js(onClick)) {
    stop("'onClick' should be a JS function")
  }

  # Create the configuration list with internal type parameter
  config <- list(
    type = "click-select", # Now set internally
    key = key,
    animation = animation,
    degree = degree,
    enable = enable,
    multiple = multiple,
    state = state,
    neighborState = neighborState,
    trigger = trigger
  )

  # Add optional parameters if provided
  if (!is.null(unselectedState)) {
    config$unselectedState <- unselectedState
  }

  if (!is.null(onClick)) {
    config$onClick <- onClick
  }

  config
}

#' Configure Collapse Expand Behavior
#'
#' Creates a configuration object for the collapse-expand behavior in G6.
#' This allows users to collapse or expand nodes/combos with child elements.
#'
#' @param key Behavior unique identifier. Useful to modify this behavior from JS side.
#' @param animation Enable expand/collapse animation effects (boolean, default: TRUE)
#' @param enable Enable expand/collapse functionality (boolean or function, default: TRUE)
#' @param trigger Trigger method: "click" or "dblclick" (string, default: "dblclick")
#' @param onCollapse Callback function when collapse is completed (function, default: NULL)
#' @param onExpand Callback function when expand is completed (function, default: NULL)
#' @param align Align with the target element to avoid view offset (boolean, default: TRUE)
#'
#' @return A list with the configuration settings
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- collapse_expand()
collapse_expand <- function(
  key = "collapse-expand",
  animation = TRUE,
  enable = TRUE,
  trigger = "dblclick",
  onCollapse = NULL,
  onExpand = NULL,
  align = TRUE
) {
  # Validate inputs
  if (!is.logical(animation)) {
    stop("'animation' should be a boolean value")
  }

  if (!is.logical(enable) && !is_js(enable)) {
    stop("'enable' should be a boolean or a JS function")
  }

  if (!trigger %in% c("click", "dblclick")) {
    stop("'trigger' should be one of 'click' or 'dblclick'")
  }

  if (!is.null(onCollapse) && !is_js(onCollapse)) {
    stop("'onCollapse' should be a JS function")
  }

  if (!is.null(onExpand) && !is_js(onExpand)) {
    stop("'onExpand' should be a JS function")
  }

  if (!is.logical(align)) {
    stop("'align' should be a boolean value")
  }

  # Create the configuration list with internal type parameter
  config <- list(
    type = "collapse-expand", # Set internally
    key = key,
    animation = animation,
    enable = enable,
    trigger = trigger,
    align = align
  )

  # Add optional callback functions if provided
  if (!is.null(onCollapse)) {
    config$onCollapse <- onCollapse
  }

  if (!is.null(onExpand)) {
    config$onExpand <- onExpand
  }

  config
}

#' Configure Create Edge Behavior
#'
#' Creates a configuration object for the create-edge behavior in G6.
#' This allows users to create edges between nodes by clicking or dragging.
#'
#' @param key Behavior unique identifier. Useful to modify this behavior from JS side.
#' @param trigger The way to trigger edge creation: "click" or "drag" (string, default: "drag")
#' @param enable Whether to enable this behavior (boolean or function, default: TRUE)
#' @param onCreate Callback function for creating an edge, returns edge data (function, default: NULL)
#' @param onFinish Callback function for successfully creating an edge (function, default: NULL)
#' @param style Style of the newly created edge (list, default: NULL)
#'
#' @return A list with the configuration settings
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- create_edge()
create_edge <- function(
  key = "create-edge",
  trigger = "drag",
  enable = TRUE,
  onCreate = NULL,
  onFinish = NULL,
  style = NULL
) {
  # Validate inputs
  if (!trigger %in% c("click", "drag")) {
    stop("'trigger' should be one of 'click' or 'drag'")
  }

  if (!is.logical(enable) && !is_js(enable)) {
    stop("'enable' should be a boolean or a JS function")
  }

  if (!is.null(onCreate) && !is_js(onCreate)) {
    stop("'onCreate' should be a JS function")
  }

  if (!is.null(onFinish) && !is_js(onFinish)) {
    stop("'onFinish' should be a JS function")
  }

  if (!is.null(style) && !is.list(style)) {
    stop("'style' should be a list")
  }

  # Create the configuration list with internal type parameter
  config <- list(
    type = "create-edge", # Set internally
    key = key,
    trigger = trigger,
    enable = enable
  )

  # Add optional parameters if provided
  if (!is.null(onCreate)) {
    config$onCreate <- onCreate
  }

  if (!is.null(onFinish)) {
    config$onFinish <- onFinish
  }

  if (!is.null(style)) {
    config$style <- style
  }

  config
}

#' Configure Drag Canvas Behavior
#'
#' Creates a configuration object for the drag-canvas behavior in G6.
#' This allows users to drag the canvas to pan the view.
#'
#' @param key Behavior unique identifier. Useful to modify this behavior from JS side.
#' @param enable Whether to enable this behavior (boolean or function, default: function that enables dragging only on canvas)
#' @param animation Drag animation configuration for keyboard movement (list, default: NULL)
#' @param direction Allowed drag direction: "x", "y", or "both" (string, default: "both")
#' @param range Draggable viewport range in viewport size units (number or numeric vector, default: Inf)
#' @param sensitivity Distance to trigger a single keyboard movement (number, default: 10)
#' @param trigger Keyboard keys to trigger dragging (list, default: NULL)
#' @param onFinish Callback function when dragging is completed (function, default: NULL)
#'
#' @return A list with the configuration settings
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- drag_canvas()
#'
#' # Custom configuration
#' config <- drag_canvas(
#'   enable = TRUE,
#'   direction = "x",
#'   range = c(-100, 100),
#'   sensitivity = 5,
#'   trigger = list(
#'    up = "ArrowUp",
#'    down = "ArrowDown",
#'    left = "ArrowLeft",
#'    right = "ArrowRight"
#'   )
#' )
drag_canvas <- function(
  key = "drag-canvas",
  enable = TRUE,
  animation = NULL,
  direction = "both",
  range = Inf,
  sensitivity = 10,
  trigger = NULL,
  onFinish = NULL
) {
  # Validate inputs
  if (!is.logical(enable) && !is_js(enable)) {
    stop("'enable' should be a boolean or a function")
  }

  if (!is.null(animation) && !is.list(animation)) {
    stop("'animation' should be a list of animation configuration options")
  }

  if (!direction %in% c("x", "y", "both")) {
    stop("'direction' should be one of 'x', 'y', or 'both'")
  }

  if (!is.numeric(range) && !is.infinite(range)) {
    stop("'range' should be a number, numeric vector, or Inf")
  }

  if (!is.numeric(sensitivity) || sensitivity <= 0) {
    stop("'sensitivity' should be a positive number")
  }

  if (!is.null(trigger) && !is.list(trigger)) {
    stop("'trigger' should be a list of keyboard trigger configuration")
  }

  if (!is.null(onFinish) && !is_js(onFinish)) {
    stop("'onFinish' should be a JS function")
  }

  # Create the configuration list with internal type parameter
  config <- list(
    type = "drag-canvas", # Set internally
    key = key,
    enable = enable,
    direction = direction,
    range = range,
    sensitivity = sensitivity
  )

  # Add optional parameters if provided
  if (!is.null(animation)) {
    config$animation <- animation
  }

  if (!is.null(trigger)) {
    config$trigger <- trigger
  }

  if (!is.null(onFinish)) {
    config$onFinish <- onFinish
  }

  config
}

#' Configure Drag Element Behavior
#'
#' Creates a configuration object for the drag-element behavior in G6.
#' This allows users to drag nodes and combos in the graph.
#'
#' @param key Unique identifier for the behavior, used for subsequent operations (string, default: NULL)
#' @param enable Whether to enable the drag function (boolean or function, default: function that enables dragging for nodes and combos)
#' @param animation Whether to enable drag animation (boolean, default: TRUE)
#' @param state Identifier for the selected state of nodes (string, default: "selected")
#' @param dropEffect Defines the operation effect after dragging ends: "link", "move", or "none" (string, default: "move")
#' @param hideEdge Controls the display state of edges during dragging: "none", "out", "in", "both", or "all" (string, default: "none")
#' @param shadow Whether to enable ghost nodes (boolean, default: FALSE)
#' @param cursor Customize the mouse style during dragging (list, default: NULL)
#'
#' @return A list with the configuration settings
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- drag_element()
#'
#' # Custom configuration
#' config <- drag_element(
#'   key = "my-drag-behavior",
#'   animation = FALSE,
#'   dropEffect = "link",
#'   hideEdge = "both",
#'   shadow = TRUE,
#'   cursor = list(
#'     default = "default",
#'     grab = "grab",
#'     grabbing = "grabbing"
#'   ),
#'   enable = JS(
#'    "(e) => {
#'      return e.targetType === 'node' || e.targetType === 'combo';
#'    }"
#'   )
#' )
drag_element <- function(
  key = "drag-element",
  enable = TRUE,
  animation = TRUE,
  state = "selected",
  dropEffect = "move",
  hideEdge = "none",
  shadow = FALSE,
  cursor = NULL
) {
  # Validate inputs
  if (!is.logical(enable) && !is_js(enable)) {
    stop("'enable' should be a boolean or a JS function")
  }

  if (!is.logical(animation)) {
    stop("'animation' should be a boolean value")
  }

  if (!is.character(state)) {
    stop("'state' should be a string")
  }

  valid_drop_effects <- c("link", "move", "none")
  if (!dropEffect %in% valid_drop_effects) {
    stop("'dropEffect' should be one of 'link', 'move', or 'none'")
  }

  valid_hide_edge_options <- c("none", "out", "in", "both", "all")
  if (!hideEdge %in% valid_hide_edge_options) {
    stop("'hideEdge' should be one of 'none', 'out', 'in', 'both', or 'all'")
  }

  if (!is.logical(shadow)) {
    stop("'shadow' should be a boolean value")
  }

  if (!is.null(cursor) && !is.list(cursor)) {
    stop("'cursor' should be a list of cursor style configurations")
  }

  # Create the configuration list with internal type parameter
  config <- list(
    type = "drag-element", # Set internally
    key = key,
    animation = animation,
    state = state,
    dropEffect = dropEffect,
    hideEdge = hideEdge,
    shadow = shadow,
    enable = enable
  )

  if (!is.null(cursor)) {
    config$cursor <- cursor
  }

  config
}

#' Configure Drag Element Force Behavior
#'
#' Creates a configuration object for the drag-element-force behavior in G6.
#' This allows users to drag nodes and combos with force-directed layout interactions.
#'
#' @param key Unique identifier for the behavior, used for subsequent operations (string, default: "drag-element-force")
#' @param fixed Whether to keep the node position fixed after dragging ends (boolean, default: FALSE)
#' @param enable Whether to enable the drag function (boolean or JS function, default: JS function that enables dragging for nodes and combos)
#' @param state Identifier for the selected state of nodes (string, default: "selected")
#' @param hideEdge Controls the display state of edges during dragging: "none", "out", "in", "both", or "all" (string, default: "none")
#' @param cursor Customize the mouse style during dragging (list, default: NULL)
#'
#' @return A list with the configuration settings
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- drag_element_force()
#'
#' # Custom configuration with JavaScript arrow function and custom key
#' config <- drag_element_force(
#'   key = "my-custom-drag-force",
#'   fixed = TRUE,
#'   enable = htmlwidgets::JS("(event) => { return event.targetType === 'node'; }"),
#'   hideEdge = "both",
#'   cursor = list(
#'     default = "default",
#'     grab = "grab",
#'     grabbing = "grabbing"
#'   )
#' )
drag_element_force <- function(
  key = "drag-element-force",
  fixed = FALSE,
  enable = htmlwidgets::JS(
    "(event) => { return event.targetType === 'node' || event.targetType === 'combo'; }"
  ),
  state = "selected",
  hideEdge = "none",
  cursor = NULL
) {
  # Validate inputs
  if (!is.logical(fixed)) {
    stop("'fixed' should be a boolean value")
  }

  if (!is.logical(enable) && !is_js(enable)) {
    stop(
      "'enable' should be a boolean or a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  if (!is.character(state)) {
    stop("'state' should be a string")
  }

  valid_hide_edge_options <- c("none", "out", "in", "both", "all")
  if (!hideEdge %in% valid_hide_edge_options) {
    stop("'hideEdge' should be one of 'none', 'out', 'in', 'both', or 'all'")
  }

  if (!is.null(cursor) && !is.list(cursor)) {
    stop("'cursor' should be a list of cursor style configurations")
  }

  # Create the configuration list with internal type parameter
  config <- list(
    type = "drag-element-force", # Set internally
    key = key, # User-configurable with default
    fixed = fixed,
    state = state,
    hideEdge = hideEdge,
    enable = enable
  )

  # Add optional parameters if provided
  if (!is.null(cursor)) {
    config$cursor <- cursor
  }

  config
}

#' Configure Fix Element Size Behavior
#'
#' Creates a configuration object for the fix-element-size behavior in G6.
#' This allows maintaining fixed visual sizes for elements during zoom operations.
#'
#' @param key Unique identifier for the behavior, used for subsequent operations (string, default: "fix-element-size")
#' @param enable Whether to enable this interaction (boolean or JS function, default: TRUE)
#' @param reset Whether to restore style when elements are redrawn (boolean, default: FALSE)
#' @param state Specify the state of elements to fix size (string, default: "")
#' @param node Node configuration item(s) to define which attributes maintain fixed size (list or array of lists, default: NULL)
#' @param nodeFilter Node filter to determine which nodes maintain fixed size (JS function, default: returns TRUE for all nodes)
#' @param edge Edge configuration item(s) to define which attributes maintain fixed size (list or array of lists, default: predefined list)
#' @param edgeFilter Edge filter to determine which edges maintain fixed size (JS function, default: returns TRUE for all edges)
#' @param combo Combo configuration item(s) to define which attributes maintain fixed size (list or array of lists, default: NULL)
#' @param comboFilter Combo filter to determine which combos maintain fixed size (JS function, default: returns TRUE for all combos)
#'
#' @return A list with the configuration settings
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- fix_element_size()
#'
#' # Custom configuration with filters and specific shape configurations
#' config <- fix_element_size(
#'   key = "my-fix-size-behavior",
#'   reset = TRUE,
#'   state = "active",
#'   node = list(
#'     list(shape = "circle", fields = c("r", "lineWidth")),
#'     list(shape = "label", fields = c("fontSize"))
#'   ),
#'   nodeFilter = htmlwidgets::JS("(node) => node.type === 'important'"),
#'   edge = list(shape = "line", fields = c("lineWidth", "lineDash")),
#'   edgeFilter = htmlwidgets::JS("(edge) => edge.weight > 5")
#' )
fix_element_size <- function(
  key = "fix-element-size",
  enable = TRUE,
  reset = FALSE,
  state = "",
  node = NULL,
  nodeFilter = htmlwidgets::JS("() => true"),
  edge = list(
    list(shape = "key", fields = c("lineWidth")),
    list(shape = "halo", fields = c("lineWidth")),
    list(shape = "label", fields = c("fontSize"))
  ),
  edgeFilter = htmlwidgets::JS("() => true"),
  combo = NULL,
  comboFilter = htmlwidgets::JS("() => true")
) {
  # Validate inputs
  if (!is.logical(enable) && !is_js(enable)) {
    stop(
      "'enable' should be a boolean or a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  if (!is.logical(reset)) {
    stop("'reset' should be a boolean value")
  }

  if (!is.character(state)) {
    stop("'state' should be a string")
  }

  # Validate node configuration
  if (!is.null(node) && !is.list(node)) {
    stop("'node' should be a list or array of configuration objects")
  }

  # Validate node filter
  if (!is_js(nodeFilter)) {
    stop(
      "'nodeFilter' should be a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  # Validate edge configuration
  if (!is.null(edge) && !is.list(edge)) {
    stop("'edge' should be a list or array of configuration objects")
  }

  # Validate edge filter
  if (!is_js(edgeFilter)) {
    stop(
      "'edgeFilter' should be a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  # Validate combo configuration
  if (!is.null(combo) && !is.list(combo)) {
    stop("'combo' should be a list or array of configuration objects")
  }

  # Validate combo filter
  if (!is_js(comboFilter)) {
    stop(
      "'comboFilter' should be a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  # Create the configuration list with internal type parameter
  config <- list(
    type = "fix-element-size", # Set internally
    key = key, # User-configurable with default
    enable = enable,
    reset = reset,
    state = state,
    nodeFilter = nodeFilter,
    edgeFilter = edgeFilter,
    comboFilter = comboFilter
  )

  # Add optional configuration parameters if provided
  if (!is.null(node)) {
    config$node <- node
  }

  if (!is.null(edge)) {
    config$edge <- edge
  }

  if (!is.null(combo)) {
    config$combo <- combo
  }

  config
}

#' Configure Focus Element Behavior
#'
#' Creates a configuration object for the focus-element behavior in G6.
#' This behavior allows focusing on specific elements by automatically adjusting the viewport.
#'
#' @param key Unique identifier for the behavior, used for subsequent operations (string, default: "focus-element")
#' @param animation Focus animation settings (list, default: list with duration 500ms and easing "ease-in")
#' @param enable Whether to enable the focus feature (boolean or JS function, default: TRUE)
#'
#' @return A list with the configuration settings
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- focus_element()
#'
#' # Custom configuration
#' config <- focus_element(
#'   key = "my-focus-behavior",
#'   animation = list(duration = 1000, easing = "ease-out"),
#'   enable = htmlwidgets::JS("(event) => event.targetType === 'node'")
#' )
focus_element <- function(
  key = "focus-element",
  animation = list(duration = 500, easing = "ease-in"),
  enable = TRUE
) {
  # Validate inputs
  if (!is.list(animation)) {
    stop("'animation' should be a list with animation settings")
  }

  # Define valid easing values
  valid_easing_values <- c("ease-in-out", "ease-in", "ease-out", "linear")

  if (is.list(animation)) {
    if (!is.null(animation$duration) && !is.numeric(animation$duration)) {
      stop("'animation$duration' should be a number")
    }

    if (!is.null(animation$easing)) {
      if (!is.character(animation$easing)) {
        stop("'animation$easing' should be a string")
      }

      if (!animation$easing %in% valid_easing_values) {
        stop(
          "'animation$easing' should be one of: ",
          paste(valid_easing_values, collapse = ", ")
        )
      }
    }
  }

  if (!is.logical(enable) && !is_js(enable)) {
    stop(
      "'enable' should be a boolean or a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  # Create the configuration list with internal type parameter
  list(
    type = "focus-element", # Set internally
    key = key, # User-configurable with default
    animation = animation,
    enable = enable
  )
}

#' Configure Hover Activate Behavior
#'
#' Creates a configuration object for the hover-activate behavior in G6.
#' This behavior activates elements when the mouse hovers over them.
#'
#' @param key Unique identifier for the behavior (string, default: "hover-activate")
#' @param animation Whether to enable animation (boolean, default: TRUE)
#' @param enable Whether to enable hover feature (boolean or JS function, default: TRUE)
#' @param degree Degree of relationship to activate elements (number or JS function, default: 0)
#' @param direction Specify edge direction: "both", "in", or "out" (string, default: "both")
#' @param state State of activated elements (string, default: "active")
#' @param inactiveState State of inactive elements (string, default: NULL)
#' @param onHover Callback when element is hovered (JS function, default: NULL)
#' @param onHoverEnd Callback when hover ends (JS function, default: NULL)
#'
#' @return A list with the configuration settings
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- hover_activate()
#'
#' # Custom configuration
#' config <- hover_activate(
#'   key = "my-hover-behavior",
#'   animation = FALSE,
#'   degree = 1,
#'   direction = "out",
#'   state = "highlight",
#'   inactiveState = "inactive",
#'   onHover = htmlwidgets::JS("(event) => { console.log('Hover on:', event.target.id); }")
#' )
hover_activate <- function(
  key = "hover-activate",
  animation = TRUE,
  enable = TRUE,
  degree = 0,
  direction = "both",
  state = "active",
  inactiveState = NULL,
  onHover = NULL,
  onHoverEnd = NULL
) {
  # Validate inputs
  if (!is.logical(animation)) {
    stop("'animation' should be a boolean value")
  }

  if (!is.logical(enable) && !is_js(enable)) {
    stop(
      "'enable' should be a boolean or a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  if (!is.numeric(degree) && !is_js(degree)) {
    stop(
      "'degree' should be a number or a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  valid_directions <- c("both", "in", "out")
  if (!direction %in% valid_directions) {
    stop(
      "'direction' should be one of: ",
      paste(valid_directions, collapse = ", ")
    )
  }

  if (!is.character(state)) {
    stop("'state' should be a string")
  }

  if (!is.null(inactiveState) && !is.character(inactiveState)) {
    stop("'inactiveState' should be a string")
  }

  if (!is.null(onHover) && !is_js(onHover)) {
    stop(
      "'onHover' should be a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  if (!is.null(onHoverEnd) && !is_js(onHoverEnd)) {
    stop(
      "'onHoverEnd' should be a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  # Create the configuration list with internal type parameter
  config <- list(
    type = "hover-activate", # Set internally
    key = key, # User-configurable with default
    animation = animation,
    enable = enable,
    degree = degree,
    direction = direction,
    state = state
  )

  # Add optional parameters if provided
  if (!is.null(inactiveState)) {
    config$inactiveState <- inactiveState
  }

  if (!is.null(onHover)) {
    config$onHover <- onHover
  }

  if (!is.null(onHoverEnd)) {
    config$onHoverEnd <- onHoverEnd
  }

  config
}

#' Configure Lasso Select Behavior
#'
#' Creates a configuration object for the lasso-select behavior in G6.
#' This behavior allows selecting elements by drawing a lasso around them.
#'
#' @param key Unique identifier for the behavior (string, default: "lasso-select")
#' @param animation Whether to enable animation (boolean, default: FALSE)
#' @param enable Whether to enable lasso selection (boolean or JS function, default: TRUE)
#' @param enableElements Types of elements that can be selected (character vector, default: c("node", "combo", "edge"))
#' @param immediately Whether to select immediately, only effective when selection mode is default (boolean, default: FALSE)
#' @param mode Selection mode: "union", "intersect", "diff", or "default" (string, default: "default")
#' @param onSelect Callback for selected element state (JS function, default: NULL)
#' @param state State to switch to when selected (string, default: "selected")
#' @param style Style of the lasso during selection (list, default: NULL)
#' @param trigger Press this shortcut key along with mouse click to select (character vector, default: c("shift"))
#'
#' @return A list with the configuration settings
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- lasso_select()
#'
#' # Custom configuration
#' config <- lasso_select(
#'   key = "my-lasso-select",
#'   animation = TRUE,
#'   enableElements = c("node", "combo"),
#'   mode = "union",
#'   state = "highlight",
#'   trigger = c("control"),
#'   style = list(
#'     stroke = "#1890FF",
#'     lineWidth = 2,
#'     fillOpacity = 0.1
#'   )
#' )
lasso_select <- function(
  key = "lasso-select",
  animation = FALSE,
  enable = TRUE,
  enableElements = c("node", "combo", "edge"),
  immediately = FALSE,
  mode = "default",
  onSelect = NULL,
  state = "selected",
  style = NULL,
  trigger = c("shift")
) {
  # Validate inputs
  if (!is.character(key)) {
    stop("'key' should be a string")
  }

  if (!is.logical(animation)) {
    stop("'animation' should be a boolean value")
  }

  if (!is.logical(enable) && !is_js(enable)) {
    stop(
      "'enable' should be a boolean or a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  valid_elements <- c("node", "edge", "combo")
  if (!all(enableElements %in% valid_elements)) {
    stop(
      "'enableElements' should only contain: ",
      paste(valid_elements, collapse = ", ")
    )
  }

  if (!is.logical(immediately)) {
    stop("'immediately' should be a boolean value")
  }

  valid_modes <- c("union", "intersect", "diff", "default")
  if (!mode %in% valid_modes) {
    stop("'mode' should be one of: ", paste(valid_modes, collapse = ", "))
  }

  if (!is.null(onSelect) && !is_js(onSelect)) {
    stop(
      "'onSelect' should be a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  if (!is.character(state)) {
    stop("'state' should be a string")
  }

  if (!is.null(style) && !is.list(style)) {
    stop("'style' should be a list of style properties")
  }

  valid_triggers <- c("control", "shift", "alt", "meta")
  if (!all(trigger %in% valid_triggers)) {
    warning(
      "Some 'trigger' values may not be standard. Valid options include: ",
      paste(valid_triggers, collapse = ", ")
    )
  }

  # Create the configuration list with internal type parameter
  config <- list(
    type = "lasso-select", # Set internally
    key = key, # User-configurable with default
    animation = animation,
    enable = enable,
    enableElements = enableElements,
    immediately = immediately,
    mode = mode,
    state = state,
    trigger = trigger
  )

  # Add optional parameters if provided
  if (!is.null(onSelect)) {
    config$onSelect <- onSelect
  }

  if (!is.null(style)) {
    config$style <- style
  }

  config
}

#' Configure Optimize Viewport Transform Behavior
#'
#' Creates a configuration object for the optimize-viewport-transform behavior in G6.
#' This behavior improves performance during viewport transformations by temporarily
#' hiding certain elements.
#'
#' @param key Unique identifier for the behavior (string, default: "optimize-viewport-transform")
#' @param enable Whether to enable this behavior (boolean or JS function, default: TRUE)
#' @param debounce How long after the operation ends to restore the visibility of all elements in milliseconds (number, default: 200)
#' @param shapes Function to specify which graphical elements should remain visible during canvas operations (JS function, default: returns TRUE for nodes)
#'
#' @return A list with the configuration settings
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- optimize_viewport_transform()
#'
#' # Custom configuration
#' config <- optimize_viewport_transform(
#'   key = "my-optimize-transform",
#'   debounce = 500,
#'   shapes = htmlwidgets::JS("(type) => type === 'node' || type === 'edge'")
#' )
#'
#' # With conditional enabling
#' config <- optimize_viewport_transform(
#'   enable = htmlwidgets::JS("(event) => event.getCurrentTransform().zoom < 0.5")
#' )
optimize_viewport_transform <- function(
  key = "optimize-viewport-transform",
  enable = TRUE,
  debounce = 200,
  shapes = htmlwidgets::JS("(type) => type === 'node'")
) {
  # Validate inputs
  if (!is.logical(enable) && !is_js(enable)) {
    stop(
      "'enable' should be a boolean or a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  if (!is.numeric(debounce) || debounce < 0) {
    stop("'debounce' should be a non-negative number")
  }

  if (!is_js(shapes)) {
    stop(
      "'shapes' should be a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  # Create the configuration list with internal type parameter
  config <- list(
    type = "optimize-viewport-transform", # Set internally
    key = key, # User-configurable with default
    enable = enable,
    debounce = debounce,
    shapes = shapes
  )

  config
}

#' Configure Scroll Canvas Behavior
#'
#' Creates a configuration object for the scroll-canvas behavior in G6.
#' This behavior allows scrolling the canvas with mouse wheel or keyboard.
#'
#' @param key Unique identifier for the behavior (string, default: "scroll-canvas")
#' @param enable Whether to enable this behavior (boolean or JS function, default: TRUE)
#' @param direction Allowed scrolling direction: "x", "y", or NULL for no limit (string or NULL, default: NULL)
#' @param range Scrollable viewport range in viewport size units (numeric or numeric vector, default: 1)
#' @param sensitivity Scrolling sensitivity, the larger the value, the faster the scrolling (numeric, default: 1)
#' @param trigger Keyboard shortcuts to trigger scrolling (list, default: NULL)
#' @param onFinish Callback function when scrolling is finished (JS function, default: NULL)
#' @param preventDefault Whether to prevent the browser's default event (boolean, default: TRUE)
#'
#' @return A list with the configuration settings
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- scroll_canvas()
#'
#' # Custom configuration
#' config <- scroll_canvas(
#'   key = "my-scroll-behavior",
#'   direction = "x",
#'   range = c(-2, 2),
#'   sensitivity = 1.5,
#'   preventDefault = FALSE
#' )
#'
#' # With keyboard triggers and callback
#' config <- scroll_canvas(
#'   enable = htmlwidgets::JS("(event) => !event.altKey"),
#'   trigger = list(
#'     up = "w",
#'     down = "s",
#'     left = "a",
#'     right = "d"
#'   ),
#'   onFinish = htmlwidgets::JS("() => { console.log('Scrolling finished'); }")
#' )
scroll_canvas <- function(
  key = "scroll-canvas",
  enable = TRUE,
  direction = NULL,
  range = 1,
  sensitivity = 1,
  trigger = NULL,
  onFinish = NULL,
  preventDefault = TRUE
) {
  # Validate inputs
  if (!is.logical(enable) && !is_js(enable)) {
    stop(
      "'enable' should be a boolean or a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  valid_directions <- c("x", "y", NULL)
  if (!is.null(direction) && !direction %in% c("x", "y")) {
    stop("'direction' should be one of: 'x', 'y', or NULL")
  }

  if (!is.numeric(range) && !is.numeric(as.vector(range))) {
    stop("'range' should be a number or a numeric vector")
  }

  if (!is.numeric(sensitivity) || sensitivity <= 0) {
    stop("'sensitivity' should be a positive number")
  }

  if (!is.null(trigger) && !is.list(trigger)) {
    stop("'trigger' should be a list of keyboard shortcuts")
  }

  if (!is.null(onFinish) && !is_js(onFinish)) {
    stop(
      "'onFinish' should be a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  if (!is.logical(preventDefault)) {
    stop("'preventDefault' should be a boolean value")
  }

  # Create the configuration list with internal type parameter
  config <- list(
    type = "scroll-canvas", # Set internally
    key = key, # User-configurable with default
    enable = enable,
    range = range,
    sensitivity = sensitivity,
    preventDefault = preventDefault
  )

  # Add optional parameters if provided
  if (!is.null(direction)) {
    config$direction <- direction
  }

  if (!is.null(trigger)) {
    config$trigger <- trigger
  }

  if (!is.null(onFinish)) {
    config$onFinish <- onFinish
  }

  config
}

#' Configure Zoom Canvas Behavior
#'
#' Creates a configuration object for the zoom-canvas behavior in G6.
#' This behavior allows zooming the canvas with mouse wheel or keyboard shortcuts.
#'
#' @param key Unique identifier for the behavior (string, default: "zoom-canvas")
#' @param animation Zoom animation effect settings (list, default: list with duration 200ms)
#' @param enable Whether to enable this behavior (boolean or JS function, default: TRUE)
#' @param origin Zoom center point in viewport coordinates (list with x, y values, default: NULL)
#' @param onFinish Callback function when zooming is finished (JS function, default: NULL)
#' @param preventDefault Whether to prevent the browser's default event (boolean, default: TRUE)
#' @param sensitivity Zoom sensitivity, the larger the value, the faster the zoom (numeric, default: 1)
#' @param trigger How to trigger zooming, supports mouse wheel and keyboard shortcuts (list, default: NULL)
#'
#' @return A list with the configuration settings
#' @export
#'
#' @examples
#' # Basic configuration
#' config <- zoom_canvas()
#'
#' # Custom configuration
#' config <- zoom_canvas(
#'   key = "my-zoom-behavior",
#'   animation = list(duration = 300, easing = "ease-in-out"),
#'   origin = list(x = 0, y = 0),
#'   sensitivity = 1.5,
#'   preventDefault = FALSE
#' )
#'
#' # With keyboard triggers and callback
#' config <- zoom_canvas(
#'   enable = htmlwidgets::JS("(event) => !event.altKey"),
#'   trigger = list(
#'     zoomIn = "+",
#'     zoomOut = "-",
#'     reset = "0"
#'   ),
#'   onFinish = htmlwidgets::JS("() => { console.log('Zooming finished'); }")
#' )
zoom_canvas <- function(
  key = "zoom-canvas",
  animation = list(duration = 200),
  enable = TRUE,
  origin = NULL,
  onFinish = NULL,
  preventDefault = TRUE,
  sensitivity = 1,
  trigger = NULL
) {
  # Validate inputs
  if (!is.character(key)) {
    stop("'key' should be a string")
  }

  if (!is.list(animation)) {
    stop("'animation' should be a list with animation settings")
  }

  if (is.list(animation) && !is.null(animation$duration)) {
    if (!is.numeric(animation$duration) || animation$duration < 0) {
      stop("'animation$duration' should be a non-negative number")
    }
  }

  if (!is.logical(enable) && !is_js(enable)) {
    stop(
      "'enable' should be a boolean or a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  if (!is.null(origin)) {
    if (!is.list(origin)) {
      stop("'origin' should be a list")
    }
  }

  if (!is.null(onFinish) && !is_js(onFinish)) {
    stop(
      "'onFinish' should be a JavaScript function wrapped with htmlwidgets::JS()"
    )
  }

  if (!is.logical(preventDefault)) {
    stop("'preventDefault' should be a boolean value")
  }

  if (!is.numeric(sensitivity) || sensitivity <= 0) {
    stop("'sensitivity' should be a positive number")
  }

  if (!is.null(trigger) && !is.list(trigger)) {
    stop("'trigger' should be a list of trigger configurations")
  }

  # Create the configuration list with internal type parameter
  config <- list(
    type = "zoom-canvas", # Set internally
    key = key, # User-configurable with default
    animation = animation,
    enable = enable,
    preventDefault = preventDefault,
    sensitivity = sensitivity
  )

  # Add optional parameters if provided
  if (!is.null(origin)) {
    config$origin <- origin
  }

  if (!is.null(onFinish)) {
    config$onFinish <- onFinish
  }

  if (!is.null(trigger)) {
    config$trigger <- trigger
  }

  config
}
