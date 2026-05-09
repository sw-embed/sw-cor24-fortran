# SNOBOL4 builtins verification

Sanity test for the three SNOBOL4 primitives that FTI-0's normalizer
depends on: `SIZE`, `SUBSTR`, `CHAR`. These were the subject of
`sw-embed/sw-cor24-snobol4` issue #1.

## Files

- `test_builtins.sno` -- a small SNOBOL4 program that exercises each
  primitive and prints a labelled result line per call.
- `test_builtins.expected` -- the expected UART output, one line per
  `OUTPUT = ...` in the test program.

## How to run (when snobol4 is installed)

This test runs against the deployed SNOBOL4 interpreter at
`$TOOLROOT/../lib/cor24/snobol4.lgo`. Once that file exists:

    scripts/verify-snobol4.sh

The script invokes `cor24-emu --lgo snobol4.lgo --uart-file
test_builtins.sno`, captures the UART output, and diffs it against
`test_builtins.expected`.

## Why this lives here

The corresponding fixture in the sibling repo
(`sw-cor24-snobol4/examples/test_builtins.sno`) verifies the
*upstream* implementation. This local copy verifies that the
*deployed* interpreter -- the one FTI-0 actually invokes -- behaves
the way our normalizer assumes it will. They serve different
audiences and may diverge over time.

See also: `docs/snobol4-blockers.md`.
