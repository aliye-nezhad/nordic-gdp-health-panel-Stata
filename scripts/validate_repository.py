#!/usr/bin/env python3
"""Static repository checks; this script does not execute Stata or test estimates."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
REQUIRED_FILES = [
    "README.md",
    "LICENSE",
    ".gitignore",
    "data/README.md",
    "data/raw/nordic_gdp_health_panel_2000_2018.xlsx",
    "replication/run_analysis.do",
    "docs/REPRODUCIBILITY.md",
]
EXPECTED_OUTPUTS = [
    "data/processed/nordic_gdp_health_panel_2000_2018.dta",
    "outputs/tables/descriptive_statistics.txt",
    "outputs/tables/correlation_matrix.txt",
    "outputs/tables/hausman_test.txt",
    "outputs/tables/model_comparison.txt",
    "outputs/figures/log_gdp_by_country.png",
    "outputs/figures/life_expectancy_by_country.png",
    "outputs/figures/age_dependency_by_country.png",
    "outputs/figures/fe_residuals_vs_fitted.png",
    "outputs/logs/nordic_panel_analysis.log",
]

def main():
    errors = []
    for item in REQUIRED_FILES:
        if not (ROOT / item).is_file():
            errors.append(f"Missing required repository file: {item}")

    readme_path = ROOT / "README.md"
    do_path = ROOT / "replication/run_analysis.do"
    if readme_path.exists():
        readme = readme_path.read_text(encoding="utf-8")
        if "do replication/run_analysis.do" not in readme:
            errors.append("README must document: do replication/run_analysis.do")
        if "do run_analysis.do" in readme:
            errors.append("README still contains the obsolete root-level do-file command.")
        if "docs/REPRODUCIBILITY.md" not in readme:
            errors.append("README must link to docs/REPRODUCIBILITY.md.")

    if do_path.exists():
        do_file = do_path.read_text(encoding="utf-8")
        if not re.search(r"(?m)^version\\s+15\\.1\\s*$", do_file):
            errors.append("Do-file must declare its minimum Stata version (15.1).")
        if 'local data_file "data/raw/nordic_gdp_health_panel_2000_2018.xlsx"' not in do_file:
            errors.append("Do-file input path does not match the committed raw workbook.")
        if "do replication/run_analysis.do" not in do_file:
            errors.append("Do-file header must show the correct repository-root invocation.")
        for output in EXPECTED_OUTPUTS:
            if output not in do_file and output not in {
                "data/processed/nordic_gdp_health_panel_2000_2018.dta",
                "outputs/logs/nordic_panel_analysis.log",
            }:
                errors.append(f"Expected output path is not declared in the do-file: {output}")

    if errors:
        print("STATIC REPOSITORY VALIDATION FAILED")
        for error in errors:
            print(f"- {error}")
        return 1

    print("STATIC REPOSITORY VALIDATION PASSED")
    print(f"Required files checked: {len(REQUIRED_FILES)}")
    print(f"Expected generated artifacts checked: {len(EXPECTED_OUTPUTS)}")
    print("Note: this check does not run Stata or verify numerical results.")
    return 0

if __name__ == "__main__":
    sys.exit(main())
