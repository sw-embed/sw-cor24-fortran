# Development Tools

This document describes the tools used in the sw-cor24-fortran project.

## Core Toolchain

| Tool | Purpose | Location |
|------|---------|----------|
| snobol4 | SNOBOL4 interpreter -- runs the FTI-0 compiler source | `sw-cor24-snobol4` |
| plsw | PL/SW transpiler -- converts .plsw/.msw to .s assembly | `sw-cor24-plsw` |
| cor24-run | COR24 assembler + emulator | `sw-cor24-emulator` |

All COR24 repos live under `~/github/sw-embed/` as siblings.

## SNOBOL4 Interpreter

The FTI-0 compiler is a SNOBOL4 program. The SNOBOL4 interpreter runs it.

```bash
# Run the FTI-0 compiler on a source file
snobol4 snobol4/src/driver.sno < input.f

# Run with dump modes (when implemented)
snobol4 snobol4/src/driver.sno -dump-lines < input.f
snobol4 snobol4/src/driver.sno -dump-statements < input.f
```

### SNOBOL4 Key Features Used

- Pattern matching for fixed-form source normalization
- Tables for symbol tables and label tables
- String processing for tokenization and emission
- Pattern-driven statement classification

## PL/SW Transpiler

Converts emitted PL/SW files to COR24 assembly.

```bash
# Transpile a single PL/SW file
plsw output.msw

# Transpile with linking
plsw main.msw runtime.msw
```

## COR24 Emulator

Assembles and emulates COR24 machine code.

```bash
# Assemble and run
cor24-run program.s

# Assemble only
cor24-run --assemble program.s -o program.bin
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

The full pipeline from FORTRAN source to execution:

```
.f source
  -> [snobol4 interpreter runs driver.sno]
  -> .msw/.plsw files (emitted PL/SW)
  -> [plsw transpiler]
  -> .s assembly
  -> [cor24-run assembler+emulator]
  -> execution on COR24
```

Each stage can be tested independently.
