Author snobol4/src/emit_asm.sno covering only PROGRAM / STOP / END
kinds (halt skeleton, no PRINT yet).

Reads classified records on RAWINPUT from 0x090000:
  stmt<N> line=<M> label=<L> kind=<KIND> text=<text>

Always emits the boilerplate (_start, _halt loop, _putc, _puts)
once at startup. Per-record dispatch on kind:
  PROGRAM -> emit `_main:` label and prologue
  STOP    -> emit `lc r0,0; bra _halt`
  END     -> emit `_main` epilogue (`mov sp,fp; pop r1; pop r2;
             pop fp; jmp (r1)`); then `.data` + (empty) literal pool

Other kinds: pass through silently for now (this saga is the
skeleton; PRINT and others come in subsequent steps).

Use the SNOBOL4 dialect idioms learned from classify.sno:
  - BREAK / SPAN(<literal>) / literal / REM, no POS/ARB
  - Single-direction :S/:F gotos
  - In-place substitution where helpful
  - Extract function-call results to temps if double-nested
    predicate args appear (the dcsno-ident-double-nested-arg
    workaround pattern)

Acceptance: a hand-crafted classified-records input (PROGRAM, STOP,
END only) produces a .s file that cor24-asm accepts and cor24-emu
runs to halt with exit code 0 and no UART output.