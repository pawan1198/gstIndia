# ============================================================================
# gstIndia — Three new analysis functions
# File  : R/analysis_extra.R
# Author: Pawan
# Adds  : gst_revenue_summary(), gst_returns_summary(), ewb_trend()
# ============================================================================

# Suppress R CMD CHECK notes for data.table column names used with `.SD`, `by=`, etc.
utils::globalVariables(c(
  # gst_revenue_summary
  "gross_net_collection", "category", "month_date", "financial_year",
  "cgst", "sgst", "igst", "cess", "total",
  # gst_returns_summary
  "gstr1_filing", "gstr3b_filing",
  "state", "filed", "liable", "filing_pct",
  # ewb_trend
  "ewb_data", "direction", "ewb_count", "assessable_value",
  "mom_growth", "yoy_growth", "prev_month", "prev_year"
))


# ----------------------------------------------------------------------------
#' National Monthly GST Revenue Summary
#'
#' Returns a tidy \code{data.table} of national monthly GST revenue broken
#' down by all five components (CGST, SGST, IGST, Cess, Total) for a chosen
#' \code{category} from \code{gross_net_collection}.
#'
#' @param financial_year Character scalar or \code{NULL} (default).
#'   E.g. \code{"2024-25"}. When \code{NULL} all available years are returned.
#' @param category Character scalar. One of \code{"gross_revenue"} (default),
#'   \code{"domestic"}, \code{"igst_import"}, \code{"refund"},
#'   \code{"net_revenue"}.
#' @param include_yoy Logical. If \code{TRUE} (default) appends a
#'   \code{yoy_pct} column showing year-on-year growth in \code{total}.
#'
#' @return A \code{data.table} with columns:
#'   \code{financial_year}, \code{month_date}, \code{category},
#'   \code{cgst}, \code{sgst}, \code{igst}, \code{cess}, \code{total},
#'   and optionally \code{yoy_pct}.
#'
#' @examples
#' \dontrun{
#' # Gross revenue for FY 2024-25
#' gst_revenue_summary(financial_year = "2024-25")
#'
#' # Net revenue across all years, no YoY column
#' gst_revenue_summary(category = "net_revenue", include_yoy = FALSE)
#' }
#'
#' @import data.table
#' @export
gst_revenue_summary <- function(financial_year = NULL,
                                category       = "gross_revenue",
                                include_yoy    = TRUE) {

  # ── Input validation ────────────────────────────────────────────────────────
  valid_cats <- c("domestic", "igst_import", "gross_revenue",
                  "refund", "net_revenue")
  if (!category %in% valid_cats) {
    stop(
      "'category' must be one of: ",
      paste(valid_cats, collapse = ", "),
      call. = FALSE
    )
  }

  # ── Work on a copy so we never mutate the package dataset ──────────────────
  dt <- data.table::copy(gross_net_collection)

  # ── Filter by category ─────────────────────────────────────────────────────
  dt <- dt[dt[["category"]] == category]

  # ── Optional financial-year filter ─────────────────────────────────────────
  if (!is.null(financial_year)) {
    if (!financial_year %in% dt[["financial_year"]]) {
      stop("'financial_year' not found. Use gst_years() to see available years.",
           call. = FALSE)
    }
    dt <- dt[dt[["financial_year"]] == financial_year]
  }

  # ── Sort chronologically ───────────────────────────────────────────────────
  data.table::setorder(dt, month_date)

  # ── YoY growth on `total` ──────────────────────────────────────────────────
  if (include_yoy) {
    dt[, prev_year := data.table::shift(total, n = 12L, type = "lag")]
    dt[, yoy_pct  := round((total - prev_year) / prev_year * 100, 2)]
    dt[, prev_year := NULL]
  }

  # ── Return tidy columns only ───────────────────────────────────────────────
  keep_cols <- c("financial_year", "month_date", "category",
                 "cgst", "sgst", "igst", "cess", "total")
  if (include_yoy) keep_cols <- c(keep_cols, "yoy_pct")

  dt[, .SD, .SDcols = intersect(keep_cols, names(dt))]
}


# ----------------------------------------------------------------------------
#' Combined GSTR-1 and GSTR-3B Returns Summary
#'
#' Merges \code{gstr1_filing} and \code{gstr3b_filing} into a single
#' \code{data.table} so you can compare filing counts and compliance rates
#' for both return types side by side.  Optionally aggregates across states
#' to give a national picture.
#'
#' @param financial_year Character scalar or \code{NULL} (default).
#'   E.g. \code{"2024-25"}. When \code{NULL} all years are returned.
#' @param by Character scalar. One of \code{"state"} (default) or
#'   \code{"national"}. When \code{"national"} the function averages
#'   compliance percentages and sums filed / liable counts across all states.
#' @param month Character scalar in \code{"YYYY-MM"} format or \code{NULL}
#'   (default). Filters to a single month.
#'
#' @return A \code{data.table} with columns:
#'   \code{financial_year}, \code{month_date},
#'   (if \code{by = "state"}: \code{state}),
#'   \code{gstr1_filed}, \code{gstr1_liable}, \code{gstr1_pct},
#'   \code{gstr3b_filed}, \code{gstr3b_liable}, \code{gstr3b_pct}.
#'
#' @examples
#' \dontrun{
#' # State-wise for FY 2024-25
#' gst_returns_summary(financial_year = "2024-25")
#'
#' # National monthly trend
#' gst_returns_summary(by = "national")
#'
#' # Single month snapshot
#' gst_returns_summary(month = "2025-01", by = "state")
#' }
#'
#' @import data.table
#' @export
gst_returns_summary <- function(financial_year = NULL,
                                by             = "state",
                                month          = NULL) {

  # ── Input validation ────────────────────────────────────────────────────────
  by <- match.arg(by, c("state", "national"))

  # ── Copies ─────────────────────────────────────────────────────────────────
  r1  <- data.table::copy(gstr1_filing)
  r3b <- data.table::copy(gstr3b_filing)

  # ── Standardise column names to a known set ────────────────────────────────
  # Rename filing_pct -> gstr1_pct / gstr3b_pct etc.
  data.table::setnames(r1,
    old = c("filed", "liable", "filing_pct"),
    new = c("gstr1_filed", "gstr1_liable", "gstr1_pct"),
    skip_absent = TRUE
  )
  data.table::setnames(r3b,
    old = c("filed", "liable", "filing_pct"),
    new = c("gstr3b_filed", "gstr3b_liable", "gstr3b_pct"),
    skip_absent = TRUE
  )

  # ── Optional filters ───────────────────────────────────────────────────────
  if (!is.null(financial_year)) {
    r1  <- r1[r1[["financial_year"]] == financial_year]
    r3b <- r3b[r3b[["financial_year"]] == financial_year]
  }
  if (!is.null(month)) {
    r1  <- r1[r1[["month"]] == month]
    r3b <- r3b[r3b[["month"]] == month]
  }

  # ── Merge on common keys ───────────────────────────────────────────────────
  join_keys <- intersect(
    c("financial_year", "month", "month_date", "state", "state_code", "region"),
    intersect(names(r1), names(r3b))
  )

  dt <- merge(r1, r3b, by = join_keys, all = TRUE)

  # ── National aggregation ───────────────────────────────────────────────────
  if (by == "national") {
    dt <- dt[, .(
      gstr1_filed   = sum(gstr1_filed,   na.rm = TRUE),
      gstr1_liable  = sum(gstr1_liable,  na.rm = TRUE),
      gstr1_pct     = round(mean(gstr1_pct,  na.rm = TRUE), 4),
      gstr3b_filed  = sum(gstr3b_filed,  na.rm = TRUE),
      gstr3b_liable = sum(gstr3b_liable, na.rm = TRUE),
      gstr3b_pct    = round(mean(gstr3b_pct, na.rm = TRUE), 4)
    ), by = .(financial_year, month_date)]
  }

  data.table::setorder(dt, month_date)
  dt
}


# ----------------------------------------------------------------------------
#' E-Way Bill Monthly Trend with Growth Rates
#'
#' Summarises \code{ewb_data} by month (optionally filtered by direction
#' and/or state) and appends month-on-month (\code{mom_pct}) and
#' year-on-year (\code{yoy_pct}) growth rates for both e-way bill count
#' and assessable value.
#'
#' @param financial_year Character scalar or \code{NULL} (default).
#' @param state Character scalar — full state name — or \code{NULL} (default,
#'   all states).  Use \code{gst_states()} to see valid names.
#' @param direction Character scalar. One of \code{"both"} (default),
#'   \code{"intrastate"}, or \code{"interstate"}.
#' @param include_mom Logical. Append month-on-month growth? Default \code{TRUE}.
#' @param include_yoy Logical. Append year-on-year growth?  Default \code{TRUE}.
#'
#' @return A \code{data.table} with columns:
#'   \code{financial_year}, \code{month_date},
#'   (if \code{direction = "both"}: \code{direction}),
#'   \code{ewb_count}, \code{assessable_value},
#'   and optionally \code{mom_pct_count}, \code{yoy_pct_count},
#'   \code{mom_pct_value}, \code{yoy_pct_value}.
#'
#' @examples
#' \dontrun{
#' # National trend for FY 2024-25, both directions
#' ewb_trend(financial_year = "2024-25")
#'
#' # Interstate only, Maharashtra
#' ewb_trend(state = "Maharashtra", direction = "interstate")
#'
#' # All years, intrastate, no YoY (fewer rows of history)
#' ewb_trend(direction = "intrastate", include_yoy = FALSE)
#' }
#'
#' @import data.table
#' @export
ewb_trend <- function(financial_year = NULL,
                      state          = NULL,
                      direction      = "both",
                      include_mom    = TRUE,
                      include_yoy    = TRUE) {

  # ── Input validation ────────────────────────────────────────────────────────
  direction <- match.arg(direction, c("both", "intrastate", "interstate"))

  # ── Copy ───────────────────────────────────────────────────────────────────
  dt <- data.table::copy(ewb_data)

  # ── Filters ────────────────────────────────────────────────────────────────
  if (!is.null(financial_year)) {
    dt <- dt[dt[["financial_year"]] == financial_year]
  }
  if (!is.null(state)) {
    dt <- dt[dt[["state"]] == state]
  }
  if (direction != "both") {
    dt <- dt[dt[["direction"]] == direction]
  }

  # ── Aggregate: sum EWB count + assessable value ────────────────────────────
  # Group keys depend on whether we split by direction
  grp <- if (direction == "both") {
    c("financial_year", "month_date", "direction")
  } else {
    c("financial_year", "month_date")
  }

  dt <- dt[, .(
    ewb_count        = sum(ewb_count,        na.rm = TRUE),
    assessable_value = sum(assessable_value, na.rm = TRUE)
  ), by = grp]

  data.table::setorder(dt, month_date)

  # ── Growth rates ───────────────────────────────────────────────────────────
  # Apply within each direction group (or no group if direction != "both")
  growth_by <- if (direction == "both") "direction" else character(0)

  if (include_mom) {
    dt[,
      `:=`(
        mom_pct_count = round(
          (ewb_count - data.table::shift(ewb_count, 1L)) /
            data.table::shift(ewb_count, 1L) * 100, 2),
        mom_pct_value = round(
          (assessable_value - data.table::shift(assessable_value, 1L)) /
            data.table::shift(assessable_value, 1L) * 100, 2)
      ),
      by = growth_by
    ]
  }

  if (include_yoy) {
    dt[,
      `:=`(
        yoy_pct_count = round(
          (ewb_count - data.table::shift(ewb_count, 12L)) /
            data.table::shift(ewb_count, 12L) * 100, 2),
        yoy_pct_value = round(
          (assessable_value - data.table::shift(assessable_value, 12L)) /
            data.table::shift(assessable_value, 12L) * 100, 2)
      ),
      by = growth_by
    ]
  }

  dt
}
