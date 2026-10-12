# Build the country-year table from V-Dem and World Bank sources.
# Inputs (see docs/data_sources.md); set the file names below once downloaded.
# Output: data/derived/country_year.rds (one row per ISO3 country and year, 2017 to 2021)
# No models are fitted here.

source("R/utils.R")
suppressPackageStartupMessages({ library(dplyr); library(readr); library(countrycode) })

# TODO: set these to the downloaded files and record access dates in docs/data_sources.md
files <- list(
  vdem          = file.path(paths$external, "vdem", "V-Dem-CY-Full+Others-v11.1.csv"),
  wdi_gdp       = file.path(paths$external, "worldbank", "wdi_gdp_pc_ppp.csv"),
  wgi           = file.path(paths$external, "worldbank", "wgi.csv"),
  wb_classes    = file.path(paths$external, "worldbank", "wb_classification.csv")
)
absent <- names(files)[!file.exists(unlist(files))]
if (length(absent)) stop("Missing input files: ", paste(absent, collapse = ", "), call. = FALSE)

years <- 2017:2021

# V-Dem: Electoral Democracy Index. country_text_id is ISO3 for most countries;
# exceptions (e.g. Kosovo) are handled in config/country_overrides.csv.
# v11.1 ends in 2020. Rows for 2021 are added by carrying the 2020 values forward
# (the latest available value, matching what the original option does for everyone).
vdem_last <- read_specs()$dimensions$d04$options$alt_vdem_fieldwork$vdem_last_year
vdem <- read_csv(files$vdem, col_select = c(country_name, country_text_id, year, v2x_polyarchy, v2x_libdem),
                 show_col_types = FALSE) |>
  filter(year %in% years) |>
  transmute(iso3 = country_text_id, year, vdem_edi = v2x_polyarchy, vdem_libdem = v2x_libdem,
            vdem_carried_forward = FALSE)
stopifnot(max(vdem$year) == vdem_last)
later <- setdiff(years, vdem$year)
vdem <- bind_rows(vdem, lapply(later, function(y) vdem |> filter(year == vdem_last) |>
                                 mutate(year = as.integer(y), vdem_carried_forward = TRUE)))

# World Bank. Expected long format: iso3, year, value columns. Adapt to the downloaded files.
gdp <- read_csv(files$wdi_gdp, show_col_types = FALSE) |>
  filter(year %in% years) |>
  transmute(iso3, year, gdp_pc_ppp)
wgi <- read_csv(files$wgi, show_col_types = FALSE) |>
  filter(year %in% years) |>
  transmute(iso3, year, gov_effectiveness = GE.EST, pol_stability = PV.EST, control_corruption = CC.EST)
classes <- read_csv(files$wb_classes, show_col_types = FALSE) |>
  transmute(iso3, income_group, region)

country_year <- vdem |>
  left_join(gdp, by = c("iso3", "year")) |>
  left_join(wgi, by = c("iso3", "year")) |>
  left_join(classes, by = "iso3")

ensure_dir(paths$derived)
saveRDS(country_year, file.path(paths$derived, "country_year.rds"))
cat(sprintf("Country-years: %d  Countries: %d\n", nrow(country_year), length(unique(country_year$iso3))))
