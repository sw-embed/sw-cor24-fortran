Authored 17 golden-test fixture files under snobol4/tests/normalize/:
8 input .f files, 8 .expected outputs in the format
`stmt<N> line=<M> label=<L> text=<text>`, and a README.md documenting
the format, naming, and deferred-runner status.

Test coverage: comments, labels, continuation, col-72 truncation,
blank lines, multi-line statements, and full programs (hello, sum10).

The fixtures define the contract normalize.sno must satisfy. Runner
script (scripts/test-normalize.sh) and execution were intentionally
deferred -- both remain blocked on sw-embed/sw-cor24-snobol4#1.