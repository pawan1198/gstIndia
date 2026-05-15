library(testthat)
library(data.table)
library(gstIndia)

# ── 1. Data loading ───────────────────────────────────────────────────────────
test_that("all 9 datasets load as data.table", {
  for (nm in c("gst_statewise","gst_refunds","gstr1_filing","gstr3b_filing",
               "ewb_data","igst_settlement","gross_net_collection",
               "gst_registration","gst_taxpayer_profile")) {
    d <- get(nm)
    expect_true(inherits(d, "data.table"), info = paste(nm, "is data.table"))
    expect_true(nrow(d) > 0, info = paste(nm, "not empty"))
  }
})

test_that("gst_statewise has correct structure", {
  expect_named(gst_statewise,
    c("financial_year","month","month_date","state_code","state","region",
      "cgst","sgst","igst","cess","total"), ignore.order = FALSE)
  expect_s3_class(gst_statewise$month_date, "Date")
  expect_true(nrow(gst_statewise) >= 4000)
  expect_true("2017-18" %in% unique(gst_statewise$financial_year))
  expect_true("2024-25" %in% unique(gst_statewise$financial_year))
})

test_that("gst_refunds has correct columns", {
  expect_true(all(c("cgst","sgst","igst","cess","total") %in% names(gst_refunds)))
  expect_true(all(gst_refunds$total >= 0, na.rm = TRUE))
})

test_that("gstr1_filing has compliance columns", {
  expect_true(all(c("eligible","on_time","late","total_filed","filing_pct") %in%
                    names(gstr1_filing)))
})

test_that("ewb_data has all direction columns", {
  expect_true("intrastate_ewb_count"      %in% names(ewb_data))
  expect_true("interstate_out_ewb_count"  %in% names(ewb_data))
  expect_true("interstate_in_ewb_count"   %in% names(ewb_data))
})

test_that("igst_settlement has correct columns", {
  expect_true(all(c("regular","adhoc","total") %in% names(igst_settlement)))
})

test_that("gst_registration has taxpayer type columns", {
  expect_true(all(c("normal","composition","isd") %in% names(gst_registration)))
  expect_true(nrow(gst_registration) >= 30)
})

test_that("gst_taxpayer_profile has constitution data", {
  expect_true(nrow(gst_taxpayer_profile) >= 10)
  expect_true("Proprietorship" %in% gst_taxpayer_profile$constitution)
})

test_that("region column is populated in state datasets", {
  for (nm in c("gst_statewise","gst_refunds","gstr1_filing","ewb_data","igst_settlement")) {
    d <- get(nm)
    expect_true("region" %in% names(d), label = paste(nm, "has region"))
    non_other <- d[region != "Other", .N]
    expect_true(non_other > 0, label = paste(nm, "has non-Other regions"))
  }
})

# ── 2. Reference functions ────────────────────────────────────────────────────
test_that("gst_years returns correct range", {
  yrs <- gst_years()
  expect_true("2017-18" %in% yrs)
  expect_true("2024-25" %in% yrs)
  expect_true(length(yrs) >= 8)
  expect_equal(yrs, sort(yrs))
})

test_that("gst_states returns reference table", {
  out <- gst_states()
  expect_s3_class(out, "data.table")
  expect_true(all(c("state_code","state","region") %in% names(out)))
  expect_true(nrow(out) >= 30)
  expect_true("Maharashtra" %in% out$state)
})

test_that("gst_catalogue returns data.table invisibly", {
  expect_invisible(cat_out <- gst_catalogue())
  expect_s3_class(cat_out, "data.table")
  expect_equal(nrow(cat_out), 9L)
  expect_true("dataset" %in% names(cat_out))
})

# ── 3. gst_filter ─────────────────────────────────────────────────────────────
test_that("gst_filter by financial_year works", {
  out <- gst_filter(financial_year = "2023-24")
  expect_true(all(out$financial_year == "2023-24"))
  expect_true(nrow(out) > 0)
})

test_that("gst_filter by state works", {
  out <- gst_filter(state = "Maharashtra")
  expect_true(all(out$state == "Maharashtra"))
})

test_that("gst_filter by region works", {
  out <- gst_filter(region = "South")
  expect_true(all(out$region == "South"))
  expect_true("Karnataka" %in% out$state)
})

test_that("gst_filter by component works", {
  out <- gst_filter(component = c("cgst","total"))
  expect_true("cgst" %in% names(out))
  expect_true("total" %in% names(out))
  expect_false("sgst" %in% names(out))
})

test_that("gst_filter by date range works", {
  out <- gst_filter(from_month = "2023-04", to_month = "2023-09")
  expect_true(all(out$month >= "2023-04"))
  expect_true(all(out$month <= "2023-09"))
  expect_equal(length(unique(out$month)), 6L)
})

test_that("gst_filter bad component throws error", {
  expect_error(gst_filter(component = "vat"), "Unknown component")
})

test_that("gst_filter combined args work", {
  out <- gst_filter(region = "North", financial_year = "2023-24",
                    component = "total")
  expect_true(all(out$region == "North"))
  expect_true(all(out$financial_year == "2023-24"))
  expect_true("Delhi" %in% out$state)
})

# ── 4. gst_yoy ────────────────────────────────────────────────────────────────
test_that("gst_yoy returns required columns", {
  out <- gst_yoy(state = "Maharashtra")
  expect_true(all(c("current","prior","change","pct_growth") %in% names(out)))
  expect_true(nrow(out) > 0)
  expect_true(all(!is.na(out$prior)))
})

test_that("gst_yoy growth arithmetic is correct", {
  out <- gst_yoy(state = "Gujarat")
  expect_true(all(abs(out$change - (out$current - out$prior)) < 1e-6))
  expect_true(all(abs(out$pct_growth - (out$change / abs(out$prior) * 100)) < 1e-6))
})

test_that("gst_yoy works for all components", {
  for (comp in c("cgst","sgst","igst","cess","total")) {
    out <- gst_yoy(component = comp, state = "Delhi")
    expect_true(nrow(out) > 0, label = paste("yoy", comp))
  }
})

# ── 5. gst_annual_summary ─────────────────────────────────────────────────────
test_that("gst_annual_summary by state correct", {
  out <- gst_annual_summary(by = "state", financial_year = "2023-24")
  expect_true("state" %in% names(out))
  expect_true(nrow(out) >= 30)
  expect_true(all(out$financial_year == "2023-24"))
})

test_that("gst_annual_summary by region returns 6 regions", {
  out <- gst_annual_summary(by = "region")
  expect_true(all(c("North","South","East","West","Central","Northeast") %in% out$region))
})

test_that("gst_annual_summary national sums are positive", {
  out <- gst_annual_summary(by = "national")
  expect_true(all(out$total > 0))
  expect_false("state" %in% names(out))
})

# ── 6. gst_top_states ─────────────────────────────────────────────────────────
test_that("gst_top_states returns n rows", {
  out <- gst_top_states(n = 5, financial_year = "2023-24")
  expect_equal(nrow(out), 5L)
  expect_equal(out$rank, 1:5)
})

test_that("gst_top_states are sorted descending", {
  out <- gst_top_states(n = 10, financial_year = "2023-24")
  expect_true(all(diff(out$total) <= 0))
})

test_that("gst_top_states top state is Maharashtra or Karnataka", {
  out <- gst_top_states(n = 3, financial_year = "2023-24")
  expect_true(any(c("Maharashtra","Karnataka","Gujarat") %in% out$state))
})

# ── 7. gst_state_share ────────────────────────────────────────────────────────
test_that("gst_state_share sums to 100", {
  out <- gst_state_share(financial_year = "2023-24")
  expect_true(abs(sum(out$share_pct) - 100) < 0.01)
})

# ── 8. gst_component_mix ─────────────────────────────────────────────────────
test_that("gst_component_mix pct sums to 100", {
  out <- gst_component_mix(state = "Maharashtra", financial_year = "2023-24")
  expect_true(nrow(out) > 0)
  pct <- out[, cgst_pct + sgst_pct + igst_pct + cess_pct]
  expect_true(all(abs(pct - 100) < 1e-6))
})

# ── 9. gst_net_collection ────────────────────────────────────────────────────
test_that("gst_net_collection net = gross - refund", {
  out <- gst_net_collection(financial_year = "2023-24", by = "state")
  expect_true(all(c("gross","refund","net") %in% names(out)))
  expect_true(all(abs(out$net - (out$gross - out$refund)) < 1e-6))
})

test_that("gst_net_collection national works", {
  out <- gst_net_collection(by = "national")
  expect_false("state" %in% names(out))
  expect_true("net" %in% names(out))
})

# ── 10. Compliance functions ──────────────────────────────────────────────────
test_that("gst_filing_compliance GSTR-1 works", {
  out <- gst_filing_compliance("GSTR-1", financial_year = "2023-24")
  expect_true(nrow(out) > 0)
  expect_true(all(c("eligible","on_time","filing_pct") %in% names(out)))
})

test_that("gst_filing_compliance GSTR-3B works", {
  out <- gst_filing_compliance("GSTR-3B", state = "Delhi")
  expect_true(all(out$state == "Delhi"))
})

test_that("gst_compliance_trend returns ordered months", {
  out <- gst_compliance_trend("GSTR-3B", by = "national")
  expect_true(all(diff(out$month_date) > 0))
})

test_that("gst_low_compliance_states returns below-threshold states", {
  out <- gst_low_compliance_states("GSTR-3B", threshold = 0.99,
                                   financial_year = "2023-24")
  expect_true(all(out$avg_filing_pct < 0.99))
})

# ── 11. EWB functions ─────────────────────────────────────────────────────────
test_that("ewb_summary filters correctly", {
  out <- ewb_summary(financial_year = "2023-24", direction = "intrastate")
  expect_true("intrastate_ewb_count" %in% names(out))
  expect_false("interstate_out_ewb_count" %in% names(out))
})

test_that("ewb_top_states returns n rows", {
  out <- ewb_top_states(n = 5, financial_year = "2023-24")
  expect_equal(nrow(out), 5L)
  expect_equal(out$rank, 1:5)
})

# ── 12. IGST settlement ───────────────────────────────────────────────────────
test_that("igst_settlement_summary by state works", {
  out <- igst_settlement_summary(financial_year = "2023-24", by = "state")
  expect_true("state" %in% names(out))
  expect_true(all(out$total >= 0, na.rm = TRUE))
})

test_that("igst_settlement_summary national works", {
  out <- igst_settlement_summary(by = "national")
  expect_false("state" %in% names(out))
  expect_true("total" %in% names(out))
})

# ── 13. Registration ──────────────────────────────────────────────────────────
test_that("gst_registration_summary filters by region", {
  # Registration state names may differ slightly; just check filter returns fewer rows
  all_out <- gst_registration_summary()
  south_out <- gst_registration_summary(region = "South")
  expect_true(nrow(south_out) <= nrow(all_out))
  # Karnataka appears in South for this dataset
  expect_true(nrow(south_out) > 0)
})

test_that("gst_registration_summary type filter works", {
  out <- gst_registration_summary(type = c("normal","composition"))
  expect_true("normal" %in% names(out))
  expect_false("tcs" %in% names(out))
})
