# Robustness Studies: Preregistration

Follows the COS preregistration template section by section. This is the text of the preregistration sent to COS for review; it is not registered yet.

## 1. Paper, analyst, and focal result

| | |
| --- | --- |
| Analyst | Aleksandar Tomašević, Institute of Physics Belgrade |
| Paper ID | IBYR |
| Date | 1 November 2026 |

**The focal result.** Table 1 (p. 2610), life satisfaction column, row "Anti-democratic attitudes × level of democracy": b = -0.23, SE = 0.08, p = .002, 95% CI [-0.38, -0.09].

**The analysis that produces it.** Unit: respondents (level 1) nested in countries (level 2); 131,846 respondents in 78 countries surveyed in WVS wave 7 or EVS 2017. Outcome: life satisfaction, single item, 1 to 10. Focal predictor: the product of the V-Dem Electoral Democracy Index 2020 (country level, 0 to 1) and anti-democratic attitudes (three reverse-coded regime items combined into a latent variable, cluster-mean centered). Adjusted for gender, age, education, marital status, employment status, GDP per capita PPP, government effectiveness, political stability, perceptions of corruption, World Bank income group and region. Estimator: linear mixed model with random intercepts and a random slope for attitudes (Stata 17), with multiple imputation of missing data. Uncertainty: model-based standard errors pooled across imputations, 95% confidence intervals. Direction: negative; the democracy slope decreases as anti-democratic attitudes increase.

**The focal estimate.** The fixed-effect coefficient on the product term `att_cwc:democracy`. Under d04 alternatives, `democracy` is the fieldwork-year electoral index or the 2020 liberal index; under a01, `att_cwc` is the two-item score; under a02, the country mean of attitudes is an added level-2 term and the focal term is unchanged. No option makes the quantity multi-valued.

## 2. Data

**Data source.** Joint EVS/WVS 2017 to 2021, GESIS ZA7505 v2.0.0 (doi 10.4232/1.13737). V-Dem Country-Year v11.1 (doi 10.23696/vdemds21), supplying the Electoral Democracy Index (v2x_polyarchy) and the Liberal Democracy Index (v2x_libdem). World Bank WDI (GDP per capita, PPP), WGI (government effectiveness, political stability, control of corruption), and the World Bank income-group and region classifications, all for 2020.

ZA7505 v2.0.0 and V-Dem v11.1 are the releases the author cites. Both are archived and will be used instead of the current releases. The article does not name the World Bank releases. I will use the archived 2022 WDI and WGI releases where they can be retrieved (the article was received on 28 November 2022), otherwise the current releases, and record which one was used.

Access date: none of these files has been downloaded for this study yet. The file name and access date of each will be recorded at download, before any data preparation, and reported with the outcomes.

**Author materials.** ☐ Yes ☒ No. No replication code or supplement is available. Only the article was consulted.

**Prior work with this paper or these data.** ☒ Yes ☐ No. With the data sources in general, not with this paper or this data file.

- WVS and EVS: I have analyzed earlier WVS and EVS data in unpublished work. I have not used the Joint EVS/WVS 2017 to 2021 file (ZA7505) before, and I have not analyzed the variables of this paper's model (the regime items, life satisfaction, or their relation to democracy).
- V-Dem: I have used V-Dem data in earlier work unrelated to this paper.
- European Social Survey: my published survey work uses the ESS. I worked on Serbia's participation in the ESS (2017 to 2025) and taught a workshop on statistical methods for ESS data (2019). Publications include Stanojević, D., & Tomašević, A. (2021). Housing and family trajectories of young adults in five countries: Sweden, Germany, United Kingdom, Italy and Serbia: Sequence analysis of European Social Survey data. *Sociologija*, 63(2), 262 to 288. https://doi.org/10.2298/SOC2102262S
- This paper: I have not reproduced or otherwise worked with Prati (2023) before this robustness study, in the reproduction workflow or elsewhere.

## 3. Dimensions and statuses

| # | Dimension | Status | Reason (none needed for Varied) |
| --- | --- | --- | --- |
| d01 | Analytic sample construction | Set aside | All respondents in the countries matched to V-Dem. Dropping territories or partially merged countries is reasonable but judged less consequential than the five varied. |
| d02 | Missing data handling | Varied | |
| d03 | Outcome operationalization | Not applicable | The outcome is a single, directly recorded 1 to 10 item with no construction step. |
| d04 | Focal predictor operationalization | Varied | |
| d05 | Categorization and thresholding | Set aside | Age, GDP per capita, the governance indicators, the democracy index and the attitude score are continuous, so cutpoints were open, but categorizing them is judged less consequential than the five varied decisions. |
| d06 | Covariate set | Varied | |
| d07 | Estimator and functional form | Set aside | An ordinal mixed model is defensible for a 10-point item, but linear models are standard for this outcome and keep the interaction on the reported scale. |
| d08 | Clustering, nesting, and standard errors | Set aside | The article already models slope variance across countries, which addresses the main standard-error concern for a cross-level interaction. An unstructured random-effects covariance is a smaller variation. |
| d09 | Sampling weights and complex design | Set aside | The joint file supplies design weights, unused in the article. They adjust within-country composition, while the focal term rests on between-country variation in democracy. |

| Code | Decision |
| --- | --- |
| a01 | Composition of the anti-democratic attitudes scale |
| a02 | Contextual term (country mean) for the cluster-mean centered moderator |

## 4. The five you are varying

### d04: Democracy measure (the level-2 component of the focal predictor)

| Option | Original? | What it does | Why it is a reasonable choice for this question |
| --- | --- | --- | --- |
| orig_vdem2020 | Yes | V-Dem Electoral Democracy Index for 2020 for every country. | |
| alt_vdem_fieldwork | No | V-Dem Electoral Democracy Index for each respondent's fieldwork year (S020), V-Dem v11.1. Version 11.1 ends in 2020, so respondents interviewed in 2021 keep the 2020 score, the latest available value, as under the original option. The affected country-years will be listed in the outcome report. | Fieldwork spans 2017 to 2021, so a fixed 2020 score can postdate the interview by up to three years. Matching the index to the survey year measures the regime respondents lived under when interviewed. |
| alt_vdem_libdem2020 | No | V-Dem Liberal Democracy Index (v2x_libdem) for 2020, from the same v11.1 release. | Same source and vintage as the original, full coverage of the file, and the broader construct (electoral democracy plus liberal constraints on the executive) that much of the democracy and well-being literature means by democracy. |

### a01: Anti-democratic attitudes scale composition

| Option | Original? | What it does | Why it is a reasonable choice for this question |
| --- | --- | --- | --- |
| orig_three_items | Yes | Strong leader, expert rule and army rule items, reversed, scored as factor scores from a one-factor CFA (baseline reading of "latent variable"). | |
| alt_two_items | No | Strong leader and army rule items only, scored from a two-indicator factor model with equal loadings. | Reliability is modest (omega = .63), and preference for rule by experts is often treated as technocratic rather than autocratic (Kirsch and Welzel, 2019, cited by the author). The two-item scale keeps only the clearly autocratic options. |

### a02: Contextual term for the moderator

| Option | Original? | What it does | Why it is a reasonable choice for this question |
| --- | --- | --- | --- |
| orig_no_context | Yes | Attitudes are cluster-mean centered; the country mean of attitudes is not in the model. | |
| alt_country_mean | No | The country mean of attitudes is added as a level-2 predictor. | With cluster-mean centering, omitting the country mean leaves between-country differences in attitudes to be absorbed by democracy and the country controls. Including it is the standard contextual specification; the focal term remains the within-country product. |

### d06: Country-level controls

| Option | Original? | What it does | Why it is a reasonable choice for this question |
| --- | --- | --- | --- |
| orig_full | Yes | GDP per capita PPP, government effectiveness, political stability, control of corruption, income group, region. | |
| alt_no_governance | No | Drops government effectiveness, political stability and control of corruption; keeps GDP, income group and region. | Governance quality is partly a consequence of democracy, so adjusting for it can absorb the country-level variation the focal term relies on. With 78 countries, the full set uses about 13 level-2 parameters. |

### d02: Missing data

| Option | Original? | What it does | Why it is a reasonable choice for this question |
| --- | --- | --- | --- |
| orig_mi | Yes | Multiple imputation (m = 20, 10 iterations, mice default methods: predictive mean matching for numeric variables, logistic and multinomial regression for binary and nominal factors; all individual analysis variables plus country indicators as predictors), estimates pooled with Rubin's rules. The method, m and imputation model are my reading; the article reports only that multiple imputation was used. | |
| alt_complete_case | No | Listwise deletion of respondents missing any analysis variable. | With item missingness below 3%, complete-case analysis is a standard choice, and it is the author's own robustness check (b = -0.27, SE = 0.08). |

## 5. Combinations that cannot be run

| Dimensions | Combination | Why it is excluded |
| --- | --- | --- |
| none | | Every combination is defined. |

## 6. Specification count

| | |
| --- | --- |
| Dimensions varied | 5 |
| Combinations before exclusions | 48 |
| Combinations excluded | 0 |
| Specifications to be run | 48 |

## 7. Notes

- Code: https://github.com/atomashevic/cos-robustness-ibyr. The run scripts refuse to fit any model until the registration is recorded in config/specifications.yaml.
- No model has been fitted, and no data have been downloaded or prepared for this study. The baseline takes the original option on every varied dimension; any gap between the baseline and Table 1 will be reported as a result.
- Decisions the article leaves open, with the baseline reading of each:
  - Scoring the moderator: the article says “latent variable” and reports omega. Baseline: factor scores (regression method) from a pooled one-factor CFA on the three reversed items. A unit-weighted mean is the other reading.
  - Missingness: the article writes “>3%” in a sentence describing missingness as low overall. Read as below 3%.
  - Imputation method, m and model: not reported. Baseline as described under d02.
  - “Don't know” answers on the regime items: not reported. Treated as missing and imputed.
  - Estimation: Stata 17 mixed. Baseline: maximum likelihood and an independent random-effects covariance, the Stata defaults.
  - GDP per capita: the article does not mention a log. Entered unlogged, in USD 10,000.
  - Year of the country controls: not reported. Baseline: 2020, matching the V-Dem year.
  - “Perceptions of corruption”: operationalized as the WGI Control of Corruption estimate, since it sits with two other WGI indicators.
  - Education, marital status and employment status: coding not reported. Joint-file categories as supplied, entered as factors.
  - Age: not reported. Continuous, linear.
- Convergence: a boundary (singular) fit counts as converged. The estimate is kept and flagged as singular, and one singular imputation does not fail a specification. An optimizer failure, including one in any imputed dataset, marks the specification as not converged, with no estimate.
- The robustness paragraph (p. 2613) gives a second complete-case estimate labelled life satisfaction (b = -0.08, SE = 0.02) that matches the happiness model. It looks like a typo and does not affect the focal result. The happiness model is not part of this study.
- A correction to the article (doi 10.1007/s11482-023-10216-6) changed only the format of the abstract.
