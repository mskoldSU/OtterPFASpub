#' Generate summary table for perch fits
#'
#' @param perch_mixed_models Fitted short-term perch mixed models.
#' @param perch_smooth_models Fitted long-term perch smooth models.
#'
#
#' @return A table
#'
#' @examples
#' \dontrun{
#' tab_perch_fits()
#' }
#'
#' @import dplyr
#' @import tidyr
#' @import lme4
#'
#' @export
#'
tab_perch_lmer_fits <- function(perch_mixed_models = perch_lmer_fits, perch_smooth_models = perch_gam_fits){
  results <- perch_mixed_models |> ungroup() |> select(-group) |> mutate(results = lapply(fit, broom.mixed::tidy, conf.int = TRUE)) |>
    unnest(results) |> ungroup()
  results_gam <- perch_smooth_models |>
    mutate(edf = summary(fit)[["s.table"]][1, 1],
           p.value = summary(fit)[["s.table"]][1, 4] |> scales::pvalue(),
           check = mean(predict(fit) < data$log_value)|> scales::percent(),
           n = nrow(data)) |> ungroup() |>
    select(Variable = long_name, `GAM EDF` = edf, `GAM p-value` = p.value, `GAM Positive residuals`= check)
results |> filter(term == "year") |>
  left_join(results |> filter(group == "lake") |> select(long_name, var_lake = estimate), by = "long_name") |>
  left_join(results |> filter(group == "Residual") |> select(long_name, var_res = estimate), by = "long_name") |>
  mutate(slope = (exp(estimate) - 1) |> scales::percent(accuracy = 0.1),
         lower = exp(conf.low) - 1,
         upper = exp(conf.high) - 1,
         conf_interval = paste0("(", scales::percent(lower, accuracy = 0.1), ", ",
                                scales::percent(upper, accuracy = 0.1), ")"),
         p.value = 2 * stats::pnorm(-abs(statistic)),
         p.value = scales::pvalue(p.value, accuracy = 0.001)
         ) |>
  select(Variable = long_name, Trend = slope, `Trend conf.int.` = conf_interval,
         `Trend p-value` = p.value, `Variance Rand.eff.` = var_lake, `Variance residuals` = var_res) |>
  left_join(results_gam, by = "Variable")
}
