library(readr)
library(dplyr)
library(g6R)
library(purrr)
library(shiny)
library(scales)

# See: https://github.com/steveberardi/bigsky/releases/tag/v0.4.1
# See: https://github.com/steveberardi/bigsky/blob/main/docs/stars.md
# See: https://astronexus.com/projects/hyg-details

# Load your stars data
stars_tbl <- read_csv("~/Downloads/bigsky.0.4.1.stars.csv.gz")

# Filter for visible stars (e.g., magnitude < 6)
stars_tbl <- stars_tbl |>
  filter(magnitude < 7, !is.na(constellation), !is.na(hip_id))

# Convert RA/Dec to radians
stars_tbl <- stars_tbl |>
  mutate(
    ra_rad = ra_degrees_j2000 * pi / 180,
    dec_rad = dec_degrees_j2000 * pi / 180
  )

# Project to 2D (azimuthal equidistant projection)
radius <- 300
stars_tbl <- stars_tbl |>
  mutate(
    x = radius * cos(dec_rad) * sin(ra_rad) + radius,
    y = radius * cos(dec_rad) * cos(ra_rad) + radius
  )

# Asterism processing
fab_lines <- readLines("~/Downloads/constellationship.fab")
asterism_map <- list()
for (line in fab_lines) {
  line <- trimws(line)
  if (line == "" || grepl("^#", line)) {
    next
  }
  parts <- strsplit(line, "\\s+")[[1]]
  abbr <- tolower(parts[1])
  hips <- as.integer(parts[-c(1, 2)]) # skip abbr and count
  asterism_map[[abbr]] <- hips
}

# Prepare nodes (use hip_id as id)
nodes_tbl <- stars_tbl |>
  mutate(id = as.character(hip_id)) |>
  filter(!is.na(id)) |>
  group_by(id) |>
  slice(1) |>
  ungroup() |>
  select(id, x, y, magnitude, bv, constellation, name)

# Create edges by connecting each star to the next within each constellation
get_asterism_edges <- function(hips) {
  if (length(hips) < 2) {
    return(NULL)
  }
  tibble::tibble(
    source = as.character(hips[-length(hips)]),
    target = as.character(hips[-1])
  ) |>
    filter(source != target)
}

edges_tbl <- purrr::map_dfr(
  asterism_map,
  get_asterism_edges
) |>
  distinct(source, target)

bubble_sets_list <- split(nodes_tbl, nodes_tbl$constellation) |>
  imap(
    ~ hull(
      key = sprintf("bubble-set-%s", .y),
      members = .x$id,
      labelText = .y,
      labelFill = "#ffffff",
      labelBackgroundFill = "#db1f90ff",
      labelBackground = TRUE,
      labelPadding = 5,
      fill = "#db1f90ff",
      stroke = "#db1f90ff"
    )
  )

bv_to_color <- function(bv) {
  bv <- pmax(pmin(bv, 2), -0.4)
  # Ultra-bright, neon palette for maximum shine
  scales::col_numeric(
    palette = c("#00fff7", "#ffffff", "#fff700", "#ffea00", "#ff00e1"),
    domain = c(-0.4, 2)
  )(bv)
}

jsonUrl <- NULL

skymap_json_path <- file.path(
  system.file("extdata", package = "g6R"),
  "skymap.json"
)

R.utils::gunzip(
  system.file("extdata", "skymap.json.gz", package = "g6R"),
  destname = file.path(
    system.file("extdata", package = "g6R"),
    "skymap.json"
  ),
  remove = FALSE,
  overwrite = TRUE
)

if (file.exists(skymap_json_path)) {
  jsonUrl <- "data/skymap.json"
}

# # Serve only the extdata directory
shiny::addResourcePath("data", system.file("extdata", package = "g6R"))

ui <- fluidPage(
  actionButton("save_state", "Save graph"),
  g6_output("skymap", width = "900px", height = "900px")
)

server <- function(input, output, session) {
  output$skymap <- render_g6({
    graph <- if (!is.null(jsonUrl)) {
      # Much faster in theory
      g6(
        jsonUrl = jsonUrl
      )
    } else {
      g6(
        nodes = pmap(
          nodes_tbl,
          function(id, x, y, magnitude, bv, constellation, name) {
            color <- bv_to_color(bv)
            node_style <- list(
              x = x,
              y = y,
              size = 5 * (2 + (6 - magnitude) * 1.5),
              fill = color,
              stroke = color,
              stroke = "#ffffff",
              backgroundShadowColor = "#ffffff",
              backgroundShadowBlur = 60,
              opacity = 1
            )
            if (!is.na(name)) {
              node_style$labelText <- name
            }
            g6_node(
              id = id,
              style = node_style
            )
          }
        ),
        edges = pmap(edges_tbl, function(source, target) {
          g6_edge(
            source = source,
            target = target,
            style = list(stroke = "#aaa", lineWidth = 1)
          )
        })
      )
    }

    graph |>
      g6_options(theme = "dark", background = "#000", animation = FALSE) |>
      g6_layout() |>
      g6_behaviors(
        "drag-canvas",
        "zoom-canvas",
        "optimize-viewport-transform",
        "hover-activate"
      ) |>
      g6_plugins(
        minimap(
          containerStyle = list(
            border = "1px solid #aaa",
            background = "#000"
          ),
          maskStyle = list(
            background = "rgba(255, 255, 255, 0.46)"
          )
        )
      )
  })

  observeEvent(input$save_state, {
    con <- gzfile(
      file.path(system.file("extdata", package = "g6R"), "skymap.json.gz"),
      "w"
    )
    on.exit(close(con))
    jsonlite::write_json(
      input[["skymap-state"]],
      con,
      auto_unbox = TRUE,
      pretty = TRUE
    )
  })

  #proxy <- g6_proxy("skymap")
  #observeEvent(req(input[["skymap-initialized"]]), {
  #  walk(unname(bubble_sets_list$leo), ~ proxy |> g6_add_plugin(.x))
  #})
}

shinyApp(ui, server)
