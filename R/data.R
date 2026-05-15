#' State-wise Monthly GST Collection (2017–2026)
#'
#' Monthly domestic GST collection broken down by state/UT and component,
#' covering FY 2017-18 through FY 2025-26. Values in **Rs. Crore**.
#'
#' @format A `data.table` with 4,306 rows and 11 columns:
#' \describe{
#'   \item{financial_year}{`character`. Financial year, e.g. `"2023-24"`.}
#'   \item{month}{`character`. Month in `"YYYY-MM"` format.}
#'   \item{month_date}{`Date`. First day of the month.}
#'   \item{state_code}{`character`. Two-digit GST state code (zero-padded).}
#'   \item{state}{`character`. Full state/UT name.}
#'   \item{region}{`character`. Geographic region: `"North"`, `"South"`,
#'     `"East"`, `"West"`, `"Central"`, `"Northeast"`, or `"Other"`.}
#'   \item{cgst}{`numeric`. Central GST (Rs. Crore).}
#'   \item{sgst}{`numeric`. State GST (Rs. Crore).}
#'   \item{igst}{`numeric`. Integrated GST (Rs. Crore).}
#'   \item{cess}{`numeric`. GST Compensation Cess (Rs. Crore).}
#'   \item{total}{`numeric`. Sum of all components (Rs. Crore).}
#' }
#' @source Ministry of Finance, Government of India. <https://www.gst.gov.in>
#' @examples
#' data(gst_statewise)
#' gst_statewise[state == "Maharashtra", .(month, total)][order(month)]
"gst_statewise"


#' State-wise Monthly GST Refund Disbursements (2020–2026)
#'
#' Monthly refunds disbursed per state/UT and component, covering
#' FY 2020-21 through FY 2025-26. Values in **Rs. Crore**.
#'
#' @format A `data.table` with 2,911 rows and 11 columns:
#' \describe{
#'   \item{financial_year}{`character`. Financial year.}
#'   \item{month}{`character`. Month in `"YYYY-MM"`.}
#'   \item{month_date}{`Date`. First day of the month.}
#'   \item{state_code}{`character`. GST state code.}
#'   \item{state}{`character`. State/UT name.}
#'   \item{region}{`character`. Geographic region.}
#'   \item{cgst}{`numeric`. CGST refund (Rs. Crore).}
#'   \item{sgst}{`numeric`. SGST refund (Rs. Crore).}
#'   \item{igst}{`numeric`. IGST refund (Rs. Crore).}
#'   \item{cess}{`numeric`. Cess refund (Rs. Crore).}
#'   \item{total}{`numeric`. Total refund (Rs. Crore).}
#' }
#' @source Ministry of Finance, Government of India. <https://www.gst.gov.in>
#' @examples
#' data(gst_refunds)
#' gst_refunds[financial_year == "2023-24",
#'             .(total_refund = sum(total, na.rm = TRUE)), by = state][order(-total_refund)]
"gst_refunds"


#' GSTR-1 Return Filing Compliance by State (2017–2026)
#'
#' Monthly state-wise GSTR-1 (outward supply) filing statistics, including
#' eligible taxpayers, on-time filers, late filers, total filed, and filing
#' percentage. Covers FY 2017-18 through FY 2025-26.
#'
#' @format A `data.table` with 3,876 rows and 11 columns:
#' \describe{
#'   \item{financial_year}{`character`. Financial year.}
#'   \item{state_code}{`character`. GST state code.}
#'   \item{state}{`character`. State/UT name.}
#'   \item{month}{`character`. Month in `"YYYY-MM"`.}
#'   \item{month_date}{`Date`. First day of the month.}
#'   \item{region}{`character`. Geographic region.}
#'   \item{eligible}{`numeric`. Taxpayers eligible to file.}
#'   \item{on_time}{`numeric`. Taxpayers who filed by due date.}
#'   \item{late}{`numeric`. Taxpayers who filed after due date.}
#'   \item{total_filed}{`numeric`. Total returns filed.}
#'   \item{filing_pct}{`numeric`. Filing percentage (total_filed / eligible).}
#' }
#' @source Ministry of Finance, Government of India. <https://www.gst.gov.in>
#' @examples
#' data(gstr1_filing)
#' # States with highest compliance in FY 2023-24
#' gstr1_filing[financial_year == "2023-24",
#'              .(avg_pct = mean(filing_pct, na.rm = TRUE)), by = state][order(-avg_pct)]
"gstr1_filing"


#' GSTR-3B Return Filing Compliance by State (2017–2026)
#'
#' Monthly state-wise GSTR-3B (summary return) filing statistics. Same
#' structure as [gstr1_filing]. Covers FY 2017-18 through FY 2025-26.
#'
#' @format A `data.table` with 3,914 rows and 11 columns. Same columns as
#'   [gstr1_filing].
#' @source Ministry of Finance, Government of India. <https://www.gst.gov.in>
#' @seealso [gstr1_filing], [gst_filing_compliance()]
#' @examples
#' data(gstr3b_filing)
#' gstr3b_filing[state == "Delhi", .(month, filing_pct)][order(month)]
"gstr3b_filing"


#' E-Way Bill Statistics by State (2018–2026)
#'
#' Monthly state-wise e-Way Bill generation statistics for intrastate and
#' interstate movement of goods. Covers FY 2018-19 through FY 2025-26.
#' Assessable values in **Rs. Crore**.
#'
#' @format A `data.table` with 3,474 rows and 15 columns:
#' \describe{
#'   \item{financial_year}{`character`. Financial year.}
#'   \item{state_code}{`character`. GST state code.}
#'   \item{state}{`character`. State/UT name.}
#'   \item{month}{`character`. Month in `"YYYY-MM"`.}
#'   \item{month_date}{`Date`. First day of the month.}
#'   \item{region}{`character`. Geographic region.}
#'   \item{intrastate_suppliers}{`numeric`. Suppliers generating intrastate EWBs.}
#'   \item{intrastate_ewb_count}{`numeric`. Number of intrastate e-Way Bills.}
#'   \item{intrastate_assessable_value}{`numeric`. Intrastate goods value (Rs. Crore).}
#'   \item{interstate_out_suppliers}{`numeric`. Suppliers for outgoing interstate EWBs.}
#'   \item{interstate_out_ewb_count}{`numeric`. Outgoing interstate EWB count.}
#'   \item{interstate_out_assessable_value}{`numeric`. Outgoing interstate value (Rs. Crore).}
#'   \item{interstate_in_suppliers}{`numeric`. Suppliers for incoming interstate EWBs.}
#'   \item{interstate_in_ewb_count}{`numeric`. Incoming interstate EWB count.}
#'   \item{interstate_in_assessable_value}{`numeric`. Incoming interstate value (Rs. Crore).}
#' }
#' @source National Informatics Centre / GST Council. <https://ewaybillgst.gov.in>
#' @examples
#' data(ewb_data)
#' # Total EWBs by state in FY 2023-24
#' ewb_data[financial_year == "2023-24",
#'          .(total_ewb = sum(intrastate_ewb_count + interstate_out_ewb_count, na.rm = TRUE)),
#'          by = state][order(-total_ewb)]
"ewb_data"


#' IGST Settlement to States (2017–2026)
#'
#' Monthly settlement of Integrated GST (IGST) to states and UTs, split into
#' regular and ad-hoc components. Covers FY 2017-18 through FY 2025-26.
#' Values in **Rs. Crore**.
#'
#' @format A `data.table` with 3,914 rows and 9 columns:
#' \describe{
#'   \item{financial_year}{`character`. Financial year.}
#'   \item{month}{`character`. Month in `"YYYY-MM"`.}
#'   \item{month_date}{`Date`. First day of the month.}
#'   \item{state_code}{`character`. GST state code.}
#'   \item{state}{`character`. State/UT name.}
#'   \item{region}{`character`. Geographic region.}
#'   \item{regular}{`numeric`. Regular IGST settlement (Rs. Crore).}
#'   \item{adhoc}{`numeric`. Ad-hoc IGST settlement (Rs. Crore).}
#'   \item{total}{`numeric`. Total IGST settlement (Rs. Crore).}
#' }
#' @source Ministry of Finance, Government of India. <https://www.gst.gov.in>
#' @examples
#' data(igst_settlement)
#' igst_settlement[financial_year == "2023-24",
#'                 .(settled = sum(total, na.rm = TRUE)), by = state][order(-settled)]
"igst_settlement"


#' Monthly Gross and Net GST Collection Comparison (FY 2024-25 and 2025-26)
#'
#' National-level monthly comparison of gross and net GST collection against
#' the same month of the prior year, with component-level breakdowns for
#' domestic collections and IGST on imports. Covers April 2024 to February 2026.
#' Values in **Rs. Crore**.
#'
#' @format A `data.table` with 23 rows. Key columns include:
#' \describe{
#'   \item{financial_year}{`character`. Financial year.}
#'   \item{month}{`character`. Month in `"YYYY-MM"`.}
#'   \item{month_date}{`Date`. First day of the month.}
#'   \item{dom_cgst_cur}{`numeric`. Domestic CGST, current month (Rs. Crore).}
#'   \item{dom_sgst_cur}{`numeric`. Domestic SGST, current month.}
#'   \item{dom_igst_cur}{`numeric`. Domestic IGST, current month.}
#'   \item{dom_cess_cur}{`numeric`. Domestic Cess, current month.}
#'   \item{gross_domestic_cur}{`numeric`. Gross domestic GST, current month.}
#'   \item{imp_igst_cur}{`numeric`. IGST on imports, current month.}
#'   \item{gross_total_cur}{`numeric`. Total gross GST (domestic + imports).}
#'   \item{refund_cur}{`numeric`. Refunds issued, current month.}
#'   \item{net_cur}{`numeric`. Net revenue after refunds, current month.}
#'   \item{*_prior}{`numeric`. Prior-year same-month values for each column above.}
#' }
#' @source Ministry of Finance, Government of India. <https://www.gst.gov.in>
#' @examples
#' data(gross_net_collection)
#' gross_net_collection[, .(month, gross_domestic_cur, refund_cur)]
"gross_net_collection"


#' State-wise GST Taxpayer Registration (as of March 2025)
#'
#' Number of registered GST taxpayers per state/UT, categorised by
#' registration type. Snapshot as of 31 March 2025.
#'
#' @format A `data.table` with 39 rows and 9 columns:
#' \describe{
#'   \item{state_code}{`character`. GST state code.}
#'   \item{state}{`character`. State/UT name.}
#'   \item{region}{`character`. Geographic region.}
#'   \item{normal}{`numeric`. Normal (regular) taxpayers.}
#'   \item{composition}{`numeric`. Composition scheme taxpayers.}
#'   \item{isd}{`numeric`. Input Service Distributors.}
#'   \item{casual}{`numeric`. Casual taxpayers.}
#'   \item{tcs}{`numeric`. Tax Collectors at Source.}
#'   \item{tds}{`numeric`. Tax Deductors at Source.}
#' }
#' @source GST Council / GSTN. <https://www.gst.gov.in>
#' @examples
#' data(gst_registration)
#' gst_registration[order(-normal), .(state, normal, composition)][1:10]
"gst_registration"


#' GST Taxpayer Constitution and Gender Profile (as of March 2025)
#'
#' National breakdown of registered GST taxpayers by constitution of business
#' and female representation, as of 31 March 2025.
#'
#' @format A `data.table` with 16 rows and 4 columns:
#' \describe{
#'   \item{constitution}{`character`. Business constitution type (e.g.
#'     `"Proprietorship"`, `"Private Limited Company"`, `"Partnership"`).}
#'   \item{total_taxpayers}{`numeric`. Total registered taxpayers.}
#'   \item{female_count}{`numeric`. Taxpayers with at least one female member.}
#'   \item{female_pct}{`numeric`. Female representation percentage.}
#' }
#' @source GST Council / GSTN. <https://www.gst.gov.in>
#' @examples
#' data(gst_taxpayer_profile)
#' gst_taxpayer_profile[order(-total_taxpayers)]
"gst_taxpayer_profile"
