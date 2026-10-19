#' Generate a visualisation of decadal spatial distribution of samples
#'
#' This function creates a map of samp+le locations
#'
#' @param otters_data Cleaned Swedish otter data.
#' @param perch_data Cleaned Swedish perch data.
#' @param no_otters_data Cleaned Norwegian otter data.
#' @param dk_otters_data Cleaned Danish otter data.
#'
#' @return A `ggplot` object representing the spatial distribution of samples
#'
#' @examples
#' \dontrun{
#' fig_distribution()
#' }
#'
#' @import sf
#' @import ggplot2
#' @import dplyr
#' @import tidyr
#'
#'
#' @export
fig_distribution <- function(
  otters_data = otters,
  perch_data = perch,
  no_otters_data = no_otters,
  dk_otters_data = dk_otters
){
  data <- otters_data |> arrange(accnr, -value) |> slice(1, .by = accnr) |>  select(accnr, X, Y, year, long_name) |>
    mutate(period = cut(year, breaks = c(1969, 1979, 1989, 1999, 2009, 2020),
                        labels = c("1969-1979", "1980-1989", "1990-1999", "2000-2009", "2010-2020")))
  counts <- data |> count(period)

  data_perch <- perch_data |>
    select(lake, X, Y, year) |>
    distinct() |>
    mutate(period = cut(year, breaks = c(1969, 1979, 1989, 1999, 2009, 2020),
                        labels = c("1969-1979", "1980-1989", "1990-1999", "2000-2009", "2010-2020"))) |>
    sf::st_as_sf(coords = c("X", "Y"), crs = 3006)
  # data |> ggplot() + geom_sf(data = sweden) +
  #   geom_point(aes(x = X, y = Y), size = .8, color = "red", alpha = .8) +
  #   facet_wrap(~period, nrow = 1) + theme_void() +
  #   labs(x = "", y = "") +
  #   geom_text(data = counts, aes(x = quantile(data$X, .05), y = max(data$Y) * 1.01, label = paste0("n = ", n)))
  scandmap <- rnaturalearth::ne_countries(scale = 50, continent = "europe", returnclass = "sf") |>
    st_transform(crs = 3006) |> st_crop(c(xmin = -100000, xmax = 935000, ymin = 6050000, ymax = 7700000)) |>
    mutate(swe = ifelse(name == "Sweden", 0, 1))
  data |>
    bind_rows(no_otters_data |> select(X, Y) |> distinct() |> mutate(period = "2010-2020")) |>
    bind_rows(dk_otters_data |> select(X, Y) |> distinct() |> mutate(period = "2010-2020")) |>
    ggplot() + geom_sf(data = scandmap, aes(fill = name), alpha = .1) +
    geom_point(aes(x = X, y = Y), size = .5, color = "red", alpha = .8) +
    facet_wrap(~period, nrow = 1) + theme_void() +
    labs(x = "", y = "") +
    geom_text(data = counts, aes(x = quantile(data$X, .05) * .5, y = max(data$Y) * 1.01, label = paste0("n = ", n))) +
    scale_fill_manual(values = c("Sweden" = "blue", "Norway" = "green", "Denmark" = "red"), breaks = c("Sweden", "Norway", "Denmark")) +
    theme(legend.position = "bottom") +
    geom_point(data = no_otters_data |> select(X, Y) |> distinct() |> mutate(period = "2010-2020"), aes(x = X, y = Y), size = 3, pch = 21, color = "red") +
    labs(fill = "") + geom_sf(data = data_perch, color = "blue", size = .5)
}
