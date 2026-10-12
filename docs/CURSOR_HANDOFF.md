# Cursor handoff: IBYR data preparation and preregistration descriptives

Take the IBYR robustness study from scaffold to a submittable preregistration. Your task ends with the data prepared, the descriptives the preregistration needs, and an updated preregistration draft. **It does not include fitting any model of life satisfaction.** Read `CLAUDE.md` first; its rules bind you. Fix verified problems rather than weakening checks to get a pass.

## 1. Establish the checkpoint

The scaffold checkpoint is commit `75f4038` on `main` in `~/work/cos-robustness-ibyr`. The repository is local only, with no remote. This handoff was added in a later commit. Inspect `git status -sb` and `git log --oneline` before starting. Preserve any local changes you find.

Read, in this order:

- `CLAUDE.md`: working rules, including the registration gate.
- `docs/focal_result.md`: the published result, the pipeline as reported with page numbers, and the table of decisions the article leaves open.
- `config/specifications.yaml` and `config/variables.yaml`.
- `docs/preregistration_draft.md`: the document your work feeds.
- `R/utils.R`, `R/02` to `R/06`, and both files in `tests/`.
- The article itself: `docs/source/IBYR.pdf` (local only, gitignored), especially pp. 2608 to 2610.

Context in two sentences: this is a Center for Open Science bounded multiverse study of one result, the cross-level interaction in Table 1 of Prati (2023) (b = -0.23, SE = 0.08). The plan varies five decisions (48 specifications) and must be registered on OSF before any model of the outcome is fitted.

## 2. The hard gate: no outcome models before registration

COS requires the analysis plan to be written and registered before anything is run. Until a human sets `registration.registered: true` and an OSF link in `config/specifications.yaml`:

- Do not run `R/07_run_baseline.R` or `R/08_run_multiverse.R`, and do not edit, bypass or stub out `check_registered()`.
- Do not fit `lmer`, `lm` or any other model with `life_satisfaction` as the outcome on real data, including quick console checks, "sanity" fits or correlations between life satisfaction and democracy.
- Do not change `registration` in the config. Only the user does that.

Allowed before registration: reading and recoding data, merging, sample counts, missingness, item distributions, the measurement model of the three regime items (for omega), and multiple imputation. Simulated-data tests are always allowed.

If something seems to require an outcome model, stop and report it instead.

## 3. Set up and run the data-free checks

R 4.3 or later. The scaffold was tested only in a cloud container (R 4.3.3, Ubuntu packages), not on this laptop.

```bash
cd ~/work/cos-robustness-ibyr
Rscript -e 'source("R/00_packages.R")'
Rscript R/01_build_spec_grid.R
Rscript tests/test_spec_grid.R
Rscript tests/test_fit_spec_simulated.R
```

Expected: 48 specifications, baseline `IBYR_01`, "All 13 checks passed", and "All simulated-data checks passed" in about 30 seconds. Record the R and package versions printed by `00_packages.R` in your report. If a test fails, diagnose and fix the code, not the test.

## 4. Check the data prerequisite

**The repository contains no data, and you cannot download the main file yourself:** GESIS requires the user's login. Check whether these exist:

| Needed | Expected location |
| --- | --- |
| Joint EVS/WVS 2017 to 2021, ZA7505 **v2.0.0** (.dta or .sav) and its codebook / variable report | `data/raw/` |
| V-Dem Country-Year **v11.1** | `data/external/vdem/` |
| World Bank: GDP per capita PPP, WGI (GE, PV, CC), income groups and regions | `data/external/worldbank/` |

Use the versions in bold; the COS guidance asks for the vintage the author used. Public sources (V-Dem archive, World Bank) you may download if your environment allows it. Record file name, version, URL and access date for every source in `docs/data_sources.md`.

If the joint file is absent, do steps 3, 5 (from the codebook alone, if it is present) and 8, then stop and report the missing prerequisite. Do not substitute a different release or a different survey file and call the step done.

Data never enters git (`data/` is ignored). Do not print respondent-level rows in reports.

## 5. Verify every variable mapping against the codebook

Every entry in `config/variables.yaml` is marked `verified: false`. The variable codes were written from memory and may be wrong. For each entry, check the ZA7505 codebook or variable report, then set `verified: true` and fill `source` with the document and page or the variable label. Correct any code that is wrong.

Check specifically:

- The negative missing-value codes (`na_negative()` in `R/utils.R` treats all negatives as missing).
- E114, E115, E116: wording matches the article (strong leader without parliament and elections; experts deciding; army rule) and 1 = very good, 4 = very bad. The scripts reverse them.
- Which education variable is harmonized across the EVS and WVS components. If `X025A_01` is not, use the harmonized one and note why.
- The fieldwork year variable (`S020`) and the country identifiers. Note how Great Britain and Northern Ireland, and any country surveyed by both EVS and WVS, appear in the file.

Country-level entries: fill the variable names from the downloaded files. For GDP, decide between constant and current international dollars, record the choice and its basis, and keep it in the "decisions the article leaves open" table.

## 6. Adapt the preparation scripts to the real files

`R/02_prepare_individual.R` should run once the mapping is verified. `R/03_prepare_country.R` assumes column names (`iso3`, `year`, `gdp_pc_ppp`, `GE.EST`, ...) that the downloaded files will not have. Adapt the reading code to the real formats. Do not change what the variables mean.

Fill `config/country_overrides.csv` for any ISO2 to ISO3 mismatch (V-Dem uses `XKX` for Kosovo, for example). Then run:

```bash
Rscript R/02_prepare_individual.R
Rscript R/03_prepare_country.R
Rscript R/04_build_analytic.R
```

## 7. Produce the descriptives and compare with the article

`R/04_build_analytic.R` writes `results/descriptives_sample.csv`, `results/descriptives_missingness.csv` and `results/descriptives_omega.csv`. Compare with the article:

| Quantity | Article |
| --- | --- |
| Respondents | 131,846 |
| Countries after merging with V-Dem | 78 |
| Item missingness | "low overall", read as below 3% |
| Omega, three-item scale | .63 |

Where the sample differs, explain it from data definitions only: which countries fail to match V-Dem, double samples, territories. Do not adjust the sample to hit 131,846. A documented gap is a result (CLAUDE.md, rule 5). Do not use any outcome model to diagnose a gap.

Then run `R/05_impute.R` (m = 20, expected 30 to 90 minutes). If it is much slower, profile it and propose a faster equivalent (for example `mice::futuremice`) before changing the configured method. Report the methods mice used and any logged events.

## 8. Update the documents

- `docs/preregistration_draft.md`: fill every TODO you can (data sources and access dates, descriptives in section 7, the decisions table in section 7 copied from `docs/focal_result.md`). Leave the date and the "Prior work" project names for the user.
- `docs/focal_result.md`: add any decision the data forced on you (education variable, GDP series, country matching, double samples), with its basis.
- `reports/claims.md`: one row per number you report, with the script that produced it.
- `README.md`: update the status table.
- Write `reports/01_data_preparation.md`: versions and access dates, verification outcome for every variable, sample flow from raw file to analytic sample, the comparison table above with our values, imputation runtime and diagnostics, and open questions. No qualitative claim without a number.

Writing style: no em dashes or en dashes; direct, plain prose.

## 9. Commit and stop

Commit in small steps with clear messages. There is no remote; do not add one or push. End with a short report to the user that names:

- what passed (tests, verification count, script runs),
- the sample comparison (our N and countries against 131,846 and 78),
- anything unresolved or needing the user's decision,
- that the preregistration draft is ready for the user to review and paste into the COS template.

Then stop. Registration, sending the proposal to COS, and every model run come after the user's review.

## Known open items

- The COS Results File Specification has not been received. `results_columns` in `R/utils.R` is provisional.
- The COS outcome reporting template link returns "not found"; the user will request it.
- The article does not say how the moderator was scored. The baseline reading is CFA factor scores; a unit-weighted mean is the alternative reading. Report the omega you get under the CFA.
- Countries with both an EVS and a WVS sample may carry two fieldwork years. The fieldwork-year options match on each respondent's year.
