Implement classify.sno: the second FTI-0 compiler phase.

Input:  normalized statement records from normalize.sno, format
        stmt<N> line=<M> label=<L> text=<text>
Output: same records with a kind=<KIND> field added between label= and text=:
        stmt<N> line=<M> label=<L> kind=<KIND> text=<text>

Statement kinds (per docs/design.md):
  PROGRAM, INTEGER_DECL, DIMENSION_DECL, ASSIGN, GOTO, IF_GOTO,
  DO, CONTINUE, PRINT, READ, STOP, END.

Same toolchain quirks as normalize: stay on the extract-to-temp
idiom for nested function calls / arithmetic-as-arg until the
dcsno funcall-arithmetic in-arg fix lands. Mark workaround sites
with `* XXX dcsno-funcall-arithmetic` so they can be reverted in
parallel with the normalize.sno revert.

Steps:
1. design-and-author -- author snobol4/src/classify.sno using the
   extract-to-temp idiom. Cover all 12 kinds. Comment the kind-
   detection rules.
2. fixtures-and-runner -- author snobol4/tests/classify/ fixture
   pairs (.in -> hand-crafted normalized records covering each
   kind; .expected -> classified records). Author scripts/test-
   classify.sh runner mirroring scripts/test-normalize.sh.
3. debug-to-green -- run runner, fix bugs in classify.sno or
   fixtures until all classify fixtures pass.

(Driver integration -- chaining normalize -> classify end-to-end
on real .f input -- is a separate later saga. This saga tests
classify in isolation.)