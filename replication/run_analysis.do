/*******************************************************************************
Project:  GDP and Health Indicators in Nordic Countries, 2000-2018
File:     run_analysis.do
Purpose:  Estimate the panel models and save the tables and figures
Author:   Aliye Nezhad
Version:  Stata 15.1+

Run this file from the repository root. Example:
    cd "C:\path\to\nordic-gdp-health-panel-Stata"
    do replication/run_analysis.do
*******************************************************************************/

version 15.1
clear all
set more off
set linesize 100
capture log close _all

local data_file "data/raw/nordic_gdp_health_panel_2000_2018.xlsx"
local warning_count 0

/*******************************************************************************
0. Check the workbook path and open the log
*******************************************************************************/

capture confirm file "`data_file'"
if _rc {
    display as error "Input file not found: `data_file'"
    display as error "From the repository root, run do replication/run_analysis.do."
    exit 601
}

capture mkdir "outputs"
capture mkdir "outputs/tables"
capture mkdir "outputs/figures"
capture mkdir "outputs/logs"
capture mkdir "data/processed"

log using "outputs/logs/nordic_panel_analysis.log", ///
    replace text name(main_log)

/*******************************************************************************
1. Import the original workbook

Columns A:H contain the data in levels. Stata calculates the logarithms below.
*******************************************************************************/

import excel using "`data_file'", ///
    sheet("Sheet1") ///
    cellrange(A2:H77) ///
    clear

rename (A B C D E F G H) ///
       (country_name year country_id time_id gdp life_expectancy ///
        age_dependency population)

replace country_name = strtrim(country_name)

/*******************************************************************************
2. Check country and year identifiers and the values used in logs
*******************************************************************************/

foreach var in year country_id time_id gdp life_expectancy age_dependency population {
    capture confirm numeric variable `var'
    if _rc {
        destring `var', replace ignore(",")
    }
}

assert _N == 76
assert country_name != ""

foreach var in year country_id time_id gdp life_expectancy age_dependency population {
    assert !missing(`var')
}

assert inrange(year, 2000, 2018)
assert inrange(country_id, 1, 4)
assert inrange(time_id, 1, 19)
isid country_id year

sort country_id year
by country_id: assert _N == 19
by country_id (year): assert time_id == _n

assert country_name == "Norway"  if country_id == 1
assert country_name == "Sweden"  if country_id == 2
assert country_name == "Finland" if country_id == 3
assert country_name == "Denmark" if country_id == 4

foreach var in gdp life_expectancy age_dependency population {
    assert `var' > 0
}

quietly summarize population if country_name == "Denmark", meanonly
if r(max) < 1000000 {
    display as text "Denmark's population field is in the tens of thousands. The other countries' values are in the millions."
    display as text "The models use the workbook values as recorded."
}

/*******************************************************************************
3. Take logs and label the variables
*******************************************************************************/

generate double lngdp = ln(gdp)
generate double lnl   = ln(life_expectancy)
generate double lna   = ln(age_dependency)
generate double lnp   = ln(population)

label variable country_name    "Country"
label variable year            "Calendar year"
label variable country_id      "Country identifier"
label variable time_id         "Within-panel time identifier"
label variable gdp             "Gross domestic product"
label variable life_expectancy "Life expectancy at birth"
label variable age_dependency  "Age dependency ratio"
label variable population      "Population field in historical workbook"
label variable lngdp           "Log GDP"
label variable lnl             "Log life expectancy"
label variable lna             "Log age dependency ratio"
label variable lnp             "Log population field"

label define country_label 1 "Norway" 2 "Sweden" 3 "Finland" 4 "Denmark"
label values country_id country_label

order country_name year country_id time_id gdp life_expectancy ///
      age_dependency population lngdp lnl lna lnp

/*******************************************************************************
4. Declare the panel and save the analysis-ready dataset
*******************************************************************************/

xtset country_id year
xtdescribe

save "data/processed/nordic_gdp_health_panel_2000_2018.dta", replace

/*******************************************************************************
5. Descriptive statistics
*******************************************************************************/

log using "outputs/tables/descriptive_statistics.txt", ///
    replace text name(descriptive_log)

summarize lngdp lnl lna lnp

log close descriptive_log

/*******************************************************************************
6. Correlation matrix
*******************************************************************************/

log using "outputs/tables/correlation_matrix.txt", ///
    replace text name(correlation_log)

correlate lngdp lnl lna lnp

log close correlation_log

/*******************************************************************************
7. Fixed-effects model and diagnostics
*******************************************************************************/

xtreg lngdp lnl lna lnp, fe
estimates store FE

predict double fe_fitted, xbu
predict double fe_residuals, e

/*******************************************************************************
8. Random-effects model and Hausman test
*******************************************************************************/

xtreg lngdp lnl lna lnp, re
estimates store RE

log using "outputs/tables/hausman_test.txt", ///
    replace text name(hausman_log)

capture noisily hausman FE RE, sigmamore
local hausman_rc = _rc

log close hausman_log

if `hausman_rc' != 0 {
    display as error "The Hausman test did not complete cleanly; review outputs/tables/hausman_test.txt."
    local warning_count = `warning_count' + 1
}

/*******************************************************************************
9. Wooldridge serial-correlation test

Regress the change in log GDP on changes in the three logged regressors.
Then regress the residuals on their one-year lag. Both regressions omit the
constant and cluster standard errors by country. Under the null, the
lagged-residual coefficient is -0.5.

See Drukker (2003), Stata Journal 3(2), 168-177.
*******************************************************************************/

log using "outputs/tables/wooldridge_serial_correlation_test.txt", ///
    replace text name(wooldridge_log)

capture drop _wooldridge_resid
capture quietly regress D.(lngdp lnl lna lnp), ///
    noconstant vce(cluster country_id)
local wooldridge_rc = _rc

if `wooldridge_rc' != 0 {
    display as error "Wooldridge test failed in the first-difference regression; return code `wooldridge_rc'."
    local warning_count = `warning_count' + 1
}
else {
    capture quietly predict double _wooldridge_resid if e(sample), residuals
    local wooldridge_rc = _rc

    if `wooldridge_rc' != 0 {
        display as error "Could not calculate the first-difference residuals. Stata return code `wooldridge_rc'."
        local warning_count = `warning_count' + 1
    }
    else {
        capture quietly regress _wooldridge_resid L._wooldridge_resid, ///
            noconstant vce(cluster country_id)
        local wooldridge_rc = _rc

        if `wooldridge_rc' != 0 {
            display as error "Wooldridge test failed in the residual regression; return code `wooldridge_rc'."
            local warning_count = `warning_count' + 1
        }
        else {
            capture quietly test L._wooldridge_resid = -0.5
            local wooldridge_rc = _rc

            if `wooldridge_rc' != 0 {
                display as error "Wooldridge test restriction could not be evaluated; return code `wooldridge_rc'."
                local warning_count = `warning_count' + 1
            }
            else {
                local wooldridge_rho = _b[L._wooldridge_resid]
                local wooldridge_F = r(F)
                local wooldridge_df = r(df)
                local wooldridge_df_r = r(df_r)
                local wooldridge_p = r(p)

                display as text "Wooldridge test for autocorrelation in panel data"
                display as text "H0: no first-order autocorrelation"
                display as text "Coefficient on lagged first-difference residuals = " ///
                    as result %9.4f `wooldridge_rho'
                display as text "F(" %3.0f `wooldridge_df' ", " ///
                    %8.0f `wooldridge_df_r' ") = " ///
                    as result %10.3f `wooldridge_F'
                display as text "Prob > F = " as result %11.4f `wooldridge_p'
            }
        }
    }
}

capture drop _wooldridge_resid
log close wooldridge_log
/*******************************************************************************
10. Historical AR(1) and FGLS specifications
*******************************************************************************/

xtregar lngdp lnl lna lnp, fe
estimates store FE_AR1

xtgls lngdp lnl lna lnp, ///
    panels(correlated) ///
    corr(ar1) ///
    igls
estimates store GLS_AR1

/*******************************************************************************
11. Export the model comparison
*******************************************************************************/

log using "outputs/tables/model_comparison.txt", ///
    replace text name(regression_log)

estimates table FE RE FE_AR1 GLS_AR1, ///
    b(%9.3f) ///
    se(%9.3f) ///
    stats(N)

log close regression_log

/*******************************************************************************
12. Export figures

The title is placed inside by() so it appears once above each faceted graph.
*******************************************************************************/

twoway line lngdp year, sort ///
    by(country_name, cols(2) title("Log GDP Over Time") note("")) ///
    xtitle("Year") ///
    ytitle("Log GDP")

graph export "outputs/figures/log_gdp_by_country.png", replace width(2000)

twoway line life_expectancy year, sort ///
    by(country_name, cols(2) title("Life Expectancy Over Time") note("")) ///
    xtitle("Year") ///
    ytitle("Years")

graph export "outputs/figures/life_expectancy_by_country.png", replace width(2000)

twoway line age_dependency year, sort ///
    by(country_name, cols(2) title("Age Dependency Ratio Over Time") note("")) ///
    xtitle("Year") ///
    ytitle("Ratio")

graph export "outputs/figures/age_dependency_by_country.png", replace width(2000)

twoway scatter fe_residuals fe_fitted, ///
    yline(0, lcolor(red)) ///
    msize(small) ///
    title("Fixed-Effects Residuals vs. Fitted Values") ///
    xtitle("Fitted log GDP") ///
    ytitle("Residual")

graph export "outputs/figures/fe_residuals_vs_fitted.png", replace width(2000)

/*******************************************************************************
13. Check that the run wrote all result files
*******************************************************************************/

local expected_outputs "data/processed/nordic_gdp_health_panel_2000_2018.dta outputs/tables/descriptive_statistics.txt outputs/tables/correlation_matrix.txt outputs/tables/hausman_test.txt outputs/tables/model_comparison.txt outputs/tables/wooldridge_serial_correlation_test.txt outputs/figures/log_gdp_by_country.png outputs/figures/life_expectancy_by_country.png outputs/figures/age_dependency_by_country.png outputs/figures/fe_residuals_vs_fitted.png outputs/logs/nordic_panel_analysis.log"

foreach output of local expected_outputs {
    capture confirm file "`output'"
    if _rc {
        display as error "Required output missing: `output'"
        local warning_count = `warning_count' + 1
    }
}

/*******************************************************************************
14. Finish
*******************************************************************************/

if `warning_count' == 0 {
    display as result "Analysis completed successfully."
}
else {
    display as error "Analysis completed with `warning_count' warning(s). Review the main log."
}

display as result "Main log: outputs/logs/nordic_panel_analysis.log"
log close main_log
