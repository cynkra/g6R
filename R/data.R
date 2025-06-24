#' Character network from "Les miserables" novel
#'
#' A dataset containing Les Misérables characters network, encoding interactions
#' between characters of Victor Hugo's novel. Two characters are connected
#' whenever they appear in the same chapter. This dataset was first created
#' by Donald Knuth as part of the Stanford Graph Base.
#' (https://people.sc.fsu.edu/~jburkardt/datasets/sgb/sgb.html).
#' It contains 77 nodes corresponding to characters of the novel, and 254 edges.
#'
#' @docType data
#'
#' @usage data(lesmis)
#'
#' @format A list with 2 data frames:
#' \describe{
#'   \item{nodes}{data frame with 77 rows for the nodes. Contains node labels and x/y coordinates.}
#'   \item{edges}{data frame with 254 rows for the edges. Contains souyrce/target and the number of times the interaction happened.}
#' }
#' @source \url{https://networks.skewed.de/net/lesmis}
"lesmis"


#' Example Network for radial layouts
#'
#' @docType data
#'
#' @usage data(radial)
#'
#' @format A list with 2 data frames:
#' \describe{
#'   \item{nodes}{data frame with 34 rows for the nodes.}
#'   \item{edges}{data frame with 58 rows for the edges.}
#' }
#' @source \url{https://assets.antv.antgroup.com/g6/radial.json}
"radial"


#' Example tree graph
#'
#' The graph contains a classification of algorithm categories
#'
#' @docType data
#'
#' @usage data(tree)
#'
#' @format A list with 2 data frames:
#' \describe{
#'   \item{nodes}{data frame with 31 rows for the nodes.}
#'   \item{edges}{data frame with 30 rows for the edges.}
#' }
#' @source \url{https://gw.alipayobjects.com/os/antvdemo/assets/data/algorithm-category.json}
"tree"


#' Example DAG graph
#'
#' The graph is a directed acyclic graph
#'
#' @docType data
#'
#' @usage data(dag)
#'
#' @format A list with 2 data frames:
#' \describe{
#'   \item{nodes}{data frame with 12 rows for the nodes.}
#'   \item{edges}{data frame with 12 rows for the edges.}
#'   \item{combo}{data frame with 3 rows for the combos.}
#' }
#' @source \url{https://gw.alipayobjects.com/os/antvdemo/assets/data/algorithm-category.json}
"dag"

#' Example pokemon data
#'
#' Pokemon evolution network to showcase combo features.
#'
#' @docType data
#'
#' @usage data(poke)
#'
#' @format A list with 3 nested lists:
#' \describe{
#'   \item{nodes}{list with 120 pokemon.}
#'   \item{edges}{list with 69 connections.}
#'   \item{combo}{list with 51 pokemon families.
#'    A family contains all evolutions of a pokemon.}
#' }
#' @source \url{https://pokeapi.co/docs/v2}
"poke"
