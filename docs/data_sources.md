# Data sources

Record the access date and exact file name for every source when you download it. The preregistration asks for source, version, access date, and whether this is the release the original author would have had.

| Source | Version used by author | File to download | Save to | Access date |
| --- | --- | --- | --- | --- |
| Joint EVS/WVS 2017 to 2021 | ZA7505 v2.0.0, doi 10.4232/1.13737 | Stata or SPSS file plus codebook, from GESIS (free account) | `data/raw/` | |
| V-Dem Country-Year | v11.1, doi 10.23696/vdemds21 | V-Dem-CY-Full+Others-v11.1 (CSV or RDS) from the V-Dem archive; supplies v2x_polyarchy and v2x_libdem; ends in 2020 | `data/external/vdem/` | |
| World Bank WDI | not reported | GDP per capita PPP, 2020 | `data/external/worldbank/` | |
| World Bank WGI | not reported | GE, PV, CC estimates, 2020 | `data/external/worldbank/` | |
| World Bank classifications | not reported | Income groups and regions (record the fiscal year file) | `data/external/worldbank/` | |

## Vintage

The COS guidance says to use the vintage contemporaneous with the original analysis where it can be retrieved. The article was received November 28, 2022. Both ZA7505 v2.0.0 and V-Dem v11.1 are archived, so use those exact versions, not the latest releases. For World Bank data, the archived WDI and WGI releases from 2022 are the closest match; if they cannot be retrieved, use current releases and record that.

## Not committed

Everything under `data/` is gitignored. Do not move data files elsewhere in the repository.
