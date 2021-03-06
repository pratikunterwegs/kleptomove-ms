#' ---
#' output: html_document
#' editor_options:
#'   chunk_output_type: console
#' ---
#'
#' # Process landscape snapshots
#'
## -----------------------------------------------------------------------------
library(data.table)
library(glue)
library(kleptomoveMS)

#'
#' ## Items per cell
#'
## -----------------------------------------------------------------------------
# read paths
paths <- list.dirs("data_sim/", recursive = F)
paths <- paths[grep("rep_001", paths)]

# select gens
gens_for_figure <- stringr::str_pad(c(1, 10, 50), width = 5, pad = "0")

# get paths for files
data_landscape <- CJ(
  gen = gens_for_figure,
  path = paths
)

# add sim_type
data_landscape[, sim_type := rep(
  rep(c(
    "facultative", "foragers",
    "obligate", "random"
  ), each = 10), 3
)]

growth_rates <- c(0.001, 0.005, 0.01, 0.02, 0.03, 0.04, 0.05, 0.075, 0.1, 0.25)

data_landscape[, regrowth := rep(
  growth_rates, 12
)]

# get paths
data_landscape$image <- glue_data(data_landscape, "{path}/{gen}.png")

# get data
data_landscape$data <- lapply(data_landscape$image,
  kleptomoveMS::read_landscape,
  layer = 4,
  crop_dim = 60,
  type = "items"
)

# convert gen to numeric
data_landscape[, gen := as.numeric(gen)]

# unlist
data_landscape <- data_landscape[, unlist(data, recursive = F),
  by = c("sim_type", "gen", "regrowth")
]

# save
fwrite(data_landscape,
  file = "data_sim/results/data_landscape_item_count_1_50.csv"
)

#'
#' ## Foragers per cell
#'
## -----------------------------------------------------------------------------
# read paths
paths <- list.dirs("data_sim/", recursive = F)
paths <- paths[grep("rep_001", paths)]

# select gens
gens_for_figure <- stringr::str_pad(c(1, 10, 50), width = 5, pad = "0")

# get paths for files
data_landscape <- CJ(
  gen = gens_for_figure,
  path = paths
)

# add sim_type
data_landscape[, sim_type := rep(
  rep(c(
    "facultative", "foragers",
    "obligate", "random"
  ), each = 10), 3
)]

growth_rates <- c(0.001, 0.005, 0.01, 0.02, 0.03, 0.04, 0.05, 0.075, 0.1, 0.25)

data_landscape[, regrowth := rep(
  growth_rates, 12
)]

# get paths
data_landscape$image <- glue_data(data_landscape, "{path}/{gen}.png")

# get data
data_landscape$agent_data <- lapply(data_landscape$image,
  kleptomoveMS::read_landscape,
  layer = c(1, 2, 3),
  crop_dim = 60,
  type = "items"
)

# convert gen to numeric
data_landscape[, gen := as.numeric(gen)]

# unlist
data_landscape <- data_landscape[, unlist(agent_data, recursive = F),
  by = c("sim_type", "gen", "regrowth")
]

# rename items to agents
setnames(data_landscape, "items", "agents")

# rescale
data_landscape$agents = data_landscape$agents / 
  (min(data_landscape$agents[data_landscape$agents > 0]))

# save data
fwrite(data_landscape, file = "data_sim/results/data_agent_count_1_50.csv")
