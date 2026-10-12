# Multiple imputation of individual-level analysis variables.
# Input:  data/derived/analytic.rds
# Output: data/derived/imputations.rds (a mids object)
#
# Baseline reading (article reports only "multiple imputations"): mice default
# methods (pmm for numeric, logreg for binary, polyreg for nominal factors),
# m from config, country indicators as a predictor so imputations respect
# clustering. Country-level variables are complete by construction and are
# attached after imputation (R/06_fit_spec.R).
# No models of the outcome are fitted here. Runtime: expect 30 to 90 minutes.

source("R/utils.R")
suppressPackageStartupMessages(library(mice))

specs    <- read_specs()
settings <- specs$settings
analytic <- readRDS(file.path(paths$derived, "analytic.rds"))

imp_vars <- c("life_satisfaction", "regime_strong_leader", "regime_experts", "regime_army",
              "sex", "age", "education", "marital_status", "employment", "country")
dat <- analytic[, imp_vars]

meth <- make.method(dat)
meth["country"] <- ""                 # predictor only, never imputed
pred <- make.predictorMatrix(dat)

imp <- mice(dat, m = settings$n_imputations, maxit = settings$imputation_maxit %||% 10,
            method = meth, predictorMatrix = pred, seed = settings$seed, printFlag = TRUE)

saveRDS(imp, file.path(paths$derived, "imputations.rds"))
cat("Methods used:\n"); print(imp$method)
cat("Logged events:", if (is.null(imp$loggedEvents)) 0 else nrow(imp$loggedEvents), "\n")
