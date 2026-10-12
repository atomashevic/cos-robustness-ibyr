# Claims ledger

Every number intended for the outcome report or the preregistration, with the script that produced it and its status.

| Claim | Value | Script and output | Status |
| --- | --- | --- | --- |
| Specifications to be run | 48 | `R/01_build_spec_grid.R`, `results/spec_grid.csv` | verified |
| d05 status | set_aside. Age, GDP per capita, the governance indicators, the democracy index and the attitude score are continuous, so cutpoints were open, but categorizing them is judged less consequential than the five varied decisions. The dimension is not varied, so the grid stays 48. | `config/specifications.yaml`, `docs/proposal.md`, `docs/preregistration_draft.md`; rechecked with `tests/test_spec_grid.R` | fixed |
| alt_vdem_fieldwork exclusion | Respondents whose fieldwork year (S020) is after 2020 are excluded from that option only. V-Dem v11.1 ends in 2020. They remain in every other specification. Country list not filled: no ZA7505 file in `data/raw`. | `config/specifications.yaml`, `R/06_fit_spec.R`, `R/04_build_analytic.R`, `docs/preregistration_draft.md` | fixed |
| Singular fit | A boundary (singular) fit keeps its estimate and sets singular to TRUE. One singular imputation does not fail the specification. Optimizer failure sets converged to FALSE and stores no estimate. | `R/06_fit_spec.R`, `docs/preregistration_draft.md`; checked against lme4 1.1.35.1 `checkConv` | fixed |
