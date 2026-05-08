# Development Tools

This document describes the tools used in the sw-cor24-fortran project.

## Core Toolchain

All toolchain binaries are PATH-resolved from `$TOOLROOT`
(`/disk1/github/softwarewrighter/devgroup/work/bin/` on the devgroup
host). No sibling-clone setup is required to invoke them.

| Tool | Purpose | Source repo |
|------|---------|-------------|
| `tc24r` | C -> COR24 `.s` | sw-cor24-x-tinyc |
| `cor24-asm` | `.s` -> `.lgo` / `.bin` / `.lst` (with optional `--base-addr`) | sw-cor24-x-assembler |
| `cor24-emu` | run `.lgo`; load raw bytes via `--load-binary` | sw-cor24-emulator |
| `cor24-dbg` | debug `.lgo` | sw-cor24-emulator |
| `link24`, `meta-gen` | PL/SW separate-compilation linker | sw-cor24-plsw |
| `pl-sw` | wraps `cor24-emu --lgo plsw.lgo` | sw-cor24-plsw |
| `snobol4` | wraps `cor24-emu --lgo snobol4.lgo` (after the dcsno bootstrap brief ships -- see `docs/snobol4-blockers.md`) | sw-cor24-snobol4 |

The deprecated `cor24-run` (with its `--run` and `--assemble`
sub-flags) still exists in transition but is slated for retirement;
new code uses `cor24-asm` + `cor24-emu` per the
`dc-migrate-toolchain.md` brief mapping.

## Compiling FTI-0 source

The FTI-0 compiler is a SNOBOL4 program. To run it on a `.f` source,
use the project wrapper which slots the user's `.f` through
`cor24-emu --lgo snobol4.lgo` with our compiler's `.sno` as the
program:

```bash
# Compile a .f source (output to stdout)
scripts/fortran examples/hello.f
```

`scripts/fortran` resolves `snobol4.lgo` via `$TOOLROOT/../lib/cor24/`
(or by deriving from `pl-sw`'s install dir if `$TOOLROOT` is unset).
It errors with a clear pointer when the SNOBOL4 deployment is missing
-- see `docs/snobol4-blockers.md`.

To exercise the deployed SNOBOL4 interpreter alone (independent of
FTI-0), pass a `.sno` program directly:

```bash
cor24-emu --lgo $TOOLROOT/../lib/cor24/snobol4.lgo \
          --uart-file your-program.sno \
          -u "$(printf 'input data\x04')" \
          --speed 0 -n 100000000
```

### SNOBOL4 Key Features Used

- Pattern matching for fixed-form source normalization
- Tables for symbol tables and label tables
- String processing for tokenization and emission
- Pattern-driven statement classification

## PL/SW Compiler

Converts PL/SW source to COR24 assembly. Use the `pl-sw` wrapper
(it wraps `cor24-emu --lgo plsw.lgo`):

```bash
# Compile a single .plsw file (assembly to stdout)
pl-sw -u "$(cat input.plsw)"$'\x04' --speed 0 -n 200000000 > output.s
```

For multi-file .plsw with includes, see `sw-cor24-plsw/scripts/pipeline.sh`
for the `FILE:` / `SOURCE:` UART framing protocol.

Then assemble:

```bash
cor24-asm output.s -o output.lgo
```

## COR24 Assembler and Emulator

Assemble `.s` -> `.lgo` / `.bin`:

```bash
cor24-asm program.s -o program.lgo
cor24-asm program.s --bin program.bin --listing program.lst
```

Run a `.lgo`:

```bash
cor24-emu --lgo program.lgo --speed 0
cor24-emu --lgo program.lgo --terminal --echo            # interactive
cor24-emu --lgo program.lgo -u "$(cat input)"            # UART input
```

## Development Helpers

### markdown-checker

Validates that markdown files use ASCII-only characters.

```bash
# Validate all markdown
markdown-checker -f "**/*.md"

# Auto-fix tree symbols
markdown-checker --fix
```

Run this before committing any markdown changes.

### agentrail

Manages the development saga and tracks milestone progress.

```bash
agentrail status          # Current saga state
agentrail history         # All completed steps
agentrail plan            # View the plan
agentrail next            # Current step + context
```

## Tool Discovery

When working with a new COR24 repo:

1. Check `~/github/sw-embed/` for sibling repos
2. Look for README.md and build instructions in each repo
3. Verify tools are on PATH
4. Run `--help` on tools for AI-agent-specific guidance

## Build Pipeline

The full pipeline from FORTRAN source to execution on COR24:

```
input.f                 (FTI-0 source)
  -> scripts/fortran    (cor24-emu --lgo snobol4.lgo --uart-file driver.sno -u <input.f>)
  -> .plsw / .msw       (emitted PL/SW)
  -> pl-sw              (cor24-emu --lgo plsw.lgo)
  -> .s                 (COR24 assembly)
  -> cor24-asm          (assembler)
  -> .lgo               (COR24 image)
  -> cor24-emu          (run on the emulator)
```

Each stage can be tested independently. At runtime, every layer is
just `cor24-emu --lgo <some>.lgo` with appropriate UART input -- the
"tower" is purely a build-time dependency graph.
