g6_options <- function(
  node = node_options(),
  edge = edge_options(),
  autoFit = auto_fit_config(),
  autoResize = FALSE,
  background = NULL,
  canvas = g6_canvas_config(),
  cursor = valid_cursors,
  devicePixelRatio = NULL,
  renderer = NULL,
  padding = NULL,
  rotation = 0,
  x = NULL,
  y = NULL,
  zoom = 1,
  zoomRange = c(0.01, 10),
  animation = animation_config(),
  theme = c("light", "dark")
) {
  arg_names <- names(formals())
  # Create list of argument values
  config <- mget(arg_names)
  # Drop NULL elements
  dropNulls(config)
}

#' @keywords internal
valid_cursors <- c(
  'auto',
  'default',
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
  state = list(),
  palette = list(),
  animation = list()
) {
  # Match type argument against possible values
  type <- match.arg(type)

  # Create and return the node options structure
  list(
    node = list(
      type = type,
      style = style,
      state = state,
      palette = palette,
      animation = animation
    )
  )
}

# TBD check defaults
node_style_options <- function(
  # Common style attributes
  fill = NULL,
  stroke = NULL,
  lineWidth = NULL,
  opacity = NULL,
  fillOpacity = NULL,
  strokeOpacity = NULL,
  cursor = NULL,

  # Positioning
  x = NULL,
  y = NULL,
  z = NULL,
  zIndex = NULL,

  # Size and transformation
  size = NULL,
  transform = NULL,
  transformOrigin = NULL,

  # Line styles
  lineDash = NULL,
  lineDashOffset = NULL,
  lineCap = c("butt", "round", "square"),
  lineJoin = c("miter", "round", "bevel"),
  increasedLineWidthForHitTesting = NULL,

  # Shadow
  shadowColor = NULL,
  shadowBlur = NULL,
  shadowOffsetX = NULL,
  shadowOffsetY = NULL,
  shadowType = c("outer", "inner"),

  # Visibility
  visibility = c("visible", "hidden"),

  # State
  collapsed = NULL,

  # Allow other attributes to be passed
  ...
) {
  # Process enum parameters if provided
  if (!is.null(lineCap)) lineCap <- match.arg(lineCap)
  if (!is.null(lineJoin)) lineJoin <- match.arg(lineJoin)
  if (!is.null(shadowType)) shadowType <- match.arg(shadowType)
  if (!is.null(visibility)) visibility <- match.arg(visibility)

  # Build the style object
  dropNulls(
    list(
      fill = fill,
      stroke = stroke,
      lineWidth = lineWidth,
      opacity = opacity,
      fillOpacity = fillOpacity,
      strokeOpacity = strokeOpacity,
      cursor = cursor,
      x = x,
      y = y,
      z = z,
      zIndex = zIndex,
      size = size,
      transform = transform,
      transformOrigin = transformOrigin,
      lineDash = lineDash,
      lineDashOffset = lineDashOffset,
      lineCap = lineCap,
      lineJoin = lineJoin,
      increasedLineWidthForHitTesting = increasedLineWidthForHitTesting,
      shadowColor = shadowColor,
      shadowBlur = shadowBlur,
      shadowOffsetX = shadowOffsetX,
      shadowOffsetY = shadowOffsetY,
      shadowType = shadowType,
      visibility = visibility,
      collapsed = collapsed,
      ...
    )
  )
}

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
  state = list(),
  palette = list(),
  animation = list()
) {
  # Match type argument against possible values
  type <- match.arg(type)

  # Create and return the edge options structure
  list(
    edge = list(
      type = type,
      style = style,
      state = state,
      palette = palette,
      animation = animation
    )
  )
}

# TBD check defaults
edge_style_options <- function(
  # Common style attributes
  stroke = "#000",
  lineWidth = 1,
  opacity = 1,
  strokeOpacity = 1,
  cursor = "default",

  # Z-index and visibility
  zIndex = 1,
  visibility = c("visible", "hidden"),

  # Line styles
  lineDash = 0,
  lineDashOffset = NULL,
  lineCap = c("butt", "round", "square"),
  lineJoin = c("miter", "round", "bevel"),

  # Arrow styles
  startArrow = FALSE,
  endArrow = FALSE,

  # Backwards compatibility for arrow styles
  sourceArrow = NULL, # alias for startArrow
  targetArrow = NULL, # alias for endArrow

  # Label configuration
  label = TRUE,

  # Shadow
  shadowColor = NULL,
  shadowBlur = NULL,
  shadowOffsetX = NULL,
  shadowOffsetY = NULL,
  # Allow other attributes to be passed
  ...
) {
  # Process enum parameters if provided
  if (!is.null(lineCap)) lineCap <- match.arg(lineCap)
  if (!is.null(lineJoin)) lineJoin <- match.arg(lineJoin)
  if (!is.null(visibility)) visibility <- match.arg(visibility)

  # Handle arrow aliases (backwards compatibility)
  if (is.null(startArrow) && !is.null(sourceArrow)) {
    startArrow <- sourceArrow
  }
  if (is.null(endArrow) && !is.null(targetArrow)) {
    endArrow <- targetArrow
  }

  dropNulls(
    list(
      stroke = stroke,
      lineWidth = lineWidth,
      opacity = opacity,
      strokeOpacity = strokeOpacity,
      cursor = cursor,
      zIndex = zIndex,
      visibility = visibility,
      lineDash = lineDash,
      lineDashOffset = lineDashOffset,
      lineCap = lineCap,
      lineJoin = lineJoin,
      startArrow = startArrow,
      endArrow = endArrow,
      label = label,
      labelCfg = labelCfg,
      controlPoints = controlPoints,
      loopCfg = loopCfg,
      polyOffset = polyOffset,
      radius = radius,
      curveOffset = curveOffset,
      curvePosition = curvePosition,
      shadowColor = shadowColor,
      shadowBlur = shadowBlur,
      shadowOffsetX = shadowOffsetX,
      shadowOffsetY = shadowOffsetY,
      ...
    )
  )
}

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
  # Get all argument names
  arg_names <- names(formals())
  # Create list of argument values
  config <- mget(arg_names)
  # Drop NULL elements
  dropNulls(config)
}

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
    autoFit = list(
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
  )
}

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
  # Match arguments against their possible values
  direction <- match.arg(direction)
  fill <- match.arg(fill)

  # Validate numeric parameters
  if (!is.null(delay) && (!is.numeric(delay) || delay < 0)) {
    stop("'delay' must be a non-negative numeric value")
  }

  if (!is.null(duration) && (!is.numeric(duration) || duration < 0)) {
    stop("'duration' must be a non-negative numeric value")
  }

  if (!is.null(iterations) && (!is.numeric(iterations) || iterations < 0)) {
    stop("'iterations' must be a non-negative numeric value")
  }

  # Create the config list
  dropNulls(list(
    delay = delay,
    direction = direction,
    duration = duration,
    easing = easing,
    fill = fill,
    iterations = iterations
  ))
}
