#' Table of Short-Term Trends
#'
#' This function generates a table of short-term trends in concentration levels
#' over a specified period. It estimates yearly percentage change based on model
#' predictions and quantifies uncertainty with confidence intervals.
#'
#' @param first_year Numeric. The starting year for the trend analysis (default: 2010).
#' @param last_year Numeric. The ending year for the trend analysis (default: 2020).
#' @param spatial_models Fitted censored spatiotemporal models.
#' @return A table with yearly concentration changes and confidence intervals.
#' @import ggplot2 dplyr tibble scales
#' @export
tab_short_trends <- function(first_year = 2010, last_year = 2020, spatial_models = spatial_fits){
  range <- last_year - first_year
  spatial_models |> mutate(Xp = list(predict(fit, newdata = tibble(X = mean(data$X),
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
                         lower = (exp(diff_estimate - diff_se * 1.96)^(1 / range) - 1),
                         p_value = (2 * pnorm(-abs(diff_estimate / diff_se))) |> scales::pvalue()
  ) |>
    ungroup() |>
    select(long_name, diff, lower, upper, p_value) |>
    mutate(yearly_rate = scales::percent(diff, accuracy = 0.1),
           lower = scales::percent(lower, accuracy = 0.1),
           upper = scales::percent(upper, accuracy = 0.1),
           conf_interval = paste0("(", lower, ", ", upper, ")"),
           term = "Yearly rate"
           ) |>
    select(long_name, term, effect = yearly_rate, conf_interval, p_value)
}
