#' Table of age and sex effects
#'
#' This function generates a table of age and sex effects
#'
#' @param spatial_models Fitted censored spatiotemporal models.
#'
#' @return A table with effects and confidence intervals.
#' @import ggplot2 dplyr tibble scales
#' @export
tab_sex_age <- function(spatial_models = spatial_fits){
spatial_models |> mutate(results = list(broom::tidy(fit, parametric = TRUE, conf.int = TRUE) |> filter(term %in% c("ageSubadult", "sexM")))) |>
    unnest(results) |>
    mutate(effect = (exp(estimate) - 1) |> scales::percent(accuracy = 0.1),
           conf.low = exp(conf.low) - 1,
           conf.high = exp(conf.high) - 1,
           conf_interval = paste0("(", scales::percent(conf.low, accuracy = 0.1), ", ",
                             scales::percent(conf.high, accuracy = 0.1), ")"),
           p_value = scales::pvalue(p.value)) |>
    ungroup() |>
    select(long_name, term, effect, conf_interval, p_value)
}
