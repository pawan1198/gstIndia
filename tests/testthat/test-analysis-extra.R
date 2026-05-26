# tests/testthat/test-analysis-extra.R
# Tests for: gst_revenue_summary(), gst_returns_summary(), ewb_trend()

library(testthat)
library(data.table)

# ── gst_revenue_summary() ────────────────────────────────────────────────────

test_that("gst_revenue_summary returns a data.table", {
  result <- gst_revenue_summary()
  expect_s3_class(result, "data.table")
})

test_that("gst_revenue_summary has expected columns", {
  result <- gst_revenue_summary()
  expect_true(all(c("financial_year", "month_date", "category",
                    "cgst", "sgst", "igst", "cess", "total") %in% names(result)))
})

test_that("gst_revenue_summary yoy_pct column present when include_yoy = TRUE", {
  result <- gst_revenue_summary(include_yoy = TRUE)
  expect_true("yoy_pct" %in% names(result))
})

test_that("gst_revenue_summary no yoy_pct when include_yoy = FALSE", {
  result <- gst_revenue_summary(include_yoy = FALSE)
  expect_false("yoy_pct" %in% names(result))
})

test_that("gst_revenue_summary filters by financial_year", {
  result <- gst_revenue_summary(financial_year = "2024-25")
  expect_true(all(result[["financial_year"]] == "2024-25"))
})

test_that("gst_revenue_summary filters by category", {
  result <- gst_revenue_summary(category = "net_revenue")
  expect_true(all(result[["category"]] == "net_revenue"))
})

test_that("gst_revenue_summary stops on bad category", {
  expect_error(gst_revenue_summary(category = "bad_cat"), "'category' must be one of")
})

test_that("gst_revenue_summary stops on unknown financial_year", {
  expect_error(gst_revenue_summary(financial_year = "1999-00"), "'financial_year' not found")
})


# ── gst_returns_summary() ────────────────────────────────────────────────────

test_that("gst_returns_summary returns a data.table", {
  result <- gst_returns_summary()
  expect_s3_class(result, "data.table")
})

test_that("gst_returns_summary has both GSTR-1 and GSTR-3B columns", {
  result <- gst_returns_summary()
  expect_true("gstr1_pct"  %in% names(result))
  expect_true("gstr3b_pct" %in% names(result))
})

test_that("gst_returns_summary national aggregation drops state column", {
  result <- gst_returns_summary(by = "national")
  expect_false("state" %in% names(result))
})

test_that("gst_returns_summary state level keeps state column", {
  result <- gst_returns_summary(by = "state")
  expect_true("state" %in% names(result))
})

test_that("gst_returns_summary filters by financial_year", {
  result <- gst_returns_summary(financial_year = "2024-25")
  expect_true(all(result[["financial_year"]] == "2024-25"))
})

test_that("gst_returns_summary compliance pct values are between 0 and 1", {
  result <- gst_returns_summary()
  pcts <- c(result[["gstr1_pct"]], result[["gstr3b_pct"]])
  pcts <- pcts[!is.na(pcts)]
  expect_true(all(pcts >= 0 & pcts <= 1))
})


# ── ewb_trend() ──────────────────────────────────────────────────────────────

test_that("ewb_trend returns a data.table", {
  result <- ewb_trend()
  expect_s3_class(result, "data.table")
})

test_that("ewb_trend has ewb_count and assessable_value columns", {
  result <- ewb_trend()
  expect_true(all(c("ewb_count", "assessable_value") %in% names(result)))
})

test_that("ewb_trend include_mom adds mom growth columns", {
  result <- ewb_trend(include_mom = TRUE, include_yoy = FALSE)
  expect_true("mom_pct_count" %in% names(result))
  expect_true("mom_pct_value" %in% names(result))
})

test_that("ewb_trend include_yoy adds yoy growth columns", {
  result <- ewb_trend(include_yoy = TRUE, include_mom = FALSE)
  expect_true("yoy_pct_count" %in% names(result))
  expect_true("yoy_pct_value" %in% names(result))
})

test_that("ewb_trend no growth columns when both FALSE", {
  result <- ewb_trend(include_mom = FALSE, include_yoy = FALSE)
  expect_false(any(c("mom_pct_count", "yoy_pct_count") %in% names(result)))
})

test_that("ewb_trend direction filter works", {
  result <- ewb_trend(direction = "intrastate")
  if ("direction" %in% names(result)) {
    expect_true(all(result[["direction"]] == "intrastate"))
  }
  expect_s3_class(result, "data.table")
})

test_that("ewb_trend filters by financial_year", {
  result <- ewb_trend(financial_year = "2024-25")
  expect_true(all(result[["financial_year"]] == "2024-25"))
})

test_that("ewb_trend rows are in chronological order", {
  result <- ewb_trend(direction = "interstate")
  expect_true(all(diff(as.numeric(result[["month_date"]])) >= 0))
})
