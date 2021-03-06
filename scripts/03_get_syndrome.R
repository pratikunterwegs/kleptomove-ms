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
#' ## Run syndrome function over data
#'
## -----------------------------------------------------------------------------
# read parameter combinations
param_combinations <- fread("data_sim/results/data_param_combinations.csv")
param_combinations[, folder_path := stringr::str_replace(folder_path, "data", "data_sim")]

# select obligate sims
param_combinations <- param_combinations[sim_type == "obligate", ]
# get weight data
syndrome_data <- lapply(param_combinations$folder_path, function(path) {
  kleptomoveMS::get_pref_handler_by_strat(
    data_folder = path,
    generations = seq(1, 100),
    weight_klept_bias = 5,
    weight_of_interest = c(
      handler_pref = 3,
      item_pref = 4,
      nh_pref = 2
    )
  )
})

# add to data
data <- copy(param_combinations[, c("sim_type", "replicate", "regrowth")])
data$syndrome_data <- syndrome_data

# unlist
data <- data[, unlist(syndrome_data, recursive = FALSE),
  by = c("sim_type", "replicate", "regrowth")
]

# save data
fwrite(data, file = "data_sim/results/data_syndrome.csv")

#'
#' ## Get handler preference by strategy
#'
## -----------------------------------------------------------------------------
# read parameter combinations
param_combinations <- fread("data_sim/results/data_param_combinations.csv")
param_combinations[, folder_path := stringr::str_replace(folder_path, "data", "data_sim")]

# select obligate sims
param_combinations <- param_combinations[sim_type == "obligate" &
  regrowth == 0.01, ]
# weight data
syndrome_data <- lapply(param_combinations$folder_path, function(path) {
  kleptomoveMS::get_pref_handler_by_strat(
    data_folder = path,
    generations = seq(1, 100),
    weight_klept_bias = 5,
    weight_of_interest = c(
      handler_pref = 3
    ),
    handler_pref_by_strategy = TRUE
  )
})

# add to data
data <- copy(param_combinations[, c("sim_type", "replicate", "regrowth")])
data$syndrome_data <- syndrome_data

# unlist
data <- data[, unlist(syndrome_data, recursive = FALSE),
  by = c("sim_type", "replicate", "regrowth")
]

# save data
fwrite(data, file = "data_sim/results/data_syndrome_by_strategy.csv")
