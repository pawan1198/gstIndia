## data-raw/prepare_data.R
## Run this script to regenerate data/*.rda from raw CSVs
## usethis::use_data_raw() workflow

library(data.table)

# ── 1. State-wise monthly GST ────────────────────────────────────────────────
sw <- fread(
  file.path("data-raw", "gst_statewise.csv"),
  colClasses = list(
    character = c("financial_year", "state_code", "state", "month"),
    numeric   = c("cgst", "sgst", "igst", "cess", "total")
  )
)

# Clean state codes – left-pad to 2 digits for consistency
sw[, state_code := formatC(as.integer(gsub("[^0-9]", "", state_code)),
                           width = 2, flag = "0")]

# Parse month to Date (first day of month)
sw[, month_date := as.Date(paste0(month, "-01"))]

# Canonical state names (handle minor spelling differences across years)
name_map <- c(
  "Jammu And Kashmir"           = "Jammu and Kashmir",
  "Jammu & Kashmir"             = "Jammu and Kashmir",
  "Andaman And Nicobar Island"  = "Andaman and Nicobar Islands",
  "Andaman And Nicobar Islands" = "Andaman and Nicobar Islands",
  "Andaman and Nicobar Island"  = "Andaman and Nicobar Islands",
  "Dadra And Nagar Haveli"      = "Dadra and Nagar Haveli",
  "Daman And Diu"               = "Daman and Diu",
  "Lakshadweep"                 = "Lakshadweep"
)
for (old in names(name_map)) {
  sw[state == old, state := name_map[old]]
}

# Add region column
region_map <- list(
  North    = c("Jammu and Kashmir", "Himachal Pradesh", "Punjab", "Chandigarh",
               "Uttarakhand", "Haryana", "Delhi", "Ladakh"),
  West     = c("Rajasthan", "Gujarat", "Maharashtra", "Goa",
               "Daman and Diu", "Dadra and Nagar Haveli",
               "Dadra And Nagar Haveli And Daman And Diu"),
  South    = c("Karnataka", "Kerala", "Tamil Nadu", "Andhra Pradesh",
               "Telangana", "Puducherry", "Lakshadweep"),
  East     = c("West Bengal", "Odisha", "Bihar", "Jharkhand",
               "Andaman and Nicobar Islands"),
  Central  = c("Uttar Pradesh", "Madhya Pradesh", "Chhattisgarh"),
  Northeast= c("Sikkim", "Arunachal Pradesh", "Nagaland", "Manipur",
               "Mizoram", "Tripura", "Meghalaya", "Assam"),
  Other    = c("Other Territory", "CBIC")
)
sw[, region := "Other"]
for (r in names(region_map)) {
  sw[state %in% region_map[[r]], region := r]
}

# Re-order columns
setcolorder(sw, c("financial_year", "month", "month_date",
                  "state_code", "state", "region",
                  "cgst", "sgst", "igst", "cess", "total"))
setkey(sw, state, month_date)

gst_statewise <- sw[]

# ── 2. All-India summary ─────────────────────────────────────────────────────
ai <- fread(
  file.path("data-raw", "gst_allindia.csv"),
  colClasses = list(
    character = c("financial_year", "category", "month"),
    numeric   = c("cgst", "sgst", "igst", "cess", "total")
  )
)
ai[, month_date := as.Date(paste0(month, "-01"))]
setcolorder(ai, c("financial_year", "month", "month_date", "category",
                  "cgst", "sgst", "igst", "cess", "total"))
setkey(ai, category, month_date)

gst_allindia <- ai[]

# ── 3. Save ──────────────────────────────────────────────────────────────────
usethis::use_data(gst_statewise, overwrite = TRUE)
usethis::use_data(gst_allindia,  overwrite = TRUE)

message("Data saved: gst_statewise (", nrow(gst_statewise), " rows), ",
        "gst_allindia (", nrow(gst_allindia), " rows)")
