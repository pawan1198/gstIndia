#' gstIndia: Comprehensive India GST Data Repository (2017–2026)
#'
#' @description
#' A complete, analysis-ready repository of India's GST ecosystem covering
#' July 2017 through early 2026. All monetary values are in **Rs. Crore**
#' (1 Crore = 10 million INR). Data is sourced from the Ministry of Finance,
#' Government of India, and the GST Council.
#'
#' ## Datasets
#'
#' | Dataset | Rows | Description |
#' |---|---|---|
#' | [gst_statewise] | 4,306 | Monthly state/UT domestic GST (CGST/SGST/IGST/CESS) |
#' | [gst_refunds] | 2,911 | Monthly state/UT refund disbursements |
#' | [gstr1_filing] | 3,876 | GSTR-1 return filing compliance by state/month |
#' | [gstr3b_filing] | 3,914 | GSTR-3B return filing compliance by state/month |
#' | [ewb_data] | 3,474 | E-Way Bill statistics (intrastate & interstate) |
#' | [igst_settlement] | 3,914 | Monthly IGST settlement to states (regular + ad-hoc) |
#' | [gross_net_collection] | 23 | Monthly gross vs net national collection (FY 2024-26) |
#' | [gst_registration] | 39 | State-wise taxpayer registration by category |
#' | [gst_taxpayer_profile] | 16 | Taxpayer constitution and gender analysis |
#'
#' ## Key Functions
#'
#' **Collection & Refunds**
#' - [gst_filter()] — Subset statewise data by year, state, region, component
#' - [gst_yoy()] — Year-on-year growth rates
#' - [gst_annual_summary()] — Annual aggregates by state, region, or national
#' - [gst_top_states()] — Top N states by collection or refund
#' - [gst_state_share()] — State's % share of national collection
#' - [gst_component_mix()] — Monthly CGST/SGST/IGST/CESS component breakdown
#' - [gst_net_collection()] — Net collection after refunds
#'
#' **Compliance**
#' - [gst_filing_compliance()] — Return filing rates (GSTR-1 or GSTR-3B)
#' - [gst_compliance_trend()] — Compliance trend over time
#' - [gst_low_compliance_states()] — States with below-average filing rates
#'
#' **E-Way Bills**
#' - [ewb_summary()] — E-Way Bill summary by state and direction
#' - [ewb_top_states()] — Top states by e-Way Bill volume or value
#'
#' **IGST Settlement**
#' - [igst_settlement_summary()] — Annual/monthly IGST settlement to states
#'
#' **Registration & Profile**
#' - [gst_registration_summary()] — Taxpayer registration totals by state
#'
#' **Reference**
#' - [gst_states()] — State names, codes, and regions
#' - [gst_years()] — Available financial years
#'
#' @docType package
#' @name gstIndia-package
#' @aliases gstIndia
#'
#' @importFrom data.table data.table setDT setkey copy := .N .SD
#' @importFrom data.table setcolorder setnames setorder rbindlist shift
#' @importFrom utils head
"_PACKAGE"

# Suppress R CMD check NOTEs for data.table NSE and lazy-data bindings
utils::globalVariables(c(
  # datasets
  "gst_statewise","gst_refunds","gstr1_filing","gstr3b_filing",
  "ewb_data","igst_settlement","gross_net_collection",
  "gst_registration","gst_taxpayer_profile",
  # common columns
  "financial_year","month","month_date","state_code","state","region",
  "cgst","sgst","igst","cess","total",
  "cgst_pct","sgst_pct","igst_pct","cess_pct",
  "eligible","on_time","late","total_filed","filing_pct",
  "intrastate_ewb_count","intrastate_assessable_value","intrastate_suppliers",
  "interstate_out_ewb_count","interstate_out_assessable_value","interstate_out_suppliers",
  "interstate_in_ewb_count","interstate_in_assessable_value","interstate_in_suppliers",
  "regular","adhoc","collection","share_pct","prior","value","rank",
  "normal","composition","isd","casual","tcs","tds",
  "constitution","total_taxpayers","female_count","female_pct",
  "gross_domestic_cur","gross_total_cur","refund_cur","net_cur",
  ".", ".N", ".SD", ":=",
  "metric_total", "total_comp", "value",
  "avg_filing_pct", "refund", "net", "gross",
  "months_below", "non_other", "total_comp"
))
