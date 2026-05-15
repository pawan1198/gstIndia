# gstIndia 2.0.0

## Breaking changes

* Package completely rebuilt from the ground up. All v1.x function signatures
  are retained but several datasets are new — see **New datasets** below.

## New datasets (v2.0.0)

* `gst_refunds` — state-wise monthly GST refund disbursements (FY 2020-21 to 2025-26)
* `gstr1_filing` — GSTR-1 return filing compliance by state/month (FY 2017-18 to 2025-26)
* `gstr3b_filing` — GSTR-3B return filing compliance (FY 2017-18 to 2025-26)
* `ewb_data` — E-Way Bill statistics, intrastate & interstate (FY 2018-19 to 2025-26)
* `igst_settlement` — monthly IGST settlement to states, regular + ad-hoc (FY 2017-18 to 2025-26)
* `gross_net_collection` — monthly gross/net national collection with YoY comparison (Apr 2024–Feb 2026)
* `gst_registration` — state-wise taxpayer registration by category (snapshot Mar 2025)
* `gst_taxpayer_profile` — taxpayer constitution and female representation (snapshot Mar 2025)

## Updated datasets

* `gst_statewise` — extended through FY 2025-26; now includes `region` column.

## New functions (v2.0.0)

* `gst_net_collection()` — net collection after subtracting refunds
* `gst_filing_compliance()` — GSTR-1/3B compliance filter
* `gst_compliance_trend()` — compliance trend over time by region/state
* `gst_low_compliance_states()` — identify below-threshold states
* `ewb_summary()` — e-Way Bill data filter by direction
* `ewb_top_states()` — rank states by EWB volume or value
* `igst_settlement_summary()` — IGST settlement aggregator
* `gst_registration_summary()` — taxpayer registration filter
* `gst_catalogue()` — print all available datasets

## Improvements

* All datasets now include a `region` column (North/South/East/West/Central/Northeast/Other).
* `gst_filter()` is now backed by an internal `.get_ds()` helper that avoids
  global variable collisions (fixes subtle data.table NSE bug from v1.x).
* `gst_component_mix()` rewritten to use internally-consistent denominators —
  percentages now sum to exactly 100 for every month.

---

# gstIndia 0.1.0

* Initial release.
* Datasets: `gst_statewise`, `gst_allindia`.
* Functions: `gst_filter()`, `gst_yoy()`, `gst_annual_summary()`,
  `gst_top_states()`, `gst_state_share()`, `gst_component_mix()`,
  `gst_states()`, `gst_years()`.
