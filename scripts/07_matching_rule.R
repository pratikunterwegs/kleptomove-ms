#' ---
#' output: html_document
#' editor_options:
#'   chunk_output_type: console
#' ---
#'
## -----------------------------------------------------------------------------
library(data.table)
library(kleptomoveMS)
# plotting
library(ggplot2)

#'
#' ## Agents ~ items
#'
## -----------------------------------------------------------------------------
# read data
data <- fread("data_sim/results/data_layer_counts_1_150.csv")

# get potential intake
data[, potential_in := get_potential_intake(0.2, items)]

# get correlation
data_summary <- data[, list(
  cf =
    tryCatch(
      expr = cor.test(agents, potential_in)[["estimate"]],
      error = function(e) {
        return(NA_real_)
      }
    )
),
by = c("sim_type", "gen", "replicate", "regrowth")
]
# write data
fwrite(data_summary, file = "data_sim/results/data_matching_rule.csv")

#'
#' ## Agents ~ quality
#'
## -----------------------------------------------------------------------------
# read data
data <- fread("data_sim/results/data_quality_counts_1_150.csv")

# get correlation
data_summary <- data[, list(
  cf = cor.test(agents, quality)[["estimate"]],
  cfp = cor.test(agents, quality)[["p.value"]]
),
by = c("sim_type", "gen", "replicate", "regrowth")
]

# write data
fwrite(data_summary, file = "data_sim/results/data_quality_matching_rule.csv")