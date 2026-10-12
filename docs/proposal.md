# [IBYR] Robustness Proposal

To: replications@cos.io
Subject: [IBYR] Robustness Proposal

Dear Ella and Ashleigh,

I would like to conduct the robustness study for IBYR (Prati, 2023, *Applied Research in Quality of Life*). My proposed approach is below. I will rebuild the analysis in R from the Joint EVS/WVS 2017 to 2021 file and V-Dem version 11.1, and vary five decisions around the focal cross-level interaction (48 specifications). I have worked with WVS and EVS data before and will record this in the preregistration.

I am a senior research associate at the Institute of Physics Belgrade, working in computational social science and quantitative sociology. I can deliver the preregistration draft within a week of approval.

Best regards,
Aleksandar Tomašević

---

## Proposal

**Focal result.** Table 1, life satisfaction column, row "Anti-democratic attitudes × level of democracy": b = -0.23, SE = 0.08, p = .002, 95% CI [-0.38, -0.09]. The democracy slope is positive at low anti-democratic attitudes (-1 SD) and negative at high attitudes (+1 SD).

**Data.** Joint EVS/WVS 2017 to 2021 (GESIS ZA7505, version 2.0.0), V-Dem version 11.1 for the Electoral Democracy Index 2020, and World Bank data for the country controls. The article reports 131,846 respondents in 78 countries.

**Pipeline as reported.** Life satisfaction (1 to 10) is regressed on the V-Dem Electoral Democracy Index, anti-democratic attitudes (three reverse-coded regime items combined into a latent variable, omega = .63, cluster-mean centered), and their product, controlling for gender, age, education, marital status, employment status, GDP per capita (PPP), government effectiveness, political stability, perceptions of corruption, World Bank income group and region. The model is a two-level linear mixed model (Stata 17) with random intercepts and a random slope for attitudes. Missing data are handled by multiple imputation. I will rebuild the pipeline in R (lme4, lavaan, mice) from the raw joint file.

**Proposed varied dimensions (3 × 2 × 2 × 2 × 2 = 48 specifications)**

| Code | Decision | Original option | Alternative(s) | Why the alternative is reasonable |
| --- | --- | --- | --- | --- |
| d04 | Democracy measure | V-Dem Electoral Democracy Index, fixed at 2020 | (a) Same index matched to each respondent's fieldwork year. Respondents whose fieldwork year (S020) is after 2020 are excluded from these specifications, because V-Dem v11.1 ends in 2020 and supplies no later value. They remain in every other specification. The countries are named at data preparation. (b) EIU Democracy Index, matched to fieldwork year | EVS fieldwork began in 2017, so a 2020 score can postdate the survey by three years. The author used the EIU index alongside V-Dem in a companion 78-country study (Prati, 2022a). |
| a01 | Moderator scale composition | Strong leader, expert rule and army rule | Strong leader and army rule only | Omega is .63, and rule by experts is often read as technocratic rather than autocratic preference (Kirsch and Welzel, 2019, cited by the author). |
| a02 | Contextual term for the centered moderator | Cluster-mean centered attitudes, no country mean | Add the country mean of attitudes at level 2 | Without the country mean, between-country differences in attitudes are absorbed by democracy and the controls. The focal term stays the within-country product. |
| d06 | Country-level controls | GDP, government effectiveness, political stability, corruption, income group, region | Drop the three governance indicators | Governance quality is partly a consequence of democracy, so adjusting for it can absorb the focal country-level variation. The full set spends about 13 parameters on 78 countries. |
| d02 | Missing data | Multiple imputation | Complete-case analysis | Both are standard with item missingness below 3%. |

**Dimensions not varied.** d01 sample (set aside), d03 outcome (not applicable: single recorded item), d05 categorization (set aside: Age, GDP per capita, the governance indicators, the democracy index and the attitude score are continuous, so cutpoints were open, but categorizing them is judged less consequential than the five varied decisions.), d07 estimator (set aside: linear mixed models are standard for this outcome), d08 random effects and standard errors (set aside: the random slope is already modelled), d09 weights (set aside: design weights exist but the focal term rests on between-country variation). Full reasons will be in the preregistration.
