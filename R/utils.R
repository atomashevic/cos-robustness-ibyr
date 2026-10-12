# Shared helpers. Sourced by every script; run scripts from the repository root.

suppressPackageStartupMessages({
  library(yaml)
})

paths <- list(
  raw      = "data/raw",
  external = "data/external",
  derived  = "data/derived",
  results  = "results",
  reports  = "reports",
  specs    = "config/specifications.yaml",
  vars     = "config/variables.yaml"
)

read_specs <- function(path = paths$specs) yaml::read_yaml(path)
read_vars  <- function(path = paths$vars)  yaml::read_yaml(path)

# Block model fitting until the plan is registered (COS guidance 1.1).
check_registered <- function(specs = read_specs()) {
  reg <- specs$registration
  if (!isTRUE(reg$registered) || !nzchar(reg$osf_url %||% "")) {
    stop(
      "The analysis plan is not registered yet. COS requires the plan to be ",
      "written before anything is run. Set registration.registered: true and ",
      "registration.osf_url in config/specifications.yaml after OSF registration.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

`%||%` <- function(a, b) if (is.null(a)) b else a

# Warn loudly if any variable mapping is still unverified against the codebook.
warn_unverified <- function(vars = read_vars()) {
  flat <- c(vars$individual, vars$country)
  unverified <- names(flat)[!vapply(flat, function(x) isTRUE(x$verified), logical(1))]
  if (length(unverified)) {
    warning(
      length(unverified), " variable mappings are not verified against the codebook: ",
      paste(unverified, collapse = ", "),
      call. = FALSE
    )
  }
  invisible(unverified)
}

# Joint EVS/WVS missing-value codes are negative. Verify against the codebook.
na_negative <- function(x) {
  x <- as.numeric(x)
  x[x < 0] <- NA
  x
}

# Build the full specification grid from the YAML, one row per combination.
build_spec_grid <- function(specs = read_specs()) {
  dims <- specs$dimensions
  opts <- lapply(dims, function(d) names(d$options))
  grid <- expand.grid(opts, stringsAsFactors = FALSE, KEEP.OUT.ATTRS = FALSE)
  names(grid) <- names(dims)

  # Declared exclusions: list of named lists, e.g. list(d04 = "alt_x", d02 = "alt_y")
  for (ex in specs$excluded_combinations %||% list()) {
    hit <- Reduce(`&`, Map(function(col, val) grid[[col]] == val, names(ex), ex))
    grid <- grid[!hit, , drop = FALSE]
  }

  orig <- as.data.frame(lapply(grid, function(col) startsWith(col, "orig_")))
  grid$is_baseline <- Reduce(`&`, orig)
  grid <- grid[order(!grid$is_baseline), , drop = FALSE]
  grid$spec_id <- sprintf("%s_%02d", specs$paper_id, seq_len(nrow(grid)))
  rownames(grid) <- NULL
  grid[, c("spec_id", names(dims), "is_baseline")]
}

# Results file columns. Provisional: align with the COS Results File
# Specification once COS sends it.
results_columns <- c(
  "spec_id", "d04", "a01", "a02", "d06", "d02", "is_baseline", "focal_term",
  # eleven estimate columns
  "estimate", "std_error", "statistic", "statistic_type", "df", "p_value",
  "ci_lower", "ci_upper", "effect_size", "effect_size_type", "n_obs",
  # model status
  "converged", "failure_reason",
  # standard errors computed after fitting
  "se_procedure", "se_grouping", "se_n",
  # extra
  "n_groups", "n_imputations", "notes"
)

# Rubin's rules for one scalar parameter.
pool_rubin <- function(est, se) {
  m    <- length(est)
  qbar <- mean(est)
  ubar <- mean(se^2)
  b    <- if (m > 1) stats::var(est) else 0
  tvar <- ubar + (1 + 1 / m) * b
  r    <- (1 + 1 / m) * b / ubar
  df   <- if (b > 0) (m - 1) * (1 + 1 / r)^2 else Inf
  list(estimate = qbar, std_error = sqrt(tvar), df = df)
}

ensure_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE)
  invisible(path)
}
