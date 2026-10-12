# CLAUDE.md: COS robustness study IBYR

The study is defined by three documents. Read them before any work:

1. `docs/focal_result.md`: the published result and the pipeline as reported.
2. `config/specifications.yaml`: the five varied decisions and their options.
3. COS robustness guidance (linked in README.md). Its rules override anything here.

## Rules

1. **Raw data never enters git.** `data/` contents stay gitignored. Reports show aggregates only.
2. **Variable names come from codebooks, not memory.** Every entry in `config/variables.yaml` cites the codebook it was checked against. Entries marked `verified: false` are unverified.
3. **Rebuild from source.** Start from the raw Joint EVS/WVS file and the raw country sources, never from an analytic file supplied by anyone else.
4. **No model fits before registration.** COS requires the plan to be written before anything is run. Until `registration.registered` is true in `config/specifications.yaml`, only data preparation and descriptives are allowed (N, countries, missingness, scale reliability). The run scripts enforce this; do not bypass the check.
5. **Do not tune the baseline toward Table 1.** Report the gap between the rebuilt baseline and the published values as a result. Fix only genuine errors in our own code, and log each fix in `reports/claims.md`.
6. **The plan freezes at registration.** After the OSF registration, `config/specifications.yaml` and `R/06_fit_spec.R` change only to fix bugs. Log every deviation, with its reason, in `reports/deviations.md`.
7. **Failed fits stay in the results file.** A specification whose model did not converge gets `converged = FALSE`, a reason, and no estimate. Never fill in numbers from a fit that did not converge.
8. **N is the number the model used**, after exclusions and missing data, never the number of rows in the file.
9. **Claims ledger.** Every number intended for the outcome report goes into `reports/claims.md` with the script that produced it.

## Conventions

- R only. lme4 for mixed models (ML, not REML, to match Stata `mixed` defaults), lavaan for scale scoring, mice for imputation.
- Scripts in `R/` run in numeric order from the repository root.
- Seeds are set in `config/specifications.yaml` (`settings.seed`).
- Writing style: no em dashes or en dashes. Direct, plain scientific prose.
