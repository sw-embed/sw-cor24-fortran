# Normalize Phase Tests

Golden-file tests for the FTI-0 source normalizer (`snobol4/src/normalize.sno`).

## Status

Test fixtures only. The runner script (`scripts/test-normalize.sh`)
and execution against the implementation are deferred until
`sw-embed/sw-cor24-snobol4#1` lands the missing SIZE/SUBSTR/CHAR
primitives required by `normalize.sno`.

## File format

Each test is a pair of files:

- `<name>.f` -- a fixed-form FTI-0 input
- `<name>.expected` -- the expected normalizer output

## .expected output format

One line per logical (post-normalization) statement:

    stmt<N> line=<M> label=<L> text=<statement text>

Where:

- `<N>` is the 1-based logical statement number
- `<M>` is the 1-based source line number where the statement starts
  (the first physical line, before any continuations)
- `<L>` is the numeric label (cols 1-5) if present, else empty
- `<text>` is the cols-7-72 statement text after merging continuations
  and rstripping trailing whitespace

## Normalization rules under test

- comment lines (`C` or `*` in col 1) are skipped
- numeric labels in cols 1-5 are extracted (leading spaces stripped)
- continuation lines (col 6 non-blank and non-`0`) append cols 7-72
  to the previous statement
- text beyond column 72 is ignored
- blank lines are skipped

## Tests

| Name | Covers |
|------|--------|
| test_comments | C and * comment lines mixed with statements |
| test_labels | numeric labels in cols 1-5 |
| test_continuation | continuation line merging |
| test_columns | text beyond col 72 dropped |
| test_blank | blank lines skipped |
| test_multiline_stmt | a single statement spanning many lines |
| test_full_hello | full-program normalization (mirror of examples/hello.f) |
| test_full_sum10 | full-program normalization (mirror of examples/sum10.f) |

## Why no runner yet

`normalize.sno` itself cannot be implemented until the SNOBOL4 interpreter
in `sw-embed/sw-cor24-snobol4` provides the SIZE, SUBSTR, and CHAR
primitives. See:

- `.agentrail/steps/002-implement-normalize/summary.md`
- issue: `sw-embed/sw-cor24-snobol4#1`

These fixtures define the contract that the implementation must satisfy
when it lands.
