% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fun_weight_evo.R
\name{get_agent_distribution}
\alias{get_agent_distribution}
\title{Summarise Kleptomove output.}
\usage{
get_agent_distribution(
  data_folder,
  which_gen = seq(991, 998, 1),
  n_time = 200,
  capacity_matrix,
  layers = c("items", "foragers", "klepts", "klepts_intake", "foragers_intake")
)
}
\arguments{
\item{data_folder}{Which data folder to summarise. Data folders should
contain the results of ONE replicate of ONE parameter combination.}

\item{which_gen}{Which generations to look for. Defaults to 991 -- 998.}

\item{n_time}{The timesteps per generation.}

\item{capacity_matrix}{The capacity matrix.}

\item{layers}{Which layers to read in. Defaults to all layers.}
}
\value{
A data.table of the per-capacity, per-timestep, per-generation
values (mean, median, standard deviation) of each layer.
}
\description{
A function to get the per-generation per-timestep occupancy per cell.
}
