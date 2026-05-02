#' State-wise Monthly GST Collection in India (2017-2026)
#'
#' @description
#' A `data.table` containing monthly domestic GST collection figures broken down
#' by state/UT and GST component, covering Financial Years 2017-18 through
#' 2025-26. All values are in **Rs. Crore** (1 Crore = 10 million).
#'
#' @format A `data.table` with columns:
#' \describe{
#'   \item{financial_year}{`character`. Financial year label, e.g. `"2023-24"`.}
#'   \item{month}{`character`. Calendar month in `"YYYY-MM"` format.}
#'   \item{month_date}{`Date`. First day of the month, for time-series plotting.}
#'   \item{state_code}{`character`. Two-digit GST state code (zero-padded).}
#'   \item{state}{`character`. Full name of the state or Union Territory.}
#'   \item{region}{`character`. Broad geographic region: `"North"`, `"South"`,
#'     `"East"`, `"West"`, `"Central"`, `"Northeast"`, or `"Other"`.}
#'   \item{cgst}{`numeric`. Central GST collection (Rs. Crore).}
#'   \item{sgst}{`numeric`. State GST collection (Rs. Crore).}
#'   \item{igst}{`numeric`. Integrated GST collection (Rs. Crore).}
#'   \item{cess}{`numeric`. GST Compensation Cess (Rs. Crore).}
#'   \item{total}{`numeric`. Total domestic GST (CGST + SGST + IGST + CESS),
#'     in Rs. Crore.}
#' }
#'
#' @details
#' Data is sourced from the Ministry of Finance, Government of India, and
#' covers domestic GST only (excludes IGST on imports). The dataset spans
#' from July 2017 (GST rollout) through February 2026. Financial Year 2017-18
#' has only 9 months of data (Jul 2017 – Mar 2018). State codes follow the
#' GST Council's official mapping. Some Union Territories have been merged
#' (e.g., Daman & Diu with Dadra & Nagar Haveli from FY 2020-21 onward).
#'
#' @source
#' Ministry of Finance, Government of India. GST Revenue Collection Data.
#' <https://www.gst.gov.in>
#'
#' @examples
#' library(data.table)
#' data(gst_statewise)
#'
#' # Preview
#' gst_statewise
#'
#' # Total collection by financial year
#' gst_statewise[, .(total_cr = sum(total, na.rm = TRUE)),
#'               by = financial_year][order(financial_year)]
#'
#' # Maharashtra monthly trend
#' maha <- gst_statewise[state == "Maharashtra",
#'                       .(month_date, total)]
#' maha[order(month_date)]
"gst_statewise"


#' All-India Monthly GST Summary (2020-2026)
#'
#' @description
#' A `data.table` of All-India monthly GST aggregates by category, covering
#' Financial Years 2020-21 through 2025-26. Values are in **Rs. Crore**.
#'
#' @format A `data.table` with columns:
#' \describe{
#'   \item{financial_year}{`character`. Financial year label.}
#'   \item{month}{`character`. Calendar month in `"YYYY-MM"` format.}
#'   \item{month_date}{`Date`. First day of the month.}
#'   \item{category}{`character`. One of:
#'     `"domestic"` (domestic GST),
#'     `"igst_import"` (IGST on imports),
#'     `"gross_revenue"` (total gross collections),
#'     `"refund"` (refunds issued),
#'     `"net_revenue"` (gross minus refunds).}
#'   \item{cgst}{`numeric`. CGST component (Rs. Crore).}
#'   \item{sgst}{`numeric`. SGST component (Rs. Crore).}
#'   \item{igst}{`numeric`. IGST component (Rs. Crore).}
#'   \item{cess}{`numeric`. Cess component (Rs. Crore).}
#'   \item{total}{`numeric`. Total of all components (Rs. Crore).}
#' }
#'
#' @details
#' Available only from FY 2020-21 onwards, as earlier files did not include
#' the All-India summary sheet. Use [gst_statewise] for earlier years or for
#' state-level analysis.
#'
#' @source
#' Ministry of Finance, Government of India. GST Revenue Collection Data.
#' <https://www.gst.gov.in>
#'
#' @examples
#' library(data.table)
#' data(gst_allindia)
#'
#' # Monthly gross revenue trend
#' gst_allindia[category == "gross_revenue", .(month_date, total)][order(month_date)]
#'
#' # Annual net revenue
#' gst_allindia[category == "net_revenue",
#'              .(net = sum(total, na.rm = TRUE)), by = financial_year]
"gst_allindia"
