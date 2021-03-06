#'
## -----------------------------------------------------------------------------
library(kleptomoveMS)

library(data.table)
library(glue)

library(ggplot2)

#'
#' ## get parameters
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

#'
#' ## get intake variance in last gens
#'
## -----------------------------------------------------------------------------
# get intake variance
intake_variance <- lapply(params$folder_path, function(path) {
  kleptomoveMS::get_intake_variance(
    data_folder = path
  )
})

# make data
data <- copy(params)
data <- unique(params, by = c("sim_type", "replicate", "regrowth"))
data[, folder_path := NULL]

# add list
data$intake_variance <- intake_variance

# unlist
data <- data[, unlist(intake_variance, recursive = FALSE),
  by = c("sim_type", "replicate", "regrowth")
]

# save
fwrite(data, file = "data_sim/data_intake_variance.csv")
