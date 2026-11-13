# Reproducing the results

Open a licensed copy of Stata 15.1 or later and set the working directory to the repository folder. The do-file uses built-in Stata commands.

```stata
do replication/run_analysis.do
```

The do-file imports [the workbook](../data/raw/nordic_gdp_health_panel_2000_2018.xlsx) and prepares the country-year panel before fitting the models. It replaces the processed dataset, tables, and figures in the working copy. It also writes these files when run in Stata.

| File | Contents |
| --- | --- |
| `outputs/tables/wooldridge_serial_correlation_test.txt` | Test for serial correlation |
| `outputs/figures/fe_residuals_vs_fitted.png` | Residuals and fitted values from the fixed-effects model |
| `outputs/logs/nordic_panel_analysis.log` | Stata commands, estimation results, and messages |

## Wooldridge test for serial correlation

First I regress the first difference of log GDP on the first differences of the three regressors without a constant. I then regress the residuals on their one-year lag, again without a constant, and test whether the lag coefficient equals −0.5. Both regressions use standard errors clustered by country. The panel has four country clusters, so the usual clustered p-value can be unreliable. [Drukker (2003)](https://doi.org/10.1177/1536867X0300300206)

## Checking a Stata run

A run that produces all eleven files and reports no diagnostic errors ends with `Analysis completed successfully.` If Stata reports a warning, the log or the individual test report identifies the step to inspect. Use the 76-observation panel and the four saved tables as reference points when comparing results. Stata records the run date and the working path in text logs, so compare their estimates and test statistics directly.
