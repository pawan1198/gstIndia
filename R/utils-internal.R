# Internal helpers — not exported

.get_ds <- function(name) {
  e <- asNamespace("gstIndia")
  get(name, envir = e)
}

.safe_match_arg <- function(x, choices) {
  match.arg(x, choices, several.ok = TRUE)
}

.add_pct <- function(dt, num_cols, denom_col) {
  for (col in num_cols) {
    pct_col <- paste0(col, "_pct")
    dt[get(denom_col) > 0,
       (pct_col) := get(col) / get(denom_col) * 100]
  }
  dt
}

# Shared column sets
.ID_COLS   <- c("financial_year", "month", "month_date", "state_code", "state", "region")
.COMP_COLS <- c("cgst", "sgst", "igst", "cess", "total")
.FILE_COLS <- c("eligible", "on_time", "late", "total_filed", "filing_pct")
