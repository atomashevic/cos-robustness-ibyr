# Robustness Studies: Preregistration

Follows the COS preregistration template section by section. This is the text of the preregistration sent to COS for review; it is not registered yet.

## 1. Paper, analyst, and focal result

| | |
| --- | --- |
| Analyst | Aleksandar Tomašević, Institute of Physics Belgrade |
| Paper ID | IBYR. Prati, G. (2023). Applied Research in Quality of Life, 18, 2605 to 2618. https://doi.org/10.1007/s11482-023-10200-0 |
| Date | 1 November 2026 |

**The focal result.** Table 1 (p. 2610), life satisfaction column, row “Anti-democratic attitudes × level of democracy”: b = -0.23, SE = 0.08, p = .002, 95% CI [-0.38, -0.09].

**The analysis that produces it.**

Unit and population: respondents (level 1) nested in countries (level 2); 131,846 respondents in 78 countries surveyed in WVS wave 7 or EVS 2017, after merging with V-Dem.

Outcome: life satisfaction, a single item (“All things considered, how satisfied are you with your life as a whole these days?”), 1 to 10.

Focal predictor: the product of the V-Dem Electoral Democracy Index for 2020 (country level, 0 to 1) and anti-democratic attitudes (three reverse-coded items on ways of governing: strong leader, rule by experts, army rule; combined into a latent variable, omega = .63; cluster-mean centered).

Adjusted for: gender, age, education, marital status, employment status, GDP per capita (PPP), government effectiveness, political stability, perceptions of corruption, World Bank income group and World Bank region.

Estimator: two-level linear mixed model with random intercepts and a random slope for attitudes (Stata 17 mixed, maximum likelihood), after multiple imputation of missing data. I will fit it in R with lme4, score the scale with lavaan, and impute with mice.

Uncertainty: model-based standard errors pooled across imputations; 95% confidence intervals.

Direction: negative. The slope of life satisfaction on the level of democracy decreases as anti-democratic attitudes increase; it is positive at low attitudes and negative at high attitudes (Fig. 1, p. 2611).

**The focal estimate.** The fixed-effect coefficient on the product term att_cwc:democracy in the life satisfaction model. Under the d04 alternatives, democracy is the fieldwork-year electoral index or the 2020 liberal index; under a01, att_cwc is the two-item score; under a02, the country mean of attitudes is an added level-2 term and the focal term is unchanged. No option makes the quantity multi-valued.

## 2. Data

**Data source.**

Joint EVS/WVS 2017 to 2021, GESIS ZA7505 v2.0.0 (doi 10.4232/1.13737).

V-Dem Country-Year v11.1 (doi 10.23696/vdemds21), supplying the Electoral Democracy Index (v2x_polyarchy) and the Liberal Democracy Index (v2x_libdem).

World Bank WDI GDP per capita, PPP (constant 2017 international $, series NY.GDP.PCAP.PP.KD); WGI estimates of government effectiveness, political stability and control of corruption; and the World Bank income-group and region classifications; all for 2020. The article does not say whether GDP is in constant or current prices; the constant-price series is the baseline reading.

ZA7505 v2.0.0 and V-Dem v11.1 are the releases the author cites. Both are archived and will be used instead of the current releases. The article does not name the World Bank releases. I will use the archived 2022 WDI and WGI releases where they can be retrieved (the article was received on 28 November 2022), otherwise the current releases, and record which one was used.

Access date: none of these files has been downloaded for this study yet. The file name and access date of each will be recorded at download, before any data preparation, and reported with the outcomes.

**Author materials.** ☐ Yes ☒ No. No replication code or supplement is available. Only the article was consulted.

**Prior work with this paper or these data.** ☒ Yes ☐ No.

Yes, with the data sources in general, not with this paper or this data file.

WVS and EVS: I have analyzed earlier WVS and EVS data in unpublished work. I have not used the Joint EVS/WVS 2017 to 2021 file (ZA7505) before, and I have not analyzed the variables of this paper's model (the regime items, life satisfaction, or their relation to democracy).

V-Dem: I have used V-Dem data in earlier work unrelated to this paper.

European Social Survey: my published survey work uses the ESS. I worked on Serbia's participation in the ESS (2017 to 2025) and taught a workshop on statistical methods for ESS data (2019). Publications include Stanojević, D., & Tomašević, A. (2021). Housing and family trajectories of young adults in five countries: Sweden, Germany, United Kingdom, Italy and Serbia: Sequence analysis of European Social Survey data. Sociologija, 63(2), 262 to 288. https://doi.org/10.2298/SOC2102262S

This paper: I have not reproduced or otherwise worked with Prati (2023) before this robustness study, in the reproduction workflow or elsewhere.

## 3. Dimensions and statuses

| # | Dimension | Status | Reason (none needed for Varied) |
| --- | --- | --- | --- |
| d01 | Analytic sample construction | Set aside | The analytic sample is all respondents in the countries matched to V-Dem. Country-level variables are not imputed, so a country without a World Bank value for a control that a specification includes is excluded from that specification; the excluded countries will be reported. Dropping territories or partially merged countries is reasonable but judged less consequential than the five varied decisions. |
| d02 | Missing data handling | Varied |  |
| d03 | Outcome operationalization | Not applicable | The outcome is a single, directly recorded 1-to-10 item with no construction step. |
| d04 | Focal predictor operationalization | Varied |  |
| d05 | Categorization and thresholding | Set aside | Age, GDP per capita, the governance indicators, the democracy index and the attitude score are continuous, so cutpoints were open, but categorizing them is judged less consequential than the five varied decisions. |
| d06 | Covariate set | Varied |  |
| d07 | Estimator and functional form | Set aside | An ordinal mixed model is defensible for a 10-point item, but linear mixed models are standard for this outcome and keep the interaction on the reported scale. |
| d08 | Clustering, nesting, and standard errors | Set aside | The article already models slope variance across countries, which addresses the main standard-error concern for a cross-level interaction. An unstructured random-effects covariance is a smaller variation. |
| d09 | Sampling weights and complex design | Set aside | The joint file supplies design weights, which the article does not use. They adjust within-country composition, while the focal term rests on between-country variation in democracy. |

| Code | Decision |
| --- | --- |
| a01 | Composition of the anti-democratic attitudes scale |
| a02 | Contextual term (country mean) for the cluster-mean centered moderator |

## 4. The five you are varying

### d04: Democracy measure (the level-2 component of the focal predictor)

| Option | Original? | What it does | Why it is a reasonable choice for this question |
| --- | --- | --- | --- |
| orig_vdem2020 | Yes | V-Dem Electoral Democracy Index for 2020, V-Dem v11.1, for every country. | — |
| alt_vdem_fieldwork | No | V-Dem Electoral Democracy Index for each respondent's fieldwork year (S020), V-Dem v11.1. Version 11.1 ends in 2020, so respondents interviewed in 2021 keep the 2020 score, the latest available value, as under the original option. The affected country-years will be listed in the outcome report. | Fieldwork spans 2017 to 2021, so a fixed 2020 score can postdate the interview by up to three years. Matching the index to the survey year measures the regime respondents lived under when interviewed. |
| alt_vdem_libdem2020 | No | V-Dem Liberal Democracy Index (v2x_libdem) for 2020, from the same v11.1 release. | Same source and vintage as the original, full coverage of the file, and the broader construct (electoral democracy plus liberal constraints on the executive) that much of the democracy and well-being literature means by democracy. |

### a01: Composition of the anti-democratic attitudes scale

| Option | Original? | What it does | Why it is a reasonable choice for this question |
| --- | --- | --- | --- |
| orig_three_items | Yes | Strong leader, expert rule and army rule items, reverse coded, scored as factor scores (regression method) from a pooled one-factor CFA. The article says only that the items were combined into a latent variable and reports omega; I read that as a factor model. | — |
| alt_two_items | No | Strong leader and army rule items only, reverse coded, scored from a two-indicator factor model with equal loadings. | Reliability is modest (omega = .63), and a preference for rule by experts is often read as technocratic rather than autocratic (Kirsch and Welzel, 2019, cited by the author). The two-item scale keeps only the clearly autocratic options. |

### a02: Contextual term for the cluster-mean centered moderator

| Option | Original? | What it does | Why it is a reasonable choice for this question |
| --- | --- | --- | --- |
| orig_no_context | Yes | Attitudes are cluster-mean centered, and the country mean of attitudes is not in the model. | — |
| alt_country_mean | No | The country mean of attitudes is added as a level-2 predictor. The focal term stays the product of within-country centered attitudes and democracy. | With cluster-mean centering, omitting the country mean leaves between-country differences in attitudes to be absorbed by democracy and the country controls. Including it is the standard contextual specification. |

### d06: Country-level controls

| Option | Original? | What it does | Why it is a reasonable choice for this question |
| --- | --- | --- | --- |
| orig_full | Yes | GDP per capita (PPP), government effectiveness, political stability, perceptions of corruption (WGI Control of Corruption), World Bank income group and region. | — |
| alt_no_governance | No | Drops government effectiveness, political stability and control of corruption; keeps GDP per capita, income group and region. | Governance quality is partly a consequence of democracy, so adjusting for it can absorb the country-level variation the focal term relies on. With 78 countries, the full set uses about 13 level-2 parameters. |

### d02: Missing data handling

| Option | Original? | What it does | Why it is a reasonable choice for this question |
| --- | --- | --- | --- |
| orig_mi | Yes | Multiple imputation of the individual-level analysis variables: m = 20, 10 iterations, mice default methods (predictive mean matching for numeric variables, logistic and multinomial regression for binary and nominal factors), with all individual analysis variables and country indicators as predictors. The imputation model contains no country-level variables and no product term; the country indicators absorb country-level differences in means. Estimates are pooled with Rubin's rules. The article reports only that multiple imputation was used; the method, m and the imputation model are my reading. | — |
| alt_complete_case | No | Listwise deletion of respondents missing any analysis variable. | With item missingness below 3%, complete-case analysis is a standard choice, and it is the author's own robustness check (b = -0.27, SE = 0.08). |

## 5. Combinations that cannot be run

| Dimensions | Combination | Why it is excluded |
| --- | --- | --- |
| None | — | Every combination is defined. |

## 6. Specification count

| | |
| --- | --- |
| Dimensions varied | 5 |
| Combinations before exclusions | 48 (3 × 2 × 2 × 2 × 2) |
| Combinations excluded | 0 |
| Specifications to be run | 48 |

## 7. Notes

Code: https://github.com/atomashevic/cos-robustness-ibyr. The scripts that fit models stop unless the registration is recorded in config/specifications.yaml. No data have been downloaded or prepared, and no model has been fitted. The baseline takes the original option on every varied dimension, and any difference between the baseline and Table 1 will be reported as a result.

The article does not report several decisions, and the baseline uses the following readings. The moderator is scored as regression-method factor scores from a one-factor CFA pooled across countries, because the article describes a latent variable and reports omega; a unit-weighted mean is the other possible reading. The phrase “>3%” in the description of item missingness is read as below 3%. “Don't know” answers on the regime items are treated as missing and imputed. Estimation uses maximum likelihood and an independent random-effects covariance, the defaults of Stata's mixed command. GDP per capita enters unlogged, in units of 10,000 international dollars. All country-level controls are taken for 2020, the V-Dem year. “Perceptions of corruption” is the WGI Control of Corruption estimate, because the article lists it with two other WGI indicators. Education, marital status and employment status enter as factors with the joint file's categories, and age enters as a continuous linear term.

A boundary (singular) fit counts as converged; its estimate is kept and the fit is flagged as singular. An optimizer failure in the observed data or in any imputed dataset marks the specification as not converged, and no estimate is recorded.

On p. 2613 the article reports a second complete-case estimate labelled life satisfaction (b = -0.08, SE = 0.02) that matches the happiness model. This is probably a typographical error and does not concern the focal result. A correction to the article (doi 10.1007/s11482-023-10216-6) changed only the format of the abstract.
