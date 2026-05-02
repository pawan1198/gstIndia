# Suppress R CMD check NOTEs for data.table NSE variables
utils::globalVariables(c(
  "gst_statewise", "gst_allindia",
  "financial_year", "month", "month_date", "state_code", "state", "region",
  "cgst", "sgst", "igst", "cess", "total",
  "cgst_pct", "sgst_pct", "igst_pct", "cess_pct",
  "collection", "share_pct", "prior", "value",
  ".", ".N", ".SD", ":="
))

#' gstIndia: India State-Wise Monthly GST Collection Data
#'
#' @description
#' Provides tidy, analysis-ready datasets of India's Goods and Services Tax
#' (GST) collections from July 2017 through early 2026. Data is sourced from
#' official Government of India Ministry of Finance releases.
#'
#' ## Main Datasets
#'
#' - [gst_statewise]: Monthly state-wise domestic GST by component
#'   (CGST, SGST, IGST, CESS) — ~4,000 rows across 36 states/UTs.
#' - [gst_allindia]: Monthly All-India aggregates with category breakdowns
#'   (domestic, IGST on imports, gross revenue, refunds, net revenue).
#'
#' ## Key Functions
#'
#' - [gst_filter()]: Subset data by year, state, or component
#' - [gst_yoy()]: Year-on-year growth rates
#' - [gst_annual_summary()]: Annual totals by state or component
#' - [gst_top_states()]: Top N states by collection in a given period
#' - [gst_state_share()]: State-level share of national collection
#'
#' @docType package
#' @name gstIndia-package
#' @aliases gstIndia
#'
#' @importFrom data.table data.table setDT setkey copy := .N .SD fread
#' @importFrom data.table merge.data.table rbindlist setcolorder setnames
#'
"_PACKAGE"
