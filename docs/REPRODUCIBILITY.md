# Reproducibility and validation

## Two distinct levels of validation

This repository distinguishes between static repository validation and execution
of the empirical analysis. They are not interchangeable.

### 1. Automated static validation

GitHub Actions runs `scripts/validate_repository.py`. It checks that required
source files and the raw workbook are present, that the README gives the correct
repository-root command, that the do-file declares its Stata version and input
path, and that expected generated artifacts are represented in the workflow.

This check does **not** execute Stata, estimate models, validate numerical
results, or establish that the econometric analysis has been reproduced.

### 2. Full statistical reproduction

Full reproduction requires Stata 15.1 or later and the community-contributed
`xtserial` command for the Wooldridge serial-correlation test. The first run
may need internet access to install `xtserial`.

From the repository root, open Stata and run:

```stata
do replication/run_analysis.do
```

The do-file imports the committed workbook, validates the 76-observation
four-country annual panel, reconstructs the log variables, estimates the
historical specifications, and regenerates the processed dataset, tables,
figures, and execution log.

A successful run should end with:

```text
Analysis completed successfully.
```

If the script reports warnings, inspect
`outputs/logs/nordic_panel_analysis.log`. In particular, the Hausman test and
the availability of `xtserial` must be checked. A run with skipped diagnostics
is not a fully successful reproduction.

## Output handling

Generated outputs are committed as reference artifacts. Re-running the script
overwrites the processed dataset and generated outputs. Compare the regenerated
files with the committed versions after execution. Log files may contain
machine-specific paths and timestamps, so compare substantive results rather
than expecting byte-for-byte identity for logs.

## Econometric integrity

The reproducibility work does not change the historical model specification or
its estimation commands. In particular, it does not rescale or otherwise alter
the Denmark population observations. The known population-scale inconsistency
and incomplete source metadata remain disclosed in `data/README.md` and the
main README. They are data interpretation limitations, not grounds for
silently modifying the replication input.

## GitHub Actions limitation

The automated workflow intentionally performs static validation only. Stata is
proprietary software and requires a valid license and an appropriately
configured installation. No Stata license, installer, or credential is stored
in this repository or exposed in workflow logs. A green static check must never
be described as a successful Stata execution.
