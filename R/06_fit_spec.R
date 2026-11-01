# Functions that fit one specification. Sourced by the run scripts.
# Frozen after registration except for bug fixes (README.md, rule 6).

source("R/utils.R")
suppressPackageStartupMessages({ library(lavaan); library(lme4) })

ITEMS <- list(
  orig_three_items = c("regime_strong_leader", "regime_experts", "regime_army"),
  alt_two_items    = c("regime_strong_leader", "regime_army")
)
DEMOCRACY <- c(
  orig_vdem2020      = "dem_vdem2020",
  alt_vdem_fieldwork = "dem_vdem_fieldwork",
  alt_vdem_libdem2020 = "dem_vdem_libdem2020"
)
INDIVIDUAL_CONTROLS <- c("sex", "age", "education", "marital_status", "employment")
GOVERNANCE <- c("gov_effectiveness", "pol_stability", "control_corruption")
FOCAL_TERM <- "att_cwc:democracy"

# V-Dem v11.1 ends in this year. For alt_vdem_fieldwork, later fieldwork keeps
# the score of this year (carried forward in R/03_prepare_country.R). Nobody is excluded.
VDEM_LAST_YEAR <- local({
  y <- read_specs()$dimensions$d04$options$alt_vdem_fieldwork$vdem_last_year
  if (!is.numeric(y) || length(y) != 1L || !is.finite(y)) {
    stop("alt_vdem_fieldwork vdem_last_year must be one year.", call. = FALSE)
  }
  as.integer(y)
})

# Installed lme4 1.1.35.1, lme4:::checkConv: a singular fit stores exactly this
# string in optinfo$conv$lme4$messages, signals it with message() (the default
# action is "message"), and returns before the gradient and Hessian checks.
# A normal bobyqa exit keeps optimizer code 0. The string is not non-convergence.
SINGULAR_MSG <- "boundary (singular) fit: see help('isSingular')"

is_singular_notice <- function(msg) {
  is.character(msg) && length(msg) == 1L && !is.na(msg) && identical(trimws(msg), SINGULAR_MSG)
}

# Empty character vector means the fit converged. The singular notice is
# removed. Any other lme4 message, a warning that reports convergence trouble,
# or an optimizer code other than 0, is a failure.
convergence_failure <- function(fit, warns = character(0)) {
  msgs <- fit@optinfo$conv$lme4$messages
  if (is.null(msgs)) msgs <- character(0)
  msgs <- as.character(unlist(msgs, use.names = FALSE))
  msgs <- msgs[!vapply(msgs, is_singular_notice, logical(1))]
  warn_hit <- grep("converge", warns, value = TRUE, ignore.case = TRUE)
  warn_hit <- warn_hit[!vapply(warn_hit, is_singular_notice, logical(1))]
  opt_code <- fit@optinfo$conv$opt
  opt_fail <- if (is.numeric(opt_code) && length(opt_code) == 1L &&
                  !is.na(opt_code) && opt_code != 0) {
    sprintf("optimizer convergence code %s", opt_code)
  } else character(0)
  unique(c(opt_fail, msgs, warn_hit))
}

# One-factor CFA on complete item data; returns regression factor scores and omega.
# Two items: loadings constrained equal so the model is identified.
score_attitudes <- function(df, items, equal_loadings = length(items) == 2) {
  rhs <- if (equal_loadings) paste0("a*", items, collapse = " + ") else paste(items, collapse = " + ")
  fit <- lavaan::cfa(paste("att =~", rhs), data = df[, items])
  pe  <- lavaan::parameterEstimates(fit)
  lam <- pe$est[pe$op == "=~"]
  th  <- pe$est[pe$op == "~~" & pe$lhs %in% items & pe$lhs == pe$rhs]
  psi <- pe$est[pe$op == "~~" & pe$lhs == "att" & pe$rhs == "att"]
  list(
    scores = as.numeric(lavaan::lavPredict(fit, method = "regression")[, 1]),
    omega  = sum(lam)^2 * psi / (sum(lam)^2 * psi + sum(th))
  )
}

# Variables a specification's model needs.
spec_vars <- function(spec) {
  country_controls <- c("gdp_pc_ppp", "income_group", "region",
                        if (spec$d06 == "orig_full") GOVERNANCE)
  c("life_satisfaction", ITEMS[[spec$a01]], INDIVIDUAL_CONTROLS,
    DEMOCRACY[[spec$d04]], country_controls, "country")
}

# Build the model frame for one dataset (one imputation, or the observed data).
prepare_spec_data <- function(df, spec) {
  needed <- spec_vars(spec)
  dat <- df[stats::complete.cases(df[, needed]), needed]
  dat$country   <- droplevels(dat$country)
  dat$democracy <- dat[[DEMOCRACY[[spec$d04]]]]
  sc <- score_attitudes(dat, ITEMS[[spec$a01]])
  dat$att       <- sc$scores
  dat$att_cmean <- stats::ave(dat$att, dat$country)
  dat$att_cwc   <- dat$att - dat$att_cmean
  dat$gdp_pc_10k <- dat$gdp_pc_ppp / 1e4
  attr(dat, "omega") <- sc$omega
  dat
}

spec_formula <- function(spec) {
  rhs <- c("att_cwc * democracy", INDIVIDUAL_CONTROLS, "gdp_pc_10k", "income_group", "region")
  if (spec$d06 == "orig_full") rhs <- c(rhs, GOVERNANCE)
  if (spec$a02 == "alt_country_mean") rhs <- c(rhs, "att_cmean")
  stats::as.formula(paste("life_satisfaction ~", paste(rhs, collapse = " + "),
                          "+ (1 + att_cwc || country)"))
}

# Fit one model. A singular fit keeps its estimate. An error or an optimizer
# failure returns no estimate.
fit_one <- function(dat, spec, settings) {
  warns <- character(0)
  fit <- withCallingHandlers(
    tryCatch(
      lme4::lmer(spec_formula(spec), data = dat, REML = FALSE,
                 control = lme4::lmerControl(optimizer = settings$optimizer %||% "bobyqa")),
      error = function(e) e
    ),
    warning = function(w) { warns <<- c(warns, conditionMessage(w)); invokeRestart("muffleWarning") },
    message = function(m) {
      if (is_singular_notice(conditionMessage(m))) invokeRestart("muffleMessage")
    }
  )
  if (inherits(fit, "error")) return(list(ok = FALSE, reason = paste("error:", conditionMessage(fit))))
  conv_msgs <- convergence_failure(fit, warns)
  if (length(conv_msgs)) return(list(ok = FALSE, reason = paste("non-convergence:", paste(conv_msgs, collapse = "; "))))
  if (!FOCAL_TERM %in% names(lme4::fixef(fit))) return(list(ok = FALSE, reason = paste("focal term", FOCAL_TERM, "absent")))

  b  <- unname(lme4::fixef(fit)[FOCAL_TERM])
  se <- unname(sqrt(diag(as.matrix(stats::vcov(fit))))[names(lme4::fixef(fit)) == FOCAL_TERM])
  dem_country <- tapply(dat$democracy, dat$country, mean)
  list(
    ok = TRUE, estimate = b, std_error = se,
    effect_size = b * stats::sd(dat$att_cwc) * stats::sd(dem_country) / stats::sd(dat$life_satisfaction),
    n_obs = stats::nobs(fit), n_groups = unname(lme4::ngrps(fit)["country"]),
    singular = isTRUE(lme4::isSingular(fit)),
    warnings = warns[!vapply(warns, is_singular_notice, logical(1))]
  )
}

empty_row <- function(spec) {
  row <- as.data.frame(setNames(rep(list(NA), length(results_columns)), results_columns))
  for (k in c("spec_id", "d04", "a01", "a02", "d06", "d02", "is_baseline")) row[[k]] <- spec[[k]]
  row$focal_term <- FOCAL_TERM
  row$effect_size_type <- "standardized interaction: b x SD(att_cwc) x SD(democracy, countries) / SD(life_satisfaction)"
  row
}

# Run one specification. `analytic` is the observed data with country-level columns;
# `imp` is the mids object from R/05_impute.R.
run_spec <- function(spec, analytic, imp, settings) {
  row <- empty_row(spec)
  country_cols <- setdiff(names(analytic), names(imp$data))

  if (spec$d02 == "orig_mi") {
    fits <- lapply(seq_len(imp$m), function(i) {
      d <- cbind(mice::complete(imp, i), analytic[, country_cols, drop = FALSE])
      fit_one(prepare_spec_data(d, spec), spec, settings)
    })
    # A singular imputation has ok TRUE and an estimate, so it is pooled.
    # One singular imputation does not fail the specification. An error or
    # an optimizer failure has ok FALSE, and then the row has no estimate.
    ok <- vapply(fits, `[[`, logical(1), "ok")
    row$n_imputations <- imp$m
    if (!all(ok)) {
      row$converged <- FALSE
      row$failure_reason <- sprintf("%d of %d imputations failed; first: %s",
                                    sum(!ok), imp$m, fits[[which(!ok)[1]]]$reason)
      return(row)
    }
    p <- pool_rubin(vapply(fits, `[[`, numeric(1), "estimate"),
                    vapply(fits, `[[`, numeric(1), "std_error"))
    crit <- if (is.finite(p$df)) stats::qt(0.975, p$df) else stats::qnorm(0.975)
    row$estimate <- p$estimate; row$std_error <- p$std_error; row$df <- p$df
    row$statistic <- p$estimate / p$std_error
    row$statistic_type <- "t (Rubin's rules)"
    row$p_value <- 2 * (if (is.finite(p$df)) stats::pt(-abs(row$statistic), p$df) else stats::pnorm(-abs(row$statistic)))
    row$effect_size <- mean(vapply(fits, `[[`, numeric(1), "effect_size"))
    row$n_obs <- fits[[1]]$n_obs; row$n_groups <- fits[[1]]$n_groups
    row$se_procedure <- "Rubin's rules: within-imputation model-based SEs (lme4, ML) combined with between-imputation variance"
    row$se_grouping <- NA
    row$se_n <- imp$m
    sing <- sum(vapply(fits, `[[`, logical(1), "singular"))
    if (sing) row$notes <- sprintf("singular fit in %d imputations", sing)
  } else {
    f <- fit_one(prepare_spec_data(analytic, spec), spec, settings)
    row$n_imputations <- 0
    if (!f$ok) { row$converged <- FALSE; row$failure_reason <- f$reason; return(row) }
    crit <- stats::qnorm(0.975)
    row$estimate <- f$estimate; row$std_error <- f$std_error; row$df <- NA
    row$statistic <- f$estimate / f$std_error
    row$statistic_type <- "z (Wald, model-based SE as in Stata mixed)"
    row$p_value <- 2 * stats::pnorm(-abs(row$statistic))
    row$effect_size <- f$effect_size
    row$n_obs <- f$n_obs; row$n_groups <- f$n_groups
    if (f$singular) row$notes <- "singular fit"
  }
  row$ci_lower <- row$estimate - crit * row$std_error
  row$ci_upper <- row$estimate + crit * row$std_error
  row$converged <- TRUE
  row
}
