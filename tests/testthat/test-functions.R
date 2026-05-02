library(testthat)
library(data.table)
library(gstIndia)

# ── Data structure ────────────────────────────────────────────────────────────

test_that("gst_statewise loads correctly", {
  data(gst_statewise)
  expect_s3_class(gst_statewise, "data.table")
  expect_true(nrow(gst_statewise) > 4000)
  expect_named(gst_statewise,
               c("financial_year","month","month_date","state_code",
                 "state","region","cgst","sgst","igst","cess","total"),
               ignore.order = FALSE)
  expect_s3_class(gst_statewise$month_date, "Date")
})

test_that("gst_allindia loads correctly", {
  data(gst_allindia)
  expect_s3_class(gst_allindia, "data.table")
  expect_true(nrow(gst_allindia) > 100)
  expect_true("category" %in% names(gst_allindia))
  expect_true(all(c("domestic","gross_revenue") %in%
                    unique(gst_allindia$category)))
})

test_that("financial years span 2017-18 to 2025-26", {
  yrs <- gst_years()
  expect_true("2017-18" %in% yrs)
  expect_true("2024-25" %in% yrs)
  expect_true(length(yrs) >= 8)
})

# ── gst_filter() ─────────────────────────────────────────────────────────────

test_that("gst_filter returns data.table", {
  out <- gst_filter(financial_year = "2023-24")
  expect_s3_class(out, "data.table")
  expect_true(nrow(out) > 0)
  expect_true(all(out$financial_year == "2023-24"))
})

test_that("gst_filter by state works", {
  out <- gst_filter(state = "Maharashtra")
  expect_true(all(out$state == "Maharashtra"))
})

test_that("gst_filter by region works", {
  out <- gst_filter(region = "South")
  expect_true(all(out$region == "South"))
})

test_that("gst_filter component selection works", {
  out <- gst_filter(component = c("cgst","total"))
  expect_true("cgst" %in% names(out))
  expect_true("total" %in% names(out))
  expect_false("sgst" %in% names(out))
})

test_that("gst_filter date range works", {
  out <- gst_filter(from_month = "2023-04", to_month = "2023-06")
  expect_true(all(out$month >= "2023-04"))
  expect_true(all(out$month <= "2023-06"))
})

test_that("gst_filter bad component throws error", {
  expect_error(gst_filter(component = "vat"), "Unknown component")
})

# ── gst_yoy() ────────────────────────────────────────────────────────────────

test_that("gst_yoy returns growth columns", {
  out <- gst_yoy(state = "Maharashtra")
  expect_true(all(c("current","prior","change","pct_growth") %in% names(out)))
  expect_true(all(!is.na(out$prior)))
})

test_that("gst_yoy component argument works", {
  out <- gst_yoy(component = "cgst", state = "Delhi")
  expect_s3_class(out, "data.table")
  expect_true(nrow(out) > 0)
})

# ── gst_annual_summary() ─────────────────────────────────────────────────────

test_that("gst_annual_summary by state works", {
  out <- gst_annual_summary(by = "state", financial_year = "2023-24")
  expect_true("state" %in% names(out))
  expect_true(all(out$financial_year == "2023-24"))
  # should have at least 30 states
  expect_true(nrow(out) >= 30)
})

test_that("gst_annual_summary by region works", {
  out <- gst_annual_summary(by = "region")
  expect_true("region" %in% names(out))
  expect_true(all(c("North","South","East","West") %in% out$region))
})

test_that("gst_annual_summary national works", {
  out <- gst_annual_summary(by = "national")
  expect_true("financial_year" %in% names(out))
  expect_false("state" %in% names(out))
})

# ── gst_top_states() ─────────────────────────────────────────────────────────

test_that("gst_top_states returns correct n rows", {
  out <- gst_top_states(n = 5, financial_year = "2023-24")
  expect_equal(nrow(out), 5)
  expect_equal(out$rank, 1:5)
})

test_that("gst_top_states are ordered descending", {
  out <- gst_top_states(n = 10, financial_year = "2023-24")
  expect_true(all(diff(out$total) <= 0))
})

test_that("Maharashtra or Gujarat in top 5", {
  out <- gst_top_states(n = 5, financial_year = "2023-24")
  expect_true(any(c("Maharashtra","Gujarat","Karnataka") %in% out$state))
})

# ── gst_state_share() ────────────────────────────────────────────────────────

test_that("gst_state_share shares sum to ~100", {
  out <- gst_state_share(financial_year = "2023-24")
  expect_true(abs(sum(out$share_pct) - 100) < 0.01)
})

# ── gst_states() ─────────────────────────────────────────────────────────────

test_that("gst_states returns reference table", {
  out <- gst_states()
  expect_true("state" %in% names(out))
  expect_true("region" %in% names(out))
  expect_true(nrow(out) >= 30)
})

# ── gst_component_mix() ──────────────────────────────────────────────────────

test_that("gst_component_mix percentages sum to ~100", {
  out <- gst_component_mix(state = "Maharashtra",
                           financial_year = "2023-24")
  expect_true(nrow(out) > 0)
  pct_sum <- out[, cgst_pct + sgst_pct + igst_pct + cess_pct]
  # each month's four components must sum to exactly 100 (computed from same denominator)
  expect_true(all(abs(pct_sum - 100) < 1e-6))
})
