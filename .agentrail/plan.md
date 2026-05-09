Resume milestone-1 source-normalization work, now that:
- dcsno has shipped snobol4.lgo (and snobol4 wrapper on PATH)
- dcemu has shipped the --lgo + --load-binary fix (verified 2026-05-08)
- the canonical pattern works: snobol4 --load-binary <prog>.sno@0x080000 --entry 0

Original plan from milestone-1-source-normalization (now archived under
.agentrail-archive/) ran into the dcemu bug + uncertain deployment state
and pivoted into the Path-A short-circuit fortran-hello-world saga. That
saga shipped a hand-written hello.lgo demo for dwftn but didn't dogfood
the SNOBOL4-based compiler at all. This saga resumes the real work.

Steps:
1. fix-verify-snobol4 -- rewrite scripts/verify-snobol4.sh to use the
   canonical `snobol4 --load-binary X@0x080000 --entry 0 --quiet` pattern
   (no --uart-file misuse). Confirm it flips from BLOCKED to OK against
   the deployed interpreter.
2. write-test-normalize-runner -- author scripts/test-normalize.sh that
   runs normalize.sno against each .f fixture and diffs UART output vs
   the .expected file. Smoke-test the runner on a trivial .sno first.
3. debug-normalize-against-fixtures -- point the runner at the draft
   snobol4/src/normalize.sno. Watch fixtures fail. Read each failure
   honestly, fix the SNOBOL4 source, repeat until all 8 are green.
4. (followups for separate sagas: classify, expr, symbols/labels,
   lower, emit_plsw, integrate-driver -- each its own saga)