#' ---
#' output: html_document
#' editor_options:
#'   chunk_output_type: console
#' ---
#'
## -----------------------------------------------------------------------------
library(data.table)
library(glue)
library(ggplot2)

#'
#' ## get agents in all gens
#'
## -----------------------------------------------------------------------------
params <- fread("data_sim/results/data_param_combinations.csv")
params$folder_path <- stringr::str_replace(
  params$folder_path,
  "data",
  "data_sim"
)

# remove params over 0.02
# params = params[regrowth <= 0.02,]

# select gens
gens_for_figure <- stringr::str_pad(seq(50), width = 5, pad = "0")

# get paths for files
params$gens <- list(gens_for_figure)

# unlist
params <- params[, unlist(gens_for_figure, recursive = F),
  by = list(sim_type, replicate, regrowth, folder_path)
]
# rename col
setnames(params, "V1", "gen")

# get paths
params$image <- glue_data(params, "{folder_path}/{gen}.png")

# copy as data
data <- copy(params)

#'
## -----------------------------------------------------------------------------
# get data
agent_data <- lapply(data$image,
  kleptomoveMS::read_landscape,
  layer = c(1, 3), # read only foragers and klepts
  crop_dim = 60,
  type = "items"
)

# remove where agents are 0
agent_data <- lapply(
  agent_data, function(df) {
    df <- df[items > 0, ]
    setnames(df, "items", "agents")
    # df[, agents := round(agents / 0.02)]
  }
)

#'
#' ## get items in all gens
#'
## -----------------------------------------------------------------------------
# copy as data
data <- copy(params)

# get data
item_data <- lapply(data$image,
  kleptomoveMS::read_landscape,
  layer = c(4), # read items
  crop_dim = 60,
  type = "items"
)

#'
#' ## get quality layer
#'
## -----------------------------------------------------------------------------
quality_data <- kleptomoveMS::read_landscape(
  "data_sim/data_parameters/kernels32.png",
  layer = 1, crop_dim = 60, type = "items"
)

setnames(quality_data, old = "items", new = "quality")

# agent quality data
quality_data <- lapply(agent_data, function(df) {
  merge(df, quality_data, by = intersect(names(df), names(quality_data)), all = F)
})

# unlist
data$layer_data <- quality_data

# unlist
data <- data[, unlist(layer_data, recursive = F),
  by = c("sim_type", "gen", "replicate", "regrowth", "folder_path", "image")
]

# select data
data[, gen := as.numeric(gen)]
data <- data[, list(sim_type, gen, replicate, regrowth, x, y, agents, quality)]

# save data
fwrite(data, file = "data_sim/results/data_quality_counts_1_150.csv")

#'
#'
#' ## get full layer data
#'
## -----------------------------------------------------------------------------
# keep item data on occupied cells
layer_data <- Map(function(adf, idf) {
  idf <- merge(adf, idf, by = intersect(names(adf), names(idf)), all = FALSE)
}, agent_data, item_data)

data <- copy(params)

# add layer data to param data
data$layer_data <- layer_data

# unlist
data <- data[, unlist(layer_data, recursive = F),
  by = c("sim_type", "gen", "replicate", "regrowth", "folder_path", "image")
]

# select data
data[, gen := as.numeric(gen)]
data <- data[, list(sim_type, gen, replicate, regrowth, x, y, agents, items)]

# save data
fwrite(data, file = "data_sim/results/data_layer_counts_1_150.csv")

#'
#' ## get items variance
#'
## -----------------------------------------------------------------------------
# get item variance
data <- copy(params)
data[, item_variance := kleptomoveMS::get_layer_variance(
  landscape_file = image,
  layer = 4,
  crop_dim = 120,
  max_K = 5
)]

# save data
data <- data[, list(sim_type, gen, replicate, regrowth, item_variance)]

# save data
fwrite(data, file = "data_sim/results/data_item_variance_1_150.csv")

#'