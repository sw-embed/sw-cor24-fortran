Implement the source normalization phase in snobol4/src/normalize.sno.

The normalizer reads fixed-form FORTRAN source and produces normalized statement records. Reference docs/design.md for the source form specification and docs/architecture.md for the normalization phase responsibilities.

Requirements:
- Read fixed-form physical lines from input
- Detect comment lines (C or * in column 1) -- skip them
- Extract label field from columns 1-5 (numeric label, may be blank)
- Detect continuation marker in column 6 (non-blank, non-zero character)
- Merge continued lines into single logical statements
- Ignore anything beyond column 72
- Preserve source line mapping (physical line number -> logical statement)
- Handle blank lines (skip)
- Produce normalized statement records with: statement_id, source_line(s), label (if any), statement_text

Output format (dump mode -dump-lines):
For each logical statement, print a line like:
  stmt<N> line=<M> label=<L> text=<statement text>

Where N is the statement sequence number, M is the starting physical source line, L is the numeric label (or blank), and text is the assembled statement body (trimmed).

The normalizer should be a SNOBOL4 program that can be INCLUDEd by driver.sno or run standalone for testing.

Also update driver.sno to support reading a .f file and invoking normalize.sno, with a -dump-lines flag.

Test against the example files in examples/ (hello.f, sum10.f, goto1.f, array1.f) to verify normalization works correctly.