# GDP and Health Indicators in Nordic Countries

I use Stata to examine how GDP moved with life expectancy, the age dependency ratio, and population within Denmark, Finland, Norway, and Sweden from 2000 through 2018.

## Data

The workbook has 76 observations, one per country and year. I take logs of GDP, life expectancy, the age dependency ratio, and population. GDP is treated as nominal. The original workbook gives no source links, indicator codes, or download dates.

Denmark's population field ranges from 69,650 to 71,625. The other countries' values are in the millions. The analysis uses the workbook values as recorded, so Denmark's entries limit what can be inferred about population from the estimates. [Workbook and variable notes](data/README.md)

## Models and findings

The country fixed-effects model compares changes within each country. In the saved results, the coefficient on log life expectancy is 18.22 in this model and 8.58 in the fixed-effects model with AR(1) errors. The coefficient on log age dependency is −2.57 in the fixed-effects model and 0.13 in feasible GLS with AR(1) errors. These shifts show how sensitive the estimates are to the specification. [Model comparison](outputs/tables/model_comparison.txt)

In the saved results, the Hausman test rejects the null that differences between the fixed-effects and random-effects coefficients are unsystematic (χ²(3) = 42.87). The do-file also includes a Wooldridge test for serial correlation. With four country clusters, the usual cluster-robust p-value can be unreliable. The regressions describe associations that can reflect shared time trends, changes in nominal prices, or other omitted factors. [Hausman test](outputs/tables/hausman_test.txt) · [Serial-correlation test and run notes](docs/REPRODUCIBILITY.md)

## Run the analysis

Use a licensed copy of Stata 15.1 or later. The do-file uses built-in Stata commands. Clone the repository or download a copy.

```bash
git clone https://github.com/aliye-nezhad/nordic-gdp-health-panel-Stata.git
```

Open Stata, set the working directory to the repository folder, and run the do-file.

```stata
do replication/run_analysis.do
```

The do-file replaces the processed dataset, tables, and figures in the working copy. It also writes a Wooldridge test report, a residuals-versus-fitted plot, and a Stata log. [Output paths and run notes](docs/REPRODUCIBILITY.md)

## Repository structure

```text
├── data/
│   ├── raw/nordic_gdp_health_panel_2000_2018.xlsx
│   ├── processed/nordic_gdp_health_panel_2000_2018.dta
│   └── README.md
├── docs/REPRODUCIBILITY.md
├── outputs/
│   ├── figures/
│   │   ├── age_dependency_by_country.png
│   │   ├── life_expectancy_by_country.png
│   │   └── log_gdp_by_country.png
│   └── tables/
│       ├── correlation_matrix.txt
│       ├── descriptive_statistics.txt
│       ├── hausman_test.txt
│       └── model_comparison.txt
├── replication/run_analysis.do
└── LICENSE
```

## Author

Aliye Nezhad

## License

The [MIT License](LICENSE) covers the code and documentation. The workbook's license is unspecified.
