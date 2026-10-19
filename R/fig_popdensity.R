#' Generate cloropleth of Swedish population densities
#'
#' This function creates a cloropleth of municipal population densities in Sweden
#'
#'
#' @param population_data Swedish municipal population-density data.
#' @return A ggplot2 object
#' @import ggplot2 dplyr
#' @export
#'
#' @examples
#' fig_popdensity()
fig_popdensity <- function(population_data = pop_densities){
  population_data |> ggplot() + geom_sf(aes(fill = cut(density, c(0, 10, 100, 1000000),
                                                   labels = c("Low", "Medium", "High"))),
                                    color = NA) +
    labs(fill = "", title = "Human population density") +
    scale_fill_viridis_d() + theme_void()
}
