Create golden-file tests for the normalization phase.

Create test input/output pairs in snobol4/tests/normalize/:

1. test_comments.f + test_comments.expected
   - Input with C and * comment lines, mixed with real statements
   - Expected: only non-comment statements in output

2. test_labels.f + test_labels.expected
   - Input with numeric labels in cols 1-5
   - Expected: label field correctly extracted

3. test_continuation.f + test_continuation.expected
   - Input with continuation lines (non-blank in col 6)
   - Expected: continued lines merged into single logical statement

4. test_columns.f + test_columns.expected
   - Input with text beyond column 72
   - Expected: text beyond col 72 ignored

5. test_blank.f + test_blank.expected
   - Input with blank lines interspersed
   - Expected: blank lines skipped

6. test_multiline_stmt.f + test_multiline_stmt.expected
   - Input with a multi-line statement (e.g., long INTEGER declaration)
   - Expected: correctly assembled single statement

7. test_full_hello.f + test_full_hello.expected
   - examples/hello.f as input
   - Expected: full normalized output

8. test_full_sum10.f + test_full_sum10.expected
   - examples/sum10.f as input
   - Expected: full normalized output

Each .expected file should contain the exact output format:
  stmt<N> line=<M> label=<L> text=<statement text>

Create a test runner script (scripts/test-normalize.sh) that runs the normalizer on each test input and compares output to the expected file, reporting pass/fail.

Run all tests and verify they pass.