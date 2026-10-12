# Focal result and reported pipeline

Source: Prati (2023), *Applied Research in Quality of Life* 18, 2605 to 2618, doi 10.1007/s11482-023-10200-0. Page numbers below are journal pages. A correction (doi 10.1007/s11482-023-10216-6) changed only the abstract format.

## Focal result

Table 1 (p. 2610), life satisfaction column, row "Anti-democratic attitudes × level of democracy".

| Quantity | Value |
| --- | --- |
| b | -0.23 |
| SE | 0.08 |
| p | .002 |
| 95% CI | [-0.38, -0.09] |

Direction: the slope of life satisfaction on the level of democracy decreases as anti-democratic attitudes increase. Simple slopes (Fig. 1, p. 2611): positive at -1 SD of attitudes, negative at +1 SD.

**Focal estimate in our output:** the fixed-effect coefficient on the product term `att_cwc:democracy` in the life satisfaction model.

### Other values in Table 1 (for checking the baseline)

| Term | b (SE) | p | 95% CI |
| --- | --- | --- | --- |
| Intercept | 8.64 (1.14) | < .001 | 6.40, 10.87 |
| Anti-democratic attitudes | 0.14 (0.05) | .006 | 0.04, 0.23 |
| Level of democracy | -0.06 (0.35) | .857 | -0.75, 0.62 |
| Interaction | -0.23 (0.08) | .002 | -0.38, -0.09 |
| SD of attitudes slope | 0.15 (0.02) | | 0.12, 0.18 |
| SD of random intercept | 0.44 (0.04) | | 0.37, 0.51 |
| SD of level-1 residual | 2.04 (0.00) | | 2.03, 2.05 |

Preliminary analyses (p. 2609): empty-model ICC = .12, 95% CI [.09, .15]. Adding the random slope for attitudes: LR χ²(1) = 215.77, p < .001.

Author's robustness checks (pp. 2610, 2613): complete cases b = -0.27, SE = 0.08, p = .001, 95% CI [-0.42, -0.11]; without covariates b = -0.23, SE = 0.08, p = .002.

## Pipeline as reported

| Element | As reported | Page |
| --- | --- | --- |
| Data | WVS wave 7 (2017 to 2021) and EVS 2017, via the Joint EVS/WVS 2017 to 2021 file (ZA7505 v2.0.0) | 2608, refs |
| Sample | 131,846 respondents, 78 countries, after merging with V-Dem | 2608 |
| Outcome | "All things considered, how satisfied are you with your life as a whole these days?", 1 to 10 | 2608 |
| Moderator | Three items on ways of governing (strong leader without parliament and elections; experts deciding; army rule), each 1 very good to 4 very bad, reverse coded, "constructing the latent variable", omega = .63 | 2608 |
| Centering | Attitudes cluster-mean centered | 2608 |
| Democracy | V-Dem Electoral Democracy Index 2020 (V-Dem v11.1), 0 to 1 | 2608 |
| Individual controls | gender, age, education, marital status, employment status | 2609 |
| Country controls | GDP per capita (PPP), government effectiveness, political stability, perceptions of corruption, World Bank income group (4), World Bank region | 2609 |
| Control sources | Joint EVS/WVS, V-Dem 2020, World Bank data | 2609 |
| Missing data | "Item-level missingness was low overall (>3%)"; multiple imputation | 2608 |
| Model | Multilevel mixed-effects linear regression, random intercept and random slope for attitudes; Stata 17 | 2608, 2609 |
| Inference | 95% CIs; simple slopes and Johnson-Neyman via Preacher et al. (2006) tool | 2608, 2609 |
| Weights | not mentioned | |

## Decisions the article leaves open

Each gets a baseline reading. The reading and its basis go into the preregistration notes.

| Decision | Article | Baseline reading | Basis |
| --- | --- | --- | --- |
| How the moderator is scored | "latent variable", omega reported | Factor scores (regression method) from a pooled one-factor CFA on the three reversed items | Wording and omega point to a factor model; a unit-weighted mean is the alternative reading |
| Missingness threshold | ">3%" | Below 3% | Context says "low overall" |
| Imputation method, m, model | not reported | mice default methods (pmm for numeric, logreg and polyreg for factors), m = 20, all individual analysis variables plus country indicators | Common default; country indicators keep the clustering in the imputation model |
| "Don't know" on regime items | not reported | Treated as missing and imputed | Follows from multiple imputation of item nonresponse |
| Estimation | Stata 17 `mixed` | Maximum likelihood (Stata default), independent random-effects covariance (Stata default) | Software defaults |
| GDP per capita | "GDP at PPP per capita" | Not logged, in USD 10,000 | Article does not mention a log |
| Year of country controls | not reported | 2020, matching the V-Dem year | Only year named in the article |
| Corruption source | "perceptions of corruption" | World Bank WGI Control of Corruption | Sits with two other WGI indicators named with WGI labels |
| Education, marital status, employment coding | not reported | Joint-file categories as supplied, entered as factors | No recoding described |
| Age | not reported | Continuous, linear | No banding described |

## Notes for reviewers

- The robustness paragraph (p. 2613) gives a second complete-case estimate (b = -0.08, SE = 0.02) labelled as life satisfaction. It matches the happiness model and is likely a typo. It does not affect the focal result.
- The happiness model is not part of this study. The focal result is the life satisfaction model only.
