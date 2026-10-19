prepare_proportion_data <- function(otters) {
  otters |>
    dplyr::filter(group %in% c("FOSA", "PFCA", "PFSA")) |>
    dplyr::summarise(
      value = sum(value, na.rm = TRUE),
      .by = c(accnr, decimal_date, X, Y, group, age, sex, year)
    ) |>
    dplyr::mutate(n_groups = dplyr::n(), .by = accnr) |>
    dplyr::filter(n_groups == 3L) |>
    dplyr::select(-n_groups)
}

resample_proportion_data <- function(data) {
  data |>
    dplyr::nest_by(accnr, year) |>
    dplyr::ungroup() |>
    dplyr::group_by(year) |>
    dplyr::slice_sample(prop = 1, replace = TRUE) |>
    tidyr::unnest(data) |>
    dplyr::ungroup()
}

fit_proportion_models <- function(data) {
  data |>
    dplyr::nest_by(group) |>
    dplyr::mutate(
      fit = list(
        mgcv::gam(
          log(value) ~ s(X, Y, bs = "tp", k = 75) +
            s(decimal_date, k = 5) + age + sex,
          data = data
        )
      )
    )
}

proportion_prediction_grid <- function(sweden) {
  grid <- sf::st_make_grid(
    sweden,
    what = "centers",
    cellsize = 10000
  )
  grid <- grid[sweden]

  sf::st_coordinates(grid) |>
    tibble::as_tibble() |>
    dplyr::mutate(
      decimal_date = 2010,
      age = "Adult",
      sex = "M"
    )
}

predict_proportion_trends <- function(fits, sweden) {
  aggregate_grid <- proportion_prediction_grid(sweden)

  fits |>
    dplyr::mutate(
      predictions = list(
        tibble::tibble(
          decimal_date = 1970:2020,
          X = mean(data$X),
          Y = mean(data$Y),
          age = "Adult",
          sex = "M"
        )
      ),
      predictions = list(
        dplyr::mutate(
          predictions,
          temporal_effect = predict(
            fit,
            newdata = predictions,
            type = "terms"
          )[, "s(decimal_date)"]
        )
      ),
      level_2010 = mean(exp(predict(fit, newdata = aggregate_grid))),
      temporal_2010 = exp(
        predict(
          fit,
          newdata = tibble::tibble(
            X = mean(data$X),
            Y = mean(data$Y),
            decimal_date = 2010,
            age = "Adult",
            sex = "M"
          ),
          type = "terms"
        )[, "s(decimal_date)"]
      ),
      scale_factor = level_2010 / temporal_2010,
      predictions = list(
        dplyr::mutate(
          predictions,
          concentration = exp(temporal_effect) * scale_factor
        )
      )
    ) |>
    dplyr::select(group, predictions) |>
    tidyr::unnest(predictions) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      proportion = concentration / sum(concentration),
      .by = decimal_date
    )
}

bootstrap_proportion_trends <- function(data, sweden, n_boot = 1000L) {
  results <- lapply(seq_len(n_boot), function(iteration) {
    data |>
      resample_proportion_data() |>
      fit_proportion_models() |>
      predict_proportion_trends(sweden) |>
      dplyr::mutate(bootstrap = iteration)
  })

  dplyr::bind_rows(results)
}

prepare_proportion_comparisons <- function(dk_otters, no_otters) {
  dk_data <- dk_otters |>
    tibble::as_tibble() |>
    dplyr::filter(group %in% c("FOSA", "PFCA", "PFSA")) |>
    dplyr::summarise(value = sum(value), .by = c(group, accnr)) |>
    dplyr::summarise(value = exp(mean(log(value))), .by = group) |>
    dplyr::mutate(
      proportion = value / sum(value),
      decimal_date = 2014.5,
      site = "dk"
    )

  no_data <- no_otters |>
    tibble::as_tibble() |>
    dplyr::filter(group %in% c("FOSA", "PFCA", "PFSA")) |>
    dplyr::summarise(value = sum(value), .by = c(X, group)) |>
    dplyr::mutate(
      decimal_date = ifelse(X < 0, 2010, 2018),
      site = ifelse(X < 0, "no_s", "no_n")
    ) |>
    dplyr::mutate(proportion = value / sum(value), .by = site)

  dplyr::bind_rows(dk_data, no_data)
}

fig_proportion_trends <- function(
  trends,
  bootstrap_trends,
  comparisons,
  color_groups
) {
  plot <- ggplot2::ggplot(
    trends,
    ggplot2::aes(x = decimal_date, color = group)
  )

  if (!is.null(bootstrap_trends)) {
    ribbon_data <- bootstrap_trends |>
      dplyr::summarise(
        upper = stats::quantile(proportion, 0.975, na.rm = TRUE),
        lower = stats::quantile(proportion, 0.025, na.rm = TRUE),
        .by = c(decimal_date, group)
      )

    plot <- plot + ggplot2::geom_ribbon(
      data = ribbon_data,
      ggplot2::aes(ymin = lower, ymax = upper, fill = group),
      alpha = 0.5,
      color = NA
    )
  }

  plot +
    ggplot2::geom_line(ggplot2::aes(y = proportion), linewidth = 1) +
    ggplot2::geom_point(
      data = comparisons,
      ggplot2::aes(
        x = decimal_date,
        y = proportion,
        color = group,
        shape = site
      ),
      size = 3,
      show.legend = FALSE,
      alpha = 0.7
    ) +
    ggplot2::theme_bw() +
    ggplot2::scale_y_continuous(
      labels = scales::percent,
      limits = c(0, 1),
      expand = ggplot2::expansion(c(0, 0))
    ) +
    ggplot2::scale_x_continuous(
      limits = c(1970, 2020),
      expand = ggplot2::expansion(c(0.01, 0.01))
    ) +
    ggplot2::scale_color_manual(values = color_groups) +
    ggplot2::scale_fill_manual(values = color_groups) +
    ggplot2::scale_shape_manual(
      values = c(dk = 16, no_n = 15, no_s = 17)
    ) +
    ggplot2::labs(
      x = "",
      y = "Proportion of geometric means",
      fill = "",
      color = ""
    ) +
    ggplot2::theme(
      legend.position = "inside",
      legend.position.inside = c(0.90, 0.95),
      legend.background = ggplot2::element_rect(
        fill = "transparent",
        color = NA
      )
    )
}
