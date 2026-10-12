# Install missing packages. Run once: source("R/00_packages.R")

pkgs <- c(
  "yaml",        # config files
  "haven",       # reading the Joint EVS/WVS Stata or SPSS file
  "readr",       # CSV input and output
  "dplyr",       # data preparation
  "countrycode", # matching country codes across sources
  "lavaan",      # CFA scoring of the attitudes scale
  "mice",        # multiple imputation
  "lme4"         # linear mixed models
)

missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing)

cat("R", R.version$major, ".", R.version$minor, "\n", sep = "")
for (p in pkgs) cat(sprintf("%-12s %s\n", p, as.character(utils::packageVersion(p))))
