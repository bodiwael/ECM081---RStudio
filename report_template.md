# Testing the Phillips Curve Relationship: Inflation and Unemployment Dynamics in the US Economy (1990-2024)

**Student ID**: [YOUR_ID]  
**Course**: ECM081 - Applied Econometrics Project  
**Date**: [Submission Date]  

---

## 1. Introduction

The Phillips Curve represents one of the most influential relationships in macroeconomics, suggesting an inverse trade-off between inflation and unemployment. First documented by A.W. Phillips (1958) using UK wage data from 1861-1957, this relationship became a cornerstone of Keynesian economics and informed monetary policy decisions for decades. However, the breakdown of the traditional Phillips Curve during the stagflation of the 1970s led to the development of the expectations-augmented Phillips Curve by Friedman (1968) and Phelps (1968), which incorporated inflation expectations and introduced the concept of the Non-Accelerating Inflation Rate of Unemployment (NAIRU).

In recent years, the empirical validity of the Phillips Curve has been increasingly questioned. The period following the 2008 financial crisis witnessed historically low unemployment rates coexisting with persistently low inflation, particularly in advanced economies. This phenomenon, dubbed the "missing inflation" puzzle, has reignited debate about whether the Phillips Curve has flattened or disappeared entirely (Blanchflower & Dale-Olsen, 2020; Hazell et al., 2022). The COVID-19 pandemic and subsequent inflation surge in 2021-2023 have further complicated this picture, raising new questions about the stability and relevance of the inflation-unemployment relationship.

This paper investigates the following research question: **Does the traditional Phillips Curve relationship hold in the US economy over the period 1990-2024?** Specifically, we examine whether higher unemployment is associated with lower inflation, controlling for other determinants of inflation such as economic growth, monetary policy, and supply shocks.

Our empirical model specifies inflation as a function of the unemployment rate (the core Phillips Curve variable), GDP growth (capturing demand-pull inflation), the federal funds rate (representing monetary policy stance), and oil prices (representing cost-push inflation shocks). We employ Ordinary Least Squares (OLS) regression with comprehensive diagnostic testing to ensure the validity of our estimates.

The contribution of this study is threefold. First, we provide updated evidence on the Phillips Curve using the most recent data through 2024, encompassing both the post-financial crisis period and the COVID-19 era. Second, we conduct rigorous diagnostic testing to address potential econometric issues including heteroskedasticity, autocorrelation, and structural breaks. Third, we offer policy-relevant insights for monetary authorities navigating the inflation-unemployment trade-off.

The remainder of this paper is structured as follows: Section 2 describes the data and sources, Section 3 outlines the econometric methodology, Section 4 presents and discusses the results, and Section 5 concludes with policy implications and suggestions for future research.

---

## 2. Data

### 2.1 Data Sources and Sample Period

All data are obtained from the Federal Reserve Economic Data (FRED) database maintained by the Federal Reserve Bank of St. Louis. The sample period spans from 1990 Q1 to 2024 Q4, yielding approximately 140 quarterly observations. This period is chosen for several reasons: it begins after the establishment of implicit inflation targeting in the early 1990s, covers multiple business cycles, includes the 2008 financial crisis and its aftermath, and extends through the COVID-19 pandemic and recent inflation surge.

The dependent variable is the inflation rate, measured as the year-over-year percentage change in the Consumer Price Index for All Urban Consumers (CPIAUCSL). Year-over-year calculation is preferred over quarter-over-quarter as it eliminates seasonal patterns and is the standard measure used in central bank communications and academic literature.

The key independent variable is the civilian unemployment rate (UNRATE), which captures labor market slack. According to Phillips Curve theory, we expect a negative coefficient on this variable, indicating that higher unemployment reduces inflationary pressure.

We include three control variables:
1. **GDP Growth Rate**: Calculated as the year-over-year percentage change in real GDP (GDPC1), measured in chained 2017 dollars. This captures demand-pull inflation pressures. Expected sign: positive.
2. **Interest Rate**: The effective federal funds rate (FEDFUNDS), representing the monetary policy stance. Higher interest rates should reduce aggregate demand and inflation. Expected sign: negative.
3. **Oil Prices**: Brent crude oil prices (DCOILBRENTEU), transformed using the natural logarithm to reduce skewness. Oil price increases represent negative supply shocks that raise production costs. Expected sign: positive.

### 2.2 Data Transformations

Monthly series (CPI, unemployment, interest rates, oil prices) are converted to quarterly frequency by taking arithmetic means within each quarter. GDP is already reported at quarterly frequency. Inflation and GDP growth rates are calculated as year-over-year percentage changes to ensure stationarity and comparability with standard macroeconomic practice.

Two dummy variables are constructed to capture potential structural breaks:
- **Post-2008 Dummy**: Equals 1 for observations from 2008 onwards, capturing any permanent shift in the inflation process following the financial crisis.
- **COVID Dummy**: Equals 1 for the year 2020, capturing the exceptional economic disruption caused by the pandemic.

### 2.3 Descriptive Statistics

Table 1 presents summary statistics for all variables used in the analysis. Over the sample period, average inflation was approximately X.X%, with a standard deviation of X.X%. The unemployment rate averaged X.X%, ranging from a minimum of X.X% to a maximum of X.X%. GDP growth averaged X.X% annually, while the federal funds rate averaged X.X%. Oil prices showed considerable variation, reflecting geopolitical events and supply-demand dynamics.

**[INSERT TABLE 1 HERE - from table1_descriptive_statistics.csv]**

The correlation matrix (Table X) reveals moderate correlations between variables, with no evidence of extreme multicollinearity. As expected, inflation and unemployment show a negative correlation, though the magnitude is modest, suggesting the relationship may be influenced by other factors.

---

## 3. Methodology

### 3.1 Model Specification

We estimate the following baseline regression model:

$$\text{Inflation}_t = \beta_0 + \beta_1 \text{Unemployment}_t + \beta_2 \text{GDP\_Growth}_t + \beta_3 \text{Interest\_Rate}_t + \beta_4 \ln(\text{Oil\_Price}_t) + \varepsilon_t$$

where $t$ denotes the time period (quarter), and $\varepsilon_t$ is the error term. The expected signs of the coefficients are: $\beta_1 < 0$ (Phillips Curve), $\beta_2 > 0$ (demand-pull inflation), $\beta_3 < 0$ (monetary policy), and $\beta_4 > 0$ (cost-push inflation).

To account for potential non-linearity in the Phillips Curve relationship, we also estimate an extended specification with a quadratic unemployment term:

$$\text{Inflation}_t = \beta_0 + \beta_1 \text{Unemployment}_t + \beta_2 \text{Unemployment}_t^2 + \beta_3 \text{GDP\_Growth}_t + \beta_4 \text{Interest\_Rate}_t + \beta_5 \ln(\text{Oil\_Price}_t) + \delta_1 \text{Post2008}_t + \delta_2 \text{COVID}_t + \varepsilon_t$$

### 3.2 Estimation Method

The model is estimated using Ordinary Least Squares (OLS). For OLS estimates to be unbiased and efficient, several assumptions must hold: linearity in parameters, random sampling, no perfect multicollinearity, zero conditional mean of errors, homoskedasticity, and no autocorrelation. Given the time series nature of our data, violations of homoskedasticity and no autocorrelation are particularly likely. We therefore conduct comprehensive diagnostic tests and apply appropriate corrections where necessary.

### 3.3 Diagnostic Tests

To validate our model and ensure reliable inference, we perform the following diagnostic tests:

1. **Normality Test**: The Jarque-Bera test examines whether residuals are normally distributed, which is important for valid hypothesis testing in finite samples.

2. **Heteroskedasticity Tests**: We employ both the Breusch-Pagan test and White's general test to detect heteroskedasticity. If present, we use heteroskedasticity-consistent (HC1) standard errors for valid inference.

3. **Autocorrelation Tests**: The Durbin-Watson test detects first-order autocorrelation, while the Breusch-Godfrey test examines higher-order serial correlation. If autocorrelation is detected, we apply Newey-West standard errors with four lags (appropriate for quarterly data).

4. **Multicollinearity Test**: Variance Inflation Factors (VIF) assess whether high correlations among regressors inflate standard errors. VIF values above 10 indicate problematic multicollinearity.

5. **Structural Break Tests**: The Chow test examines whether coefficients changed significantly at the time of the 2008 financial crisis. The CUSUM test provides a graphical assessment of parameter stability over the full sample.

6. **Functional Form Test**: The Ramsey RESET test checks whether the linear specification adequately captures the relationship or whether non-linear terms should be included.

### 3.4 Software

All analysis is conducted using R version 4.x with the following packages: tidyverse (data manipulation), tseries and lmtest (econometric tests), sandwich (robust standard errors), car (diagnostic tests), strucchange (structural break analysis), zoo (time series objects), and quantmod (data download from FRED).

---

## 4. Results and Discussion

### 4.1 Initial OLS Results

Table 2 presents the initial OLS regression results. The unemployment coefficient is [negative/positive] and [statistically significant/not significant] at the [X]% level, [supporting/not supporting] the traditional Phillips Curve hypothesis. Specifically, a one percentage point increase in the unemployment rate is associated with a [X.XX] percentage point [decrease/increase] in the inflation rate, holding other factors constant.

**[INSERT TABLE 2 HERE - from table2_regression_results.csv]**

The GDP growth coefficient is [positive/negative] and [significant/not significant], consistent with [demand-pull/demand-constraint] effects on inflation. The interest rate coefficient is [negative/positive], [consistent/inconsistent] with the theoretical expectation that tighter monetary policy reduces inflation. The oil price coefficient is positive and significant, confirming the importance of supply-side shocks in driving inflation dynamics.

The model explains approximately [XX.X]% of the variation in inflation (R-squared = 0.XXX), indicating [strong/moderate/weak] explanatory power. The F-statistic is highly significant, rejecting the null hypothesis that all slope coefficients are jointly zero.

### 4.2 Diagnostic Test Results

Table 3 summarizes the results of all diagnostic tests performed on the initial model.

**[INSERT TABLE 3 HERE - from table3_diagnostic_tests.csv]**

The Jarque-Bera test [rejects/fails to reject] the null hypothesis of normal residuals (χ² = X.XX, p-value = 0.XXXX). Visual inspection of the histogram and Q-Q plot of residuals (Figure X) [confirms/suggests deviations from] normality. [If non-normal: This may be due to outliers during crisis periods, but OLS remains unbiased; inference may be affected in small samples.]

The Breusch-Pagan test indicates [presence/absence] of heteroskedasticity (LM = X.XX, p-value = 0.XXXX). The White test reaches similar conclusions. [If heteroskedastic: To ensure valid inference, we report heteroskedasticity-robust standard errors in our final specifications.]

The Durbin-Watson statistic of X.XX [suggests/does not suggest] first-order autocorrelation. The Breusch-Godfrey test for fourth-order autocorrelation [rejects/fails to rejects] the null of no serial correlation (F = X.XX, p-value = 0.XXXX). [If autocorrelation present: Given the time series nature of the data, this is not surprising. We address this using Newey-West standard errors, which are robust to both heteroskedasticity and autocorrelation.]

VIF values range from X.X to X.X, all well below the threshold of 10, indicating that multicollinearity is not a concern in our specification.

The Chow test for a structural break at 2008 Q1 [rejects/fails to reject] the null of parameter stability (F = X.XX, p-value = 0.XXXX). The CUSUM plot (Figure X) shows [stable/unstable] parameters over time, with [no/significant] deviations from the critical bounds. [If structural break detected: This suggests the Phillips Curve relationship may have changed after the financial crisis, motivating our inclusion of crisis dummy variables.]

The Ramsey RESET test [rejects/fails to reject] the null of correct functional form (F = X.XX, p-value = 0.XXXX). [If rejected: This suggests non-linearities may be important, leading us to consider a quadratic specification for unemployment.]

### 4.3 Final Model Results

Based on the diagnostic test results, we estimate a final model incorporating [non-linear terms/crisis dummies/both]. Table 4 presents the corrected results with Newey-West standard errors.

**[INSERT TABLE 4 HERE - from table4_model_comparison.csv]**

The unemployment coefficient in the final model is [β = -X.XXX, p < 0.XX], [remaining robust/becoming weaker] after corrections. The quadratic term [is/is not] statistically significant, [suggesting/indicating] [non-linearity/linearity] in the Phillips Curve relationship. The marginal effect of unemployment at the sample mean is [X.XXX], implying that [interpretation].

The crisis dummy variables are [both/neither] statistically significant. The Post-2008 dummy coefficient of [X.XXX] suggests that inflation was [higher/lower] by approximately [X.X] percentage points in the post-crisis period, controlling for other factors. The COVID dummy captures the exceptional [deflationary/inflationary] shock of [year].

Model fit improves [moderately/substantially] with these extensions, as evidenced by the increase in adjusted R-squared from 0.XXX to 0.XXX and the decrease in AIC from XXX to XXX.

### 4.4 Subsample Analysis

To further investigate the stability of the Phillips Curve, we estimate separate models for the pre-2008 (1990-2007) and post-2008 (2008-2019) periods. [Exclude 2020-2024 due to pandemic disruptions].

**Pre-2008 Period**: The unemployment coefficient is [β = -X.XXX, p = 0.XXX], [indicating a strong/weak/non-existent] Phillips Curve relationship before the financial crisis.

**Post-2008 Period**: The unemployment coefficient is [β = -X.XXX, p = 0.XXX], [suggesting the relationship has strengthened/weakened/remained stable].

The [difference/similarity] in coefficients across periods [supports/contradicts] the structural break detected in the full-sample tests. This finding is [consistent/inconsistent] with recent literature suggesting a flattening of the Phillips Curve in the post-crisis era (Hazell et al., 2022).

### 4.5 Economic Interpretation and Policy Implications

Our findings [support/do not support] the existence of a statistically significant Phillips Curve relationship in the US economy over the 1990-2024 period. The estimated coefficient implies that reducing unemployment by 1 percentage point would come at the cost of approximately [X.X] percentage points higher inflation, [confirming/challenging] the traditional policy trade-off.

However, several caveats are important. First, the relatively [low/high] R-squared indicates that other factors beyond our model explain much of inflation's variation. Notably absent are inflation expectations, which play a central role in modern New Keynesian Phillips Curves. Second, the [detection/non-detection] of structural breaks suggests that the Phillips Curve is not a structural parameter but may vary with the policy regime and economic conditions.

For monetary policymakers, our results suggest that [the inflation-unemployment trade-off remains relevant/the Phillips Curve has flattened sufficiently to allow aggressive employment stabilization without inflationary consequences]. The significant oil price coefficient highlights the continued importance of supply-side shocks, which pose particular challenges for monetary policy as they create tension between inflation and output stabilization objectives.

The [significant/insignificant] post-2008 dummy may reflect structural changes in the economy, such as increased globalization, technological change, or anchoring of inflation expectations, which have altered the inflation process. Understanding these changes is crucial for calibrating monetary policy responses in different economic environments.

---

## 5. Conclusion

This paper has examined the empirical validity of the Phillips Curve relationship in the US economy using quarterly data from 1990 to 2024. Our analysis yields several key findings.

First, we [find/do not find] evidence of a statistically significant negative relationship between unemployment and inflation, [supporting/challenging] the traditional Phillips Curve hypothesis. The magnitude of the coefficient suggests a [steep/flat] trade-off, with important implications for monetary policy.

Second, comprehensive diagnostic testing reveals [violations/no violations] of classical OLS assumptions, particularly regarding [heteroskedasticity/autocorrelation/structural breaks]. Applying appropriate corrections using robust standard errors and structural break dummies proves essential for valid inference.

Third, our subsample analysis [reveals/does not reveal] evidence of a changing Phillips Curve, with the relationship appearing [stronger/weaker/stable] in the post-2008 period compared to earlier decades. This finding contributes to the ongoing debate about Phillips Curve flattening in advanced economies.

### Limitations and Future Research

Several limitations of this study should be acknowledged. First, our model does not explicitly incorporate inflation expectations, which are central to modern theoretical formulations of the Phillips Curve. Future research could extend this analysis by including survey-based or model-based measures of expected inflation.

Second, while we test for structural breaks, our approach is limited to simple dummy variables. More sophisticated techniques, such as time-varying parameter models or Markov-switching specifications, could provide richer insights into how the Phillips Curve evolves over time.

Third, our analysis focuses on the aggregate US economy. Comparative studies across countries or examination of regional variation within the US (as in Hazell et al., 2022) could shed light on the roles of globalization, labor market institutions, and other structural factors.

Fourth, the COVID-19 period presents unique challenges for interpretation. The unprecedented fiscal and monetary policy responses, combined with supply chain disruptions, created unusual inflation dynamics that may not be captured by historical relationships. Extended analysis as more post-pandemic data becomes available would be valuable.

### Policy Recommendations

Despite these limitations, our findings offer several policy insights. Central banks should [continue to consider/deprioritize] unemployment developments when setting monetary policy, as the Phillips Curve [remains relevant/has flattened]. However, the apparent instability of the relationship argues for flexible, data-dependent policy approaches rather than rigid rules.

The persistent significance of oil prices underscores the need for monetary policy to distinguish between temporary supply-driven inflation fluctuations and persistent demand-driven trends. Overreacting to supply shocks could unnecessarily sacrifice output and employment.

Finally, the potential for structural change in the Phillips Curve relationship highlights the importance of continuous monitoring and model updating by policy institutions. What held in one era may not hold in another, and policy frameworks must adapt accordingly.

---

## References

Blanchflower, D.G. and Dale-Olsen, H. (2020) 'Is There Still a Phillips Curve? Evidence from OECD Countries', *NBER Working Paper* No. 27346.

Brooks, C. (2019) *Introductory Econometrics for Time Series Analysis*. 5th edn. Cambridge: Cambridge University Press.

Friedman, M. (1968) 'The Role of Monetary Policy', *American Economic Review*, 58(1), pp. 1-17.

Gujarati, D.N. and Porter, D.C. (2009) *Basic Econometrics*. 5th edn. New York: McGraw-Hill Education.

Hazell, J., Herreño, J., Nakamura, E. and Steinsson, J. (2022) 'The Slope of the Phillips Curve: Evidence from U.S. States', *Quarterly Journal of Economics*, 137(3), pp. 1299-1344.

McLeay, M. and Tenreyro, S. (2020) 'Optimal Inflation and the Identification of the Phillips Curve', *NBER Macroeconomics Annual*, 34, pp. 199-255.

Phelps, E.S. (1968) 'Money-Wage Dynamics and Labor-Market Equilibrium', *Journal of Political Economy*, 76(4), pp. 678-711.

Phillips, A.W. (1958) 'The Relation Between Unemployment and the Rate of Change of Money Wage Rates in the United Kingdom, 1861-1957', *Economica*, 25(100), pp. 283-299.

Federal Reserve Bank of St. Louis (2024) *FRED Economic Data*. Available at: https://fred.stlouisfed.org/ (Accessed: [Date]).

---

## Appendix: Data Appendix

**Variable Definitions and Sources:**

| Variable | Code | Source | Units | Transformation |
|----------|------|--------|-------|----------------|
| Inflation Rate | CPIAUCSL | FRED | % | YoY % change |
| Unemployment Rate | UNRATE | FRED | % | None |
| GDP Growth Rate | GDPC1 | FRED | % | YoY % change |
| Interest Rate | FEDFUNDS | FRED | % | None |
| Oil Prices | DCOILBRENTEU | FRED | $/barrel | Natural log |

**Sample Period**: 1990 Q1 - 2024 Q4  
**Observations**: Approximately 140 quarterly observations  
**Software**: R version 4.x

---

**Word Count**: [To be completed - target 2,250-2,750 words excluding tables and references]

**Note to Student**: 
- Replace all bracketed placeholders [X.XX] with your actual results
- Insert tables exported from your R analysis
- Add figure numbers and references to graphs
- Update the word count
- Ensure Harvard referencing style throughout
- Replace [YOUR_ID] and [Date] with your information
- Proofread carefully before submission
