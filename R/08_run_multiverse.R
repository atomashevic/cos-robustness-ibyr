# Run all specifications in the grid. Blocked until the plan is registered.
# Resumable: specifications already in the results file are skipped.
# Output: results/multiverse_results.csv, results/sessionInfo.txt

source("R/06_fit_spec.R")

specs <- read_specs()
check_registered(specs)

analytic <- readRDS(file.path(paths$derived, "analytic.rds"))
imp      <- readRDS(file.path(paths$derived, "imputations.rds"))
grid     <- build_spec_grid(specs)
out      <- file.path(paths$results, "multiverse_results.csv")

done <- if (file.exists(out)) utils::read.csv(out)$spec_id else character(0)
todo <- grid[!grid$spec_id %in% done, ]
cat(sprintf("%d specifications to run (%d already done)\n", nrow(todo), length(done)))

for (i in seq_len(nrow(todo))) {
  spec <- as.list(todo[i, ])
  set.seed(specs$settings$seed)
  t0 <- Sys.time()
  row <- tryCatch(run_spec(spec, analytic, imp, specs$settings),
                  error = function(e) {
                    r <- empty_row(spec); r$converged <- FALSE
                    r$failure_reason <- paste("error:", conditionMessage(e)); r
                  })
  utils::write.table(row[, results_columns], out, sep = ",", row.names = FALSE,
                     col.names = !file.exists(out), append = file.exists(out), qmethod = "double")
  cat(sprintf("[%s] %s  converged=%s  b=%s  (%.1f min)\n", format(Sys.time(), "%H:%M"), spec$spec_id,
              row$converged, format(round(row$estimate, 3)), as.numeric(difftime(Sys.time(), t0, units = "mins"))))
}

writeLines(utils::capture.output(utils::sessionInfo()), file.path(paths$results, "sessionInfo.txt"))
