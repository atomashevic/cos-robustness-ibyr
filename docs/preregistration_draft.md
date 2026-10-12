# Robustness Studies: Preregistration (draft)

Follows the COS preregistration template section by section. Copy into the COS document once the proposal is accepted. Items marked TODO need the data or a decision.

## 1. Paper, analyst, and focal result

| | |
| --- | --- |
| Analyst | Aleksandar Tomašević, Institute of Physics Belgrade |
| Paper ID | IBYR |
| Date | TODO |

**The focal result.** Table 1 (p. 2610), life satisfaction column, row "Anti-democratic attitudes × level of democracy": b = -0.23, SE = 0.08, p = .002, 95% CI [-0.38, -0.09].

**The analysis that produces it.** Unit: respondents (level 1) nested in countries (level 2); 131,846 respondents in 78 countries surveyed in WVS wave 7 or EVS 2017. Outcome: life satisfaction, single item, 1 to 10. Focal predictor: the product of the V-Dem Electoral Democracy Index 2020 (country level, 0 to 1) and anti-democratic attitudes (three reverse-coded regime items combined into a latent variable, cluster-mean centered). Adjusted for gender, age, education, marital status, employment status, GDP per capita PPP, government effectiveness, political stability, perceptions of corruption, World Bank income group and region. Estimator: linear mixed model with random intercepts and a random slope for attitudes (Stata 17), with multiple imputation of missing data. Uncertainty: model-based standard errors pooled across imputations, 95% confidence intervals. Direction: negative; the democracy slope decreases as anti-democratic attitudes increase.

**The focal estimate.** The fixed-effect coefficient on the product term `att_cwc:democracy`. Under d04 alternatives, `democracy` is the alternative measure; under a01, `att_cwc` is the two-item score; under a02, the country mean of attitudes is an added level-2 term and the focal term is unchanged. No option makes the quantity multi-valued.

## 2. Data

**Data source.** Joint EVS/WVS 2017 to 2021, GESIS ZA7505 v2.0.0 (doi 10.4232/1.13737), accessed TODO. V-Dem Country-Year v11.1 (doi 10.23696/vdemds21), accessed TODO. World Bank WDI and WGI, release TODO, accessed TODO. EIU Democracy Index (d04 alternative only), file TODO, accessed TODO. ZA7505 v2.0.0 and V-Dem v11.1 are the releases the author cites.

**Author materials.** ☐ Yes ☒ No. No replication code or supplement is available. Only the article was consulted.

**Prior work with this paper or these data.** ☒ Yes ☐ No. I have analyzed WVS and EVS data in earlier, unrelated work. TODO: name the projects. I have not worked with this paper before.

## 3. Dimensions and statuses

| # | Dimension | Status | Reason (none needed for Varied) |
| --- | --- | --- | --- |
| d01 | Analytic sample construction | Set aside | All respondents in the countries matched to V-Dem. Dropping territories or partially merged countries is reasonable but judged less consequential than the five varied. |
| d02 | Missing data handling | Varied | |
| d03 | Outcome operationalization | Not applicable | The outcome is a single, directly recorded 1 to 10 item with no construction step. |
| d04 | Focal predictor operationalization | Varied | |
| d05 | Categorization and thresholding | Not applicable | No continuous variable is cut by the analyst. Income group and region are categories supplied by the source. TODO: confirm age enters as continuous. |
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
| alt_vdem_fieldwork | No | V-Dem Electoral Democracy Index for the year of each country's fieldwork (2017 to 2021). | Fieldwork spans five years. Matching the index to the survey year measures the regime respondents lived under when interviewed. |
| alt_eiu_fieldwork | No | EIU Democracy Index for each country's fieldwork year, divided by 10. Countries without an EIU score are dropped from these specifications. | The EIU index is a standard alternative measure of the same construct, and the author used it alongside V-Dem in Prati (2022a). |

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
| alt_complete_case | No | Listwise deletion of respondents missing any analysis variable. | With item missingness below 3%, complete-case analysis is a standard and widely used choice. |

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

- Decisions the article leaves open, with the baseline reading for each, are listed in `docs/focal_result.md` ("Decisions the article leaves open"). TODO: paste the table here.
- Estimation uses maximum likelihood and an independent random-effects covariance, matching Stata `mixed` defaults.
- A specification counts as failed if the model fails to converge in any imputed dataset; it is recorded without an estimate.
- The robustness paragraph (p. 2613) reports a second complete-case estimate labelled life satisfaction that matches the happiness model; this looks like a typo and does not affect the focal result.
- No model was fitted before this plan was written. Before submission, only data preparation and descriptives were run (sample size, number of countries, item missingness, scale reliability). TODO: report those descriptives here, next to the article's N = 131,846 and 78 countries.
