# gstIndia <img src="man/figures/logo.png" align="right" height="139" alt="" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/pawan1198/gstIndia/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/pawan1198/gstIndia/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/gstIndia)](https://CRAN.R-project.org/package=gstIndia)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

**gstIndia** provides tidy, analysis-ready datasets of India's Goods and
Services Tax (GST) collections from **July 2017 through early 2026**, sourced
from the Ministry of Finance, Government of India. It includes:

- **`gst_statewise`** — 4,000+ rows of monthly state/UT-level domestic GST
  broken down by component (CGST, SGST, IGST, CESS) across 36 states and UTs.
- **`gst_allindia`** — Monthly All-India aggregates (domestic, imports,
  gross revenue, refunds, net revenue) from FY 2020-21 onward.
- **Helper functions** for filtering, ranking, growth analysis, and component
  mix computation.

All monetary values are in **Rs. Crore** (1 Crore = 10 million INR).

---

## Installation

```r
# Install from GitHub (recommended)
# install.packages("remotes")
remotes::install_github("pawan1198/gstIndia")

# Or install from CRAN (once published)
install.packages("gstIndia")
```

---

## Quick Start

```r
library(gstIndia)
library(data.table)

# --- Explore the data -------------------------------------------------------
gst_statewise          # 4,081 rows × 11 cols
gst_allindia           # 142 rows × 9 cols
gst_years()            # "2017-18" … "2025-26"
gst_states()           # 36 states/UTs with codes and regions

# --- Filter -----------------------------------------------------------------
# Southern states, FY 2023-24, total only
gst_filter(region = "South", financial_year = "2023-24", component = "total")

# --- Annual summary ---------------------------------------------------------
gst_annual_summary(by = "state", financial_year = "2023-24")[order(-total)][1:5]
#    financial_year         state region     cgst     sgst      igst      cess     total
# 1:        2023-24   Maharashtra   West 47316.0 64178.8 137556.7 13148.5 262200.0
# 2:        2023-24     Karnataka  South 28124.3 35476.5  66254.8  4628.9 134484.5
# ...

# --- Top states -------------------------------------------------------------
gst_top_states(n = 5, financial_year = "2024-25")

# --- Year-on-year growth ----------------------------------------------------
gst_yoy(state = "Delhi")[order(-month_date)][1:6]

# --- State share of national total ------------------------------------------
gst_state_share(financial_year = "2023-24")[1:5]
```

---

## Datasets

### `gst_statewise`

| Column | Type | Description |
|---|---|---|
| `financial_year` | chr | e.g. `"2023-24"` |
| `month` | chr | `"YYYY-MM"` |
| `month_date` | Date | First day of month |
| `state_code` | chr | 2-digit GST state code |
| `state` | chr | Full state/UT name |
| `region` | chr | North / South / East / West / Central / Northeast / Other |
| `cgst` | dbl | Central GST (Rs. Crore) |
| `sgst` | dbl | State GST (Rs. Crore) |
| `igst` | dbl | Integrated GST (Rs. Crore) |
| `cess` | dbl | Compensation Cess (Rs. Crore) |
| `total` | dbl | CGST + SGST + IGST + CESS |

### `gst_allindia`

| Column | Type | Description |
|---|---|---|
| `financial_year` | chr | e.g. `"2023-24"` |
| `month` | chr | `"YYYY-MM"` |
| `month_date` | Date | First day of month |
| `category` | chr | `domestic` / `igst_import` / `gross_revenue` / `refund` / `net_revenue` |
| `cgst` | dbl | Rs. Crore |
| `sgst` | dbl | Rs. Crore |
| `igst` | dbl | Rs. Crore |
| `cess` | dbl | Rs. Crore |
| `total` | dbl | Rs. Crore |

---

## Functions

| Function | Description |
|---|---|
| `gst_filter()` | Subset by year, state, region, component, or date range |
| `gst_yoy()` | Month-over-same-month YoY growth rates |
| `gst_annual_summary()` | Annual totals by state, region, or national |
| `gst_top_states()` | Top N states by collection |
| `gst_state_share()` | Each state's % share of national total |
| `gst_component_mix()` | Monthly CGST/SGST/IGST/CESS share breakdown |
| `gst_states()` | Reference table of states, codes, regions |
| `gst_years()` | All available financial years |

---

## Visualisation

```r
library(ggplot2)

# Monthly national gross revenue trend (FY 2020-21 onwards)
data(gst_allindia)

ggplot(
  gst_allindia[category == "gross_revenue"],
  aes(month_date, total / 1e3)
) +
  geom_line(colour = "#1B6CA8", linewidth = 0.8) +
  geom_smooth(method = "loess", se = FALSE, colour = "#E84545", linetype = "dashed") +
  scale_y_continuous(labels = scales::comma_format(suffix = "K Cr")) +
  labs(
    title    = "India Monthly GST Gross Revenue",
    subtitle = "FY 2020-21 to FY 2025-26  |  Rs. '000 Crore",
    x = NULL, y = NULL,
    caption  = "Source: Ministry of Finance, GoI"
  ) +
  theme_minimal(base_size = 13)
```

---

## Data Source

Ministry of Finance, Government of India — GST Revenue Collection Data.  
<https://www.gst.gov.in>

Data covers July 2017 (GST rollout) through February 2026.  
FY 2025-26 figures are provisional.

---

## Citation

```r
citation("gstIndia")
```

```
Kumar P (2025). gstIndia: India State-Wise Monthly GST Collection Data (2017-2026).
R package version 0.1.0. https://github.com/pawan1198/gstIndia
```

---

## Contributing

Bug reports and pull requests are welcome at
<https://github.com/pawan1198/gstIndia/issues>.

---

## License

MIT © Pawan
