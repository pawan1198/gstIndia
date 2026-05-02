#' Filter GST State-wise Data
#'
#' @description
#' Convenience wrapper to subset [gst_statewise] by financial year, state,
#' region, and/or GST component. Returns a `data.table`.
#'
#' @param financial_year `character` vector of financial years to keep, e.g.
#'   `c("2022-23", "2023-24")`. `NULL` (default) returns all years.
#' @param state `character` vector of state/UT names to keep. `NULL` returns
#'   all states. Partial matching is **not** performed; use exact names as in
#'   [gst_statewise].
#' @param region `character` vector of region labels (`"North"`, `"South"`,
#'   `"East"`, `"West"`, `"Central"`, `"Northeast"`, `"Other"`).
#'   `NULL` returns all regions.
#' @param component `character` vector of components to return. One or more of
#'   `"cgst"`, `"sgst"`, `"igst"`, `"cess"`, `"total"`. Default `NULL`
#'   returns all components.
#' @param from_month `character` start month `"YYYY-MM"` (inclusive). Default
#'   `NULL` (no lower bound).
#' @param to_month `character` end month `"YYYY-MM"` (inclusive). Default
#'   `NULL` (no upper bound).
#'
#' @return A `data.table` with columns `financial_year`, `month`, `month_date`,
#'   `state_code`, `state`, `region`, and the selected components.
#'
#' @export
#'
#' @examples
#' # All states, last two financial years
#' gst_filter(financial_year = c("2023-24", "2024-25"))
#'
#' # Punjab and Haryana, CGST + TOTAL only
#' gst_filter(state = c("Punjab", "Haryana"), component = c("cgst", "total"))
#'
#' # Southern region, FY 2022-23
#' gst_filter(region = "South", financial_year = "2022-23")
#'
#' # Date range across years
#' gst_filter(from_month = "2023-04", to_month = "2024-03")
gst_filter <- function(financial_year = NULL,
                       state          = NULL,
                       region         = NULL,
                       component      = NULL,
                       from_month     = NULL,
                       to_month       = NULL) {
  gst_statewise <- NULL  # avoid R CMD check NOTE
  e <- asNamespace("gstIndia")
  dt <- copy(get("gst_statewise", envir = e))

  fy_arg     <- financial_year
  state_arg  <- state
  region_arg <- region

  if (!is.null(fy_arg))     dt <- dt[get("financial_year") %in% fy_arg]
  if (!is.null(state_arg))  dt <- dt[get("state") %in% state_arg]
  if (!is.null(region_arg)) dt <- dt[get("region") %in% region_arg]

  if (!is.null(from_month))
    dt <- dt[get("month") >= from_month]

  if (!is.null(to_month))
    dt <- dt[get("month") <= to_month]

  id_cols  <- c("financial_year", "month", "month_date",
                "state_code", "state", "region")
  all_comp <- c("cgst", "sgst", "igst", "cess", "total")

  if (!is.null(component)) {
    bad <- setdiff(component, all_comp)
    if (length(bad))
      stop("Unknown component(s): ", paste(bad, collapse = ", "),
           ". Choose from: ", paste(all_comp, collapse = ", "), ".")
    dt <- dt[, .SD, .SDcols = c(id_cols, component)]
  }

  dt
}


#' Year-on-Year Growth in GST Collection
#'
#' @description
#' Computes month-over-same-month-of-prior-year growth rates for each state,
#' returning both the absolute change and percentage growth.
#'
#' @param component `character(1)`. Which component to use for growth
#'   calculation. One of `"cgst"`, `"sgst"`, `"igst"`, `"cess"`, `"total"`
#'   (default).
#' @param state `character` vector to filter states. `NULL` (default) = all.
#' @param financial_year `character` vector to filter years. `NULL` = all.
#'
#' @return A `data.table` with columns `state`, `month`, `month_date`,
#'   `current`, `prior`, `change`, `pct_growth`.
#'
#' @export
#'
#' @examples
#' # YoY growth for Maharashtra
#' gst_yoy(state = "Maharashtra")
#'
#' # National CGST growth, last two years
#' gst_yoy(component = "cgst", financial_year = c("2023-24", "2024-25"))
gst_yoy <- function(component     = "total",
                    state         = NULL,
                    financial_year = NULL) {
  comp_choices <- c("cgst", "sgst", "igst", "cess", "total")
  component <- match.arg(component, comp_choices)

  dt <- gst_filter(state = state, financial_year = financial_year,
                   component = component)
  setnames(dt, component, "value")

  # Lag by 12 months per state
  setkey(dt, state, month_date)
  dt[, prior := shift(value, 12L), by = state]
  dt[, `:=`(change     = value - prior,
            pct_growth = (value - prior) / abs(prior) * 100)]

  setnames(dt, "value", "current")
  dt[!is.na(prior)]
}


#' Annual GST Summary
#'
#' @description
#' Aggregates monthly state-wise data to annual totals, optionally grouped by
#' state, region, or component.
#'
#' @param by `character(1)`. Grouping level: `"state"` (default), `"region"`,
#'   or `"national"`.
#' @param component `character` vector of components to sum. Defaults to all:
#'   `c("cgst","sgst","igst","cess","total")`.
#' @param financial_year `character` vector to filter. `NULL` = all years.
#'
#' @return A `data.table` with `financial_year`, grouping column(s), and
#'   summed component columns.
#'
#' @export
#'
#' @examples
#' # Annual state totals
#' gst_annual_summary()
#'
#' # Annual by region
#' gst_annual_summary(by = "region")
#'
#' # National CGST and SGST only
#' gst_annual_summary(by = "national", component = c("cgst", "sgst"))
gst_annual_summary <- function(by            = c("state", "region", "national"),
                               component     = c("cgst","sgst","igst","cess","total"),
                               financial_year = NULL) {
  by        <- match.arg(by)
  all_comp  <- c("cgst", "sgst", "igst", "cess", "total")
  component <- match.arg(component, all_comp, several.ok = TRUE)

  dt <- gst_filter(financial_year = financial_year, component = component)

  # Exclude non-state rows for state-level summaries
  if (by %in% c("state", "region"))
    dt <- dt[!state %in% c("Other Territory", "CBIC")]

  group_by <- switch(by,
    state    = c("financial_year", "state", "region"),
    region   = c("financial_year", "region"),
    national = "financial_year"
  )

  dt[, lapply(.SD, sum, na.rm = TRUE),
     by      = group_by,
     .SDcols = component
  ][order(financial_year)]
}


#' Top States by GST Collection
#'
#' @description
#' Returns the top `n` states ranked by total GST collection for a given
#' financial year or month range.
#'
#' @param n `integer(1)`. Number of top states to return. Default `10L`.
#' @param component `character(1)`. Component to rank by. Default `"total"`.
#' @param financial_year `character` vector. `NULL` = all years pooled.
#' @param from_month `character`. Start month `"YYYY-MM"`.
#' @param to_month `character`. End month `"YYYY-MM"`.
#' @param exclude_other `logical(1)`. Exclude `"Other Territory"` and
#'   `"CBIC"` rows (default `TRUE`).
#'
#' @return A `data.table` with columns `rank`, `state`, and the chosen
#'   component total.
#'
#' @export
#'
#' @examples
#' # Top 5 states in FY 2023-24
#' gst_top_states(n = 5, financial_year = "2023-24")
#'
#' # Top 10 by CGST in Q1 FY 2024-25
#' gst_top_states(component = "cgst",
#'                from_month = "2024-04", to_month = "2024-06")
gst_top_states <- function(n              = 10L,
                           component      = "total",
                           financial_year = NULL,
                           from_month     = NULL,
                           to_month       = NULL,
                           exclude_other  = TRUE) {
  component <- match.arg(component, c("cgst","sgst","igst","cess","total"))

  dt <- gst_filter(financial_year = financial_year,
                   from_month     = from_month,
                   to_month       = to_month,
                   component      = component)

  if (exclude_other)
    dt <- dt[!state %in% c("Other Territory", "CBIC")]

  out <- dt[, .(collection = sum(get(component), na.rm = TRUE)), by = state]
  setorder(out, -collection)
  out[, rank := seq_len(.N)]
  setcolorder(out, c("rank", "state", "collection"))
  setnames(out, "collection", component)
  head(out, n)
}


#' State Share of National GST Collection
#'
#' @description
#' Calculates each state's percentage share of the national total for a given
#' financial year or date range.
#'
#' @param component `character(1)`. Component to use. Default `"total"`.
#' @param financial_year `character` vector. `NULL` = all years pooled.
#' @param from_month `character`. Start month `"YYYY-MM"`.
#' @param to_month `character`. End month `"YYYY-MM"`.
#' @param exclude_other `logical(1)`. Exclude `"Other Territory"` and
#'   `"CBIC"`. Default `TRUE`.
#'
#' @return A `data.table` with columns `state`, `region`, `collection`,
#'   and `share_pct`.
#'
#' @export
#'
#' @examples
#' # State shares in FY 2023-24
#' gst_state_share(financial_year = "2023-24")
gst_state_share <- function(component      = "total",
                            financial_year = NULL,
                            from_month     = NULL,
                            to_month       = NULL,
                            exclude_other  = TRUE) {
  component <- match.arg(component, c("cgst","sgst","igst","cess","total"))

  dt <- gst_filter(financial_year = financial_year,
                   from_month     = from_month,
                   to_month       = to_month,
                   component      = component)

  if (exclude_other)
    dt <- dt[!state %in% c("Other Territory", "CBIC")]

  out <- dt[, .(collection = sum(get(component), na.rm = TRUE),
                region     = region[1L]),
            by = state]

  out[, share_pct := collection / sum(collection) * 100]
  setorder(out, -collection)
  setnames(out, "collection", component)
  out
}


#' Monthly Component Mix
#'
#' @description
#' For a given state (or national aggregate), returns the monthly share
#' of each GST component in the total collection.
#'
#' @param state `character(1)`. State name. If `NULL`, aggregates all states
#'   (national level).
#' @param financial_year `character` vector. `NULL` = all years.
#'
#' @return A `data.table` with `month_date`, `cgst_pct`, `sgst_pct`,
#'   `igst_pct`, `cess_pct`.
#'
#' @export
#'
#' @examples
#' # Component mix for Gujarat over all years
#' gst_component_mix(state = "Gujarat")
#'
#' # National component mix for FY 2023-24
#' gst_component_mix(financial_year = "2023-24")
gst_component_mix <- function(state = NULL, financial_year = NULL) {
  # Keep only rows that represent individual months (not annual totals),
  # identified by having a valid month_date
  dt <- gst_filter(state = state, financial_year = financial_year)
  dt <- dt[!is.na(get("month_date"))]

  # Aggregate across states (if no state filter) by month
  agg <- dt[, lapply(.SD, sum, na.rm = TRUE),
            by      = c("month", "month_date"),
            .SDcols = c("cgst", "sgst", "igst", "cess")]

  # Compute total from components so it is internally consistent
  agg[, total := cgst + sgst + igst + cess]

  agg[total > 0, `:=`(
    cgst_pct = cgst / total * 100,
    sgst_pct = sgst / total * 100,
    igst_pct = igst / total * 100,
    cess_pct = cess / total * 100
  )]
  setorder(agg, month_date)
  agg[, .(month_date, cgst_pct, sgst_pct, igst_pct, cess_pct)]
}


#' Available States and Their Codes
#'
#' @description
#' Returns a reference `data.table` of all state/UT names, codes, and
#' regions present in [gst_statewise].
#'
#' @return A `data.table` with `state_code`, `state`, and `region`.
#'
#' @export
#'
#' @examples
#' gst_states()
gst_states <- function() {
  e <- asNamespace("gstIndia")
  dt <- get("gst_statewise", envir = e)
  unique(dt[, .(state_code, state, region)])[order(state_code)]
}


#' Available Financial Years
#'
#' @description
#' Returns a character vector of all financial years present in
#' [gst_statewise].
#'
#' @return A sorted `character` vector of financial year labels.
#'
#' @export
#'
#' @examples
#' gst_years()
gst_years <- function() {
  e <- asNamespace("gstIndia")
  dt <- get("gst_statewise", envir = e)
  sort(unique(dt[["financial_year"]]))
}
