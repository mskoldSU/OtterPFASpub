#' @importFrom utils globalVariables
NULL

# Names evaluated inside dplyr and ggplot2 data masks, plus data objects and
# model targets created by the reproducible workflow.
globalVariables(c(
  "PFAS", "RPF", "V1", "V2", "Vc", "X", "Xp", "Y", "accnr", "age",
  "body_burden", "cens_prop", "check", "cint", "cohen", "color_groups",
  "conc", "concentration", "conf.high", "conf.low", "conf_interval",
  "cyst", "data", "decimal_date", "density", "diff_estimate", "diff_se",
  "dk_otters", "edf", "effect", "estimate", "fit", "fitted_2010", "grid",
  "group", "group_long", "interval", "is_censored", "jutland", "lake",
  "level_2010", "log_range_spat", "log_range_temp", "long_name", "lower",
  "lsi", "n_control", "n_exposed", "name", "newdata", "no_otters",
  "odds_ratio", "otter_max", "otters", "p.value", "p_value", "perch",
  "perch_gam_fits", "perch_lmer_fits", "perch_long_fit", "period",
  "pop_densities", "pop_level", "pos", "precipitation",
  "pred", "predictions", "proportion", "r2", "res_var", "results",
  "scale_factor", "scandinavia", "se", "sex", "site", "slope", "smi",
  "space_edf", "space_p", "spatial_fits", "swe", "sweden", "temporal_2010",
  "temporal_effect", "term", "time_edf", "time_p", "upper", "value",
  "var_lake", "var_res", "year", "yearly_rate"
))