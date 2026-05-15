Remove the last piece of the runtime-splice workaround:
inline `_putint` into `emit_asm.sno`, delete
`snobol4/runtime/putint.s`, drop the awk splice from
`scripts/fortran`. Now possible because the 2026-05-14T17:31
dcsno build (md5 `ae8308f6`) fixed the ~364-stmt halt
documented in
`tools/briefs/dcsno-emit-asm-halt-near-364-stmts.md`.

Result: scripts/fortran is a clean 3-phase pipeline with no
post-processing, snobol4/runtime/ is gone, the compiler emits
the full COR24 .s on its own.

Steps:
1. inline-putint-and-delete-runtime -- inline ~70 _putint
   OUTPUTs into emit_asm.sno; delete runtime/putint.s; drop
   the awk splice + the marker check in scripts/fortran.
   Verify all 10 demos byte-identical.
2. dgmark-and-pr.
