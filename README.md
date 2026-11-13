# GDP and Health Indicators in Nordic Countries, 2000–2018

This repository contains a Stata analysis of the relationship between GDP and selected health and demographic indicators in Denmark, Finland, Norway, and Sweden over 2000–2018. The source workbook contains 76 country-year observations, forming a strongly balanced annual panel with 19 observations for each country.

The analysis is an observational panel-data exercise. Its estimates describe associations and specification sensitivity; they are not causal effects.

## Research question and specification

The analysis examines how log GDP varies with life expectancy, the age-dependency ratio, and the population field in the historical workbook. The baseline specification is:

\[
\ln(GDP_{it}) =
\alpha_i
+\beta_1\ln(LifeExpectancy_{it})
+\beta_2\ln(AgeDependency_{it})
+\beta_3\ln(Population_{it})
+\epsilon_{it},
\]

where \(\alpha_i\) denotes country-specific effects.

The original level variables are imported from columns A–H of the workbook. Logarithms are calculated in Stata; formula-generated log columns elsewhere in the workbook are not used.

## Data and limitations

The input file [data/raw/nordic_gdp_health_panel_2000_2018.xlsx](data/raw/nordic_gdp_health_panel_2000_2018.xlsx) is included in the repository. The workbook does not provide source URLs, indicator codes, retrieval dates, or a complete data dictionary. The price basis and units of the GDP series are not sufficiently documented in the workbook, so the variables are used as recorded.

The population field also contains an apparent scale or definition inconsistency: Denmark's values range from approximately 69,650 to 71,625, while the values for Finland, Norway, and Sweden are in the millions. These historical values are preserved rather than adjusted without source documentation. Population-related estimates, particularly comparisons across countries, require caution. Further details are provided in the [data notes](data/README.md).

## Empirical workflow

The do-file [replication/run_analysis.do](replication/run_analysis.do) performs the following steps:

1. Imports the original workbook and validates the country-year structure, identifiers, nonmissing values, and positive values used in logarithms.
2. Constructs the logarithmic variables and declares the strongly balanced panel.
3. Exports descriptive statistics and a correlation matrix.
4. Estimates country fixed-effects and random-effects models and performs a Hausman specification test.
5. Implements the Wooldridge/Drukker serial-correlation procedure using built-in Stata commands.
6. Estimates fixed-effects AR(1) and feasible GLS AR(1) specifications as additional model comparisons.
7. Constructs fitted values and residuals, exports figures and tables, saves the processed dataset, and checks that the expected output files exist.

The panel contains only four countries. Cluster-robust inference based on four country clusters is therefore fragile, and the serial-correlation test's clustered p-value should not be treated as decisive. The AR(1) and FGLS estimates are reported as specification comparisons, not as a basis for causal interpretation. Shared time trends, changes in nominal values, omitted factors, and the population-field inconsistency further limit interpretation.

## Reproducing the analysis

A licensed installation of Stata 15.1 or later is required. The do-file uses built-in Stata commands and does not require user-written ado packages, Java, or network downloads.

Clone the repository:

~~~bash
git clone https://github.com/aliye-nezhad/nordic-gdp-health-panel-Stata.git
cd nordic-gdp-health-panel-Stata
~~~

Verify the input workbook against its SHA-256 checksum:

~~~bash
sha256sum --check data/raw.sha256
~~~

In Stata, with the working directory set to the repository root, run:

~~~stata
do replication/run_analysis.do
~~~

The do-file writes the processed dataset, tables, figures, and execution log to the paths listed in the [reproducibility guide](docs/REPRODUCIBILITY.md). Existing files at those paths are replaced in the working copy.

GitHub Actions checks required files, documented paths, key workflow components, and the raw-workbook checksum. It does not execute Stata or verify numerical estimates. A successful Actions run is therefore evidence that the repository checks passed, not evidence that the econometric workflow was run in CI. The committed files under [outputs/](outputs/README.md) are reference outputs from an earlier Stata execution.

## Repository structure

~~~text
├── .github/workflows/reproducibility.yml
├── data/
│   ├── raw/
│   │   └── nordic_gdp_health_panel_2000_2018.xlsx
│   ├── processed/
│   │   └── nordic_gdp_health_panel_2000_2018.dta
│   ├── raw.sha256
│   └── README.md
├── docs/REPRODUCIBILITY.md
├── outputs/
│   ├── figures/
│   ├── tables/
│   └── README.md
├── replication/run_analysis.do
└── LICENSE
~~~

## Author

Aliye Nezhad

## License

The [MIT License](LICENSE) applies to the code and documentation. The source workbook's original license and upstream provenance are not specified in the file.