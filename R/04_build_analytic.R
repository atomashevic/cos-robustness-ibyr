# Merge individual and country data, define the analytic sample, and write the
# descriptives the preregistration needs (N, countries, missingness, omega).
# Inputs:  data/derived/individual.rds, data/derived/country_year.rds
# Outputs: data/derived/analytic.rds, results/descriptives_*.csv
# No models of the outcome are fitted here (only the measurement model of the
# three regime items, for omega).

source("R/utils.R")
source("R/06_fit_spec.R")   # score_attitudes()
suppressPackageStartupMessages({ library(dplyr); library(readr); library(countrycode) })

ind <- readRDS(file.path(paths$derived, "individual.rds"))
cy  <- readRDS(file.path(paths$derived, "country_year.rds"))

# ISO2 (joint file) to ISO3 (country sources), with manual overrides
overrides <- read_csv("config/country_overrides.csv", comment = "#", show_col_types = FALSE)
ind$iso3 <- countrycode(ind$country_iso2, "iso2c", "iso3c", warn = FALSE)
if (nrow(overrides)) {
  m <- match(ind$country_iso2, overrides$iso2)
  ind$iso3[!is.na(m)] <- overrides$iso3[m[!is.na(m)]]
}
unmatched <- sort(unique(ind$country_iso2[is.na(ind$iso3)]))
if (length(unmatched)) cat("No ISO3 code for:", paste(unmatched, collapse = ", "), "\n")

# Country-level variables
fixed_2020 <- cy |>
  filter(year == 2020) |>
  transmute(iso3, dem_vdem2020 = vdem_edi, dem_vdem_libdem2020 = vdem_libdem, gdp_pc_ppp, gov_effectiveness,
            pol_stability, control_corruption, income_group, region)
# Fieldwork after V-Dem v11.1 ends (2020) carries the 2020 score forward,
# flagged by vdem_carried_forward (see R/03_prepare_country.R).
at_fieldwork <- cy |>
  transmute(iso3, year, dem_vdem_fieldwork = vdem_edi, vdem_carried_forward)

analytic_all <- ind |>
  left_join(fixed_2020, by = "iso3") |>
  left_join(at_fieldwork, by = c("iso3", "year")) |>
  mutate(country = factor(iso3))

# Analytic sample: countries matched to V-Dem 2020 (article p. 2608)
dropped <- analytic_all |>
  filter(is.na(dem_vdem2020)) |>
  distinct(country_iso2)
analytic <- analytic_all |>
  filter(!is.na(dem_vdem2020)) |>
  mutate(country = droplevels(country))

saveRDS(analytic, file.path(paths$derived, "analytic.rds"))

# Descriptives for the preregistration
ensure_dir(paths$results)

# Countries with fieldwork after the last V-Dem v11.1 year: under alt_vdem_fieldwork
# these respondents carry the 2020 score forward. Counts only.
late <- analytic |>
  filter(vdem_carried_forward %in% TRUE) |>
  count(country_iso2, country, year, name = "n_respondents") |>
  arrange(country_iso2, year)
write.csv(late, file.path(paths$results, "descriptives_vdem_carried_forward.csv"), row.names = FALSE)
cat("Country-years with the 2020 V-Dem score carried forward: ",
    if (nrow(late)) paste(unique(as.character(late$country_iso2)), collapse = ", ") else "none",
    "\n", sep = "")
n_tab <- data.frame(
  quantity  = c("respondents", "countries", "countries dropped (no V-Dem 2020)", "respondents in article", "countries in article"),
  value     = c(nrow(analytic), nlevels(analytic$country), nrow(dropped), 131846, 78)
)
write.csv(n_tab, file.path(paths$results, "descriptives_sample.csv"), row.names = FALSE)
print(n_tab)
if (nrow(dropped)) cat("Dropped countries:", paste(dropped$country_iso2, collapse = ", "), "\n")

analysis_vars <- c("life_satisfaction", "regime_strong_leader", "regime_experts", "regime_army",
                   "sex", "age", "education", "marital_status", "employment",
                   "dem_vdem2020", "dem_vdem_fieldwork", "dem_vdem_libdem2020", "gdp_pc_ppp",
                   "gov_effectiveness", "pol_stability", "control_corruption", "income_group", "region")
miss <- data.frame(
  variable    = analysis_vars,
  pct_missing = round(100 * vapply(analysis_vars, function(v) mean(is.na(analytic[[v]])), numeric(1)), 2)
)
write.csv(miss, file.path(paths$results, "descriptives_missingness.csv"), row.names = FALSE)
print(miss, row.names = FALSE)

items3 <- c("regime_strong_leader", "regime_experts", "regime_army")
items2 <- c("regime_strong_leader", "regime_army")
cc3 <- analytic[stats::complete.cases(analytic[, items3]), ]
cc2 <- analytic[stats::complete.cases(analytic[, items2]), ]
om <- data.frame(
  scale = c("three items (article: omega = .63)", "two items"),
  omega = round(c(score_attitudes(cc3, items3)$omega,
                  score_attitudes(cc2, items2, equal_loadings = TRUE)$omega), 3)
)
write.csv(om, file.path(paths$results, "descriptives_omega.csv"), row.names = FALSE)
print(om, row.names = FALSE)
