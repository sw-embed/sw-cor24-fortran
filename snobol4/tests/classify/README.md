# Classify Phase Tests

Golden-file tests for the FTI-0 statement classifier
(`snobol4/src/classify.sno`).

## File format

Each test is a pair of files:

- `<name>.in` -- normalized statement records (output of normalize.sno),
  one per line, in the format
  `stmt<N> line=<M> label=<L> text=<text>`.
- `<name>.expected` -- expected classified records, with a
  `kind=<KIND>` field inserted between `label=` and `text=`:
  `stmt<N> line=<M> label=<L> kind=<KIND> text=<text>`.

## Statement kinds covered

| Kind | Trigger keyword in `<text>` |
|---|---|
| `PROGRAM` | `PROGRAM` |
| `INTEGER_DECL` | `INTEGER` |
| `DIMENSION_DECL` | `DIMENSION` |
| `GOTO` | `GOTO` |
| `IF_GOTO` | `IF` (assumed `IF (expr) GOTO label` per FTI-0) |
| `DO` | `DO` |
| `CONTINUE` | `CONTINUE` |
| `PRINT` | `PRINT` |
| `READ` | `READ` |
| `STOP` | `STOP` |
| `END` | `END` |
| `ASSIGN` | none of the above + `<text>` contains `=` |

## Tests

| Name | Covers |
|------|--------|
| test_kinds | one record of each of the 12 kinds |
| test_full_hello | the hello.f normalize output (6 records) |
| test_full_sum10 | the sum10.f normalize output (10 records) |

## Running

    scripts/test-classify.sh

Reports per-fixture PASS/FAIL with diff inline; exits 0 if all pass,
1 if any fail, 2 if prereqs missing (snobol4 wrapper, classify.sno,
or fixtures absent).

## Why .in instead of .f

Classify operates on normalized records, not raw .f source. The .in
fixtures are hand-crafted normalized records for unit-testing
classify in isolation. End-to-end pipeline tests
(.f -> normalize -> classify -> ...) belong to a separate
integrate-driver saga.
