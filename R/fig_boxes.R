#' Generate boxplot of PFAS Concentrations
#'
#' This function creates a boxplot of PFAS concentrations in otters,
#' including additional data points from Danish and Norwegian otters.
#'
#' @param start_year Start year
#' @param end_year End year
#' @param otters_data Cleaned Swedish otter data.
#' @param dk_otters_data Cleaned Danish otter data.
#' @param no_otters_data Cleaned Norwegian otter data.
#' @param group_colors Named colours for PFAS groups.
#'
#' @return A ggplot2 object representing the boxplot.
#' @import ggplot2 dplyr
#' @export
#'
#' @examples
#' fig_boxes()
fig_boxes <- function(
  start_year = 2000,
  end_year = 2020,
  otters_data = otters,
  dk_otters_data = dk_otters,
  no_otters_data = no_otters,
  group_colors = color_groups
){
  homologues <- c("PFOA", "PFNA", "PFDA", "PFUnDA", "PFDoDA", "PFTrDA", "PFTeDA", "PFPeDA", "PFOS", "PFHxS", "FOSA")
  homologues <- levels(otters_data$name)
  otters_data |> filter(decimal_date >= start_year, decimal_date < end_year + 1, name %in%  homologues)  |>
    ggplot(aes(x = long_name, y = value)) +
    geom_boxplot(aes(fill = group), coef = Inf, alpha = .7, color = "grey30") +
    geom_point(data = dk_otters_data |> filter(name %in%  homologues), pch = 1, position = position_nudge(x = .2)) +
    geom_point(data = no_otters_data |> filter(name %in%  homologues, X > 0), pch = 0, position = position_nudge(x = -.2)) +
    geom_point(data = no_otters_data |> filter(name %in%  homologues, X < 0), pch = 2, position = position_nudge(x = -.2)) +
    theme_bw() + labs(x = "", y = "Concentration (ng/g ww)") +
    scale_y_log10(
      labels = c("0.1", 1, 10, 100, "1 000", "10 000"),
      breaks = c(0.1, 1, 10, 100, 1000, 10000)
    ) + coord_flip(ylim = c(.1, NA)) +
    theme(panel.grid.minor.x = element_blank(),
          panel.grid = element_blank(),
          legend.position = "inside",
          legend.position.inside = c(.85, .2),
          legend.background = element_rect(fill = "transparent", color = NA)) +
    labs(fill = "") +
    scale_fill_manual(values = group_colors)
}




