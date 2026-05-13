Implement FTI-0 DO/CONTINUE loops — enough to compile
examples/sum10.f end-to-end.

Demo to unblock (examples/sum10.f):

    PROGRAM SUM10
    INTEGER I
    INTEGER S
    S = 0
    DO 100 I = 1, 10
      S = S + I
100 CONTINUE
    PRINT *, S
    STOP
    END

Expected output: "55"

What's new in m8:
- KDO  (kind=DO)       parses `DO <lbl> <var> = <start>, <end>`,
  emits init (store <start> to _V_<var>) and a loop-top label
  `LDT<n>:`. Records DOLBL, DOVAR, DOEND, DOTOP for the matching
  CONTINUE.
- KCNT (kind=CONTINUE) checks if the statement's source label
  (LBL) matches the saved DOLBL. If yes, emit the increment +
  bound test + branch-back-to-DOTOP that closes the loop. If no,
  emit nothing (CONTINUE is then a no-op fall-through).

FORTRAN-II DO semantics implemented:
- I = start
- top: body
- continue-label: I = I + 1; if I <= end, branch to top
- (body executes at least once when start <= end; standard).

Codegen for the increment+test:
    la r0,_V_<var>
    lw r0,0(r0)
    add r0,1
    la r1,_V_<var>
    sw r0,0(r1)
    la r0,_V_<var>
    lw r0,0(r0)
    push r0
    la r0,<end+1>      ; <end>+1 computed at compile time
    mov r1,r0
    pop r0
    cls r0,r1          ; r0 < r1 (i.e. I < end+1, i.e. I <= end)
    brt LDT<n>

Constraints (deferred to later sagas):
- DO bounds must be integer literals. Variables and expressions
  in start/end are out of scope.
- Only one DO at a time (non-nested). Nested DOs come later.
- Step is always 1 (no `DO ... = a, b, c` step form).
- Single-line label per CONTINUE.

Steps:
1. integrate-do-continue -- add KDO and KCNT in emit_asm.sno.
   Verify sum10.f end-to-end. Regress hello.f / print-int.f /
   print-var.f / add.f / goto1.f.
2. dgmark-and-pr -- dg-mark-pr feat/m8-do-loop -> pr/m8-do-loop.
