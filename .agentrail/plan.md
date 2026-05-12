Implement FTI-0 print-variable: extend the compiler to support
INTEGER variable declarations, ASSIGN with an integer literal,
and PRINT of an INTEGER variable.

Demo to land:
    PROGRAM A
    INTEGER X
    X = 42
    PRINT *, X
    STOP
    END

Expected output: "42\n"

This is the smallest unit that adds variable plumbing to the
emitter -- it unlocks the next saga (m6) for adding arithmetic
expressions (X = 2 + 3, X = X + 1), which in turn unlocks
goto1.f / sum10.f after labels + GOTO + IF-GOTO + DO/CONTINUE.

Prior sagas:
- m1 (normalize) -- handles INTEGER, =, identifiers, variable
  names (it's a fixed-form line normalizer; semantics-agnostic).
- m2 (classify) -- already emits kind=INTEGER_DECL and kind=ASSIGN.
- m3 (emit string PRINT) + m4 (emit integer-literal PRINT) --
  current emit_asm.sno produces boilerplate, _main, _puts, _putint
  (via runtime splice), and handles PRINT of a string or int literal.

What's new in m5:
- INTEGER_DECL X    -> track X in a variable table; emit a
  `_V_X: .word 0` entry in a VARDATA pool (analogous to LITDATA).
- ASSIGN X = <int>  -> emit `la r0,N / la r1,_V_X / sw r0,0(r1)`.
- PRINT *, X        -> detect bare-identifier arg in KPRT, emit
  `la r0,_V_X / lw r0,0(r0) / push r0 / jal r1,(_putint) /
   add sp,3 / lc r0,10 / push r0 / jal r1,(_putc) / add sp,3`.
- KEND              -> .data section now emits LITDATA *and* VARDATA.

Scope guard:
- Only integer literals on the RHS of ASSIGN. Expressions
  (`X = 2 + 3`, `X = X + 1`) come in m6.
- Only INTEGER scalars. DIMENSION (arrays) deferred.
- One PRINT arg per statement (already a current limitation).

Steps:
1. integrate-int-decl-assign-printvar -- single step: do the
   emit_asm.sno extension, ship examples/print-var.f, verify
   end-to-end, regression on hello.f and print-int.f.
2. dgmark-and-pr -- dg-mark-pr feat/m5-print-var -> pr/m5-print-var.
