Drafted snobol4/src/normalize.sno (108 lines) implementing the FTI-0
source normalizer per docs/subset-fti0.md and the snobol4/tests/normalize/
fixtures. Reads fixed-form .f via INPUT, applies col-1 comment skip +
col-1-5 label extraction (lstrip + rstrip) + col-6 continuation
detection + col-7-72 text extraction (rstripped), emits records of the
form `stmt<N> line=<M> label=<L> text=<text>`.

DRAFT status: snobol4.lgo is not deployed (per docs/snobol4-blockers.md),
so verification was by mental trace only. Walked test_full_hello,
test_labels, test_continuation, test_columns, and test_blank fixtures
mentally and confirmed expected output matches.

Uses only SIZE/SUBSTR/CHAR (the snobol4#1 primitives) plus IDENT/EQ
and standard SNOBOL4 :S/:F gotos seen in dcsno's example programs.

Future work (when snobol4.lgo lands):
- Step 006-normalize-tests: write scripts/test-normalize.sh and run
  fixtures against this draft. Expect bugs from SNOBOL4 dialect
  details (failure semantics, INPUT behavior on blank lines, etc.).
- Step 007-integrate-driver: wire normalize.sno into driver.sno
  with a -dump-lines flag.