library(targets)

tar_option_set(
  packages = c(
    "cenGAM",
    "dplyr",
    "ggplot2",
    "mgcv",
    "patchwork",
    "scales",
    "sf",
    "tibble",
    "tidyr"
  ),
  seed = 2611182L
)

tar_source("R")

run_proportion_bootstrap <- env_flag(
  "OTTERPFAS_RUN_PROPORTIONS",
  default = FALSE
)

base_targets <- list(
  tar_target(
    proportion_bootstrap_enabled,
    run_proportion_bootstrap
  ),
  tar_target(
    otters_file,
    "data/otters.rda",
    format = "file"
  ),
  tar_target(
    perch_file,
    "data/perch.rda",
    format = "file"
  ),
  tar_target(
    dk_otters_file,
    "data/dk_otters.rda",
    format = "file"
  ),
  tar_target(
    no_otters_file,
    "data/no_otters.rda",
    format = "file"
  ),
  tar_target(
    sweden_file,
    "data/sweden.rda",
    format = "file"
  ),
  tar_target(
    color_groups_file,
    "data/color_groups.rda",
    format = "file"
  ),
  tar_target(
    pfas_file,
    "data/PFAS.rda",
    format = "file"
  ),
  tar_target(
    grid_file,
    "data/grid.rda",
    format = "file"
  ),
  tar_target(
    jutland_file,
    "data/jutland.rda",
    format = "file"
  ),
  tar_target(
    pop_densities_file,
    "data/pop_densities.rda",
    format = "file"
  ),

  tar_target(
    precipitation_file,
    "data/precipitation.rda",
    format = "file"
  ),
  tar_target(
    scandinavia_file,
    "data/scandinavia.rda",
    format = "file"
  ),
  tar_target(
    otters,
    load_rda_object(otters_file, "otters")
  ),
  tar_target(
    perch,
    load_rda_object(perch_file, "perch")
  ),
  tar_target(
    dk_otters,
    load_rda_object(dk_otters_file, "dk_otters")
  ),
  tar_target(
    no_otters,
    load_rda_object(no_otters_file, "no_otters")
  ),
  tar_target(
    sweden,
    load_rda_object(sweden_file, "sweden")
  ),
  tar_target(
    color_groups,
    load_rda_object(color_groups_file, "color_groups")
  ),
  tar_target(
    PFAS,
    load_rda_object(pfas_file, "PFAS")
  ),
  tar_target(
    grid,
    load_rda_object(grid_file, "grid")
  ),
  tar_target(
    jutland,
    load_rda_object(jutland_file, "jutland")
  ),
  tar_target(
    pop_densities,
    load_rda_object(pop_densities_file, "pop_densities")
  ),

  tar_target(
    precipitation,
    load_rda_object(precipitation_file, "precipitation")
  ),
  tar_target(
    scandinavia,
    load_rda_object(scandinavia_file, "scandinavia")
  ),
  tar_target(
    spatial_fits,
    fit_spatial_models(otters)
  ),
  tar_target(
    perch_long_fit,
    fit_perch_long_models(perch, otters)
  ),
  tar_target(
    perch_short_fits,
    fit_perch_short_models(perch, otters)
  ),
  tar_target(
    figure_1_plot,
    fig_distribution(
      otters_data = otters,
      perch_data = perch,
      no_otters_data = no_otters,
      dk_otters_data = dk_otters
    )
  ),
  tar_target(
    figure_1_file,
    save_plot(
      figure_1_plot,
      "figs/figure1.pdf",
      width = 7,
      height = 3
    ),
    format = "file"
  ),
  tar_target(
    figure_2_plot,
    fig_boxes(
      start_year = 2010,
      otters_data = otters,
      dk_otters_data = dk_otters,
      no_otters_data = no_otters,
      group_colors = color_groups
    )
  ),
  tar_target(
    figure_2_file,
    save_plot(figure_2_plot, "figs/figure2.pdf", width = 7, height = 6),
    format = "file"
  ),
  tar_target(
    figure_3_plot,
    fig_long_trends(
      sweden_geometry = sweden,
      spatial_models = spatial_fits,
      dk_otters_data = dk_otters,
      no_otters_data = no_otters,
      perch_models = perch_long_fit,
      group_colors = color_groups
    )
  ),
  tar_target(
    figure_3_file,
    save_plot(figure_3_plot, "figs/figure3.pdf", width = 8, height = 5),
    format = "file"
  ),
  tar_target(
    figure_4_plot,
    fig_short_trends(
      first_year = 2010,
      last_year = 2020,
      perch_data = perch,
      spatial_models = spatial_fits,
      group_colors = color_groups
    )
  ),
  tar_target(
    figure_4_file,
    save_plot(figure_4_plot, "figs/figure4.pdf", width = 7, height = 6),
    format = "file"
  ),
  tar_target(
    figure_5_plot,
    patchwork::wrap_plots(
      fig_spatiotemporal_conc(
        "TP",
        spatial_models = spatial_fits,
        sweden_geometry = sweden,
        otters_data = otters,
        dk_otters_data = dk_otters,
        no_otters_data = no_otters,
        prediction_grid = grid,
        scandinavia_map = scandinavia,
        jutland_geometry = jutland,
        pfas_metadata = PFAS
      ) + ggplot2::labs(title = "Total PFAS (PFOA-equiv.)"),
      fig_spatiotemporal_conc(
        "PFOS",
        spatial_models = spatial_fits,
        sweden_geometry = sweden,
        otters_data = otters,
        dk_otters_data = dk_otters,
        no_otters_data = no_otters,
        prediction_grid = grid,
        scandinavia_map = scandinavia,
        jutland_geometry = jutland,
        pfas_metadata = PFAS
      ),
      fig_popdensity(population_data = pop_densities),
      fig_spatiotemporal_conc(
        "PFNA",
        spatial_models = spatial_fits,
        sweden_geometry = sweden,
        otters_data = otters,
        dk_otters_data = dk_otters,
        no_otters_data = no_otters,
        prediction_grid = grid,
        scandinavia_map = scandinavia,
        jutland_geometry = jutland,
        pfas_metadata = PFAS
      ),
      fig_spatiotemporal_conc(
        "PFTrDA",
        spatial_models = spatial_fits,
        sweden_geometry = sweden,
        otters_data = otters,
        dk_otters_data = dk_otters,
        no_otters_data = no_otters,
        prediction_grid = grid,
        scandinavia_map = scandinavia,
        jutland_geometry = jutland,
        pfas_metadata = PFAS
      ),
      fig_precip(
        sweden_geometry = sweden,
        precipitation_data = precipitation
      ),
      ncol = 3,
      nrow = 2
    )
  ),
  tar_target(
    figure_5_file,
    save_plot(figure_5_plot, "figs/figure5.pdf", width = 14, height = 14.5),
    format = "file"
  ),
  tar_target(
    figure_6_plot,
    fig_MDS(
      prediction_grid = grid,
      spatial_models = spatial_fits,
      population_data = pop_densities,
      precipitation_data = precipitation,
      group_colors = color_groups
    )
  ),
  tar_target(
    figure_6_file,
    save_plot(figure_6_plot, "figs/figure6.pdf", width = 6, height = 6),
    format = "file"
  ),
  tar_target(
    proportion_bootstrap_repetitions,
    env_integer(
      "OTTERPFAS_PROPORTION_BOOT_REPS",
      default = 1000L
    )
  ),
  tar_target(
    proportion_data,
    prepare_proportion_data(otters)
  ),
  tar_target(
    proportion_fits,
    fit_proportion_models(proportion_data)
  ),
  tar_target(
    proportion_trends,
    predict_proportion_trends(proportion_fits, sweden)
  ),
  tar_target(
    proportion_bootstrap,
    if (proportion_bootstrap_enabled) {
      bootstrap_proportion_trends(
        proportion_data,
        sweden,
        n_boot = proportion_bootstrap_repetitions
      )
    } else {
      NULL
    }
  ),
  tar_target(
    proportion_comparisons,
    prepare_proportion_comparisons(dk_otters, no_otters)
  ),
  tar_target(
    figure_7_plot,
    fig_proportion_trends(
      proportion_trends,
      proportion_bootstrap,
      proportion_comparisons,
      color_groups
    )
  ),
  tar_target(
    figure_7_file,
    save_plot(
      figure_7_plot,
      "figs/figure7.pdf",
      width = 7,
      height = 6
    ),
    format = "file"
  ),
  tar_target(
    table_s6,
    dplyr::bind_rows(
      tab_sex_age(spatial_models = spatial_fits),
      tab_short_trends(
        first_year = 2010,
        last_year = 2020,
        spatial_models = spatial_fits
      )
    )
  ),
  tar_target(
    table_s6_file,
    save_table(table_s6, "tables/table_s6.csv"),
    format = "file"
  ),
  tar_target(
    table_s7,
    tab_otter_fits(spatial_models = spatial_fits)
  ),
  tar_target(
    table_s7_file,
    save_table(table_s7, "tables/table_s7.csv"),
    format = "file"
  ),
  tar_target(
    table_s8_fit_summary,
    tab_perch_fits(
      perch_mixed_models = perch_short_fits,
      perch_smooth_models = perch_long_fit
    )
  ),
  tar_target(
    table_s8_diagnostics,
    tab_perch_lmer_fits(
      perch_mixed_models = perch_short_fits,
      perch_smooth_models = perch_long_fit
    )
  ),
  tar_target(
    table_s8,
    dplyr::left_join(
      table_s8_fit_summary,
      dplyr::select(
        table_s8_diagnostics,
        Variable,
        `GAM Positive residuals`
      ),
      by = "Variable"
    )
  ),
  tar_target(
    table_s8_file,
    save_table(table_s8, "tables/table_s8.csv"),
    format = "file"
  )
)

base_targets
