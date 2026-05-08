Draft snobol4/src/normalize.sno -- the source normalizer that reads
fixed-form .f via SNOBOL4 INPUT, applies the column rules, and emits
normalized statement records in the format authored in
snobol4/tests/normalize/ fixtures (`stmt<N> line=<M> label=<L>
text=<text>`).

This step is a DRAFT: snobol4.lgo is not deployed (see
docs/snobol4-blockers.md), so we cannot run normalize.sno against
the fixtures. The deliverable is well-commented SNOBOL4 source that:

1. Implements the rules per docs/subset-fti0.md and the eight
   fixtures in snobol4/tests/normalize/:
   - skip lines with `C` or `*` in col 1 (comments)
   - skip blank lines
   - extract numeric label from cols 1-5 (leading spaces stripped)
   - col 6 non-blank and non-`0` => continuation; append cols 7-72
     to prior statement
   - cols 7-72 = statement text; chars beyond col 72 ignored;
     trailing whitespace rstripped
   - emit one record per logical statement
2. Uses only SIZE / SUBSTR / CHAR among the SNOBOL4 builtins
   that issue #1 verified.
3. Walks each fixture mentally in comments to argue correctness.

Acceptance:
- `snobol4/src/normalize.sno` exists with substantive implementation
  (NOT a stub) and clear inline comments tying behavior to fixture
  expectations.
- A "Status" comment block at the top notes "DRAFT -- unverified;
  awaits dcsno-bootstrap-snobol4-toolchain.md ship to run
  fixtures."
- No execution attempted (snobol4.lgo not deployed).

This step does NOT include driver.sno wiring or running tests --
those remain with steps 006-normalize-tests and 007-integrate-driver.