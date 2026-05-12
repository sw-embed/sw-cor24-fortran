Implement FTI-0 assignment with binary arithmetic expressions:
`X = <op1> <OP> <op2>` where each operand is a literal or
variable name, and OP is one of `+`, `-`, `*`. Also adds the
simple `X = Y` (variable copy) form that m5 didn't cover.

Demos to land:

    X = 2 + 3                        -> X holds 5
    X = X + 1                        -> increment
    PRINT *, sum-from-two-adds       -> demonstrates expression -> var -> print

End-to-end fixture (examples/add.f):

    PROGRAM ADD
    INTEGER A
    INTEGER B
    INTEGER C
    A = 7
    B = 13
    C = A + B
    PRINT *, C
    STOP
    END
    -> "20"

This unblocks the loop-counter patterns in goto1.f / sum10.f
once labels/GOTO/IF-GOTO/DO/CONTINUE land in subsequent sagas.

COR24 ISA for this saga (verified in
sw-cor24-emulator/docs/cor24-tutorial.md):
  add r0, r1   -- r0 = r0 + r1
  sub r0, r1   -- r0 = r0 - r1
  mul r0, r1   -- r0 = r0 * r1
No div/mod -- expressions that would need them are out of scope.

Codegen convention (matches existing _puts / _putint emit):
  ; load op1 into r0
  push r0
  ; load op2 into r0
  mov r1, r0
  pop r0
  add/sub/mul r0, r1
  ; r0 holds result; store to _V_<lhs>
  la r1, _V_<lhs>
  sw r0, 0(r1)

Pattern dispatch in KASN:
  1. RHS parses as <T1> <OP> <T2>   -> binary expression (KASNB).
  2. RHS parses as a digit-run      -> integer literal (KASNL, m5).
  3. RHS parses as an alpha-run     -> variable copy   (KASNV, new).
  Each operand load (KASNB inner) dispatches T-is-digit vs
  T-is-alpha; emits `la r0,N` or `la r0,_V_X / lw r0,0(r0)`.

Constraints:
- Single binary op only (no `X = A + B + C` parenthesization,
  no chained operators). A reasonable next saga.
- Operands are tokens: digit-run literals, alpha-run variable
  names. No signs on literals (`-5`), no compound expressions.
- Watch the dcsno ~233-statement cap (see
  tools/briefs/dcsno-static-program-size-limit.md). Current
  count is 176; budget ~30 new statements.

Steps:
1. integrate-binary-expr -- add the KASN binary path + KASNV
   var-copy path. Verify examples/add.f and an X = X + 1
   increment fixture. Regress hello.f / print-int.f /
   print-var.f.
2. dgmark-and-pr -- dg-mark-pr feat/m6-assign-expr -> pr/m6-assign-expr.
