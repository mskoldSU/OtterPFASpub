env_flag <- function(name, default = FALSE) {
  default_value <- if (default) "true" else "false"
  value <- tolower(trimws(Sys.getenv(name, unset = default_value)))

  if (value %in% c("true", "1", "yes")) {
    return(TRUE)
  }
  if (value %in% c("false", "0", "no")) {
    return(FALSE)
  }

  stop(
    name,
    " must be one of: true, false, 1, 0, yes, or no."
  )
}

env_integer <- function(name, default) {
  value <- Sys.getenv(name, unset = as.character(default))
  result <- suppressWarnings(as.integer(value))

  if (is.na(result) || result < 1L) {
    stop(name, " must be a positive integer.")
  }

  result
}

load_rda_object <- function(path, object) {
  environment <- new.env(parent = emptyenv())
  loaded <- load(path, envir = environment)

  if (!(object %in% loaded)) {
    stop("Object '", object, "' was not found in ", path, ".")
  }

  environment[[object]]
}

fit_spatial_models <- function(otters) {
  otters |>
    dplyr::mutate(
      cens = ifelse(is_censored, log(value), -Inf),
      log_value = log(value)
    ) |>
    dplyr::filter(!(name %in% c("PFHxA", "PFHpA"))) |>
    dplyr::nest_by(name, long_name, group) |>
    dplyr::mutate(
      fit = list(
        mgcv::gam(
          log_value ~ s(X, Y, bs = "tp", k = 75) +
            s(decimal_date, k = 5) + age + sex,
          data = data,
          family = cenGAM::tobit1(left.threshold = data$cens)
        )
      )
    )
}

save_plot <- function(plot, path, width, height) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  ggplot2::ggsave(
    filename = path,
    plot = plot,
    width = width,
    height = height
  )
  normalizePath(path, winslash = "/", mustWork = TRUE)
}
fit_perch_long_models <- function(perch, otters) {
  perch |>
    dplyr::mutate(
      name = factor(name, levels = levels(otters$name)),
      long_name = factor(long_name, levels = levels(otters$long_name))
    ) |>
    dplyr::filter(name %in% c("PFDA", "PFUnDA", "PFDoDA", "PFTrDA", "PFOS")) |>
    dplyr::summarise(
      log_value = mean(log(value)),
      .by = c("name", "year", "long_name", "group")
    ) |>
    dplyr::arrange(year) |>
    dplyr::nest_by(name, long_name, group) |>
    dplyr::mutate(
      fit = list(mgcv::gam(log_value ~ s(year, k = 5), data = data))
    )
}
save_table <- function(table, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(table, path, row.names = FALSE, na = "")
  normalizePath(path, winslash = "/", mustWork = TRUE)
}

fit_perch_short_models <- function(perch, otters, first_year = 2010, last_year = 2020) {
  perch |>
    dplyr::mutate(
      name = factor(name, levels = levels(otters$name)),
      long_name = factor(long_name, levels = levels(otters$long_name))
    ) |>
    dplyr::filter(
      name %in% c("PFNA", "PFDA", "PFUnDA", "PFDoDA", "PFTrDA", "PFOS"),
      year >= first_year,
      year <= last_year
    ) |>
    dplyr::summarise(
      value = exp(mean(log(value))),
      .by = c("name", "long_name", "group", "lake", "year")
    ) |>
    dplyr::nest_by(name, long_name, group) |>
    dplyr::mutate(
      fit = list(lme4::lmer(log(value) ~ year + (1 | lake), data = data))
    )
}
