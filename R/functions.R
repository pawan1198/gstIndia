# ── Compliance Functions ───────────────────────────────────────────────────────

#' GST Return Filing Compliance
#'
#' Retrieve GSTR-1 or GSTR-3B filing statistics filtered by year, state, or
#' region.
#'
#' @param return_type `character(1)`. `"GSTR-1"` (default) or `"GSTR-3B"`.
#' @param financial_year `character` vector. `NULL` = all.
#' @param state `character` vector. `NULL` = all.
#' @param region `character` vector. `NULL` = all.
#' @param from_month `character`. Start month `"YYYY-MM"`.
#' @param to_month `character`. End month `"YYYY-MM"`.
#'
#' @return A `data.table` with filing compliance columns.
#' @export
#' @examples
#' gst_filing_compliance("GSTR-3B", financial_year = "2023-24", region = "South")
gst_filing_compliance <- function(return_type = c("GSTR-1","GSTR-3B"),
                                  financial_year = NULL, state = NULL,
                                  region = NULL, from_month = NULL,
                                  to_month = NULL) {
  return_type <- match.arg(return_type)
  ds_name <- if (return_type == "GSTR-1") "gstr1_filing" else "gstr3b_filing"
  dt <- copy(.get_ds(ds_name))

  fy_ <- financial_year; st_ <- state; rg_ <- region
  fm_ <- from_month;     tm_ <- to_month

  if (!is.null(fy_)) dt <- dt[get("financial_year") %in% fy_]
  if (!is.null(st_)) dt <- dt[get("state")          %in% st_]
  if (!is.null(rg_)) dt <- dt[get("region")         %in% rg_]
  if (!is.null(fm_)) dt <- dt[get("month")          >= fm_]
  if (!is.null(tm_)) dt <- dt[get("month")          <= tm_]
  dt
}


#' Filing Compliance Trend Over Time
#'
#' Computes average filing percentage per month, optionally grouped by region
#' or state, for GSTR-1 or GSTR-3B.
#'
#' @param return_type `character(1)`. `"GSTR-1"` or `"GSTR-3B"`.
#' @param by `character(1)`. `"national"` (default), `"region"`, or `"state"`.
#' @param financial_year `character` vector. `NULL` = all.
#' @param state `character` vector. `NULL` = all.
#'
#' @return A `data.table` with `month_date` and `avg_filing_pct`.
#' @export
#' @examples
#' gst_compliance_trend("GSTR-3B", by = "region", financial_year = "2023-24")
gst_compliance_trend <- function(return_type = c("GSTR-1","GSTR-3B"),
                                 by = c("national","region","state"),
                                 financial_year = NULL, state = NULL) {
  return_type <- match.arg(return_type)
  by          <- match.arg(by)
  dt <- gst_filing_compliance(return_type, financial_year=financial_year, state=state)

  grp <- switch(by,
    national = c("month","month_date"),
    region   = c("month","month_date","region"),
    state    = c("month","month_date","state","region")
  )
  out <- dt[, .(avg_filing_pct = mean(filing_pct, na.rm=TRUE),
                total_eligible = sum(eligible,   na.rm=TRUE),
                total_filed    = sum(total_filed, na.rm=TRUE)), by=grp]
  setorder(out, month_date)
  out
}


#' States with Below-Average Filing Compliance
#'
#' Identify states whose average filing percentage falls below a threshold,
#' for a given return type and period.
#'
#' @param return_type `character(1)`. `"GSTR-1"` or `"GSTR-3B"`.
#' @param threshold `numeric`. Filing percentage threshold (default `0.9` = 90%).
#' @param financial_year `character` vector. `NULL` = all.
#'
#' @return A `data.table` with `state`, `region`, `avg_filing_pct`, `months_below`.
#' @export
#' @examples
#' gst_low_compliance_states("GSTR-3B", threshold = 0.85,
#'                           financial_year = "2023-24")
gst_low_compliance_states <- function(return_type = c("GSTR-1","GSTR-3B"),
                                      threshold = 0.90,
                                      financial_year = NULL) {
  return_type <- match.arg(return_type)
  dt <- gst_filing_compliance(return_type, financial_year=financial_year)

  out <- dt[, .(avg_filing_pct = mean(filing_pct, na.rm=TRUE),
                months_below   = sum(filing_pct < threshold, na.rm=TRUE),
                region         = region[1L]), by=state]
  out <- out[avg_filing_pct < threshold]
  setorder(out, avg_filing_pct)
  out
}


# ── E-Way Bill Functions ───────────────────────────────────────────────────────

#' E-Way Bill Summary
#'
#' Retrieve and aggregate e-Way Bill data by state and direction.
#'
#' @param financial_year `character` vector. `NULL` = all.
#' @param state `character` vector. `NULL` = all.
#' @param region `character` vector. `NULL` = all.
#' @param direction `character`. `"all"` (default), `"intrastate"`,
#'   `"interstate_out"`, or `"interstate_in"`.
#'
#' @return A `data.table` with EWB counts and assessable values.
#' @export
#' @examples
#' ewb_summary(financial_year = "2023-24", direction = "intrastate")[order(-intrastate_ewb_count)][1:5]
ewb_summary <- function(financial_year = NULL, state = NULL,
                        region = NULL,
                        direction = c("all","intrastate","interstate_out","interstate_in")) {
  direction <- match.arg(direction)
  dt <- copy(.get_ds("ewb_data"))
  fy_ <- financial_year; st_ <- state; rg_ <- region
  if (!is.null(fy_)) dt <- dt[get("financial_year") %in% fy_]
  if (!is.null(st_)) dt <- dt[get("state")          %in% st_]
  if (!is.null(rg_)) dt <- dt[get("region")         %in% rg_]

  ewb_cols <- if (direction == "all") {
    c("intrastate_suppliers","intrastate_ewb_count","intrastate_assessable_value",
      "interstate_out_suppliers","interstate_out_ewb_count","interstate_out_assessable_value",
      "interstate_in_suppliers","interstate_in_ewb_count","interstate_in_assessable_value")
  } else {
    grep(paste0("^",direction), names(dt), value=TRUE)
  }
  dt[, .SD, .SDcols = c(.ID_COLS, ewb_cols)]
}


#' Top States by E-Way Bill Volume or Value
#'
#' @param n `integer`. Number of states. Default `10L`.
#' @param metric `character(1)`. `"ewb_count"` (default) or `"assessable_value"`.
#' @param direction `character(1)`. `"intrastate"`, `"interstate_out"`,
#'   `"interstate_in"`, or `"all"` (sum of all).
#' @param financial_year `character` vector. `NULL` = all.
#'
#' @return A ranked `data.table`.
#' @export
#' @examples
#' ewb_top_states(n = 5, financial_year = "2023-24")
#' ewb_top_states(metric = "assessable_value", direction = "interstate_out",
#'                financial_year = "2023-24")
ewb_top_states <- function(n = 10L,
                           metric    = c("ewb_count","assessable_value"),
                           direction = c("intrastate","interstate_out","interstate_in","all"),
                           financial_year = NULL) {
  metric    <- match.arg(metric)
  direction <- match.arg(direction)
  dt <- copy(.get_ds("ewb_data"))
  if (!is.null(financial_year))
    dt <- dt[get("financial_year") %in% financial_year]

  if (direction == "all") {
    dt[, value := rowSums(.SD, na.rm=TRUE),
       .SDcols = grep(metric, names(dt), value=TRUE)]
  } else {
    col_name <- paste0(direction, "_", metric)
    dt[, value := get(col_name)]
  }
  out <- dt[, .(metric_total=sum(value, na.rm=TRUE), region=region[1L]), by=state]
  setorder(out, -metric_total)
  out[, rank := seq_len(.N)]
  setnames(out, "metric_total", paste0(direction,"_",metric))
  setcolorder(out, c("rank","state","region"))
  utils::head(out, n)
}


# ── IGST Settlement Functions ─────────────────────────────────────────────────

#' IGST Settlement Summary
#'
#' Retrieve and aggregate IGST settlement data to states.
#'
#' @param financial_year `character` vector. `NULL` = all.
#' @param state `character` vector. `NULL` = all.
#' @param by `character(1)`. `"state"` (default), `"region"`, or `"national"`.
#'
#' @return A `data.table` with regular, adhoc, and total IGST settlement.
#' @export
#' @examples
#' igst_settlement_summary(financial_year = "2023-24", by = "state")[order(-total)][1:10]
igst_settlement_summary <- function(financial_year = NULL, state = NULL,
                                    by = c("state","region","national")) {
  by <- match.arg(by)
  dt <- copy(.get_ds("igst_settlement"))
  if (!is.null(financial_year))
    dt <- dt[get("financial_year") %in% financial_year]
  if (!is.null(state))
    dt <- dt[get("state") %in% state]

  grp <- switch(by,
    state    = c("financial_year","state","region"),
    region   = c("financial_year","region"),
    national = "financial_year"
  )
  out <- dt[, lapply(.SD, sum, na.rm=TRUE), by=grp, .SDcols=c("regular","adhoc","total")]
  setorder(out, financial_year)
  out
}


# ── Registration Functions ─────────────────────────────────────────────────────

#' GST Registration Summary
#'
#' State-wise taxpayer registration counts, optionally filtered by region.
#'
#' @param region `character` vector. `NULL` = all.
#' @param type `character` vector. Registration types to include:
#'   `"normal"`, `"composition"`, `"isd"`, `"casual"`, `"tcs"`, `"tds"`.
#'   Default = all.
#'
#' @return A `data.table`.
#' @export
#' @examples
#' gst_registration_summary(region = "South")
#' gst_registration_summary()[order(-normal)][1:10]
gst_registration_summary <- function(region = NULL,
                                     type = c("normal","composition","isd","casual","tcs","tds")) {
  type <- match.arg(type, c("normal","composition","isd","casual","tcs","tds"), several.ok=TRUE)
  dt <- copy(.get_ds("gst_registration"))
  if (!is.null(region)) dt <- dt[get("region") %in% region]
  dt[, .SD, .SDcols = c("state_code","state","region", type)]
}


# ── Reference Functions ────────────────────────────────────────────────────────

#' Available States and Their Codes
#'
#' Reference table of all state/UT names, codes, and regions from
#' [gst_statewise].
#'
#' @return A `data.table` with `state_code`, `state`, and `region`.
#' @export
#' @examples
#' gst_states()
gst_states <- function() {
  dt <- .get_ds("gst_statewise")
  unique(dt[, .(state_code, state, region)])[order(state_code)]
}


#' Available Financial Years
#'
#' @return A sorted `character` vector of financial year labels.
#' @export
#' @examples
#' gst_years()
gst_years <- function() {
  sort(unique(.get_ds("gst_statewise")[["financial_year"]]))
}


#' GST Data Catalogue
#'
#' Print a summary of all datasets available in the package.
#'
#' @return Invisibly returns a `data.table` of dataset metadata.
#' @export
#' @examples
#' gst_catalogue()
gst_catalogue <- function() {
  cat <- data.table::data.table(
    dataset = c("gst_statewise","gst_refunds","gstr1_filing","gstr3b_filing",
                "ewb_data","igst_settlement","gross_net_collection",
                "gst_registration","gst_taxpayer_profile"),
    rows    = c(4306L, 2911L, 3876L, 3914L, 3474L, 3914L, 23L, 39L, 16L),
    coverage = c("FY 2017-18 to 2025-26","FY 2020-21 to 2025-26",
                 "FY 2017-18 to 2025-26","FY 2017-18 to 2025-26",
                 "FY 2018-19 to 2025-26","FY 2017-18 to 2025-26",
                 "Apr 2024 to Feb 2026","Snapshot Mar 2025",
                 "Snapshot Mar 2025"),
    description = c(
      "State-wise monthly CGST/SGST/IGST/CESS collection",
      "State-wise monthly GST refund disbursements",
      "GSTR-1 filing compliance by state and month",
      "GSTR-3B filing compliance by state and month",
      "E-Way Bill statistics (intrastate & interstate)",
      "Monthly IGST settlement to states (regular + ad-hoc)",
      "Gross vs net national GST collection with YoY comparison",
      "Taxpayer registration by state and type",
      "Taxpayer constitution and female representation"
    )
  )
  print(cat, class=FALSE)
  invisible(cat)
}
