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
