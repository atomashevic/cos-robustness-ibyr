# Read the raw Joint EVS/WVS file, keep the analysis variables, recode.
# Input:  data/raw/<ZA7505 file> (.dta or .sav)
# Output: data/derived/individual.rds
# No models are fitted here.

source("R/utils.R")
suppressPackageStartupMessages({ library(haven); library(dplyr) })

vars <- read_vars()
warn_unverified(vars)

raw_file <- list.files(paths$raw, pattern = "ZA7505.*\\.(dta|sav)$", full.names = TRUE, ignore.case = TRUE)
if (length(raw_file) != 1) {
  stop("Expected exactly one ZA7505 .dta or .sav file in data/raw/, found ", length(raw_file), call. = FALSE)
}
cat("Reading", raw_file, "\n")
raw <- if (grepl("\\.dta$", raw_file, ignore.case = TRUE)) read_dta(raw_file) else read_sav(raw_file)

iv <- vars$individual
v  <- vapply(iv, `[[`, character(1), "var")
missing_cols <- setdiff(v, names(raw))
if (length(missing_cols)) {
  stop("Variables not found in the raw file (check config/variables.yaml): ",
       paste(missing_cols, collapse = ", "), call. = FALSE)
}

ind <- raw[, v]
names(ind) <- names(v)

ind <- ind |>
  mutate(
    country_iso2 = as.character(country_iso2),
    country_id   = as.integer(country_id),
    study        = as.integer(study),
    year         = as.integer(year),
    across(c(life_satisfaction, regime_strong_leader, regime_experts, regime_army,
             regime_democratic, age), na_negative),
    # Reverse the regime items: 1 very good ... 4 very bad becomes
    # 4 ... 1, so higher values mean stronger anti-democratic attitudes.
    across(c(regime_strong_leader, regime_experts, regime_army), ~ 5 - .x),
    # Categorical controls: keep the source categories (baseline reading, see docs/focal_result.md)
    across(c(sex, education, marital_status, employment), ~ {
      x <- na_negative(.x)
      factor(x)
    })
  )

ensure_dir(paths$derived)
saveRDS(ind, file.path(paths$derived, "individual.rds"))

cat(sprintf("Rows: %d  Countries: %d\n", nrow(ind), length(unique(ind$country_iso2))))
cat("Fieldwork years:\n"); print(table(ind$year, useNA = "ifany"))
