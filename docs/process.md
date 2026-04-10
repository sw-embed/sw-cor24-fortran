# Development Process

## Overview

This document describes the development workflow for the sw-cor24-fortran project (FTI-0 compiler).

All compiler code is written in SNOBOL4 (.sno files). The compiler reads FTI-0 source (.f files) and emits PL/SW (.msw/.plsw files).

## Core Principles

- **Milestone-driven**: Each milestone produces observable, testable output
- **Phase-separated**: Compiler passes have clear boundaries and dump modes
- **Golden-file testing**: Expected output is checked against reference files
- **Readable output**: Generated PL/SW must be human-inspectable

## Development Cycle

```
Plan -> Implement phase -> Golden test -> Review -> Commit -> Push
```

### 1. Planning

- Review the plan (`docs/plan.md`) for the current milestone
- Check the design doc (`docs/design.md`) for patterns and conventions
- Check the architecture doc (`docs/architecture.md`) for phase interfaces
- Check the subset definition (`docs/subset-fti0.md`) for language rules
- Check the PL/SW mapping (`docs/plsw-mapping.md`) for target conventions

### 2. Implementation

- Compiler phases live in `snobol4/src/*.sno`
- Each phase should be independently testable
- Each phase should support a dump mode for debugging
- Follow existing SNOBOL4 patterns in the codebase

### 3. Testing

- Golden-file tests live in `snobol4/tests/` organized by phase
- Input: a small .f source file or fragment
- Expected output: a reference text file showing the phase's dump
- Run the compiler phase against input, compare output to expected
- One feature per test where practical

### 4. Review

- Self-review changes before committing
- Verify all tests pass
- Check that generated output is deterministic
- Ensure documentation reflects any design decisions

### 5. Commit and Push

- Write clear commit messages referencing the milestone
- Push immediately after commit

## Pre-Commit Quality Process

Run before every commit:

1. **Review staged files**: `git status` -- no build artifacts, no unintended files
2. **Verify tests**: run the compiler against golden test inputs, compare output
3. **Validate markdown** (if docs changed): `markdown-checker -f "**/*.md"`
4. **Update documentation** if behavior or design changed
5. **Commit** and **push**

## Testing Strategy

### Test Layers

| Layer | Input | Expected Output |
|-------|-------|-----------------|
| Normalization | .f source fragments | Normalized statement records |
| Classification | Normalized statements | Statement kind + payload |
| Expression | Expression text | Token stream / expression tree |
| Semantic | Small programs | Symbol table, label table, diagnostics |
| Lowering | Parsed programs | Lowered control-flow form |
| Emission | Lowered programs | PL/SW golden text |
| End-to-end | Example .f programs | Generated PL/SW snapshots |

### Golden Test Conventions

- Keep test inputs small and purpose-specific
- One feature per test where practical
- Add success case and failure case for each new feature
- Avoid fragile tests that depend on incidental formatting

## Debugging

Each compiler phase should support dump modes:

```
-dump-lines       Show normalized physical lines
-dump-statements  Show classified statements
-dump-symbols     Show symbol table
-dump-labels      Show label table
-dump-lowered     Show lowered control-flow form
-dump-plsw        Show emitted PL/SW
```

These are essential for incremental compiler development.

## SNOBOL4 Conventions

- Pattern matching is the primary tool for text processing
- Tables for symbol tables and label tables
- Strings for intermediate representations
- Keep expression parsing separate from statement classification
- Avoid embedding full expression parsing inside statement patterns

## Error Reporting

Errors should include:
- Phase name (normalize, classify, expr, symbols, labels, lower, emit)
- Source line number if available
- Original or normalized source text if useful
- Concise explanation

## Commit Message Format

```
type: Short summary (50 chars max)

Detailed explanation of what changed and why.
Reference the milestone number when applicable.

Types: feat, fix, docs, refactor, test, chore
```

## Git Workflow

- Direct commits to `main` (single developer)
- Push immediately after commit
- Never force push to main
