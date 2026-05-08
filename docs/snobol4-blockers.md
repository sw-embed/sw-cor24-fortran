# SNOBOL4 toolchain blockers for FTI-0 milestone 1

## Summary

FTI-0's source normalizer (`snobol4/src/normalize.sno`) cannot be
implemented or executed without three SNOBOL4 builtin functions:
`SIZE`, `SUBSTR`, and `CHAR`. These were missing from the
`sw-embed/sw-cor24-snobol4` interpreter when milestone-1 work began.
The blocker was filed there as **issue #1**.

**Status as of 2026-05-08:** the *original* blocker (issue #1, missing
primitives) appears resolved upstream. A second *deployment* blocker is
now in front of us: the SNOBOL4 interpreter image (`snobol4.lgo`) has
not yet been built and installed at the system tool location
(`$TOOLROOT/../lib/cor24/snobol4.lgo`). Without that file, no
verification or downstream FTI-0 work can run end-to-end.

This session added the runtime plumbing in our repo (`scripts/fortran`,
`scripts/verify-snobol4.sh`, `snobol4/tests/builtins/`) so that the
moment `snobol4.lgo` lands, verification and compilation will Just Work
without further changes here.

## What FTI-0 needs from SNOBOL4

The source normalizer is a fixed-form column-aware text processor. Per
`docs/subset-fti0.md` and `docs/architecture.md`, it must:

1. read each physical input line
2. detect comments (`C` or `*` in column 1)
3. extract the optional numeric label from columns 1-5
4. detect a continuation marker in column 6 (non-blank and non-`0`)
5. extract the statement text from columns 7-72 (anything beyond col 72
   is ignored)
6. merge continuation lines into a single logical statement
7. emit normalized statement records preserving source line mapping

Implementing this requires column-precise substring extraction and
string length operations on every input line.

## The original blocker: SIZE / SUBSTR / CHAR

| Builtin | Signature | Why normalize.sno needs it |
|---------|-----------|----------------------------|
| `SIZE`   | `n = SIZE(s)`             | Measure line length: detect short lines (don't read past EOL) and blank lines. |
| `SUBSTR` | `t = SUBSTR(s, pos, len)` | Extract column ranges: cols 1-5 (label), col 6 (continuation marker), cols 7-72 (statement text). The whole normalizer hinges on this. |
| `CHAR`   | `c = CHAR(code)`          | Useful for character-class tests (e.g., is col 6 a non-blank non-`0`?) and for emitting specific characters in normalized output. |

Without these, no fixed-form column extraction is possible, and the
normalizer cannot be written.

## Upstream issue

`sw-embed/sw-cor24-snobol4#1`

This issue was filed by the agent that attempted milestone-1 step 002
(implement-normalize) and discovered the missing primitives. See
`.agentrail/steps/002-implement-normalize/summary.md` in this repo for
that agent's closure note ("Blocked: SNOBOL4 missing SIZE/SUBSTR/CHAR
-- issue sw-embed/sw-cor24-snobol4#1").

## Status (2026-05-08)

The blocker has shifted. The original primitives issue (snobol4#1)
appears resolved at the source level. The live blocker is now
**toolchain deployment**: there is no `snobol4` wrapper on PATH and
no `snobol4.lgo` at `$TOOLROOT/../lib/cor24/`, so the SNOBOL4
interpreter FTI-0 sits on top of cannot be invoked.

### Source level: issue #1 appears fixed

In `sw-cor24-snobol4`:

1. `docs/plan.md` line 499 (April 2026 status section):
   > "SIZE / SUBSTR / CHAR builtins added (issue #1) ..."
2. `src/sno_exec.plsw` line 1002+ contains a real `EXEC_BUILTIN`
   proc with substantive `WHEN (X_OP = OP_SIZE / OP_SUBSTR / OP_CHAR)`
   arms (not stubs).

End-to-end verification is gated on deployment, below.

### Deployment is owned by a coordinator brief

The COR24 toolchain has consolidated onto a PATH-resolved model: each
language layer ships as `<lang>.lgo` at `$TOOLROOT/../lib/cor24/`
plus a one-line wrapper at `$TOOLROOT/<lang>` doing
`exec cor24-emu --lgo <lgo> "$@"`. PL/SW is live (`pl-sw`,
`plsw.lgo`); SNOBOL4 is not.

The unblock is tracked at:

- `/disk1/github/softwarewrighter/devgroup/tools/briefs/dcsno-bootstrap-snobol4-toolchain.md`
  (owner: dcsno; branch: `pr/bootstrap-toolchain`)
- Status per `tools/briefs/README.md` as of 2026-05-08: *"cleared,
  placeholder branch only"* -- dcsno can start; nothing shipped yet.
  The brief explicitly names dcftn as the downstream beneficiary
  (line 83 of that brief).

When dcsno ships and mike relays, mike installs the artifacts and
dcftn is unblocked. No action in this repo will accelerate that.

### What this repo has ready to verify

Once `snobol4.lgo` is installed, three pieces wire up end-to-end
with no further changes here:

- `scripts/verify-snobol4.sh` -- runs the test fixture through the
  interpreter, diffs against expected output, exit 0/1/2 for
  pass/fail/blocked.
- `snobol4/tests/builtins/` -- SIZE/SUBSTR/CHAR fixture mirroring
  the upstream `test_builtins.sno`.
- `scripts/fortran` -- user-facing `.f -> compiled output` wrapper.
  Errors with a pointer to this doc when `snobol4.lgo` is missing.

## Next steps once `snobol4` is on PATH

When mike signals that the dcsno brief has shipped:

1. Sanity-check the deployment from this repo:
   ```
   scripts/verify-snobol4.sh
   ```
   Expect exit 0 and a one-line "OK" message. Exit 1 (FAIL) means the
   deployed interpreter doesn't match what FTI-0 assumes -- file a
   blocker on dcsno before touching anything else here.
2. In `.agentrail/`, the saga is parked at step 005-normalize-tests
   (formerly 004; renumbered when the verify-and-vendor step landed
   in front of it). Step 002 (implement-normalize) is marked
   completed but its work was never written -- `snobol4/src/normalize.sno`
   is still a stub.
   - `agentrail reopen 2` and re-attempt the implementation using
     SIZE / SUBSTR / CHAR.
   - When green, `agentrail reopen 5` (or 4, depending on numbering at
     that time) and run the test runner against the fixtures already
     authored in `snobol4/tests/normalize/`.
   - Then proceed to integrate-driver and the remaining FTI-0
     milestones (classify, expr, symbols/labels, lower, emit_plsw).
3. The `.f -> .s` end-to-end smoke test, once the compiler exists, is
   `scripts/fortran examples/hello.f`.

## Adjacent risks (might surface as new blockers)

The current blocker is just SIZE / SUBSTR / CHAR for the *normalizer*.
Later FTI-0 milestones will need more of the SNOBOL4 surface:

- **Pattern matching** (SPAN, BREAK, REM) -- needed for tokenization
  in the classify and expr phases. The sibling repo's plan.md and
  examples suggest these are implemented; worth reconfirming when
  classify lands.
- **TABLE / array-like data structures** -- needed for symbol and
  label tables (milestone 4). Sibling plan.md mentions `ARR_POOL`
  and array support; FTI-0 specifics need confirmation.
- **OUTPUT to a file vs. stdout** -- needed for emitting `.msw`
  files (milestone 6). Sibling plan.md notes UART TX as the OUTPUT
  sink; may require host-side tooling to capture into a file.
- **Integer width / overflow semantics** -- COR24 is 24-bit; need
  to confirm SNOBOL4 arithmetic integers fit and that overflow
  behavior is documented.

These are not currently blockers -- they are flagged so the next
blocker discovery isn't a surprise.

## Where this is tracked

Upstream (the actual unblock):

- `/disk1/github/softwarewrighter/devgroup/tools/briefs/dcsno-bootstrap-snobol4-toolchain.md`
  -- the saga brief mike will hand to dcsno.
- `/disk1/github/softwarewrighter/devgroup/tools/briefs/README.md`
  -- the rolling status table; check here before assuming the blocker
  is still live.

In this repo:

- `.agentrail/steps/002-implement-normalize/summary.md` -- original
  blocker note from the agent who first hit this
- `.agentrail/steps/005-normalize-tests/summary.md` (or `004-...` if
  renumbered) -- runner+verify step, blocked
- `snobol4/tests/builtins/README.md` -- the SIZE/SUBSTR/CHAR
  verification fixture authored this session
- `snobol4/tests/normalize/README.md` -- the normalize-phase fixtures
  authored in a prior session
- `scripts/fortran` and `scripts/verify-snobol4.sh` -- the runtime
  plumbing waiting on `snobol4.lgo`

When the deployment lands and FTI-0 actually runs end-to-end, update
or replace this document with a "lessons learned" / postmortem note,
or fold it into a milestone retrospective.
