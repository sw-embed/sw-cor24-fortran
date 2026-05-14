Implement FTI-0 DIMENSION + array access — unblocks
examples/array1.f end-to-end.

Demo to land (examples/array1.f):

    PROGRAM ARR1
    INTEGER I
    DIMENSION A(5)
    DO 100 I = 1, 5
      A(I) = I * 10
100 CONTINUE
    PRINT *, A(3)
    STOP
    END

Expected output: "30"  (A(3) = 3 * 10).

Architecture:

- KDIM (kind=DIMENSION_DECL) parses `DIMENSION <name>(<N>)`,
  reserves N words (3*N bytes) in VARDATA as
  `_V_<name>:` + `.zero <3*N>`.

- Array address compute uses a runtime helper `_aindex(base, idx)`
  that returns `base + (idx - 1) * 3`. Lives in
  snobol4/runtime/prelude.s alongside _start/_halt/_putc/_puts.
  Both array read and array store go through it.

- Refactor: EXPR (the shared assign/if expression evaluator)
  gains an array-ref form `<VAR>(<IDX>)` (EXPRA path) that
  computes the address via _aindex and dereferences. Same EXPR
  is now reused for PRINT: routing PRINT *, <expr> through EXPR
  with MODE='P' (new) emits putint + newline after computing
  the value. This collapses KPRTI / KPRTV / array-PRINT into
  one tiny dispatch.

- KASN gains an array-LHS form: `<VAR>(<IDX>) = <expr>`. Parses
  LHS as an array ref, routes RHS through EXPR with MODE='AA'
  (new). EXPRDAA stores r0 (the RHS value) into &<VAR>(<IDX>).

Operand types in this saga: integer literal or variable name
for <IDX>, same as for binary expr operands.

Constraints (out of scope):
- Multi-dimensional arrays (`DIMENSION A(M, N)`).
- Array in binary expressions (`X = A(I) + B(J)`).
- Array as IF inner (`IF (A(I)) GOTO`) -- comes for free via
  the EXPR refactor but not specifically tested in m9.
- Bounds checking.

Steps:
1. integrate-array -- add KDIM, EXPRA, EXPRDAA, EXPRDP; refactor
   KPRT to route through EXPR with MODE='P'; add _aindex to
   runtime/prelude.s. Verify array1.f end-to-end. Regress all
   six prior demos.
2. dgmark-and-pr -- dg-mark-pr feat/m9-array -> pr/m9-array.
