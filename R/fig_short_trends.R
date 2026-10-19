#' Plot Short-Term Trends
#'
#' This function generates a plot of short-term trends in concentration levels
#' over a specified period. It estimates yearly percentage change based on model
#' predictions and visualizes the results with confidence intervals.
#'
#' @param first_year Numeric. The starting year for the trend analysis (default: 2010).
#' @param last_year Numeric. The ending year for the trend analysis (default: 2020).
#' @param perch_data Cleaned Swedish perch data.
#' @param spatial_models Fitted censored spatiotemporal models.
#' @param group_colors Named colours for PFAS groups.
#' @return A ggplot object displaying yearly concentration changes with confidence intervals.
#' @import ggplot2 dplyr tibble scales
#' @export
fig_short_trends <- function(
  first_year = 2010,
  last_year = 2020,
  perch_data = perch,
  spatial_models = spatial_fits,
  group_colors = color_groups
){
  range <- last_year - first_year
  perch_plot_data <- perch_data |>
    mutate(long_name = factor(long_name, spatial_models$long_name)) |>
    filter(name %in% c("PFNA", "PFDA", "PFUnDA", "PFDoDA", "PFTrDA", "PFOS"),
           year %in% (first_year):last_year) |>
    summarise(value = exp(mean(log(value))),
              .by = c("name", "long_name", "group", "lake", "year")) |>
    nest_by(name, long_name, group) |>
    mutate(fit = list(lme4::lmer(log(value) ~ year + (1 | lake), data = data)),
           results = list(broom.mixed::tidy(fit, conf.int = TRUE, conf.level = 0.95) |> select(-group))) |>
    unnest(results) |>
    filter(term == "year") |>
    mutate(
      diff = exp(estimate) - 1,
      conf.low = exp(conf.low) - 1,
      conf.high = exp(conf.high) - 1,
    )


  plot_data <- spatial_models |>
    mutate(
      long_name = factor(long_name, spatial_models$long_name),
      Xp = list(predict(fit, newdata = tibble(X = mean(data$X),
                                                   Y = mean(data$Y),
                                                   decimal_date = c(last_year, first_year),
                                                   age= "Adult",
                                                   sex = "M"),
                             type = "lpmatrix")),
           diff_estimate = as.numeric(Xp[1, ] %*% coef(fit) - Xp[2, ] %*% coef(fit)),
           Vc = list(stats::vcov(fit)),
           diff_se = as.numeric(sqrt(t(Xp[1, ] - Xp[2, ]) %*% Vc %*% (Xp[1, ] - Xp[2, ]))),
           diff = (exp(diff_estimate)^(1 / range) - 1),
           upper = (exp(diff_estimate + diff_se * 1.96)^(1 / range) - 1),
           lower = (exp(diff_estimate - diff_se * 1.96)^(1 / range) - 1)
    )
  plot_data  |>  mutate(long_name = factor(long_name, plot_data$long_name)) |>
    ggplot(aes(x = long_name, y = diff, color = group)) +
    geom_point(size = 3) +
    geom_linerange(aes(ymin = lower, ymax = upper), linewidth = 2, alpha = .5) +
    labs(x = "", y = paste("Yearly change in concentration", first_year, "-", last_year), color = "") +
    theme_bw() + scale_y_continuous(labels = scales::percent) + coord_flip() +
    geom_hline(yintercept = 0, linetype = "dashed") +
    theme(legend.position = "inside",
          legend.position.inside = c(.2, .2),
          legend.background = element_rect(fill = "transparent", color = NA),
          panel.grid = element_blank()
    ) + scale_color_manual(values = group_colors) +
    geom_linerange(data = perch_plot_data,
                   aes(x = as.numeric(long_name) + .2, ymin = conf.low, ymax = conf.high)) +
    geom_point(data = perch_plot_data, aes(x = as.numeric(long_name) + .2))
}
