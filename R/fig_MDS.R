#' Generate MDS plot
#'
#' @param prediction_grid Spatial prediction grid.
#' @param spatial_models Fitted censored spatiotemporal models.
#' @param population_data Municipal population-density data.
#' @param precipitation_data Gridded precipitation normals.
#' @param group_colors Named colours for PFAS groups.
#' @return A ggplot2 object representing the plot.
#' @import ggplot2 dplyr mgcv sf tidyr
#' @importFrom stats cmdscale coef cor dist glm lm median pnorm predict quantile sd var
#' @export
#'
#' @examples
#' \dontrun{
#' fig_MDS()
#' }

fig_MDS <- function(
  prediction_grid = grid,
  spatial_models = spatial_fits,
  population_data = pop_densities,
  precipitation_data = precipitation_data,
  group_colors = color_groups
){
  grid_data <- prediction_grid |>
    mutate(sex = "M",
           age = "Adult",
           decimal_date = 2015,
           pos = 1:nrow(prediction_grid))

  contaminants <- spatial_models |>
    filter(name != "BB") |>
    mutate(pred = list(grid_data |> mutate(pred = predict(fit, newdata = grid_data) |> as.numeric()))) |>
    unnest(pred) |>
    ungroup() |>
    mutate(value = (pred - mean(pred)) / sd(pred), .by = "long_name") |>
    select(long_name, group, pos, value)

  population <- grid_data |>
    sf::st_as_sf(coords = c("X", "Y"), crs = sf::st_crs(population_data)) |>
    st_join(population_data) |>
    as_tibble() |>
    mutate(long_name = "Population density",
           group = "External",
           value = (log(density) - mean(log(density))) / sd(log(density))
    ) |>
    select(long_name, group, pos, value)

  precipitation_fit <- gam(log(precip) ~ s(X, Y, bs = "tp", k = 100),
                           data = precipitation_data
  )

  precip <- grid_data |>
    mutate(precip = predict(precipitation_fit, newdata = grid_data)) |>
    mutate(long_name = "Precipitation",
           group = "External",
           value = (log(precip) - mean(log(precip))) / sd(log(precip))
    ) |>
    select(long_name, group, pos, value)

  wide_data <- bind_rows(
    contaminants,
    population,
    precip
  ) |>
    pivot_wider(names_from = pos, values_from = value)

  mds <- wide_data |>
    select(-long_name, -group) |>
    as.matrix() |>
    dist() |>
    cmdscale() |>
    as.data.frame() |>
    mutate(long_name = wide_data$long_name,
           group = wide_data$group)
  # Plot MDS
  ggplot(mds, aes(x = V1, y = V2, color = group, label = long_name)) +
    #ggrepel::geom_text_repel(show.legend = FALSE) +
    geom_text(hjust = 0, aes(x = V1 + .5), size = 3, show.legend = FALSE) +
    geom_point(show.legend = FALSE) +
    labs(title = "MDS of spatial fits and external data sources",
         x = "MDS Dimension 1",
         y = "MDS Dimension 2") +
    theme_bw() +
    theme(panel.grid = element_blank()) +
    scale_color_manual(values = c(group_colors, External = "black")) +
    coord_cartesian(xlim = c(NA, 29))

}
