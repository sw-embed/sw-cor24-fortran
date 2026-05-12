Implement FTI-0 print-integer: extend the compiler to support
`PRINT *, <integer-literal>`, e.g. `PRINT *, 42` -> "42\n".

Inputs (from prior sagas):
- snobol4/src/normalize.sno  -- already preserves digits & ',' & '*'.
- snobol4/src/classify.sno   -- already kinds PRINT records.
- snobol4/src/emit_asm.sno   -- currently only handles PRINT with
  a string literal (single-apostrophe-delimited).

Goal:
- Edit examples/print-int.f containing `PRINT *, 42`.
- `scripts/fortran examples/print-int.f | cor24-asm - | cor24-emu`
  prints "42\n".
- Same compiler still passes hello.f (no regression).

Strategy:
- COR24 has no native div/mod. Implement decimal int-to-ASCII via
  repeated subtraction (write digits LIFO into a stack buffer,
  then drain LIFO -> _putc). Single _putint subroutine, takes the
  int arg @ 9(fp). Verified standalone on values 0, 1, 7, 10, 42,
  99, 100, 12345, 1234567 before integration.
- KPRT in emit_asm.sno detects integer-literal arg form via
  `TXT 'PRINT *' SPAN(' ,') SPAN('0123456789') . NUM` and emits
  `la r0,N; push r0; jal r1,(_putint); add sp,3` plus a trailing
  newline via _putc(10).

Constraints learned along the way:
- dcsno miscompiles SNOBOL4 programs above ~233 statements (filed
  in tools/briefs/dcsno-static-program-size-limit.md). Inlining
  ~70 OUTPUT lines for _putint pushes emit_asm.sno past the cap.
- Workaround: split _putint into snobol4/runtime/putint.s (static)
  and have scripts/fortran awk-splice it into emit_asm.sno's
  output at a `; __RUNTIME_PUTINT__` marker line. Pure mechanical
  splice; output is byte-equivalent to inlined form. When dcsno
  raises the cap this can be inlined back.

Steps:
1. design-and-prototype-putint -- author/verify _putint runtime
   standalone on edge-case values (0, 1, 7, 99, 100, 12345,
   1234567).
2. integrate-kprt-int-literal -- extend KPRT in emit_asm.sno
   with the integer-literal dispatch path. Splice _putint via
   scripts/fortran. End-to-end: print-int.f -> "42\n", hello.f
   still works.
3. fixtures-and-runner -- author snobol4/tests/emit/print-int/
   fixtures and add to scripts/test-emit.sh runner (if exists).
4. dgmark-and-pr -- dg-mark-pr feat/m4-print-int -> pr/m4-print-int.
