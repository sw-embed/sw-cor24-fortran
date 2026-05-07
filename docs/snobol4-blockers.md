# SNOBOL4 toolchain blockers for FTI-0 milestone 1

## Summary

FTI-0's source normalizer (`snobol4/src/normalize.sno`) cannot be
implemented or executed without three SNOBOL4 builtin functions:
`SIZE`, `SUBSTR`, and `CHAR`. These were missing from the
`sw-embed/sw-cor24-snobol4` interpreter when milestone-1 work began.
The blocker was filed there as **issue #1**.

**Status as of 2026-05-06:** the sibling repo's `docs/plan.md` and
its source code indicate the three builtins have been added (issue #1
appears resolved). The resolution has not yet been verified end-to-end
against `normalize.sno` -- the interpreter binary has not been built
on this host, and `normalize.sno` itself was never written.

The next agent should verify the upstream fix and, if confirmed,
reopen our local saga (currently parked at step 004 marked blocked).

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

## Current upstream status (2026-05-06)

Two pieces of evidence in the sibling `sw-cor24-snobol4` repo suggest
the issue has been resolved:

1. **`docs/plan.md` line 499** says (past tense, in the "April 2026"
   status section):

   > "SIZE / SUBSTR / CHAR builtins added (issue #1) ..."

2. **`src/sno_exec.plsw` line 1002+** contains a real `EXEC_BUILTIN`
   proc with substantive `WHEN (X_OP = OP_SIZE)`, `WHEN (X_OP = OP_SUBSTR)`,
   and `WHEN (X_OP = OP_CHAR)` arms. These are not stubs:

   - `OP_SIZE` walks the string descriptor and returns the length as INT
   - `OP_SUBSTR` takes (str, pos, len), copies into the string buffer,
     handles boundary cases (pos<1 clamped to 1; pos>len clamped to end)
   - `OP_CHAR` writes the given byte code into the string buffer as a
     1-character string

**What has NOT been verified:**

- `build/snobol4.bin` does not exist on this host. `just build` (in the
  sibling repo) has not been run.
- `cor24-run` may or may not be installed and ready (it is a separate
  toolchain dependency).
- `normalize.sno` itself has not been written -- the saga's step 002
  was closed in the blocked state and not retried after the upstream fix.

So while the upstream surface looks fixed, end-to-end execution of a
written normalizer against the new interpreter has not yet happened.

## Next steps to verify and unblock

For an agent with permissions to interact with the sibling repos and
GitHub:

1. Confirm `sw-embed/sw-cor24-snobol4#1` is closed on GitHub.
2. Build the interpreter:
   ```
   cd <sibling>/sw-cor24-snobol4
   just build
   ```
   Confirm `build/snobol4.bin` is produced.
3. Sanity-check the new builtins with a small SNOBOL4 program that
   exercises `SIZE`, `SUBSTR`, and `CHAR`. (See `examples/` in the
   sibling repo for the existing program style.)
4. Confirm `cor24-run` is available so `build/snobol4.bin` can actually
   execute.
5. In this repo, the saga is parked. Step 002 (implement-normalize) is
   marked completed but its work was never landed (`snobol4/src/normalize.sno`
   is still a stub). Step 004 (normalize-tests) is marked blocked.
   The cleanest path forward:
   - `agentrail reopen 2` and re-attempt the implementation
   - then `agentrail reopen 4` and run the runner against the
     fixtures already in `snobol4/tests/normalize/` (this session's
     deliverable; see that directory's README.md)
   - then proceed to step 005 (integrate-driver)

   Alternatively, insert a fresh "retry-implement-normalize" step
   between 003 and 004 with `agentrail insert --after 3 ...` if the
   reopen path is undesirable.

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

## Where this is tracked locally

- `.agentrail/steps/002-implement-normalize/summary.md` -- original
  blocker note
- `.agentrail/steps/004-normalize-tests/summary.md` -- current
  blocked-status note (set this session via `agentrail abort`)
- `snobol4/tests/normalize/README.md` -- pointer in the test fixtures
  directory

When the upstream is confirmed fixed and our saga is reopened, update
or replace this document with a "lessons learned" / postmortem note,
or fold it into a milestone retrospective.
