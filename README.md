# gstIndia <img src="man/figures/logo.png" align="right" height="139" alt=""/>

<!-- badges: start -->
[![R-CMD-check](https://github.com/pawan1198/gstIndia/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/pawan1198/gstIndia/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/gstIndia)](https://CRAN.R-project.org/package=gstIndia)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

**gstIndia** is a comprehensive, analysis-ready repository of India's Goods and
Services Tax (GST) ecosystem covering **July 2017 through early 2026**. Version
2.0.0 ships **nine tidy datasets** and **17 helper functions** covering
collection, refunds, return filing compliance, e-Way Bills, IGST settlement,
and taxpayer registration.

All monetary values are in **Rs. Crore** (1 Crore = 10 million INR).

---

## Datasets at a Glance

| Dataset | Rows | Coverage | Description |
|---|---|---|---|
| `gst_statewise` | 4,306 | FY 2017-18 → 2025-26 | Monthly CGST/SGST/IGST/CESS by state/UT |
| `gst_refunds` | 2,911 | FY 2020-21 → 2025-26 | Monthly refund disbursements by state |
| `gstr1_filing` | 3,876 | FY 2017-18 → 2025-26 | GSTR-1 filing compliance by state/month |
| `gstr3b_filing` | 3,914 | FY 2017-18 → 2025-26 | GSTR-3B filing compliance by state/month |
| `ewb_data` | 3,474 | FY 2018-19 → 2025-26 | E-Way Bill stats (intrastate & interstate) |
| `igst_settlement` | 3,914 | FY 2017-18 → 2025-26 | Monthly IGST settlement to states |
| `gross_net_collection` | 23 | Apr 2024 → Feb 2026 | Gross vs net national GST with YoY |
| `gst_registration` | 39 | Snapshot Mar 2025 | State-wise taxpayer registration by type |
| `gst_taxpayer_profile` | 16 | Snapshot Mar 2025 | Taxpayer constitution & gender profile |

---

## Installation

```r
# From GitHub (recommended)
# install.packages("remotes")
remotes::install_github("pawan1198/gstIndia")

# From CRAN (once published)
install.packages("gstIndia")
```

---

## Quick Start

```r
library(gstIndia)
library(data.table)

# ── What's available? ─────────────────────────────────────────────────────────
gst_catalogue()
gst_years()    # "2017-18" … "2025-26"
gst_states()   # 36 states/UTs with codes and regions

# ── Collection ────────────────────────────────────────────────────────────────
gst_filter(region = "South", financial_year = "2023-24", component = "total")
gst_top_states(n = 5, financial_year = "2023-24")
gst_annual_summary(by = "national")[, .(financial_year, total)]
gst_state_share(financial_year = "2023-24")[1:5]
gst_yoy(state = "Maharashtra")[order(-month_date)][1:6]
gst_component_mix(state = "Gujarat", financial_year = "2023-24")

# ── Refunds & net ─────────────────────────────────────────────────────────────
gst_net_collection(financial_year = "2023-24", by = "state")[order(-net)][1:5]

# ── Return filing compliance ──────────────────────────────────────────────────
gst_compliance_trend("GSTR-3B", by = "region", financial_year = "2023-24")
gst_low_compliance_states("GSTR-1", threshold = 0.90, financial_year = "2023-24")

# ── E-Way Bills ───────────────────────────────────────────────────────────────
ewb_top_states(n = 5, financial_year = "2023-24")
ewb_summary(financial_year = "2023-24", direction = "intrastate")[1:5]

# ── IGST settlement ───────────────────────────────────────────────────────────
igst_settlement_summary(financial_year = "2023-24", by = "state")[order(-total)][1:5]

# ── Registration ──────────────────────────────────────────────────────────────
gst_registration_summary()[order(-normal)][1:5]
gst_taxpayer_profile[order(-total_taxpayers)]
```

---

## Function Reference

### Collection & Refunds

| Function | Description |
|---|---|
| `gst_filter()` | Subset statewise data by year/state/region/component/date |
| `gst_yoy()` | Month-over-same-month year-on-year growth |
| `gst_annual_summary()` | Annual totals by state, region, or national |
| `gst_top_states()` | Top N states by collection |
| `gst_state_share()` | Each state's % share of national total |
| `gst_component_mix()` | CGST/SGST/IGST/Cess monthly share |
| `gst_net_collection()` | Net collection after refunds |

### Compliance

| Function | Description |
|---|---|
| `gst_filing_compliance()` | Filter GSTR-1 or GSTR-3B data |
| `gst_compliance_trend()` | Filing rate trend over time |
| `gst_low_compliance_states()` | States below a filing threshold |

### E-Way Bills

| Function | Description |
|---|---|
| `ewb_summary()` | Filter EWB data by direction |
| `ewb_top_states()` | Top states by EWB count or assessable value |

### IGST Settlement

| Function | Description |
|---|---|
| `igst_settlement_summary()` | Aggregate IGST settlement to states |

### Registration

| Function | Description |
|---|---|
| `gst_registration_summary()` | State-wise taxpayer registration |

### Reference

| Function | Description |
|---|---|
| `gst_states()` | State names, codes, regions |
| `gst_years()` | Available financial years |
| `gst_catalogue()` | All datasets with row counts and coverage |

---

## Example Visualisation

```r
library(ggplot2)

# GSTR-3B national compliance trend
trend <- gst_compliance_trend("GSTR-3B", by = "national")

ggplot(trend, aes(month_date, avg_filing_pct * 100)) +
  geom_line(colour = "#1B6CA8", linewidth = 0.9) +
  geom_hline(yintercept = 90, linetype = "dashed", colour = "firebrick") +
  scale_y_continuous(limits = c(0, 110), labels = scales::percent_format(scale = 1)) +
  labs(title    = "National GSTR-3B Filing Compliance",
       subtitle = "Dashed line = 90% threshold",
       x = NULL, y = "Filing %",
       caption  = "Source: Ministry of Finance, GoI") +
  theme_minimal(base_size = 13)
```

---

## Data Sources

| Dataset | Source |
|---|---|
| Collection, Refunds, IGST Settlement | Ministry of Finance, GoI — <https://www.gst.gov.in> |
| GSTR-1 / GSTR-3B Filing | Ministry of Finance, GoI — <https://www.gst.gov.in> |
| E-Way Bills | National Informatics Centre — <https://ewaybillgst.gov.in> |
| Registration & Taxpayer Profile | GST Council / GSTN — <https://www.gst.gov.in> |

FY 2025-26 figures are provisional. GST was introduced on 1 July 2017, so
FY 2017-18 contains only 9 months of data.

---

## Citation

```r
citation("gstIndia")
```

```
Pawan (2025). gstIndia: Comprehensive India GST Data Repository (2017-2026).
R package version 2.0.0. https://github.com/pawan1198/gstIndia
```

---

## License

MIT © Pawan
