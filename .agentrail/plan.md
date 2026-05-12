Implement FTI-0 labels, unconditional GOTO, and conditional
IF (expr) GOTO — enough to compile examples/goto1.f end-to-end.

Demo to unblock (examples/goto1.f):

    PROGRAM COUNT
    INTEGER I
    I = 1
100 PRINT *, I
    I = I + 1
    IF (I - 6) GOTO 100
    STOP
    END

Expected output: lines "1", "2", "3", "4", "5".

What's new in m7:
- Statement labels (cols 1-5 in source) emit `L<N>:` in the .s
  right before the labelled statement.
- KGOT  (kind=GOTO)    -> emit `bra     L<N>`.
- KIFG  (kind=IF_GOTO) -> parse `IF (<expr>) GOTO <N>`, evaluate
  expr to r0, emit `ceq r0,z; brf L<N>` (branch when nonzero).

FTI-0 IF semantics for this saga: `IF (expr) GOTO L` branches
when expr != 0; falls through when expr == 0. This matches the
goto1.f loop-exit pattern (`I - 6` is 0 when I=6).

Expression evaluator refactor:
- KASN and KIFG share the same expression grammar (single
  binary or single operand). Refactor into a common EXPR block:
  caller sets MODE ('A' for ASSIGN, 'I' for IF) and the
  per-mode target (VN for ASSIGN dest, TGT for IF target),
  jumps to EXPR; EXPR ends with a dispatch on MODE to either
  store-to-_V_<VN> or ceq/brf-L<TGT>.

Constraints:
- IF arg form: a single binary expr (`V OP T`) or a single
  operand (`V` / `<lit>`). Same grammar as ASSIGN RHS. Parens,
  chained ops, relational/logical operators, arithmetic IF
  (`IF (X) L1, L2, L3`) — all out of scope.
- GOTO arg must be a positive integer label.
- Labels in the source: only one label per statement (FORTRAN
  convention anyway).
- Cap awareness: emit_asm.sno is at 132 statements post-m6.
  Refactor + new code stays under ~180.

Steps:
1. integrate-labels-and-goto -- update LOOP pattern to capture
   the `label=` field, emit `L<N>:` when present, add KGOT and
   KIFG dispatches, refactor KASN's expr-eval into a shared EXPR
   block.
2. dgmark-and-pr -- dg-mark-pr feat/m7-goto -> pr/m7-goto.
