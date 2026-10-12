# Build the specification grid from config/specifications.yaml.
# Runs without data. Output: results/spec_grid.csv

source("R/utils.R")

specs <- read_specs()
grid  <- build_spec_grid(specs)

ensure_dir(paths$results)
utils::write.csv(grid, file.path(paths$results, "spec_grid.csv"), row.names = FALSE)

n_dims   <- length(specs$dimensions)
n_total  <- prod(vapply(specs$dimensions, function(d) length(d$options), integer(1)))
cat(sprintf(
  "Dimensions varied: %d\nCombinations before exclusions: %d\nCombinations excluded: %d\nSpecifications to be run: %d\nBaseline: %s\n",
  n_dims, n_total, n_total - nrow(grid), nrow(grid), grid$spec_id[grid$is_baseline]
))
