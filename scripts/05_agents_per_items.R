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

params = params[regrowth <= 0.05,]

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

# remove unused growth rates
data = data[regrowth <= 0.05,]

# separate data for scenario 2
data_sc2 = data[sim_type == "obligate", ]

# separate other data
data = data[!data_sc2, on = names(data)]

# handle data from scenario 2
sc2_strat = data.table(strategy = c("foragers", "klepts"))
data_sc2 = setkey(data_sc2[, c(k = 1, .SD)], k)[
  sc2_strat[, c(k = 1, .SD)], allow.cartesian = TRUE]
data_sc2[, k := NULL]

#'
## -----------------------------------------------------------------------------
# get data for scenarios 1 and 3
agent_data <- lapply(data$image,
  kleptomoveMS::read_landscape,
  layer = c(1, 3), # read only foragers and klepts if any
  crop_dim = 60,
  type = "items"
)

# scenario 2 agent data
agent_data_sc2 = Map(function(file, strategy) {
  
  layer = ifelse(strategy == "foragers", 3, 1)
  
  d = kleptomoveMS::read_landscape(
    landscape_file = file, layer = layer,
    crop_dim = 60,
    type = "items"
  )
  
  d = d[items > 0, ]
  
  setnames(d, "items", strategy)
  
}, data_sc2$image, data_sc2$strategy)

#' ## Remove unoccupied cells
#' 
# remove where agents are 0
agent_data <- lapply(
  agent_data, function(df) {
    df <- df[items > 0, ]
    setnames(df, "items", "agents")
    # df[, agents := round(agents / 0.02)]
  }
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
agent_data <- lapply(agent_data, function(df) {
  merge(df, quality_data, by = intersect(names(df), names(quality_data)), all = F)
})

# scenario 2 agent quality matching
agent_data_sc2 = lapply(agent_data_sc2, function(df) {
  merge(df, quality_data, by = intersect(names(df), names(quality_data)), all = F)
})

# unlist and merge with simulation parameters
data$layer_data <- agent_data

data_sc2$layer_data = agent_data_sc2

# unlist
data <- data[, unlist(layer_data, recursive = F),
  by = c("sim_type", "gen", "replicate", "regrowth", "folder_path", "image")
]

# assign strategy
data$strategy =  "all_agents"

data_sc2 = data_sc2[, unlist(layer_data, recursive = F),
  by = c("sim_type", "gen", "replicate", "regrowth", "folder_path", "image",
         "strategy")
]
setnames(data_sc2, "foragers", "agents")

# bind rows together
data = rbindlist(list(data, data_sc2), use.names = TRUE)

# select data
data[, gen := as.numeric(gen)]
data <- data[, list(sim_type, gen, replicate, regrowth, 
                    x, y, agents, quality, strategy)]

# save data
fwrite(data, file = "data_sim/results/data_quality_counts_1_150.csv")
