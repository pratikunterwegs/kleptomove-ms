#' ---
#' output: html_document
#' editor_options:
#'   chunk_output_type: console
#' ---
#'
## -----------------------------------------------------------------------------
#### code to make a basic overall plot
# load libraries
library(data.table)
# some helper functions
library(kleptomoveMS)

#'
## -----------------------------------------------------------------------------
# read parameter combinations
data <- fread("data_sim/results/data_param_combinations.csv")[10]

data[, folder_path := stringr::str_replace(folder_path, "data", "data_sim")]

# no random
data = data[sim_type != "random", ]

# check extractor
prepare_extractor(data$folder_path)

#'
## -----------------------------------------------------------------------------
# get strategy, fitness and conflicts over gens
data[, summary_data := lapply(
  folder_path,
  get_strategy_gen
)]

#'
## -----------------------------------------------------------------------------
# unlist
data <- data[, unlist(summary_data, recursive = F),
  by = c("sim_type", "replicate", "regrowth")
]

#'
## -----------------------------------------------------------------------------
# save data
fwrite(data, file = "data_sim/results/data_strategy_gen.csv")
