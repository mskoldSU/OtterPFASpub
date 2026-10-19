#' Generate map of yearly precipitation
#'
#'
#'
#' @param sweden_geometry Sweden boundary geometry.
#' @param precipitation_data Gridded precipitation normals.
#' @return A ggplot2 object
#' @import ggplot2 dplyr sf mgcv
#' @export
#'
#' @examples
#' fig_precip()
fig_precip <- function(
  sweden_geometry = sweden,
  precipitation_data = precipitation
){
  bbox <- st_bbox(sweden_geometry) + c(-10000, -10000 ,10000, 10000)
  cover <- st_difference(st_as_sfc(bbox), sweden_geometry)
  fit <- gam(log(precip) ~ s(X, Y, bs = "tp", k = 100),
             data = precipitation_data)
  plot_data <- expand_grid(X = seq(bbox$xmin, bbox$xmax, length.out = 50),
                           Y = seq(bbox$ymin, bbox$ymax, length.out = 100)) |>
    mutate(value = predict(fit, newdata = tibble(X = X, Y = Y)) |> exp())
  breaks <- seq(400, 1300, by = 100)
  plot_data |>
    ggplot() +
    geom_contour_filled(aes(x = X, y = Y, z = value),
                        breaks = breaks) +
    geom_sf(data = cover, fill = "white", color = "white") +
    theme_void() +
    labs(fill = "",title = "Yearly precipitation (mm)")
}
