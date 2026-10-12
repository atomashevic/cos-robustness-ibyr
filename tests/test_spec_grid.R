# Checks that run without data: Rscript tests/test_spec_grid.R

source("R/utils.R")

specs <- read_specs()
grid  <- build_spec_grid(specs)
fails <- character(0)
n_checks <- 0
check <- function(ok, msg) {
  n_checks <<- n_checks + 1
  if (!isTRUE(ok)) fails <<- c(fails, msg)
}

# Exactly one orig_ option per dimension
for (d in names(specs$dimensions)) {
  n_orig <- sum(startsWith(names(specs$dimensions[[d]]$options), "orig_"))
  check(n_orig == 1, sprintf("%s has %d orig_ options (need exactly 1)", d, n_orig))
}

check(nrow(grid) == 48, sprintf("grid has %d rows, expected 48", nrow(grid)))
check(sum(grid$is_baseline) == 1, "grid must contain exactly one baseline row")
check(!anyDuplicated(grid[, names(specs$dimensions)]), "grid has duplicate combinations")
check(grid$spec_id[1] == "IBYR_01" && grid$is_baseline[1], "baseline must be IBYR_01")
check(all(names(specs$dimensions) %in% results_columns), "results columns must include every dimension")

# Rubin's rules: no between-imputation variance gives the complete-data result
p <- pool_rubin(c(-0.2, -0.2, -0.2), c(0.08, 0.08, 0.08))
check(abs(p$estimate + 0.2) < 1e-12 && abs(p$std_error - 0.08) < 1e-12 && is.infinite(p$df),
      "pool_rubin with identical estimates")
p <- pool_rubin(c(-0.25, -0.20, -0.22, -0.24), rep(0.08, 4))
check(p$std_error > 0.08, "pool_rubin must inflate SE when estimates differ")

# The fitting gate must stop while the plan is unregistered
gate <- tryCatch(check_registered(list(registration = list(registered = FALSE, osf_url = ""))),
                 error = function(e) "stopped")
check(identical(gate, "stopped"), "check_registered must stop when unregistered")

if (length(fails)) {
  cat("FAILED:\n", paste0(" - ", fails, collapse = "\n"), "\n")
  quit(status = 1)
}
cat("All", n_checks, "checks passed.\n")
