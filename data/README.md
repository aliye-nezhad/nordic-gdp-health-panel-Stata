# Data

The [workbook](raw/nordic_gdp_health_panel_2000_2018.xlsx) contains 19 annual observations for each of four countries from 2000 through 2018. Stata reads cells `A2:H77` from `Sheet1` and calculates the logarithms from the levels in those columns. The [processed dataset](processed/nordic_gdp_health_panel_2000_2018.dta) contains the panel used for estimation.

| Excel column | Stata variable | Meaning |
| --- | --- | --- |
| A | `country_name` | Country name |
| B | `year` | Calendar year |
| C | `country_id` | Country identifier |
| D | `time_id` | Year index within country |
| E | `gdp` | Gross domestic product |
| F | `life_expectancy` | Life expectancy at birth |
| G | `age_dependency` | Age dependency ratio |
| H | `population` | Population field |

The do-file takes natural logs of GDP (`lngdp`), life expectancy (`lnl`), the age dependency ratio (`lna`), and the population field (`lnp`).

## Source and units

The workbook gives no source URLs, indicator codes, download dates, or full data dictionary. GDP is treated as nominal. Denmark's population field ranges from 69,650 to 71,625, while Finland, Norway, and Sweden each have values in the millions. The workbook leaves the difference in scale or definition unresolved. The estimates use those values as recorded.
