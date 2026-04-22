# Testing the Phillips Curve Relationship: Inflation and Unemployment Dynamics in the US Economy (1990–2024)

## Overview
This project investigates the empirical validity of the Phillips Curve relationship in the United States over the period 1990 Q1 to 2024 Q4. The analysis explores the short-run trade-off between inflation and unemployment, testing the core hypothesis that unemployment exerts a negative and statistically significant effect on inflation. 

The study period encompasses significant macroeconomic volatility, including the 1990–91 recession, the 2008 Global Financial Crisis (GFC), the COVID-19 shock of 2020–21, and the 2021–22 inflation surge.

## Data Sources and Variables
All data used in this analysis are drawn from the Federal Reserve Economic Data (FRED) database maintained by the Federal Reserve Bank of St. Louis, aggregated to a quarterly frequency (136 observations).

* **Dependent Variable:** * **Inflation (`CPIAUCSL`)**: Consumer Price Index for All Urban Consumers (Year-on-Year % change).
* **Independent Variables:**
  * **Unemployment Rate (`UNRATE`)**: Civilian unemployment rate (%).
  * **Real GDP Growth (`GDPC1`)**: Year-on-Year growth rate of chain-weighted real GDP (%).
  * **Federal Funds Rate (`FEDFUNDS`)**: Effective Federal Funds Rate (%).
  * **Brent Crude Oil Price (`DCOILBRENTEU`)**: Natural logarithm of Brent crude spot prices (USD/barrel) to capture supply-side shocks.
* **Dummy Variables:**
  * `crisis_dummy`: Captures the structural shift post-2008 GFC.
  * `covid_dummy`: Captures the COVID-19 pandemic shock (post-2020 Q1).

## Methodology
The core modelling technique is Ordinary Least Squares (OLS) time series regression. To ensure robust and valid inference, the analysis employs a comprehensive suite of econometric diagnostic tests:
* **Jarque-Bera Test** (Normality)
* **Breusch-Pagan Test** (Heteroskedasticity)
* **Breusch-Godfrey & Durbin-Watson Tests** (Serial Correlation)
* **Variance Inflation Factors (VIF)** (Multicollinearity)
* **Ramsey RESET Test** (Functional Form)
* **CUSUM Test** (Structural parameter stability)

To correct for detected heteroskedasticity and autocorrelation, the final preferred model utilizes **Newey-West HAC (Heteroskedasticity and Autocorrelation Consistent) standard errors**.

## Key Findings
1. **The Flattening Phillips Curve:** While the baseline OLS regressions suggest a negative relationship between unemployment and inflation, this effect loses statistical significance once robust Newey-West standard errors are applied to account for time-series persistence (autocorrelation). 
2. **Supply-Side Dominance:** The most robust predictor of inflation over this 34-year period is the price of oil. The model demonstrates a strong, statistically significant pass-through effect from Brent crude prices to consumer inflation.
3. **Post-GFC Regime Shift:** The inclusion of a 2008 crisis dummy suggests a noticeable downward shift in baseline inflation dynamics following the Global Financial Crisis, consistent with theories of firmly anchored inflation expectations.

## Project Structure
* `data/`: Contains the raw data pulled from FRED or the cleaned dataset used for regressions.
* `plots/`: Contains generated visual diagnostics:
  * `plot_time_series.png`: Historical trends of US Inflation vs. Unemployment.
  * `plot_phillips_curve.png`: Scatter plot visualizing the raw Phillips Curve trade-off.
  * `diagnostic_normality.png`: Residual histogram and Q-Q plots.
  * `diagnostic_cusum.png`: Parameter stability testing over time.
* `report/`: Contains the LaTeX source code (`.tex`) and the final compiled PDF report.

## How to Compile the Report
To generate the final report PDF from the LaTeX source:
1. Ensure you have a working LaTeX distribution (e.g., TeX Live, MiKTeX) or use an online editor like Overleaf.
2. Ensure the four plot images are located in the same directory as the `.tex` file.
3. Compile using `pdflatex`:
   ```bash
   pdflatex main_report.tex
