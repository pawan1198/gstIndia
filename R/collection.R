# ── Collection & Refund Functions ─────────────────────────────────────────────

#' Filter State-wise GST Collection Data
#'
#' Subset [gst_statewise] by financial year, state, region, component,
#' and/or date range. Returns a `data.table`.
#'
#' @param financial_year `character` vector of FYs, e.g. `"2023-24"`. `NULL` = all.
#' @param state `character` vector of exact state names. `NULL` = all.
#' @param region `character` vector: `"North"`, `"South"`, `"East"`, `"West"`,
#'   `"Central"`, `"Northeast"`, `"Other"`. `NULL` = all.
#' @param component `character` vector from `c("cgst","sgst","igst","cess","total")`.
#'   `NULL` returns all components.
#' @param from_month `character` start month `"YYYY-MM"` (inclusive). `NULL` = no bound.
#' @param to_month `character` end month `"YYYY-MM"` (inclusive). `NULL` = no bound.
#'
#' @return A `data.table`.
#' @export
#' @examples
#' # South India, FY 2023-24, total only
#' gst_filter(region = "South", financial_year = "2023-24", component = "total")
#'
#' # Date range across years
#' gst_filter(from_month = "2023-04", to_month = "2024-03")
gst_filter <- function(financial_year = NULL, state = NULL, region = NULL,
                       component = NULL, from_month = NULL, to_month = NULL) {
  dt <- copy(.get_ds("gst_statewise"))
  fy_  <- financial_year; st_ <- state; rg_ <- region
  fm_  <- from_month;     tm_ <- to_month

  if (!is.null(fy_)) dt <- dt[get("financial_year") %in% fy_]
  if (!is.null(st_)) dt <- dt[get("state")          %in% st_]
  if (!is.null(rg_)) dt <- dt[get("region")         %in% rg_]
  if (!is.null(fm_)) dt <- dt[get("month")          >= fm_]
  if (!is.null(tm_)) dt <- dt[get("month")          <= tm_]

  if (!is.null(component)) {
    bad <- setdiff(component, .COMP_COLS)
    if (length(bad))
      stop("Unknown component(s): ", paste(bad, collapse=", "),
           ". Choose from: ", paste(.COMP_COLS, collapse=", "))
    dt <- dt[, .SD, .SDcols = c(.ID_COLS, component)]
  }
  dt
}


#' Year-on-Year GST Growth by State
#'
#' Computes month-over-same-month-prior-year growth for each state.
#'
#' @param component `character(1)`. Component to use. Default `"total"`.
#' @param state `character` vector of states. `NULL` = all.
#' @param financial_year `character` vector of FYs. `NULL` = all.
#' @param exclude_other `logical`. Exclude `"Other Territory"` / `"CBIC"`. Default `TRUE`.
#'
#' @return A `data.table` with columns `state`, `month`, `month_date`,
#'   `current`, `prior`, `change`, `pct_growth`.
#' @export
#' @examples
#' gst_yoy(state = "Maharashtra")[order(-month_date)][1:6]
#' gst_yoy(component = "cgst", financial_year = c("2023-24", "2024-25"))
gst_yoy <- function(component = "total", state = NULL,
                    financial_year = NULL, exclude_other = TRUE) {
  component <- match.arg(component, .COMP_COLS)
  dt <- gst_filter(state = state, financial_year = financial_year,
                   component = component)
  if (exclude_other) dt <- dt[!get("state") %in% c("Other Territory", "CBIC")]

  setnames(dt, component, "value")
  setkey(dt, state, month_date)
  dt[, prior := shift(value, 12L), by = state]
  dt[, `:=`(change     = value - prior,
            pct_growth = (value - prior) / abs(prior) * 100)]
  setnames(dt, "value", "current")
  dt[!is.na(prior)]
}


#' Annual GST Summary
#'
#' Aggregate monthly state-wise data to annual totals by state, region, or
#' nationally.
#'
#' @param by `character(1)`. Grouping: `"state"` (default), `"region"`, or `"national"`.
#' @param component `character` vector of components to sum. Default = all five.
#' @param financial_year `character` vector to filter. `NULL` = all.
#' @param exclude_other `logical`. Exclude non-state rows. Default `TRUE`.
#'
#' @return A `data.table` sorted by `financial_year`.
#' @export
#' @examples
#' gst_annual_summary(by = "state", financial_year = "2023-24")[order(-total)][1:5]
#' gst_annual_summary(by = "region")
#' gst_annual_summary(by = "national", component = c("cgst","sgst"))
gst_annual_summary <- function(by = c("state","region","national"),
                               component = .COMP_COLS,
                               financial_year = NULL,
                               exclude_other = TRUE) {
  by        <- match.arg(by)
  component <- match.arg(component, .COMP_COLS, several.ok = TRUE)
  dt <- gst_filter(financial_year = financial_year, component = component)
  if (exclude_other) dt <- dt[!get("state") %in% c("Other Territory","CBIC")]

  grp <- switch(by,
    state    = c("financial_year","state","region"),
    region   = c("financial_year","region"),
    national = "financial_year"
  )
  dt[, lapply(.SD, sum, na.rm=TRUE), by=grp, .SDcols=component][order(financial_year)]
}


#' Top States by GST Collection
#'
#' Return the top `n` states ranked by total collection for a given period.
#'
#' @param n `integer`. Number of states to return. Default `10L`.
#' @param component `character(1)`. Component to rank by. Default `"total"`.
#' @param financial_year `character` vector. `NULL` = all years pooled.
#' @param from_month `character`. Start month `"YYYY-MM"`.
#' @param to_month `character`. End month `"YYYY-MM"`.
#' @param exclude_other `logical`. Exclude non-state rows. Default `TRUE`.
#'
#' @return A `data.table` with columns `rank`, `state`, `region`, and the
#'   chosen component.
#' @export
#' @examples
#' gst_top_states(n = 5, financial_year = "2023-24")
#' gst_top_states(component = "cgst", from_month = "2024-04", to_month = "2024-06")
gst_top_states <- function(n = 10L, component = "total",
                           financial_year = NULL, from_month = NULL,
                           to_month = NULL, exclude_other = TRUE) {
  component <- match.arg(component, .COMP_COLS)
  dt <- gst_filter(financial_year=financial_year, from_month=from_month,
                   to_month=to_month, component=component)
  if (exclude_other) dt <- dt[!get("state") %in% c("Other Territory","CBIC")]

  out <- dt[, .(collection = sum(get(component), na.rm=TRUE),
                region     = region[1L]), by = state]
  setorder(out, -collection)
  out[, rank := seq_len(.N)]
  setnames(out, "collection", component)
  setcolorder(out, c("rank","state","region",component))
  utils::head(out, n)
}


#' State Share of National GST Collection
#'
#' Each state's percentage share of national total for a given period.
#'
#' @param component `character(1)`. Default `"total"`.
#' @param financial_year `character` vector. `NULL` = all.
#' @param from_month `character`. Start month.
#' @param to_month `character`. End month.
#' @param exclude_other `logical`. Default `TRUE`.
#'
#' @return A `data.table` with `state`, `region`, the component total, and
#'   `share_pct`.
#' @export
#' @examples
#' gst_state_share(financial_year = "2023-24")[1:10]
gst_state_share <- function(component = "total", financial_year = NULL,
                            from_month = NULL, to_month = NULL,
                            exclude_other = TRUE) {
  component <- match.arg(component, .COMP_COLS)
  dt <- gst_filter(financial_year=financial_year, from_month=from_month,
                   to_month=to_month, component=component)
  if (exclude_other) dt <- dt[!get("state") %in% c("Other Territory","CBIC")]

  out <- dt[, .(collection=sum(get(component), na.rm=TRUE), region=region[1L]), by=state]
  out[, share_pct := collection / sum(collection) * 100]
  setorder(out, -collection)
  setnames(out, "collection", component)
  out
}


#' Monthly GST Component Mix
#'
#' Monthly share (%) of CGST, SGST, IGST, and Cess in total collection for
#' a given state or nationally.
#'
#' @param state `character(1)`. State name. `NULL` = national aggregate.
#' @param financial_year `character` vector. `NULL` = all.
#'
#' @return A `data.table` with `month_date`, `cgst_pct`, `sgst_pct`,
#'   `igst_pct`, `cess_pct`.
#' @export
#' @examples
#' gst_component_mix(state = "Gujarat", financial_year = "2023-24")
#' gst_component_mix(financial_year = "2024-25")   # national
gst_component_mix <- function(state = NULL, financial_year = NULL) {
  dt <- gst_filter(state = state, financial_year = financial_year)
  dt <- dt[!is.na(get("month_date"))]

  agg <- dt[, lapply(.SD, sum, na.rm=TRUE),
            by = c("month","month_date"),
            .SDcols = c("cgst","sgst","igst","cess")]
  agg[, total_comp := cgst + sgst + igst + cess]
  agg[total_comp > 0, `:=`(
    cgst_pct = cgst / total_comp * 100,
    sgst_pct = sgst / total_comp * 100,
    igst_pct = igst / total_comp * 100,
    cess_pct = cess / total_comp * 100
  )]
  setorder(agg, month_date)
  agg[, .(month_date, cgst_pct, sgst_pct, igst_pct, cess_pct)]
}


#' Net GST Collection (Collection Minus Refunds)
#'
#' Computes net monthly collection by subtracting [gst_refunds] from
#' [gst_statewise] for overlapping FYs (2020-21 onwards).
#'
#' @param financial_year `character` vector. `NULL` = all overlapping years.
#' @param state `character` vector. `NULL` = all states.
#' @param by `character(1)`. Grouping: `"state"` (default), `"region"`, or `"national"`.
#'
#' @return A `data.table` with `financial_year`, `month`, `month_date`,
#'   grouping column(s), `gross`, `refund`, `net`.
#' @export
#' @examples
#' gst_net_collection(financial_year = "2023-24", by = "state")[order(-net)][1:10]
gst_net_collection <- function(financial_year = NULL, state = NULL,
                               by = c("state","region","national")) {
  by <- match.arg(by)

  col <- copy(.get_ds("gst_statewise"))
  ref <- copy(.get_ds("gst_refunds"))

  if (!is.null(financial_year)) {
    col <- col[get("financial_year") %in% financial_year]
    ref <- ref[get("financial_year") %in% financial_year]
  }
  if (!is.null(state)) {
    col <- col[get("state") %in% state]
    ref <- ref[get("state") %in% state]
  }
  col <- col[!get("state") %in% c("Other Territory","CBIC")]
  ref <- ref[!get("state") %in% c("Other Territory","CBIC")]

  grp_col <- switch(by,
    state    = c("financial_year","month","month_date","state","region"),
    region   = c("financial_year","month","month_date","region"),
    national = c("financial_year","month","month_date")
  )
  gc <- col[, .(gross  = sum(total, na.rm=TRUE)), by=grp_col]
  gr <- ref[, .(refund = sum(total, na.rm=TRUE)), by=grp_col]

  out <- merge(gc, gr, by=grp_col, all.x=TRUE)
  out[is.na(refund), refund := 0]
  out[, net := gross - refund]
  setorder(out, financial_year, month_date)
  out
}
