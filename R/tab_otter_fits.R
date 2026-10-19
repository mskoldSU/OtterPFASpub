#' Generate summary table for GAM fits
#'
#' @param spatial_models Fitted censored spatiotemporal models.
#'
#
#' @return A table
#'
#' @examples
#' \dontrun{
#' tab_otter_fits()
#' }
#'
#' @import dplyr
#' @import tidyr
#'
#' @export
#'
tab_otter_fits <- function(spatial_models = spatial_fits){
  spatial_models |> mutate(space_edf = summary(fit)[["s.table"]][1, 1]|> round(1),
                         time_edf = summary(fit)[["s.table"]][2, 1]|> round(1),
                       space_p = summary(fit)[["s.table"]][1, 4] |> scales::pvalue(),
                       time_p = summary(fit)[["s.table"]][2, 4]|> scales::pvalue(),
                       r2 = summary(fit)[["r.sq"]]|> round(2),
                       n = nrow(data),
                       cens_prop = mean(data$is_censored) |> scales::percent(accuracy = 0.1),
                       cens_prop = ifelse(name == "BB", "-", cens_prop),
                       res_var = var(fit$residuals)|> round(2),
                       log_range_spat = (max(predict(fit, newdata = data |> mutate(decimal_date = 2015)) |> exp() |> log10()) -
                         min(predict(fit, newdata = data |> mutate(decimal_date = 2015))|> exp() |> log10())) |> round(2),
                       log_range_temp = (max(predict(fit, newdata = data |> mutate(X = mean(X), Y = mean(Y))) |> exp() |> log10()) -
                         min(predict(fit, newdata = data |> mutate(X = mean(X), Y = mean(Y)))|> exp() |> log10())) |> round(2)
) |> ungroup() |>
  select(Homologue = long_name, n, `Censored proportion` = cens_prop,
           `Space EDF` = space_edf,
           `Time EDF` = time_edf,
           `Space p-value` = space_p,
           `Time p-value` = time_p,
           `R Squared` = r2,
           `Residual variance` = res_var,
         `Spatial log10-range` = log_range_spat,
         `Temporal log10-range` = log_range_temp)
}
