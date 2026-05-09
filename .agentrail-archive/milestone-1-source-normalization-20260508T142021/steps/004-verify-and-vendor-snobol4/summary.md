Verified the SIZE/SUBSTR/CHAR fix is present in upstream sw-cor24-snobol4
source (sno_exec.plsw line 1002+; plan.md says "added (issue #1)").
End-to-end verification deferred: snobol4.lgo is not yet deployed at
$TOOLROOT/../lib/cor24/, owned by tools/briefs/dcsno-bootstrap-snobol4-toolchain.md
("cleared, placeholder branch only" per briefs README as of 2026-05-08).

Landed in this repo, ready to verify the moment snobol4.lgo lands:
- scripts/fortran: user-facing .f -> compiled output wrapper that
  invokes cor24-emu --lgo snobol4.lgo --uart-file driver.sno -u <src>.
- scripts/verify-snobol4.sh: gate that runs the SIZE/SUBSTR/CHAR
  fixture and diffs vs expected; exit 0/1/2 = pass/fail/blocked.
  Exits 2 today (BLOCKED).
- snobol4/tests/builtins/{test_builtins.sno,.expected,README.md}:
  the verification fixture mirroring the upstream test_builtins.sno.

Doc alignment with the PATH-resolved toolchain (per briefs/dc-migrate-toolchain.md):
- docs/tools.md rewritten around tc24r/cor24-asm/cor24-emu/pl-sw/snobol4.
- docs/snobol4-blockers.md status section recapped: blocker has
  shifted from "primitives missing" to "deployment pending dcsno".
- AGENTS.md toolchain table + pipeline diagram updated.

Audit: this repo's scripts already pass the dc-migrate-toolchain audit.