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
#' ## Agents ~ quality
#'
## -----------------------------------------------------------------------------
# read data
data <- fread("data_sim/results/data_quality_counts_1_150.csv")

# get correlation
data_summary <- data[, list(
  cf = tryCatch(
    expr = cor.test(agents, quality)[["estimate"]],
    error = function(e) {
      return(NA_real_)
    }
  ),
  cfp = tryCatch(
    expr = cor.test(agents, quality)[["p.value"]],
    error = function(e) {
      return(NA_real_)
    }
  )
),
by = c("sim_type", "gen", "replicate", "regrowth", "strategy")
]

# write data
fwrite(data_summary, file = "data_sim/results/data_quality_matching_rule.csv")
