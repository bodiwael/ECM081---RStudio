# Phillips Curve Analysis - R Code Documentation

## Project Title
**Testing the Phillips Curve Relationship: Inflation and Unemployment Dynamics in the US Economy (1990-2025)**

## Data Sources

All data is downloaded directly from **FRED (Federal Reserve Economic Data)** using the `quantmod` package in R.

### Primary Data Source
- **Database**: FRED - Federal Reserve Economic Data
- **Provider**: Federal Reserve Bank of St. Louis
- **Website**: https://fred.stlouisfed.org/
- **Access Method**: Automated download via `getSymbols()` function from quantmod package

### Variables and Series Codes

| Variable | FRED Series Code | Description | Frequency | Units |
|----------|-----------------|-------------|-----------|-------|
| **CPI Inflation** | CPIAUCSL | Consumer Price Index for All Urban Consumers | Monthly | Index 1982-84=100 |
| **Unemployment Rate** | UNRATE | Civilian Unemployment Rate | Monthly | Percent |
| **GDP** | GDPC1 | Real Gross Domestic Product | Quarterly | Billions of Chained 2017 Dollars |
| **Interest Rate** | FEDFUNDS | Federal Funds Effective Rate | Monthly | Percent |
| **Oil Prices** | DCOILBRENTEU | Brent Crude Oil Prices (Europe) | Daily/Monthly | Dollars per Barrel |

### Data Transformation Details

1. **Frequency Conversion**: 
   - Monthly data (CPI, Unemployment, Interest Rate, Oil Prices) converted to quarterly using arithmetic mean
   - GDP already quarterly, kept as-is

2. **Inflation Calculation**:
   - Year-over-year inflation rate: π_t = [(CPI_t / CPI_{t-4}) - 1] × 100
   - This measures the percentage change in CPI compared to the same quarter in the previous year

3. **GDP Growth Calculation**:
   - Year-over-year GDP growth rate: g_t = [(GDP_t / GDP_{t-4}) - 1] × 100

4. **Oil Price Transformation**:
   - Natural logarithm applied: log(Oil_Price)
   - Reduces skewness and allows elasticity interpretation

5. **Sample Period**:
   - Start: 1990 Q1
   - End: 2024 Q4 (or most recent available)
   - Total observations: ~140 quarterly observations

6. **Crisis Dummy Variables**:
   - Post_2008: = 1 for years 2008 and later, 0 otherwise
   - COVID: = 1 for year 2020, 0 otherwise

## R Package Dependencies

The following R packages are required:

```r
library(tidyverse)    # Data manipulation and visualization
library(tseries)      # Time series analysis and tests
library(lmtest)       # Econometric testing functions
library(sandwich)     # Robust standard errors
library(car)          # VIF and diagnostic tests
library(strucchange)  # Structural break tests
library(zoo)          # Time series objects
library(quantmod)     # Data download from FRED
```

### Installation Command
```r
install.packages(c("tidyverse", "tseries", "lmtest", "sandwich", 
                   "car", "strucchange", "zoo", "quantmod"))
```

## Model Specification

### Baseline Model
```
Inflation_t = β₀ + β₁(Unemployment_t) + β₂(GDP_Growth_t) + 
              β₃(Interest_Rate_t) + β₄(Log_Oil_t) + ε_t
```

### Expected Coefficient Signs

| Variable | Expected Sign | Economic Rationale |
|----------|--------------|-------------------|
| Unemployment (β₁) | **Negative** (-) | Traditional Phillips Curve: higher unemployment reduces inflationary pressure |
| GDP Growth (β₂) | **Positive** (+) | Demand-pull inflation: strong growth increases demand and prices |
| Interest Rate (β₃) | **Negative** (-) | Monetary policy: higher rates reduce aggregate demand and inflation |
| Oil Prices (β₄) | **Positive** (+) | Cost-push inflation: higher energy costs increase production costs |

### Extended Models

1. **Non-linear Phillips Curve**:
   ```
   Inflation_t = β₀ + β₁(Unemployment_t) + β₂(Unemployment_t)² + 
                 β₃(GDP_Growth_t) + β₄(Interest_Rate_t) + β₅(Log_Oil_t) + ε_t
   ```

2. **Structural Break Model**:
   ```
   Inflation_t = β₀ + β₁(Unemployment_t) + ... + δ₁(Post_2008) + δ₂(COVID) + ε_t
   ```

## Diagnostic Tests Performed

| Test | Purpose | Function Used | Null Hypothesis |
|------|---------|---------------|-----------------|
| **Jarque-Bera** | Normality of residuals | `jarque.bera.test()` | Residuals are normally distributed |
| **Breusch-Pagan** | Heteroskedasticity | `bptest()` | Homoskedastic errors |
| **White Test** | General heteroskedasticity | `bptest()` with squares | Homoskedastic errors |
| **Durbin-Watson** | First-order autocorrelation | `dwtest()` | No autocorrelation |
| **Breusch-Godfrey** | Higher-order autocorrelation | `bgtest(order=4)` | No autocorrelation |
| **VIF** | Multicollinearity | `vif()` | No multicollinearity (VIF < 10) |
| **Chow Test** | Structural break at 2008 | `sctest(type="Chow")` | No structural break |
| **CUSUM** | Parameter stability over time | `efp(type="Rec-CUSUM")` | Stable parameters |
| **Ramsey RESET** | Functional form misspecification | `resettest()` | Correct functional form |

## Correction Methods

1. **Heteroskedasticity**: 
   - Use heteroskedasticity-consistent standard errors (HC1)
   - Function: `vcovHC(model, type="HC1")`

2. **Autocorrelation**: 
   - Use Newey-West standard errors
   - Function: `NeweyWest(model, lag=4)`

3. **Functional Form Misspecification**:
   - Add quadratic terms
   - Add interaction terms
   - Consider non-linear specifications

4. **Structural Breaks**:
   - Add dummy variables for crisis periods
   - Estimate separate models for sub-periods

## Output Files Generated

When you run the R script, the following files will be created:

### Data Files
- `cleaned_data_phillips_curve.csv` - Final cleaned dataset with all variables
- `descriptive_statistics.csv` - Summary statistics for all variables
- `correlation_matrix.csv` - Correlation matrix of key variables

### Tables for Report
- `table1_descriptive_statistics.csv` - Formatted descriptive statistics table
- `table2_regression_results.csv` - Final regression results with significance stars
- `table3_diagnostic_tests.csv` - Summary of all diagnostic test results
- `table4_model_comparison.csv` - Comparison of alternative model specifications

### Visualizations
- `time_series_plots.pdf` - Time series plots of all major variables
- `phillips_curve_scatter.pdf` - Scatter plot of inflation vs unemployment (Phillips Curve)
- `residual_diagnostic_plots.pdf` - Histogram and Q-Q plot of residuals
- `cusum_plot.pdf` - CUSUM test for structural stability

## How to Run the Code

### Step 1: Install R and RStudio
Download from: https://www.rstudio.com/products/rstudio/download/

### Step 2: Install Required Packages
Open RStudio and run:
```r
install.packages(c("tidyverse", "tseries", "lmtest", "sandwich", 
                   "car", "strucchange", "zoo", "quantmod"))
```

### Step 3: Set Working Directory
```r
setwd("/path/to/your/workspace/folder")
```

### Step 4: Run the Script
```r
source("phillips_curve_analysis.R")
```

Or open the script in RStudio and click "Source" or press Ctrl+Shift+S

### Step 5: Check Output
All output files will be saved in your working directory.

## Interpretation Guide

### Phillips Curve Relationship
- **Negative & Significant β₁**: Supports traditional Phillips Curve theory
- **Insignificant β₁**: Suggests flattened Phillips Curve or expectations-augmented relationship
- **Positive β₁**: Counterintuitive; may indicate supply shocks dominating

### Model Fit
- **R-squared**: Proportion of inflation variation explained by the model
- **Adjusted R-squared**: Penalizes for number of predictors
- **AIC**: Lower values indicate better model fit (for model comparison)

### Policy Implications
- If Phillips Curve holds: Monetary policy faces trade-off between inflation and unemployment
- If Phillips Curve flat: Central banks can focus on inflation without worrying about unemployment
- Structural breaks suggest different policy regimes needed in different periods

## Common Issues & Solutions

### Issue: Cannot connect to FRED
**Solution**: Check internet connection. Alternatively, download data manually from fred.stlouisfed.org and save as CSV files.

### Issue: Missing values in dataset
**Solution**: The code automatically handles this by filtering out NA values after transformations. Early observations are lost due to differencing.

### Issue: Non-stationarity concerns
**Solution**: Using year-over-year inflation and growth rates helps address stationarity. For advanced analysis, consider cointegration tests.

### Issue: Structural breaks detected
**Solution**: Include dummy variables or estimate separate models for different periods (pre/post crisis).

## References for Literature Review

### Foundational Papers
1. **Phillips, A.W. (1958)**. "The Relation Between Unemployment and the Rate of Change of Money Wage Rates in the United Kingdom, 1861-1957". *Economica*, 25(100), 283-299.

2. **Friedman, M. (1968)**. "The Role of Monetary Policy". *American Economic Review*, 58(1), 1-17.

3. **Phelps, E.S. (1968)**. "Money-Wage Dynamics and Labor-Market Equilibrium". *Journal of Political Economy*, 76(4), 678-711.

### Modern Applications
4. **Blanchflower, D.G., & Dale-Olsen, H. (2020)**. "Is There Still a Phillips Curve? Evidence from OECD Countries". *NBER Working Paper*.

5. **Hazell, J., et al. (2022)**. "The Slope of the Phillips Curve: Evidence from U.S. States". *Quarterly Journal of Economics*, 137(3), 1299-1344.

6. **McLeay, M., & Tenreyro, S. (2020)**. "Optimal Inflation and the Identification of the Phillips Curve". *NBER Macroeconomics Annual*, 34, 199-255.

### Textbooks
7. **Brooks, C. (2019)**. *Introductory Econometrics for Time Series Analysis* (5th ed.). Cambridge University Press.

8. **Gujarati, D.N., & Porter, D.C. (2009)**. *Basic Econometrics* (5th ed.). McGraw-Hill Education.

## Academic Integrity Note

This code is provided as a template for educational purposes. You should:
- Understand each step of the analysis
- Modify the code to suit your specific research question
- Properly cite all data sources and literature
- Add your own critical analysis and interpretation
- Replace `[YOUR_ID]` with your actual student ID

## Contact & Support

For questions about:
- **Data sources**: Visit https://fred.stlouisfed.org/help/
- **R programming**: Check https://www.rdocumentation.org/
- **Econometric theory**: Consult your course textbook or lecturer

---

**Last Updated**: 2024
**Course**: ECM081 - Applied Econometrics Project
**Topic**: Testing the Phillips Curve Relationship
