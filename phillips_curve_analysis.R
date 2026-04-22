# ============================================
# ECM081 PROJECT: PHILLIPS CURVE ANALYSIS
# Testing the Phillips Curve Relationship: Inflation and Unemployment Dynamics 
# in the US Economy (1990-2025)
# Student ID: [YOUR_ID]
# ============================================

# ============================================
# SECTION 1: LOAD PACKAGES
# ============================================

# Install packages if not already installed (uncomment if needed)
# install.packages(c("tidyverse", "tseries", "lmtest", "sandwich", 
#                    "car", "strucchange", "zoo", "quantmod", "readxl"))

# Load required libraries
library(tidyverse)    # Data manipulation and visualization
library(tseries)      # Time series analysis and tests
library(lmtest)       # Econometric testing functions
library(sandwich)     # Robust standard errors
library(car)          # VIF and diagnostic tests
library(strucchange)  # Structural break tests
library(zoo)          # Time series objects
library(quantmod)     # Data download from FRED

# ============================================
# SECTION 2: DATA COLLECTION FROM FRED
# ============================================

# Note: This code downloads data directly from FRED (Federal Reserve Economic Data)
# Data Sources:
# - CPIAUCSL: Consumer Price Index for All Urban Consumers
# - UNRATE: Civilian Unemployment Rate
# - GDPC1: Real Gross Domestic Product
# - FEDFUNDS: Federal Funds Effective Rate
# - DCOILBRENTEU: Brent Crude Oil Prices (Europe)

# Download data from FRED
cat("Downloading data from FRED...\n")

# CPI Data (Monthly)
cpi_raw <- getSymbols("CPIAUCSL", src = "FRED", auto.assign = FALSE)
colnames(cpi_raw) <- "CPI"

# Unemployment Rate (Monthly)
unemp_raw <- getSymbols("UNRATE", src = "FRED", auto.assign = FALSE)
colnames(unemp_raw) <- "Unemployment"

# Real GDP (Quarterly)
gdp_raw <- getSymbols("GDPC1", src = "FRED", auto.assign = FALSE)
colnames(gdp_raw) <- "GDP"

# Federal Funds Rate (Monthly)
fedfunds_raw <- getSymbols("FEDFUNDS", src = "FRED", auto.assign = FALSE)
colnames(fedfunds_raw) <- "Interest_Rate"

# Brent Oil Prices (Daily/Monthly)
oil_raw <- getSymbols("DCOILBRENTEU", src = "FRED", auto.assign = FALSE)
colnames(oil_raw) <- "Oil_Price"

# ============================================
# SECTION 3: DATA MERGING AND FREQUENCY CONVERSION
# ============================================

cat("Processing and merging data...\n")

# Merge all monthly series first
monthly_data <- merge(cpi_raw, unemp_raw, fedfunds_raw, oil_raw)

# Convert to quarterly frequency (average for flow variables)
monthly_data_df <- as.data.frame(monthly_data)
monthly_data_df$Date <- as.Date(rownames(monthly_data_df))

# Create quarterly date variable
monthly_data_df$Year <- as.numeric(format(monthly_data_df$Date, "%Y"))
monthly_data_df$Quarter <- as.numeric(cut(monthly_data_df$Date, 
                                           breaks = "quarter", 
                                           labels = 1:4))

# Aggregate to quarterly (mean for rates and indices)
quarterly_data <- monthly_data_df %>%
  group_by(Year, Quarter) %>%
  summarise(
    CPI = mean(CPI, na.rm = TRUE),
    Unemployment = mean(Unemployment, na.rm = TRUE),
    Interest_Rate = mean(Interest_Rate, na.rm = TRUE),
    Oil_Price = mean(Oil_Price, na.rm = TRUE),
    .groups = 'drop'
  )

# Create proper date format for quarterly data
quarterly_data$Date <- as.Date(paste0(quarterly_data$Year, "-", 
                                       (quarterly_data$Quarter - 1) * 3 + 1, "-01"))

# Now add GDP (already quarterly)
gdp_df <- as.data.frame(gdp_raw)
gdp_df$Date <- as.Date(rownames(gdp_df))
gdp_df$Year <- as.numeric(format(gdp_df$Date, "%Y"))
gdp_df$Quarter <- as.numeric(cut(gdp_df$Date, 
                                  breaks = "quarter", 
                                  labels = 1:4))

gdp_quarterly <- gdp_df %>%
  group_by(Year, Quarter) %>%
  summarise(
    GDP = mean(GDP, na.rm = TRUE),
    .groups = 'drop'
  )

gdp_quarterly$Date <- as.Date(paste0(gdp_quarterly$Year, "-", 
                                      (gdp_quarterly$Quarter - 1) * 3 + 1, "-01"))

# Merge GDP with other variables
data <- left_join(quarterly_data, gdp_quarterly, by = c("Year", "Quarter", "Date"))

# Filter to sample period: 1990 Q1 to 2024 Q4
data <- data %>%
  filter(Year >= 1990 & Year <= 2024) %>%
  filter(!(Year == 2024 & Quarter > 4))

# ============================================
# SECTION 4: DATA TRANSFORMATIONS
# ============================================

cat("Calculating derived variables...\n")

# Calculate inflation rate (year-over-year percentage change in CPI)
data$Inflation_Rate <- c(NA, diff(data$CPI) / lag(data$CPI, n = 1) * 100)

# Alternative: Year-over-year inflation (more common in Phillips Curve literature)
data$Inflation_YoY <- c(rep(NA, 4), diff(data$CPI, lag = 4) / lag(data$CPI, n = 4) * 100)

# Calculate GDP growth rate (quarter-over-quarter annualized)
data$GDP_Growth <- c(NA, diff(data$GDP) / lag(data$GDP, n = 1) * 100)

# Alternative: Year-over-year GDP growth
data$GDP_Growth_YoY <- c(rep(NA, 4), diff(data$GDP, lag = 4) / lag(data$GDP, n = 4) * 100)

# Log transformation of oil prices (to reduce skewness and interpret as elasticities)
data$Log_Oil <- log(data$Oil_Price)

# Create time trend variable
data$Time_Trend <- 1:nrow(data)

# Create crisis dummy variables
data$Crisis_2008 <- ifelse(data$Year >= 2008 & data$Year <= 2009, 1, 0)
data$Post_2008 <- ifelse(data$Year >= 2008, 1, 0)
data$COVID <- ifelse(data$Year == 2020, 1, 0)

# Remove rows with NA values (from differencing)
data_clean <- data %>%
  filter(!is.na(Inflation_YoY), !is.na(GDP_Growth_YoY))

# Reset row names
rownames(data_clean) <- NULL

# ============================================
# SECTION 5: CREATE TIME SERIES OBJECT
# ============================================

# Convert to time series object for some tests
start_year <- min(data_clean$Year)
start_quarter <- min(data_clean$Quarter[data_clean$Year == start_year])

data_ts <- ts(data_clean[, c("Inflation_YoY", "Unemployment", "GDP_Growth_YoY", 
                             "Interest_Rate", "Log_Oil")],
              start = c(start_year, start_quarter),
              frequency = 4)

# ============================================
# SECTION 6: DESCRIPTIVE STATISTICS
# ============================================

cat("\n=== DESCRIPTIVE STATISTICS ===\n\n")

# Summary statistics
desc_stats <- data_clean %>%
  select(Inflation_YoY, Unemployment, GDP_Growth_YoY, Interest_Rate, Oil_Price) %>%
  summarise(
    Mean = sapply(., mean, na.rm = TRUE),
    SD = sapply(., sd, na.rm = TRUE),
    Min = sapply(., min, na.rm = TRUE),
    Max = sapply(., max, na.rm = TRUE),
    Median = sapply(., median, na.rm = TRUE),
    Skewness = sapply(., function(x) mean(((x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE))^3), na.rm = TRUE),
    Kurtosis = sapply(., function(x) mean(((x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE))^4), na.rm = TRUE)
  )

print(desc_stats)

# Correlation matrix
cat("\n=== CORRELATION MATRIX ===\n\n")
cor_matrix <- cor(data_clean[, c("Inflation_YoY", "Unemployment", "GDP_Growth_YoY", 
                                  "Interest_Rate", "Log_Oil")], 
                  use = "complete.obs")
print(round(cor_matrix, 3))

# Save descriptive statistics to CSV
write.csv(desc_stats, "descriptive_statistics.csv", row.names = FALSE)
write.csv(cor_matrix, "correlation_matrix.csv")

# ============================================
# SECTION 7: VISUALIZATION
# ============================================

cat("\nCreating visualizations...\n")

# Plot time series of key variables
pdf("time_series_plots.pdf", width = 10, height = 8)

par(mfrow = c(2, 2))

# Inflation over time
plot(data_clean$Date, data_clean$Inflation_YoY, type = "l", col = "blue", lwd = 2,
     xlab = "Year", ylab = "Inflation Rate (%)", main = "US Inflation Rate (YoY)",
     ylim = c(-2, 10))
abline(v = as.Date(c("2008-01-01", "2020-01-01")), lty = 2, col = "red")
legend("topright", legend = c("Inflation", "2008 Crisis", "COVID"), 
       col = c("blue", "red", "red"), lty = c(1, 2, 2), bty = "n")

# Unemployment over time
plot(data_clean$Date, data_clean$Unemployment, type = "l", col = "darkgreen", lwd = 2,
     xlab = "Year", ylab = "Unemployment Rate (%)", main = "US Unemployment Rate",
     ylim = c(3, 11))
abline(v = as.Date(c("2008-01-01", "2020-01-01")), lty = 2, col = "red")

# GDP Growth over time
plot(data_clean$Date, data_clean$GDP_Growth_YoY, type = "l", col = "purple", lwd = 2,
     xlab = "Year", ylab = "GDP Growth Rate (%)", main = "US GDP Growth Rate (YoY)")
abline(v = as.Date(c("2008-01-01", "2020-01-01")), lty = 2, col = "red")

# Oil Prices over time
plot(data_clean$Date, data_clean$Oil_Price, type = "l", col = "orange", lwd = 2,
     xlab = "Year", ylab = "Oil Price (USD)", main = "Brent Crude Oil Price")
abline(v = as.Date(c("2008-01-01", "2020-01-01")), lty = 2, col = "red")

dev.off()

# Phillips Curve scatter plot
pdf("phillips_curve_scatter.pdf", width = 8, height = 6)

plot(data_clean$Unemployment, data_clean$Inflation_YoY, 
     xlab = "Unemployment Rate (%)", ylab = "Inflation Rate (%)",
     main = "Phillips Curve: Inflation vs Unemployment (1990-2024)",
     pch = 19, col = rgb(0, 0, 1, 0.5), cex = 0.7)

# Add different colors for different periods
pre_crisis <- data_clean %>% filter(Year < 2008)
post_crisis <- data_clean %>% filter(Year >= 2008 & Year < 2020)
covid_period <- data_clean %>% filter(Year >= 2020)

points(pre_crisis$Unemployment, pre_crisis$Inflation_YoY, col = "blue", pch = 19, cex = 0.7)
points(post_crisis$Unemployment, post_crisis$Inflation_YoY, col = "green", pch = 19, cex = 0.7)
points(covid_period$Unemployment, covid_period$Inflation_YoY, col = "red", pch = 19, cex = 0.7)

legend("topright", legend = c("1990-2007", "2008-2019", "2020-2024"),
       col = c("blue", "green", "red"), pch = 19, bty = "n")

# Add regression line
abline(lm(Inflation_YoY ~ Unemployment, data = data_clean), col = "black", lwd = 2, lty = 2)

dev.off()

cat("Visualizations saved as PDF files.\n")

# ============================================
# SECTION 8: INITIAL OLS REGRESSION
# ============================================

cat("\n=== ESTIMATING INITIAL MODEL ===\n\n")

# Model Specification:
# Inflation_t = β₀ + β₁(Unemployment_t) + β₂(GDP_Growth_t) + 
#               β₃(Interest_Rate_t) + β₄(Log_Oil_t) + ε_t

# Expected signs:
# β₁ (Unemployment): Negative (Phillips Curve relationship)
# β₂ (GDP Growth): Positive (demand-pull inflation)
# β₃ (Interest Rate): Negative (monetary policy effect)
# β₄ (Oil Prices): Positive (cost-push inflation)

model1 <- lm(Inflation_YoY ~ Unemployment + GDP_Growth_YoY + 
             Interest_Rate + Log_Oil, data = data_clean)

cat("--- Initial OLS Results ---\n")
summary(model1)

# Store coefficients for later comparison
initial_results <- summary(model1)

# ============================================
# SECTION 9: DIAGNOSTIC TESTS
# ============================================

cat("\n=== PERFORMING DIAGNOSTIC TESTS ===\n\n")

# Create a list to store test results
diagnostic_results <- list()

# --------------------------------------------
# Test 1: Normality of Residuals (Jarque-Bera)
# --------------------------------------------
cat("Test 1: Normality of Residuals\n")

jb_test <- jarque.bera.test(model1$residuals)
diagnostic_results$normality <- jb_test

cat("Jarque-Bera Test:\n")
print(jb_test)

# Visual inspection
pdf("residual_diagnostic_plots.pdf", width = 10, height = 6)

par(mfrow = c(1, 2))

# Histogram with normal curve
hist(model1$residuals, breaks = 20, freq = FALSE, 
     main = "Histogram of Residuals", xlab = "Residuals", col = "lightblue")
curve(dnorm(x, mean = mean(model1$residuals), sd = sd(model1$residuals)), 
      add = TRUE, col = "red", lwd = 2)

# Q-Q plot
qqnorm(model1$residuals, main = "Q-Q Plot of Residuals")
qqline(model1$residuals, col = "red", lwd = 2)

dev.off()

cat("Normality test completed. Check residual_diagnostic_plots.pdf\n")

# --------------------------------------------
# Test 2: Heteroskedasticity (Breusch-Pagan)
# --------------------------------------------
cat("\nTest 2: Heteroskedasticity\n")

bp_test <- bptest(model1)
diagnostic_results$heteroskedasticity_bp <- bp_test

cat("Breusch-Pagan Test:\n")
print(bp_test)

# White test (more general)
white_test <- bptest(model1, ~ fitted(model1) + I(fitted(model1)^2))
diagnostic_results$heteroskedasticity_white <- white_test

cat("\nWhite Test:\n")
print(white_test)

# --------------------------------------------
# Test 3: Autocorrelation (Durbin-Watson & Breusch-Godfrey)
# --------------------------------------------
cat("\nTest 3: Autocorrelation\n")

dw_test <- dwtest(model1)
diagnostic_results$autocorrelation_dw <- dw_test

cat("Durbin-Watson Test:\n")
print(dw_test)

# Breusch-Godfrey test (more general, allows for higher-order autocorrelation)
bg_test <- bgtest(model1, order = 4)
diagnostic_results$autocorrelation_bg <- bg_test

cat("\nBreusch-Godfrey Test (order = 4):\n")
print(bg_test)

# --------------------------------------------
# Test 4: Multicollinearity (VIF)
# --------------------------------------------
cat("\nTest 4: Multicollinearity\n")

vif_values <- vif(model1)
diagnostic_results$multicollinearity <- vif_values

cat("Variance Inflation Factors:\n")
print(vif_values)

cat("\nRule of thumb: VIF > 10 indicates problematic multicollinearity\n")

# --------------------------------------------
# Test 5: Structural Breaks (Chow Test & CUSUM)
# --------------------------------------------
cat("\nTest 5: Structural Breaks\n")

# Chow test for 2008 crisis (2008 Q1 ≈ observation 73)
# First, find the exact observation number for 2008 Q1
obs_2008_q1 <- which(data_clean$Year == 2008 & data_clean$Quarter == 1)

if(length(obs_2008_q1) > 0) {
  chow_test <- sctest(model1, type = "Chow", point = obs_2008_q1)
  diagnostic_results$structural_break_chow <- chow_test
  
  cat("Chow Test for structural break at 2008 Q1:\n")
  print(chow_test)
}

# CUSUM test
cusum_test <- efp(model1, type = "Rec-CUSUM")
diagnostic_results$structural_break_cusum <- cusum_test

pdf("cusum_plot.pdf", width = 8, height = 6)
plot(cusum_test, main = "CUSUM Test for Structural Stability")
dev.off()

cat("\nCUSUM test plot saved as cusum_plot.pdf\n")

# --------------------------------------------
# Test 6: Functional Form (Ramsey RESET)
# --------------------------------------------
cat("\nTest 6: Functional Form\n")

reset_test <- resettest(model1, power = 2:3)
diagnostic_results$functional_form <- reset_test

cat("Ramsey RESET Test:\n")
print(reset_test)

cat("\nIf RESET test is significant, consider adding polynomial terms or interactions.\n")

# ============================================
# SECTION 10: MODEL CORRECTIONS
# ============================================

cat("\n=== APPLYING MODEL CORRECTIONS ===\n\n")

# Correction 1: Robust Standard Errors for Heteroskedasticity
cat("Applying heteroskedasticity-robust standard errors (HC1)...\n")

coeftest_hc1 <- coeftest(model1, vcov = vcovHC(model1, type = "HC1"))
cat("\nCoefficients with HC1 robust SE:\n")
print(coeftest_hc1)

# Correction 2: Newey-West Standard Errors for Autocorrelation
cat("\nApplying Newey-West standard errors (lag = 4)...\n")

coeftest_nw <- coeftest(model1, vcov = NeweyWest(model1, lag = 4))
cat("\nCoefficients with Newey-West SE:\n")
print(coeftest_nw)

# Correction 3: Add quadratic unemployment term (if RESET test significant)
cat("\nTesting non-linear Phillips Curve (quadratic unemployment)...\n")

model_nonlinear <- lm(Inflation_YoY ~ Unemployment + I(Unemployment^2) + 
                      GDP_Growth_YoY + Interest_Rate + Log_Oil, 
                      data = data_clean)

cat("\nNon-linear Model Results:\n")
summary(model_nonlinear)

# Compare models
cat("\nComparing linear vs non-linear models:\n")
anova(model1, model_nonlinear)

# Correction 4: Add crisis dummy variables
cat("\nAdding crisis dummy variables...\n")

model_crisis <- lm(Inflation_YoY ~ Unemployment + GDP_Growth_YoY + 
                   Interest_Rate + Log_Oil + Post_2008 + COVID, 
                   data = data_clean)

cat("\nModel with Crisis Dummies:\n")
summary(model_crisis)

# ============================================
# SECTION 11: FINAL MODEL ESTIMATION
# ============================================

cat("\n=== FINAL MODEL ESTIMATION ===\n\n")

# Based on diagnostic tests, select the best specification
# For this example, we'll use: nonlinear terms + crisis dummies + Newey-West SE

final_model <- lm(Inflation_YoY ~ Unemployment + I(Unemployment^2) + 
                  GDP_Growth_YoY + Interest_Rate + Log_Oil + 
                  Post_2008 + COVID, 
                  data = data_clean)

cat("--- Final Model Summary ---\n")
summary(final_model)

# Apply Newey-West standard errors (corrects for both heteroskedasticity and autocorrelation)
final_results <- coeftest(final_model, vcov = NeweyWest(final_model, lag = 4))

cat("\n--- Final Model with Newey-West Standard Errors ---\n")
print(final_results)

# Calculate marginal effect of unemployment at mean unemployment
mean_unemp <- mean(data_clean$Unemployment)
coef_unemp <- coef(final_model)["Unemployment"]
coef_unemp_sq <- coef(final_model)["I(Unemployment^2)"]

marginal_effect <- coef_unemp + 2 * coef_unemp_sq * mean_unemp
cat(sprintf("\nMarginal effect of unemployment at mean (%.2f%%): %.4f\n", 
            mean_unemp, marginal_effect))

# ============================================
# SECTION 12: SUBSAMPLE ANALYSIS
# ============================================

cat("\n=== SUBSAMPLE ANALYSIS ===\n\n")

# Pre-2008 period
cat("Pre-2008 Period (1990-2007):\n")
pre_2008 <- data_clean %>% filter(Year < 2008)
model_pre <- lm(Inflation_YoY ~ Unemployment + GDP_Growth_YoY + 
                Interest_Rate + Log_Oil, data = pre_2008)
print(summary(model_pre)$coefficients)

# Post-2008 period
cat("\nPost-2008 Period (2008-2019):\n")
post_2008_data <- data_clean %>% filter(Year >= 2008 & Year < 2020)
model_post <- lm(Inflation_YoY ~ Unemployment + GDP_Growth_YoY + 
                 Interest_Rate + Log_Oil, data = post_2008_data)
print(summary(model_post)$coefficients)

# Compare coefficients
cat("\nComparison of unemployment coefficient across periods:\n")
comparison <- data.frame(
  Period = c("Full Sample", "Pre-2008", "Post-2008"),
  Unemployment_Coefficient = c(
    coef(final_model)["Unemployment"],
    coef(model_pre)["Unemployment"],
    coef(model_post)["Unemployment"]
  ),
  Std_Error = c(
    sqrt(diag(vcovHC(final_model, type = "HC1")))["Unemployment"],
    sqrt(diag(vcovHC(model_pre, type = "HC1)))["Unemployment"],
    sqrt(diag(vcovHC(model_post, type = "HC1")))["Unemployment"]
  )
)
print(comparison)

# ============================================
# SECTION 13: EXPORT RESULTS FOR REPORT
# ============================================

cat("\n=== EXPORTING RESULTS ===\n\n")

# Create formatted tables for the report

# Table 1: Descriptive Statistics
desc_table <- data.frame(
  Variable = c("Inflation Rate (YoY)", "Unemployment Rate", 
               "GDP Growth Rate (YoY)", "Interest Rate", "Oil Price"),
  Mean = round(desc_stats$Mean, 3),
  `Std. Dev.` = round(desc_stats$SD, 3),
  Minimum = round(desc_stats$Min, 3),
  Maximum = round(desc_stats$Max, 3),
  Observations = nrow(data_clean)
)

write.csv(desc_table, "table1_descriptive_statistics.csv", row.names = FALSE)
cat("Table 1 saved: table1_descriptive_statistics.csv\n")

# Table 2: Regression Results
# Extract coefficients and standard errors
coef_table <- data.frame(
  Variable = rownames(final_results),
  Coefficient = round(final_results[, "Estimate"], 4),
  `Std. Error` = round(final_results[, "Std. Error"], 4),
  `t-statistic` = round(final_results[, "t value"], 3),
  `p-value` = round(final_results[, "Pr(>|t|)"], 4)
)

# Add significance stars
coef_table$Significance <- ifelse(coef_table$`p-value` < 0.01, "***",
                            ifelse(coef_table$`p-value` < 0.05, "**",
                            ifelse(coef_table$`p-value` < 0.1, "*", "")))

coef_table$Coefficient_Stars <- paste0(coef_table$Coefficient, coef_table$Significance)

write.csv(coef_table, "table2_regression_results.csv", row.names = FALSE)
cat("Table 2 saved: table2_regression_results.csv\n")

# Table 3: Diagnostic Tests Summary
diag_summary <- data.frame(
  Test = c("Jarque-Bera (Normality)", "Breusch-Pagan (Heteroskedasticity)",
           "Durbin-Watson (Autocorrelation)", "Breusch-Godfrey (Autocorrelation)",
           "VIF Mean", "Ramsey RESET (Functional Form)"),
  Statistic = c(
    round(jb_test$statistic, 3),
    round(bp_test$studentize, 3),
    round(dw_test$statistic, 3),
    round(bg_test$statistic, 3),
    round(mean(vif_values), 3),
    round(reset_test$statistic, 3)
  ),
  `p-value` = c(
    round(jb_test$p.value, 4),
    round(bp_test$p.value, 4),
    round(dw_test$p.value, 4),
    round(bg_test$p.value, 4),
    NA,
    round(reset_test$p.value, 4)
  ),
  Conclusion = c(
    ifelse(jb_test$p.value < 0.05, "Reject normality", "Cannot reject normality"),
    ifelse(bp_test$p.value < 0.05, "Heteroskedasticity detected", "No heteroskedasticity"),
    ifelse(dw_test$statistic < 1.5 | dw_test$statistic > 2.5, "Autocorrelation likely", "No autocorrelation"),
    ifelse(bg_test$p.value < 0.05, "Autocorrelation detected", "No autocorrelation"),
    ifelse(mean(vif_values) > 5, "Multicollinearity concern", "No multicollinearity"),
    ifelse(reset_test$p.value < 0.05, "Model misspecified", "Model correctly specified")
  )
)

write.csv(diag_summary, "table3_diagnostic_tests.csv", row.names = FALSE)
cat("Table 3 saved: table3_diagnostic_tests.csv\n")

# Table 4: Comparison of Models
model_comparison <- data.frame(
  Model = c("Initial OLS", "With Robust SE", "Non-linear", "With Crisis Dummies", "Final Model"),
  `Unemployment Coeff` = c(
    round(coef(model1)["Unemployment"], 4),
    round(coef(model1)["Unemployment"], 4),
    round(coef(model_nonlinear)["Unemployment"], 4),
    round(coef(model_crisis)["Unemployment"], 4),
    round(coef(final_model)["Unemployment"], 4)
  ),
  `R-squared` = c(
    round(summary(model1)$r.squared, 4),
    round(summary(model1)$r.squared, 4),
    round(summary(model_nonlinear)$r.squared, 4),
    round(summary(model_crisis)$r.squared, 4),
    round(summary(final_model)$r.squared, 4)
  ),
  `Adj. R-squared` = c(
    round(summary(model1)$adj.r.squared, 4),
    round(summary(model1)$adj.r.squared, 4),
    round(summary(model_nonlinear)$adj.r.squared, 4),
    round(summary(model_crisis)$adj.r.squared, 4),
    round(summary(final_model)$adj.r.squared, 4)
  ),
  AIC = c(
    round(AIC(model1), 2),
    round(AIC(model1), 2),
    round(AIC(model_nonlinear), 2),
    round(AIC(model_crisis), 2),
    round(AIC(final_model), 2)
  )
)

write.csv(model_comparison, "table4_model_comparison.csv", row.names = FALSE)
cat("Table 4 saved: table4_model_comparison.csv\n")

# Save cleaned dataset
write.csv(data_clean, "cleaned_data_phillips_curve.csv", row.names = FALSE)
cat("\nCleaned dataset saved: cleaned_data_phillips_curve.csv\n")

# ============================================
# SECTION 14: POLICY IMPLICATIONS & CONCLUSION
# ============================================

cat("\n=== KEY FINDINGS SUMMARY ===\n\n")

cat("1. Phillips Curve Relationship:\n")
cat(sprintf("   - Unemployment coefficient: %.4f (%s)\n", 
            coef(final_model)["Unemployment"],
            ifelse(coef_table$`p-value`[coef_table$Variable == "Unemployment"] < 0.05, 
                   "statistically significant", "not significant")))
cat(sprintf("   - Interpretation: A 1 percentage point increase in unemployment is associated with a %.2f percentage point decrease in inflation\n",
            abs(coef(final_model)["Unemployment"])))

cat("\n2. Model Fit:\n")
cat(sprintf("   - R-squared: %.3f\n", summary(final_model)$r.squared))
cat(sprintf("   - The model explains %.1f%% of the variation in inflation\n", 
            summary(final_model)$r.squared * 100))

cat("\n3. Diagnostic Tests Summary:\n")
cat(sprintf("   - Normality: %s\n", diag_summary$Conclusion[1]))
cat(sprintf("   - Heteroskedasticity: %s\n", diag_summary$Conclusion[2]))
cat(sprintf("   - Autocorrelation: %s\n", diag_summary$Conclusion[3]))
cat(sprintf("   - Functional Form: %s\n", diag_summary$Conclusion[6]))

cat("\n4. Policy Implications:\n")
if(coef(final_model)["Unemployment"] < 0 && coef_table$`p-value`[coef_table$Variable == "Unemployment"] < 0.05) {
  cat("   - Evidence supports the existence of a Phillips Curve trade-off\n")
  cat("   - Monetary policy faces a short-run trade-off between inflation and unemployment\n")
} else {
  cat("   - Limited evidence for traditional Phillips Curve in recent period\n")
  cat("   - May indicate flattened Phillips Curve or role of expectations\n")
}

cat("\n============================================\n")
cat("ANALYSIS COMPLETE\n")
cat("============================================\n")
cat("\nOutput files generated:\n")
cat("- time_series_plots.pdf\n")
cat("- phillips_curve_scatter.pdf\n")
cat("- residual_diagnostic_plots.pdf\n")
cat("- cusum_plot.pdf\n")
cat("- table1_descriptive_statistics.csv\n")
cat("- table2_regression_results.csv\n")
cat("- table3_diagnostic_tests.csv\n")
cat("- table4_model_comparison.csv\n")
cat("- cleaned_data_phillips_curve.csv\n")
cat("- descriptive_statistics.csv\n")
cat("- correlation_matrix.csv\n")
cat("\nReady for report writing!\n")
