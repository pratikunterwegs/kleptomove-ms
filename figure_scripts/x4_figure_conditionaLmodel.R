#' ---
#' output: html_document
#' editor_options:
#'   chunk_output_type: console
#' ---
#'
#' figure 4 for the conditional strategy case
#'
#' load libs
#'
## -----------------------------------------------------------------------------
library(data.table)

library(ggplot2)
library(colorspace)
library(patchwork)

#'
#' get data
#'
#' population activity data
#'
## -----------------------------------------------------------------------------
# activity data
data_activity <- fread("data_sim/results/data_strategy_gen.csv")
data_activity <- data_activity[
  sim_type == "facultative" &
    regrowth == 0.01
]

#'
#' population klept response to handlers
#'
## -----------------------------------------------------------------------------
# get data and filter for weight 5 which is the bias
data_klept_prop <- fread("data_sim/results/data_early_0_100_weight_evolution.csv")
data_klept_prop <- data_klept_prop[sim_type == "facultative" &
  weight_id == 7 &
  regrowth == 0.01]

# get numeric lower
data_klept_prop[, weight_num :=
  stringi::stri_extract_last(weight_value,
    regex = "[-0-9]+\\.\\d{2}"
  )]
data_klept_prop[, weight_num := as.numeric(weight_num)]

# count proportion
data_klept_prop <- data_klept_prop[weight_num < 0,
  list(klept_strategy = sum(weight_prop)),
  by = c(
    "sim_type", "replicate", "regrowth",
    "gen"
  )
]

#'
#' make population activity budget plot with weight evolution
#'
## -----------------------------------------------------------------------------
fig_activity <-
  ggplot(data_activity[gen <= 50, ]) +
  
  geom_path(
    data = data_klept_prop[gen <= 50, ],
    aes(gen, klept_strategy,
      colour = "p_klept",
      group = replicate
    )
  ) +
  geom_path(aes(gen, value,
    colour = variable,
    group = interaction(variable, replicate)
  )) +
  scale_colour_manual(
    values = c(
      foraging = "dodgerblue4",
      handling = "forestgreen",
      stealing = "indianred",
      p_klept = "darkorange"
    ),
    labels = c(
      foraging = "Searching for prey",
      handling = "Handling prey",
      stealing = "Searching for handlers",
      p_klept = "Prop. klept."
    ),
    breaks = c("foraging", "handling", "stealing", "p_klept")
  ) +
  scale_y_continuous(
    # labels = scales::percent,
    breaks = seq(0, 1, 0.25)
  ) +
  scale_x_log10(
    breaks = c(1, 3, 10, 30, 50)
  ) +
  coord_cartesian(
    xlim = c(1, 50),
    ylim = c(0, 1),
    expand = F
  ) +
  theme_classic(base_size = 8) +
  theme(
    legend.position = "top",
    legend.key.height = unit(2, units = "mm")
  ) +
  labs(
    x = "Generation",
    y = "Proportion of time",
    colour = NULL
  ) +
  guides(colour = guide_legend(nrow = 1))

#'
#' figure intake
#'
## -----------------------------------------------------------------------------
fig_intake <-
  ggplot(
    unique(data_activity[gen <= 50, ],
      by = c("gen", "replicate", "pop_fitness")
    )
  ) +
  
  geom_path(
    aes(gen, pop_fitness,
      group = replicate
    ),
  ) +
  scale_x_log10(
    breaks = c(1, 3, 10, 30, 50)
  ) +
  coord_cartesian(
    xlim = c(1, 50),
    ylim = c(0, 50),
    expand = F
  ) +
  theme_classic(base_size = 8) +
  labs(
    x = "Generation",
    y = "Mean per capita intake"
  )

#'
#' ## correlation with quality
#'
## -----------------------------------------------------------------------------
# raw correlation data
data_quality <- fread("data_sim/results/data_quality_matching_rule.csv")
data_quality <- data_quality[sim_type == "facultative" & regrowth == 0.01, ]

#'
## -----------------------------------------------------------------------------
fig_matching_quality <-
  ggplot() +
  geom_hline(
    yintercept = 0,
    col = "red"
  ) +
  geom_point(
    data = data_quality[gen < 50, ],
    aes(
      x = gen,
      y = cf
    ),
    colour = "dodgerblue4",
    shape = 1,
    stroke = 0.5,
    show.legend = F
  ) +
  theme_classic(base_size = 8) +
  coord_cartesian(
    ylim = c(-0.5, 0.5),
    xlim = c(0, 50),
    expand = F
  ) +
  xlim(0, 50) +
  labs(
    x = "Generation",
    y = "Corr. # indivs. ~ cell quality"
  )

#'
#'
#' prepare landscape at 0 and 25
#'
## -----------------------------------------------------------------------------
# get landscape data
data_land <- fread("data_sim/results/data_landscape_item_count_1_50.csv")
data_land <- data_land[sim_type == "facultative" & regrowth == 0.01, ]

# get agents
data_agent <- fread("data_sim/results/data_agent_count_1_50.csv")
data_agent <- data_agent[sim_type == "facultative" & regrowth == 0.01, ]

#'
#' plot landscape facultative model
#'
## -----------------------------------------------------------------------------
fig_land_conditional <-
  ggplot(data_land) +
  geom_tile(aes(x, y, fill = items)) +
  geom_point(
    data = data_agent[agents > 0, ],
    aes(x, y, colour = agents),
    shape = 4,
    size = 0.5,
    stroke = 1,
    alpha = 0.8
  ) +
  facet_grid(~gen,
    labeller = label_both
  ) +
  scale_fill_continuous_sequential(
    palette = "Blues",
    begin = 0.1,
    limits = c(1, NA),
    na.value = "white",
    name = "# Prey",
    guide = guide_legend(order = 1)
  )+
  scale_colour_continuous_sequential(
    palette = "Reds",
    begin = 0.2,
    limits = c(1, 5),
    na.value = "darkred",
    name = "# Consumers",
    guide = guide_legend(order = 2)
  )+
  coord_equal(expand = F) +
  kleptomoveMS::theme_custom(landscape = T, base_size = 6) +
  theme(legend.position = "bottom")

#'
#' ## Figure 4 Conditional model
#'
#' wrap figures together
#'
## -----------------------------------------------------------------------------
figure_4 <-
  wrap_plots(
    fig_activity, fig_intake,
    fig_matching_quality
  ) +
  plot_layout(guides = "collect") &
  theme(
    legend.position = "bottom"
  )

figure_4 =
  wrap_plots(
    fig_land_conditional,
    figure_4,
    ncol = 1
  ) +
  plot_annotation(
    tag_levels = "A"
  ) &
  theme(
    plot.tag = element_text(
      face = "bold",
      size = 12
    )
  )

#'
#' save figure
#'
## -----------------------------------------------------------------------------
ggsave(
  figure_4,
  filename = "figures/fig_04.png",
  height = 120, width = 150, units = "mm"
)

#'
