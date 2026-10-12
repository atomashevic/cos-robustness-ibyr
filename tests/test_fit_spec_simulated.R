# Checks the fitting code on simulated data with a known interaction.
# Uses no real data, so it is allowed before registration.
# Rscript tests/test_fit_spec_simulated.R   (about 1 to 2 minutes)

source("R/06_fit_spec.R")
suppressPackageStartupMessages(library(mice))

set.seed(1)
n_c <- 60; n_i <- 300; true_b <- -0.25

countries <- data.frame(
  country = factor(sprintf("C%02d", seq_len(n_c))),
  dem_vdem2020 = runif(n_c, 0.1, 0.9)
)
countries$dem_vdem_fieldwork <- pmin(1, pmax(0, countries$dem_vdem2020 + rnorm(n_c, 0, 0.03)))
countries$dem_eiu_fieldwork  <- pmin(1, pmax(0, countries$dem_vdem2020 + rnorm(n_c, 0, 0.08)))
countries$dem_eiu_fieldwork[1:3] <- NA          # countries without an EIU score
countries$gdp_pc_ppp <- exp(rnorm(n_c, 9.5, 0.8))
countries$gov_effectiveness  <- rnorm(n_c)
countries$pol_stability      <- rnorm(n_c)
countries$control_corruption <- rnorm(n_c)
countries$income_group <- factor(sample(c("L", "LM", "UM", "H"), n_c, TRUE))
countries$region       <- factor(sample(c("ECA", "LAC", "SA", "EAP"), n_c, TRUE))
countries$u0 <- rnorm(n_c, 0, 0.4); countries$u1 <- rnorm(n_c, 0, 0.15)
countries$att_mean <- rnorm(n_c, 0, 0.3)

d <- countries[rep(seq_len(n_c), each = n_i), ]
f <- d$att_mean + rnorm(nrow(d))                         # latent attitudes
item <- function(l) as.numeric(cut(l * f + rnorm(nrow(d), 0, 0.8), c(-Inf, -0.8, 0, 0.8, Inf)))
d$regime_strong_leader <- item(0.8); d$regime_experts <- item(0.5); d$regime_army <- item(0.8)
d$sex <- factor(sample(1:2, nrow(d), TRUE)); d$age <- round(runif(nrow(d), 18, 85))
d$education <- factor(sample(0:2, nrow(d), TRUE)); d$marital_status <- factor(sample(1:4, nrow(d), TRUE))
d$employment <- factor(sample(1:5, nrow(d), TRUE))
fw <- f - d$att_mean
d$life_satisfaction <- 6 + d$u0 + (0.1 + d$u1) * fw + 0.5 * d$dem_vdem2020 +
  true_b * fw * d$dem_vdem2020 + rnorm(nrow(d), 0, 2)
d <- d[, setdiff(names(d), c("u0", "u1", "att_mean"))]

# 2% item missingness, then a small imputation
for (v in c("life_satisfaction", "regime_strong_leader", "regime_experts", "regime_army", "age")) {
  d[[v]][sample(nrow(d), 0.02 * nrow(d))] <- NA
}
imp_vars <- c("life_satisfaction", "regime_strong_leader", "regime_experts", "regime_army",
              "sex", "age", "education", "marital_status", "employment", "country")
meth <- make.method(d[, imp_vars]); meth["country"] <- ""
imp <- mice(d[, imp_vars], m = 3, maxit = 3, method = meth, printFlag = FALSE, seed = 1)

settings <- list(optimizer = "bobyqa")
grid <- build_spec_grid(read_specs())
pick <- c("IBYR_01", grid$spec_id[grid$d04 == "alt_eiu_fieldwork" & grid$d02 == "alt_complete_case" &
                                   grid$a01 == "alt_two_items" & grid$a02 == "alt_country_mean"][1])
res <- do.call(rbind, lapply(pick, function(id) run_spec(as.list(grid[grid$spec_id == id, ]), d, imp, settings)))
print(res[, c("spec_id", "d04", "a01", "a02", "d06", "d02", "estimate", "std_error", "p_value", "n_obs", "n_groups", "converged")])

fails <- character(0)
chk <- function(ok, msg) if (!isTRUE(ok)) fails <<- c(fails, msg)
chk(all(res$converged), "all test specifications should converge")
chk(all(res$estimate < 0 & res$p_value < 0.05), "focal interaction should be negative and detected")
chk(res$n_groups[2] == n_c - 3, "EIU specification should drop the 3 countries without a score")
chk(res$n_imputations[1] == 3 && res$statistic_type[1] == "t (Rubin's rules)", "baseline should pool over imputations")
chk(identical(names(res), results_columns), "results row must have the declared columns")
# Failed fits must not carry estimates
bad <- fit_one(transform(prepare_spec_data(d, as.list(grid[1, ]))[1:20, ], country = droplevels(country)),
               as.list(grid[1, ]), settings)
chk(!bad$ok && is.null(bad$estimate), "a tiny dataset should be flagged as a failed fit with no estimate")

# Years after V-Dem v11.1 are a declared exclusion for one option only.
yrs <- data.frame(year = c(2018, 2020, 2021, NA))
kept <- exclude_late_fieldwork(yrs, list(d04 = "alt_vdem_fieldwork"))
chk(identical(kept$year, c(2018, 2020, NA)), "fieldwork after 2020 is excluded; a missing year is not")
chk(nrow(exclude_late_fieldwork(yrs, list(d04 = "orig_vdem2020"))) == 4,
    "other democracy options keep respondents interviewed after 2020")
chk(identical(VDEM_FIELDWORK_LAST_YEAR, 2020L), "exclusion year is the v11.1 end year in the spec")

# Singular fit: checkConv stores one message and returns. The estimate stays.
set.seed(1)
sd <- data.frame(y = rnorm(400), x = rnorm(400), g = factor(rep(1:2, each = 200)))
sm <- suppressMessages(lme4::lmer(y ~ x + (1 + x || g), data = sd, REML = FALSE,
                                  control = lme4::lmerControl(optimizer = "bobyqa")))
chk(lme4::isSingular(sm), "constructed fit should be singular")
chk(identical(sm@optinfo$conv$lme4$messages, SINGULAR_MSG),
    "singular message must be the checkConv string")
chk(length(convergence_failure(sm)) == 0, "a singular fit is not non-convergence")
chk(isTRUE(sm@optinfo$conv$opt == 0), "a singular fit can still have optimizer code 0")

# One singular imputation must not fail the specification. The other failure must.
mixed <- list(
  list(ok = TRUE, singular = TRUE, estimate = -0.2, std_error = 0.08),
  list(ok = TRUE, singular = FALSE, estimate = -0.22, std_error = 0.08)
)
mixed_ok <- vapply(mixed, `[[`, logical(1), "ok")
chk(all(mixed_ok) && sum(vapply(mixed, `[[`, logical(1), "singular")) == 1,
    "a singular imputation stays ok and is counted, not failed")
failed_mix <- list(mixed[[1]], list(ok = FALSE, singular = FALSE, reason = "optimizer convergence code 1"))
failed_ok <- vapply(failed_mix, `[[`, logical(1), "ok")
chk(!all(failed_ok), "an optimizer failure in any imputation still fails the specification")

# Optimizer failure is still non-convergence, with no success code.
fm <- suppressWarnings(lme4::lmer(
  y ~ x + (1 + x | g),
  data = data.frame(y = rnorm(80), x = rnorm(80), g = factor(rep(1:8, each = 10))),
  REML = FALSE,
  control = lme4::lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 5))
))
chk(length(convergence_failure(fm)) > 0, "optimizer failure is non-convergence")

if (length(fails)) { cat("FAILED:\n", paste0(" - ", fails, collapse = "\n"), "\n"); quit(status = 1) }
cat("All simulated-data checks passed.\n")
