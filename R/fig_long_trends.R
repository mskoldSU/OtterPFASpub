fig_long_trends <- function(
  sweden_geometry = sweden,
  spatial_models = spatial_fits,
  dk_otters_data = dk_otters,
  no_otters_data = no_otters,
  perch_models = perch_long_fit,
  group_colors = color_groups
){
  #' Plot Long-Term Trends
  #'
  #' This function generates a plot of long-term trends in concentration levels
  #' based on spatial fits. It estimates values and standard errors using model
  #' predictions and visualizes them with confidence intervals.
  #'
  #' @param sweden_geometry Sweden boundary geometry.
  #' @param spatial_models Fitted censored spatiotemporal models.
  #' @param dk_otters_data Cleaned Danish otter data.
  #' @param no_otters_data Cleaned Norwegian otter data.
  #' @param perch_models Fitted long-term perch GAMs.
  #' @param group_colors Named colours for PFAS groups.
  #' @return A ggplot object displaying concentration trends over time with confidence intervals.
  #' @import ggplot2 dplyr tidyr tibble
  #' @export
  agg_grid <- st_make_grid(sweden_geometry, what = "centers", cellsize = 10000)[sweden_geometry] |>
    st_coordinates() |> as_tibble() |>
    mutate(decimal_date = 2010,
           age= "Adult",
           sex = "M")

  plot_data <- spatial_models |> mutate(newdata = list(tibble(decimal_date = 1970:2020,
                                                            X = mean(data$X),
                                                            Y = mean(data$Y),
                                                            age= "Adult",
                                                            sex = "M")),
                                      newdata = list(newdata |> mutate(value = predict(fit, newdata = newdata, type = "terms")[, "s(decimal_date)"],
                                                                       se = predict(fit, newdata = newdata, se = TRUE, type = "terms")$se.fit[, "s(decimal_date)"])),
                                      level_2010 = predict(fit, newdata = agg_grid) |> exp() |> mean(),
                                      fitted_2010 = predict(fit, newdata = tibble(X = mean(data$X),
                                                                                  Y = mean(data$Y),
                                                                                  decimal_date = 2010,
                                                                                  age= "Adult",
                                                                                  sex = "M"), type = "terms")[, "s(decimal_date)"] |> exp(),
                                      factor = level_2010 / fitted_2010

  ) |>
    select(-fit, -data) |>
    unnest(newdata) |>
    mutate(conc = exp(value) * factor,
           upper = exp(value + se * 1.96) * factor,
           lower = exp(value - se * 1.96) * factor)
  external_data <- bind_rows(
    dk_otters_data |> as_tibble() |>
      summarise(conc = mean(log(value)) |> exp(), .by = c("long_name", "group", "name")) |>
      mutate(decimal_date = 2014.5, site = "dk"),
    no_otters_data |>
      rename(conc = value) |>
      mutate(decimal_date = ifelse(X < 0, 2010, 2018),
             site = ifelse(X < 0, "no_s", "no_n"))
  )

  perch_plot_data <- perch_models |>
    left_join(plot_data |> summarise(otter_max = max(conc, .by = name))) |>
    mutate(data = list(data |> mutate(value = exp(predict(fit)),
                                      conc = value / max(value) * otter_max))) |>
    unnest(data)

  plot_data |>
    mutate(long_name = factor(long_name, c( "PFHxA (C6)", "PFHpA (C7)", "PFOA (C8)", "PFNA (C9)",
                                            "PFDA (C10)", "PFUnDA (C11)", "PFDoDA (C12)", "PFTrDA (C13)",
                                            "PFTeDA (C14)", "PFPeDA (C15)", "PFBS (C4)", "PFHxS (C6)", "PFOS (C8)",
                                            "PFDS (C10)", "FOSA (C8)", "Total PFAS (PFOA-equiv.)"))) |>
    ggplot(aes(x = decimal_date, y = conc)) +
    geom_point(data = external_data, aes(shape = site, color = group), show.legend = FALSE) +
    geom_line(aes(color = group)) +
    geom_ribbon(aes(ymin = lower, ymax = upper, fill = group), alpha = 0.5) +
    facet_wrap(~long_name, scales = "free_y") +
    labs(x = "", y = "Concentration (ng/g ww)", fill = "", color = "") +
    theme_bw() + scale_y_continuous(limits = c(0, NA), expand = expansion(c(0, 0.05))) +
    theme(legend.position = "inside",
          legend.position.inside = c(.65, .1),
          legend.background = element_rect(fill = "transparent", color = NA),
          panel.grid = element_blank(),
          axis.text.x = element_text(size = rel(0.9))
    ) + scale_fill_manual(values = group_colors) +
    scale_color_manual(values = group_colors) +
    scale_shape_manual(values = c("dk" = 1, "no_n" = 0, "no_s" = 2)) +
    geom_line(data = perch_plot_data, aes(x = year, y = conc, color = group), linetype = "dashed")
}
