# COS robustness study: IBYR

Bounded multiverse robustness analysis of one published result, for the Center for Open Science Replicability Project: Health Behavior (RP:HB). Paper ID **IBYR**. Analyst: Aleksandar Tomašević.

**Outcome report due: December 1, 2026** (to replications@cos.io, subject `[IBYR] Robustness Analysis Report`, .pdf or .docx, with all outputs).

## The focal result

Prati, G. (2023). The relationship between democracy and subjective well-being as a function of anti-democratic attitudes: a multilevel analysis of 78 countries worldwide. *Applied Research in Quality of Life*, 18, 2605 to 2618. https://doi.org/10.1007/s11482-023-10200-0

Table 1, life satisfaction column, row "Anti-democratic attitudes × level of democracy":

| b | SE | p | 95% CI |
| --- | --- | --- | --- |
| -0.23 | 0.08 | .002 | [-0.38, -0.09] |

Full description of the reported pipeline, with page references and ambiguities: [`docs/focal_result.md`](docs/focal_result.md).

## Status

| Step | Status |
| --- | --- |
| Proposal sent to COS | 2026-10-12 ([`docs/proposal.md`](docs/proposal.md)) |
| Proposal accepted | 2026-10-22 |
| Preregistration sent to COS | ([`docs/preregistration_draft.md`](docs/preregistration_draft.md)) |
| Preregistration reviewed and approved | |
| Data downloaded | not yet ([`docs/data_sources.md`](docs/data_sources.md)) |
| Variable names verified against codebooks | not yet ([`config/variables.yaml`](config/variables.yaml)) |
| Data prepared, descriptives only (N, countries, missingness, omega) | |
| Registered on OSF | |
| Baseline run and compared to Table 1 | blocked until registration |
| 48 specifications run | blocked until registration |
| Outcome report sent | |

## The multiverse

Five decisions are varied (3 × 2 × 2 × 2 × 2 = 48 specifications). Definitions live in [`config/specifications.yaml`](config/specifications.yaml); the grid is in [`results/spec_grid.csv`](results/spec_grid.csv).

| Code | Decision | Options |
| --- | --- | --- |
| d04 | Democracy measure | V-Dem EDI 2020 (orig) · V-Dem EDI at fieldwork year (2021 keeps 2020) · V-Dem LDI 2020 |
| a01 | Moderator scale items | strong leader + experts + army (orig) · strong leader + army |
| a02 | Contextual term | cluster-mean centered attitudes only (orig) · plus country mean at level 2 |
| d06 | Country controls | full set (orig) · without the three governance indicators |
| d02 | Missing data | multiple imputation (orig) · complete cases |

## Layout

```
config/        specifications.yaml (the five dimensions), variables.yaml (codebook mapping)
data/          raw/, external/, derived/   (all gitignored; see data/README.md)
docs/          focal result, proposal, preregistration draft, data sources
R/             pipeline scripts, run in numeric order
reports/       claims ledger and stage reports
results/       spec grid, multiverse results file, baseline comparison
tests/         checks that run without data
```

## Running

Run from the repository root with R 4.3 or later.

```r
source("R/00_packages.R")          # installs missing packages
```

```bash
Rscript R/01_build_spec_grid.R          # works now: writes results/spec_grid.csv
Rscript tests/test_spec_grid.R          # works now, no data needed
Rscript tests/test_fit_spec_simulated.R # works now: fitting code on simulated data
Rscript R/02_prepare_individual.R       # needs data/raw/ (Joint EVS/WVS)
Rscript R/03_prepare_country.R          # needs data/external/
Rscript R/04_build_analytic.R           # analytic sample + descriptives for the preregistration
Rscript R/05_impute.R                   # multiple imputation, 30 to 90 minutes
Rscript R/07_run_baseline.R             # after registration: baseline vs Table 1
Rscript R/08_run_multiverse.R           # after registration: all 48 specifications
```

`R/06_fit_spec.R` holds the functions that fit one specification; the run scripts source it.

The two run scripts refuse to fit models until `registration.registered` is set to `true` in `config/specifications.yaml`. COS requires the plan to be written before anything is run.


## Rules

1. **Raw data never enters git.** `data/` contents stay gitignored. Reports show aggregates only.
2. **Variable names come from codebooks, not memory.** Every entry in `config/variables.yaml` cites the codebook it was checked against. Entries marked `verified: false` are unverified.
3. **Rebuild from source.** Start from the raw Joint EVS/WVS file and the raw country sources, never from an analytic file supplied by anyone else.
4. **No model fits before registration.** Until `registration.registered` is true in `config/specifications.yaml`, only data preparation and descriptives are allowed (N, countries, missingness, scale reliability). The run scripts enforce this.
5. **Do not tune the baseline toward Table 1.** The gap between the rebuilt baseline and the published values is reported as a result. Only genuine errors in our own code are fixed, and each fix is logged in `reports/claims.md`.
6. **The plan freezes at registration.** After the OSF registration, `config/specifications.yaml` and `R/06_fit_spec.R` change only to fix bugs. Every deviation is logged, with its reason, in `reports/deviations.md`.
7. **Failed fits stay in the results file.** A specification whose model did not converge gets `converged = FALSE`, a reason, and no estimate.
8. **N is the number the model used**, after exclusions and missing data, never the number of rows in the file.
9. **Claims ledger.** Every number intended for the outcome report goes into `reports/claims.md` with the script that produced it.

## COS materials

- [Project guidelines](https://docs.google.com/document/d/1moTEsxHb2-Z64OnkyuCXVw17oLz2vdtlvxxKiWz1_7Y/edit)
- [Robustness guidance](https://docs.google.com/document/d/1RjIzIAmEXCGIkvEmMEa9koS83FxrdS_ypo7SrfOvswI/edit)
- [Preregistration template](https://docs.google.com/document/d/1yloKFe6tlZWGZpyErpeEB2bcLXU7y3qw/edit)
- [Study sourcing sheet](https://docs.google.com/spreadsheets/d/1DFkniOWdYj6mc-j4Y52VeI_FGiPN9F452pSSAMbSI_s/edit)
- [Outcome reporting template](https://docs.google.com/document/d/1I1o98He_nPTKaU_J1A9Hc5XRiYOTGyZS/edit)
