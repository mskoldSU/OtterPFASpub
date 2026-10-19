#' Swedish otter PFAS observations
#'
#' Cleaned individual-level otter measurements and associated biological,
#' geographic, and PFAS variables used in the manuscript analyses.
#'
#' @format A tibble with 6,470 rows and 30 columns.
#' @keywords datasets
"otters"

#' Swedish perch PFAS observations
#'
#' Cleaned perch measurements, sampling locations, and PFAS variables used in
#' the manuscript analyses.
#'
#' @format A tibble with 4,605 rows and 17 columns.
#' @keywords datasets
"perch"

#' Danish otter PFAS observations
#'
#' Cleaned PFAS measurements for Danish otters, including spatial geometry and
#' compound classifications.
#'
#' @format An `sf` tibble with 140 rows and 16 columns.
#' @keywords datasets
"dk_otters"

#' Norwegian otter PFAS observations
#'
#' Cleaned PFAS measurements for Norwegian otters used for geographic
#' comparisons.
#'
#' @format A tibble with 23 rows and 10 columns.
#' @keywords datasets
"no_otters"

#' PFAS compound metadata
#'
#' Compound names, homologue groups, carbon-chain lengths, relative potency
#' factors, and display labels.
#'
#' @format A tibble with 15 rows and 6 columns.
#' @keywords datasets
"PFAS"

#' PFAS group colours
#'
#' Colours used consistently for PFAS groups in manuscript figures.
#'
#' @format A named character vector of length 3 containing hexadecimal colours.
#' @keywords datasets
"color_groups"

#' Prediction grid
#'
#' Coordinates of grid-cell centres used for spatial predictions in Sweden.
#'
#' @format A tibble with 484 rows and columns `X` and `Y`, in SWEREF 99 TM.
#' @keywords datasets
"grid"

#' Swedish municipal population data
#'
#' Municipal boundaries and population-density classifications used to derive
#' population exposure categories.
#'
#' @format An `sf` data frame with 290 rows and 8 columns.
#' @keywords datasets
"pop_densities"



#' Swedish precipitation normals
#'
#' Gridded normal annual precipitation used in the spatial covariate analysis.
#'
#' @format A tibble with 1,356 rows and columns `X`, `Y`, and `precip`.
#' @keywords datasets
"precipitation"

#' Sweden map geometry
#'
#' Multipolygon geometry used as the Swedish study-area boundary.
#'
#' @format An `sfc_MULTIPOLYGON` object.
#' @keywords datasets
"sweden"

#' Scandinavian map data
#'
#' Country and Swedish county geometries used as background data in manuscript
#' maps.
#'
#' @format An `sf` data frame with 11 rows and 172 columns.
#' @keywords datasets
"scandinavia"

#' Jutland map geometry
#'
#' Multipolygon geometry for Jutland used in manuscript maps.
#'
#' @format An `sfc_MULTIPOLYGON` object.
#' @keywords datasets
"jutland"
