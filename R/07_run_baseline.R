# Run the baseline specification and compare it with Table 1.
# Blocked until the plan is registered.
# Output: results/baseline_comparison.csv

source("R/06_fit_spec.R")

specs <- read_specs()
check_registered(specs)

analytic <- readRDS(file.path(paths$derived, "analytic.rds"))
imp      <- readRDS(file.path(paths$derived, "imputations.rds"))
grid     <- build_spec_grid(specs)
baseline <- as.list(grid[grid$is_baseline, ])

set.seed(specs$settings$seed)
res <- run_spec(baseline, analytic, imp, specs$settings)

published <- c(estimate = -0.23, std_error = 0.08, p_value = 0.002, ci_lower = -0.38, ci_upper = -0.09,
               n_obs = 131846, n_groups = 78)
comparison <- data.frame(
  quantity  = names(published),
  published = unname(published),
  rebuilt   = vapply(names(published), function(k) as.numeric(res[[k]]), numeric(1))
)
comparison$difference <- comparison$rebuilt - comparison$published

ensure_dir(paths$results)
write.csv(comparison, file.path(paths$results, "baseline_comparison.csv"), row.names = FALSE)
print(comparison, row.names = FALSE)
cat("\nReport the gap as a result. Do not adjust the pipeline to close it (README.md, rule 5).\n")
