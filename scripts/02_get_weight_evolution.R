#' ---
#' output: html_document
#' editor_options:
#'   chunk_output_type: console
#' ---
#'
#' # Prepare node weight evolution data
#'
#' ## Load libraries
#'
## -----------------------------------------------------------------------------
# load libs
library(data.table)
library(kleptomoveMS)

#'
#' ## Run function over data
#'
## -----------------------------------------------------------------------------
# read parameter combinations
param_combinations <- fread("data_sim/results/data_param_combinations.csv")
param_combinations[, folder_path := stringr::str_replace(folder_path, "data", "data_sim")]

# get weight evolution every 10 generation
# from each simulation
temp_gen_data <- lapply(
  param_combinations$folder_path,
  function(x) {
    get_sim_weight_evol(
      data_folder = x,
      generations = c(
        seq(1, 990, 25),
        990:998
      ),
      which_weight = NA
    )
  }
)

#'
#' ## Write sparse and final generation range sequence to file
#'
## -----------------------------------------------------------------------------
# bind with parameters
data <- param_combinations
data[, wt_data := temp_gen_data]

# unnest
data <- data[, unlist(wt_data, recursive = F),
  by = list(sim_type, replicate, regrowth)
]
fwrite(data, file = "data_sim/results/data_weight_evolution.csv")

#'
#' ## Prepare data for intial generations
#'
## -----------------------------------------------------------------------------
# read parameter combinations
param_combinations <- fread("data_sim/results/data_param_combinations.csv")
param_combinations[, folder_path := stringr::str_replace(folder_path, "data", "data_sim")]

get_sim_weight_evol(
  data_folder = param_combinations$folder_path[1],
  generations = seq(1, 100, 10),
  which_weight = c(3, 5, 7)
)

# get weight evolution every 10 generation
# from each simulation
temp_gen_data <- lapply(
  param_combinations$folder_path,
  function(x) {
    get_sim_weight_evol(
      data_folder = x,
      generations = seq(1, 100, 1),
      which_weight = c(3, 5, 7)
    )
  }
)

#'
#' ## Write sparse and final generation range sequence to file
#'
## -----------------------------------------------------------------------------
# bind with parameters
data <- copy(param_combinations)
data[, wt_data := temp_gen_data]

# unnest
data <- data[, unlist(wt_data, recursive = F),
  by = list(sim_type, replicate, regrowth)
]
fwrite(data, file = "data_sim/results/data_early_0_100_weight_evolution.csv")
