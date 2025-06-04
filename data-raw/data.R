#pak::pak("igraph/igraphdata")
library(igraph)
lesmis <- igraphdata::ns_graph("lesmis")

graph_df <- as_data_frame(lesmis, "both")
nodes <- graph_df$vertices
names(nodes)[1] <- "id"
edges <- graph_df$edges
names(edges)[1:2] <- c("source", "target")

lesmis <- list(nodes = nodes, edges = edges)

usethis::use_data(lesmis, overwrite = TRUE)


radial <- jsonlite::fromJSON("https://assets.antv.antgroup.com/g6/radial.json")
usethis::use_data(radial, overwrite = TRUE)


tree <- jsonlite::fromJSON(
  "https://gw.alipayobjects.com/os/antvdemo/assets/data/algorithm-category.json"
)

nodes <- data.frame(label = unlist(tree, use.names = FALSE))
nodes$id <- seq_len(nrow(nodes))

edges <-
  rbind(
    data.frame(source = tree$id, target = tree$children$id),
    data.frame(
      source = tree$children$id[1],
      target = tree$children$children[[1]][[1]]
    ),
    data.frame(
      source = tree$children$id[3],
      target = tree$children$children[[3]][[1]]
    ),
    data.frame(
      source = tree$children$id[2],
      target = tree$children$children[[2]]$id
    ),
    data.frame(
      source = tree$children$children[[2]]$id[1],
      target = tree$children$children[[2]]$children[[1]][[1]]
    ),
    data.frame(
      source = tree$children$children[[2]]$id[2],
      target = tree$children$children[[2]]$children[[2]][[1]]
    ),
    data.frame(
      source = tree$children$children[[2]]$id[3],
      target = tree$children$children[[2]]$children[[3]][[1]]
    )
  )

edges$source <- match(edges$source, nodes$label)
edges$target <- match(edges$target, nodes$label)

tree <- list(nodes = nodes, edges = edges)
usethis::use_data(tree, overwrite = TRUE)


dag <- jsonlite::fromJSON(
  "https://gw.alipayobjects.com/os/antvdemo/assets/data/algorithm-category.json"
)
usethis::use_data(dag, overwrite = TRUE)
