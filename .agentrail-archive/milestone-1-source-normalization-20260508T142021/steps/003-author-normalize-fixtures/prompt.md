Author golden-test input/expected fixture pairs for the normalize phase in
snobol4/tests/normalize/. This is the doable subset of the original
003-normalize-tests step; the runner script and any "verify pass" work
is deferred to a later step that remains blocked on
sw-embed/sw-cor24-snobol4#1 (SNOBOL4 missing SIZE/SUBSTR/CHAR).

Format for .expected files (one line per logical statement):
    stmt<N> line=<M> label=<L> text=<statement text>

Where:
- N is a 1-based logical statement number
- M is the 1-based source line number where the statement starts
- L is the numeric label (cols 1-5) if present, else empty
- text is the cols-7-72 statement text after merging continuations and
  rstripping trailing whitespace; characters beyond column 72 are ignored

Create these eight pairs:
  test_comments.f       + test_comments.expected
  test_labels.f         + test_labels.expected
  test_continuation.f   + test_continuation.expected
  test_columns.f        + test_columns.expected
  test_blank.f          + test_blank.expected
  test_multiline_stmt.f + test_multiline_stmt.expected
  test_full_hello.f     + test_full_hello.expected  (mirror of examples/hello.f)
  test_full_sum10.f     + test_full_sum10.expected  (mirror of examples/sum10.f)

Add snobol4/tests/normalize/README.md documenting the .expected format,
the file naming convention, and the deferred-runner status (with a
pointer to sw-embed/sw-cor24-snobol4#1).

Do NOT write scripts/test-normalize.sh. Do NOT modify normalize.sno.
Do NOT attempt to run any SNOBOL4 code.

Acceptance: 17 new files (8 .f + 8 .expected + 1 README.md) under
snobol4/tests/normalize/. All markdown ASCII-clean.