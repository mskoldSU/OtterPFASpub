# OtterPFAS reproducible code supplement

This repository contains the cleaned analysis data and code used for the manuscript ENVPOL-D-26-11182_R1. Raw source files are not distributed.

The workflow is defined in `_targets.R`. From the repository root, run:

```r
targets::tar_make()
```

This default run fits the main censored spatiotemporal models and writes
Figures 1–7 to `figs/figure1.pdf` through `figs/figure7.pdf`. By default,
Figure 7 is generated without confidence intervals because the proportions
bootstrap is expensive. Supplementary Tables S6–S8 are written as CSV files
under `tables/`.

## Optional proportions bootstrap

Figure 7's confidence intervals use 1,000 bootstrap resamples and are
intentionally opt-in:

```r
Sys.setenv(OTTERPFAS_RUN_PROPORTIONS = "true")
targets::tar_make()
```

For a quick test, reduce the number of bootstrap repetitions:

```r
Sys.setenv(
  OTTERPFAS_RUN_PROPORTIONS = "true",
  OTTERPFAS_PROPORTION_BOOT_REPS = "10"
)
targets::tar_make()
```

The full analysis uses 1,000 repetitions. The `targets` pipeline assigns reproducible target-specific random-number seeds and caches completed results under `_targets/`.
