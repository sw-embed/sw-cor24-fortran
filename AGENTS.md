# AGENTS.md

This file provides guidance to AI coding agents (opencode, Claude Code, Gemini CLI, etc.) when working with code in this repository.

## Project: sw-cor24-fortran -- FTI-0 compiler

A small educational FORTRAN integer subset compiler (FTI-0) implemented in SNOBOL4, targeting PL/SW.

A dogfooding project: this validates the SNOBOL4 interpreter and the PL/SW transpiler (and the assembler and emulator).

## CRITICAL: AgentRail Session Protocol (MUST follow exactly)

Every agent session follows this 6-step loop. Do NOT skip or reorder steps.

### 1. START (do this FIRST, before anything else)
```bash
agentrail next
```
Read the output carefully. It contains your current step, prompt, plan context, and any relevant skills/trajectories.

### 2. BEGIN (immediately after reading the next output)
```bash
agentrail begin
```

### 3. WORK (do what the step prompt says)
Do NOT ask "want me to proceed?" or "shall I start?". The step prompt IS your instruction. Execute it directly.

### 4. PRE-COMMIT QUALITY GATE (MANDATORY -- every step, no exceptions)
Every completed saga step must be high quality, documented, and pushed to GitHub.
If anything fails, fix the underlying problem -- NEVER suppress, allow, or work around a check.

#### Phase A: Verify
1. Review staged files with `git status` -- No build artifacts, no unintended files.
2. Verify documentation is up-to-date -- if code changed affected behavior, update docs.
3. Run `markdown-checker -f "**/*.md"` if any markdown changed. Fix any issues.
4. **Commit** the working, tested code.

#### Phase B: Push
5. `git push` -- Every completed step must be pushed to GitHub.

### 5. COMPLETE (LAST thing, after committing and pushing)
```bash
agentrail complete --summary "what you accomplished" \
  --reward 1 \
  --actions "tools and approach used"
```
- If the step failed: `--reward -1 --failure-mode "what went wrong"`
- If the saga is finished: add `--done`

### 6. STOP (after complete, DO NOT continue working)
Do NOT make further code changes after running `agentrail complete`.
Any changes after complete are untracked and invisible to the next session.
Future work belongs in the NEXT step, not this one.

## Key Rules

- **Do NOT skip steps** -- the next session depends on accurate tracking
- **Do NOT ask for permission** -- the step prompt is the instruction
- **Do NOT continue working** after `agentrail complete`
- **Commit before complete** -- always commit first, then record completion
- **NO Python** -- do not use Python for anything in this project
- **Implementation language is SNOBOL4** -- all compiler code is .sno files
- **Target language is PL/SW** -- the compiler emits .msw/.plsw files
- **NO direct COR24 assembly** -- we emit PL/SW, which the PL/SW toolchain lowers to assembly

## NO WORKAROUNDS

**When SNOBOL4 or PL/SW is missing a feature needed to implement/run the FTI-0 compiler, create a GitHub issue for that repo and wait for another agent to fix it. Do NOT work around missing features with hacks, data-file tricks, or fragile encoding gymnastics.**

Only make changes in this repository (`sw-cor24-fortran`). The toolchain repos (`sw-cor24-snobol4`, `sw-cor24-plsw`, `sw-cor24-emulator`) are out of scope for direct edits.

If a blocker is found:
1. File a clear, minimal issue on the blocking repo with reproduction steps and what's needed
2. Mark the current step as failed with `--reward -1 --failure-mode` referencing the issue
3. Stop -- do not proceed until the dependency is resolved

## Useful Commands

```bash
agentrail status          # Current saga state
agentrail history         # All completed steps
agentrail plan            # View the plan
agentrail next            # Current step + context
```

## Toolchain

| Tool | Purpose |
|------|---------|
| snobol4 | Interpreter to run the FORTRAN compiler SNOBOL4 source |
| plsw | Transpiler: takes .plsw/.msw files and produces .s assembly |
| `cor24-run` | COR24 assembler + emulator (downstream of PL/SW) |

### Build Pipeline

```
snobol4/src/*.sno  --[snobol4 interpreter]-->  .msw/.plsw files  --[plsw]-->  .s assembly  --[cor24-run]-->  emulate on COR24
```

The FTI-0 compiler itself is a SNOBOL4 program. The SNOBOL4 interpreter runs the compiler, which reads .f source and emits PL/SW.

### Toolchain Locations (this project validates these)

- `sw-cor24-snobol4` -- SNOBOL4 interpreter
- `sw-cor24-plsw` -- PL/SW compiler + linker
- `sw-cor24-emulator` -- COR24 assembler and emulator (Rust)

All COR24 repos live under `~/github/sw-embed/` as siblings.

## Repository Structure

```
sw-cor24-fortran/
  AGENTS.md
  README.md
  docs/              Design, architecture, subset definition, plan
  snobol4/
    src/             Compiler phases (.sno files)
    tests/           Golden tests per phase
  examples/          Sample FTI-0 input programs (.f files)
  plsw/
    runtime/         Runtime helpers (.msw)
    generated/       Emitted PL/SW output
  scripts/           Development helpers
```

## Architecture

FTI-0 is a multi-pass source-to-source compiler:

1. **Driver** -- read options, coordinate passes (`driver.sno`)
2. **Normalization** -- fixed-form line handling, continuations, comments (`normalize.sno`)
3. **Classification** -- identify statement kind, split fields (`classify.sno`)
4. **Expression parsing** -- precedence climbing / shunting-yard (`expr.sno`)
5. **Semantic analysis** -- symbol table, label table, validation (`symbols.sno`, `labels.sno`)
6. **Lowering** -- normalize control flow, expand loops (`lower.sno`)
7. **PL/SW emission** -- generate readable PL/SW output (`emit_plsw.sno`)
8. **Error handling** -- phase-tagged diagnostics (`errors.sno`)

See `docs/architecture.md` for full details.

## FTI-0 Language Subset

Integer-only, fixed-form FORTRAN subset:

- `PROGRAM`, `INTEGER`, `DIMENSION`
- Assignment, `GOTO`, `IF (expr) GOTO label`
- Counted `DO` (step defaults to 1), `CONTINUE`
- `PRINT *`, `READ *`
- `STOP`, `END`
- Explicit declarations only (no implicit typing)
- One-dimensional arrays only
- No floating point, no FORMAT, no COMMON, no EQUIVALENCE

See `docs/subset-fti0.md` for the language reference.

## PL/SW Mapping Contract

- User variables: `I` -> `F_I` (F_ prefix)
- Source labels: `100` -> `L_100` (L_ prefix)
- Generated labels: `L_DO_TEST_1`, `L_DO_EXIT_1`
- Temporaries: `T_1`, `T_2`
- Runtime helpers: `FTI_PRINT_INT`, `FTI_PRINT_NL`, `FTI_READ_INT`, `FTI_STOP`

See `docs/plsw-mapping.md` for full mapping details.

## Milestones (see docs/plan.md)

| # | Milestone | Status |
|---|-----------|--------|
| 0 | Repository and documents | Done |
| 1 | Source normalization | Next |
| 2 | Statement classification | |
| 3 | Expression parsing | |
| 4 | Symbols and labels | |
| 5 | Lowering | |
| 6 | PL/SW emission | |
| 7 | End-to-end examples | |
| 8 | Arrays and richer control flow | |

## Design Constraints

- COR24 is 24-bit: int is 24-bit, pointers are 24-bit, address space is 16 MB
- SNOBOL4 is the implementation language (pattern matching, string processing)
- PL/SW is the compilation target (inspectable, human-readable output)
- Generated PL/SW must be readable, not opaque
- Compiler output should be deterministic for the same source
- Each compiler phase should support a dump mode for debugging

## Testing

Golden-file style testing at each compiler phase:

- Normalization tests: input .f -> expected normalized statement records
- Classification tests: normalized statements -> expected kind/payload
- Expression tests: expression text -> expected tree
- Semantic tests: small programs -> expected symbol/label tables + diagnostics
- Lowering tests: parsed programs -> expected lowered form
- Emission tests: lowered programs -> expected PL/SW text
- End-to-end smoke tests: .f files -> expected PL/SW output

See `docs/test-strategy.md` for full testing strategy.

## Other COR24 Languages

- `sw-cor24-forth` -- Forth interpreter
- `sw-cor24-apl` -- APL interpreter
- `sw-cor24-basic` -- BASIC interpreter
- `sw-cor24-pascal` -- Pascal compiler + runtime
- `sw-cor24-plsw` -- PL/SW (PL/I-subset) compiler + linker
- `sw-cor24-snobol4` -- SNOBOL4 interpreter
