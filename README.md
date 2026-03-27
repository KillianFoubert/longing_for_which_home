# Longing for Which Home: A Global Analysis of the Determinants of Aspirations to Stay, Return or Migrate Onwards

## Replication Code

This repository contains the Stata replication code for:

**Bekaert, E., Constant, A.F., Foubert, K. & Ruyssen, I. (2024).** Longing for which home: A global analysis of the determinants of aspirations to stay, return or migrate onwards. *Journal of Economic Behavior and Organization*, 219, 564–587. [https://doi.org/10.1016/j.jebo.2024.02.001](https://doi.org/10.1016/j.jebo.2024.02.001)

## Abstract

This paper provides a comprehensive global analysis of the characteristics and circumstances that shape first-generation immigrants' aspirations to stay, return or migrate onwards, based on individual-level data from the Gallup World Polls across 138 countries worldwide between 2009 and 2016. Our study reveals that immigrants' stated preferences are strongly influenced by demographics, human and spiritual capital, as well as by soft factors, such as social ties and sociocultural integration, while economic factors have a more feeble influence. Changes in circumstances in the home and host countries are also important determinants of locational aspirations.

## Data Sources

The analysis combines data from the following sources. **The datasets are not included in this repository** as most require licences or registration:

| Source | Variable(s) | Access |
|--------|-------------|--------|
| Gallup World Polls (GWP) | Migration aspirations, individual controls | [Gallup](https://www.gallup.com/analytics/318875/global-research.aspx) (licence required) |
| GADM | Administrative region boundaries | [GADM](https://gadm.org/) |
| CEPII GeoDist | Bilateral distance, contiguity, language | [CEPII](http://www.cepii.fr/) |
| UCDP/PRIO Armed Conflict Dataset | Conflict occurrence | [UCDP](https://ucdp.uu.se/) |
| Bayesian Corruption Index | Corruption levels | [V-Dem](https://www.v-dem.net/) |
| Cultural Distance Dataset | Cultural proximity | Constructed from WVS |
| EM-DAT | Natural disaster frequency | [EM-DAT](https://www.emdat.be/) |
| Migration Policy Index | Migration policy restrictiveness | [IMPIC](https://www.migrationpolicyindex.org/) |
| Polity IV Project | Democracy, political instability | [Center for Systemic Peace](https://www.systemicpeace.org/) |
| World Development Indicators (WDI) | GDP growth, GNI per capita | [World Bank](https://databank.worldbank.org/) |

## Repository Structure

```
code/
├── 01_data_cleaning/              # Data preparation
│   ├── 00_GADM_cleaning_GWP.do            # Match GWP regions to GADM
│   ├── 01_create_iso_codes.do             # ISO3 codes from shapefile
│   ├── 02_clean_iso_codes.do              # ISO3 harmonisation
│   ├── 03_GWP_cleaning.do                 # Gallup World Poll (immigrants sample)
│   ├── 04_CEPII_gravity.do               # Bilateral gravity variables
│   ├── 05_conflicts_UCDP.do              # Armed conflict occurrence
│   ├── 06_corruption_index.do             # Bayesian Corruption Index
│   ├── 07_cultural_distance.do            # Cultural distance measures
│   ├── 08_natural_disasters_EMDAT.do      # Natural disaster frequency (EM-DAT)
│   ├── 09_migration_policy_index.do       # Migration policy restrictiveness
│   ├── 10_polity_IV.do                    # Democracy & political instability
│   ├── 11_regions_identifiers.do          # World region classification
│   ├── 12_trust_index.do                  # Trust indicators
│   ├── 13_WDI_GNI_GDP.do                 # GDP growth, GNI per capita
│   ├── 14_religion_dummies.do             # Major religion classification
│   ├── 15_add_GWP_variables.do            # Additional GWP variables
│   └── 16_recategorise_age.do             # Age group recategorisation
│
├── 02_merge/
│   └── 17_merge_final.do                  # Merges all sources into final panel
│
└── 03_estimations/
    └── 18_estimations.do                  # MNL estimations (Tables 1–4, appendix)
```

## Execution Order

Scripts are numbered to indicate execution order:

1. **Run `00`–`02`** — GADM regions and ISO3 codes (prerequisites).
2. **Run `03`** — clean Gallup World Poll data (first-generation immigrants, 18–75).
3. **Run `04`–`16`** — clean all control variables (order flexible).
4. **Run `17`** — merge all datasets into the final panel.
5. **Run `18`** — produce all estimation results and descriptive statistics.

**Note:** File paths in the do-files reference the authors' local Dropbox directories. Users will need to adjust the `cd` commands at the top of each file.

## Software Requirements

- Stata 16 or later
- Required Stata packages: `estout`, `wbopendata`, `spmap`, `shp2dta`, `carryforward`, `domin`

## Methods

- Multinomial logit (MNL) with host country and year fixed effects
- Dependent variable: aspirations to stay (baseline) / return home / migrate onwards
- Binomial logit for return vs migrate onwards contrast
- Dominance analysis for relative variable importance
- Heterogeneity by host and home countries' development level (LMIC vs HIC)
- Robustness: sample modifications, Heckman selection correction

## Citation

```bibtex
@article{bekaert2024longing,
  title={Longing for which home: {A} global analysis of the determinants of aspirations to stay, return or migrate onwards},
  author={Bekaert, Els and Constant, Amelie F. and Foubert, Killian and Ruyssen, Ilse},
  journal={Journal of Economic Behavior and Organization},
  volume={219},
  pages={564--587},
  year={2024},
  publisher={Elsevier},
  doi={10.1016/j.jebo.2024.02.001}
}
```

## Authors

- **Els Bekaert** — Ghent University / UNU-CRIS
- **Amelie F. Constant** — University of Pennsylvania
- **Killian Foubert** — Ghent University / UNU-CRIS
- **Ilse Ruyssen** — Ghent University / UNU-CRIS
