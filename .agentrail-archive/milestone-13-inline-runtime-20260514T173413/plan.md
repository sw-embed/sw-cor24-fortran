Inline the runtime support routines back into emit_asm.sno;
delete `snobol4/runtime/*.s` and the awk splice from
`scripts/fortran`. Now possible because dcsno's
`pr/cap-and-pattern-fixes` raised the source-byte cap from
~12,280 to ~64K (verified installed: md5 837b217e).

Before m4-print-int, emit_asm.sno emitted the entire .s
including the boilerplate / runtime. m4 / m9 hit the dcsno
12K-byte source cap and had to split out the runtime as
static files (`snobol4/runtime/prelude.s` for
_start / _halt / _putc / _aindex / _puts, and `runtime/putint.s`
for _putint), spliced in by an `awk` post-processor in
`scripts/fortran` at marker lines.

That workaround is no longer needed. Inlining gets us back to
"the compiler emits everything", which is the dogfooded form.

Steps:
1. inline-runtime-routines -- replace the two marker OUTPUTs in
   emit_asm.sno with the full inline asm-emitting OUTPUT
   sequences for prelude (~85 lines) and putint (~70 lines).
   Delete snobol4/runtime/*.s. Simplify scripts/fortran to a
   plain 3-phase pipeline with no post-processing. Verify all
   10 demos byte-identical.
2. dgmark-and-pr.
