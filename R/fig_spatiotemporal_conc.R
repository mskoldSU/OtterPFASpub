#' Generate a Spatiotemporal Visualization of Contaminant Predictions
#'
#' This function creates a map of contaminant concentrations
#' using spatial data and predictive modeling.
#'
#' @param contaminant Character. The name of the contaminant to visualize.
#'   Default is `"PFOS"`.
#' @param prediction_year Numeric. The year for which predictions should be
#'   visualized. Default is `2015`.
#'
#' @param spatial_models Fitted censored spatiotemporal models.
#' @param sweden_geometry Sweden boundary geometry.
#' @param otters_data Cleaned Swedish otter data.
#' @param dk_otters_data Cleaned Danish otter data.
#' @param no_otters_data Cleaned Norwegian otter data.
#' @param prediction_grid Spatial prediction grid.
#' @param scandinavia_map Scandinavian map data.
#' @param jutland_geometry Jutland boundary geometry.
#' @param pfas_metadata PFAS compound metadata.
#'
#' @return A `ggplot` object representing the spatial distribution of the
#'   contaminant for the given year.
#'
#' @examples
#' \dontrun{
#' fig_spatiotemporal_conc(contaminant = "PFOA", prediction_year = 2015)
#' }
#'
#' @import sf
#' @import ggplot2
#' @import dplyr
#' @import tidyr
#' @importFrom ggspatial annotation_scale
#'
#'
#' @export
fig_spatiotemporal_conc <- function(
  contaminant = "PFOS",
  prediction_year = 2015,
  spatial_models = spatial_fits,
  sweden_geometry = sweden,
  otters_data = otters,
  dk_otters_data = dk_otters,
  no_otters_data = no_otters,
  prediction_grid = grid,
  scandinavia_map = scandinavia,
  jutland_geometry = jutland,
  pfas_metadata = PFAS
){

  fit <- spatial_models$fit[[which(spatial_models$name == contaminant)]]


  # Maps
  bbox <- st_bbox(sweden_geometry) + c(-10000, -10000 ,10000, 10000)
  cover <- st_difference(st_as_sfc(bbox), sweden_geometry)

  # Data
  data <- otters_data |>
    filter(contaminant == name)
  dk_data <- dk_otters_data |> filter(contaminant == name)
  no_data <- no_otters_data |> filter(contaminant == name)
  dk_value <-mean(log(dk_data$value)) |> exp()

  # Colors
  breaks <- c(median(dk_data$value), ifelse(min(no_data$value) == Inf, NA, min(no_data$value)) ,
              predict(fit, newdata = prediction_grid |> mutate(decimal_date = prediction_year,
                                                    age= "Adult",
                                                    sex = "M")) |>
                exp()) |>
    quantile((0:10)/10, na.rm = TRUE)
  breaks <- exp(seq(log(min(breaks)), log(max(breaks)), length.out = 11)) |> signif(2)
  fill_scale <- scale_fill_viridis_d(drop = FALSE)
  color_palette <- fill_scale$palette(length(breaks) - 1)
  dk_bin <- findInterval(dk_value, breaks, rightmost.closed = TRUE)|> pmax(1)
  no_bin <- findInterval(no_data$value, breaks, rightmost.closed = TRUE) |> pmax(1)
  dk_color <- color_palette[dk_bin]
  no_color <- color_palette[no_bin]

  # Sweden values
  plot_data <- expand_grid(X = seq(bbox$xmin, bbox$xmax, length.out = 50),
                           Y = seq(bbox$ymin, bbox$ymax, length.out = 100)) |>
    mutate(value = predict(fit, newdata = tibble(X = X, Y = Y, decimal_date = prediction_year,
                                                 age= "Adult",
                                                 sex = "M")) |> exp()) |>
    mutate(value = pmax(value, min(breaks) * 1.0001),
           value = pmin(value, max(breaks) * .9999))
  plot_data$value[1:2] <- range(no_data$value)
  plot_data$value[3] <- dk_value

  # Plot
  plot_data |>
    ggplot() +
    geom_contour_filled(aes(x = X, y = Y, z = value),
                        breaks = breaks) +
    geom_sf(data = cover, fill = "white", color = "white") +
    geom_sf(data = scandinavia_map, color = "white", aes(alpha = swe), fill = "grey", show.legend = FALSE, linewidth = 0) +
    geom_sf(data = jutland_geometry, fill = dk_color, color = "white", linewidth = 0) +
    geom_point(data = data, aes(x = X, y = Y), size = .1, color = "red") +
    geom_point(data = dk_data, aes(x = X, y = Y), size = .1, color = "red") +
    geom_point(data = no_data, aes(x = X, y = Y), size = 5, shape = 21, fill = no_color) +
    geom_point(data = no_data, aes(x = X, y = Y), size = .1, color = "red") +
    scale_fill_viridis_d(drop = FALSE) +
    theme_void() +
    labs(fill = "Concentration (ng/g ww)", title = pfas_metadata$long_name[pfas_metadata$name == contaminant]) +
    theme(legend.position = "inside",
          legend.position.inside = c(.19, .78),
          panel.background = element_rect(fill = "white", color = NA),
          plot.background = element_rect(fill = "white", color = NA)
    ) +
    ggspatial::annotation_scale(pad_x = grid::unit(7, "cm"), pad_y = grid::unit(1, "cm"))
}
