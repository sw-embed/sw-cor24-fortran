Implement emit_asm.sno: the FTI-0 code-generation phase, scoped to
exactly enough to compile examples/hello.f end-to-end into a
runnable hello.lgo that prints "Hello, World!".

Input:  classified statement records (output of classify.sno),
        format stmt<N> line=<M> label=<L> kind=<KIND> text=<text>

Output: COR24 assembly (.s) on stdout.

Strategy:
- Emit COR24 .s directly (skipping documented PL/SW intermediate;
  matches the hand-written examples/hello.s pattern; minimises
  toolchain dependencies).
- Boilerplate skeleton emitted at start (always): _start, _halt
  loop, _putc subroutine, _puts subroutine.
- Per-kind dispatch:
    PROGRAM   -> emit _main: prologue (push fp, etc.)
    PRINT     -> extract string literal, emit la r0,_Sn; push r0;
                 jal r1,(_puts); add sp,3; track literal in pool
    STOP      -> emit lc r0,0; bra _halt   (return-and-halt)
    END       -> emit _main epilogue + .data section + literal pool
- String literal pool collected as records arrive; emitted at END.

Scope of THIS saga: hello.f only. Subsequent sagas extend to
print-integer, math, control flow, etc.

Steps:
1. design-and-author -- author snobol4/src/emit_asm.sno covering
   PROGRAM / STOP / END (halt skeleton, no PRINT). Verify a
   classified-records input with just those produces a .s that
   cor24-asm accepts and cor24-emu runs to halt.
2. add-print-literal -- extend emit_asm.sno to handle PRINT with
   a quoted string literal. Track literals in a pool, emit on END.
3. fixtures-and-runner -- author snobol4/tests/emit/ fixtures and
   scripts/test-emit.sh runner.
4. integrate-end-to-end -- update scripts/fortran (or write a
   pipeline script) to chain normalize -> classify -> emit on a
   real .f source. End-to-end: scripts/fortran examples/hello.f |
   cor24-asm | cor24-emu prints "Hello, World!" -- replacing the
   Path A short-circuit fixture with real compilation.