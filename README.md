# sw-cor24-fortran

Fortran compiler for the COR24 24-bit RISC ISA (future/research).

Part of the [COR24 ecosystem](https://github.com/sw-embed/sw-cor24-project).

**FTI-0**  
*A small educational FORTRAN subset compiler in SNOBOL4 targeting PL/SW.*

## Overview

`sw-cor24-fortran` is an experimental educational compiler project.

The first language subset is **FTI-0**:

- a small, fixed-form, integer-only FORTRAN-like subset
- implemented in **SNOBOL4**
- targeting **PL/SW**
- designed for clarity, testability, and historical flavor rather than full FORTRAN compatibility

The initial goal is to compile small educational programs such as:

- integer assignment
- simple expressions
- `GOTO`
- counted `DO`
- `PRINT`
- `READ`
- one-dimensional integer arrays

The project is intentionally staged:

1. normalize and parse fixed-form source
2. build symbols and resolve labels
3. lower control flow to a simple normalized form
4. emit readable PL/SW
5. later revisit floating point and richer FORTRAN features

## Status

This repository currently defines:

- the project structure
- the FTI-0 language subset
- the compiler architecture
- the PL/SW mapping contract
- the milestone plan

Compiler implementation is expected to begin with source normalization and statement classification.

## Repository structure

- `docs/` — product, architecture, design, plan, subset definition
- `snobol4/` — compiler source and tests
- `examples/` — sample FTI-0 input programs
- `plsw/` — runtime helpers and generated output
- `scripts/` — development helpers

## First milestone

The first executable milestone is:

- accept a tiny `.f` source file
- normalize fixed-form statements
- classify statements
- dump normalized statement records

No code generation is required for the first milestone.

## Naming

- Repository: `sw-cor24-fortran`
- Subset language: `FTI-0`
- Compiler executable: `fti0c`

## Non-goals for FTI-0

FTI-0 does **not** initially support:

- floating point
- `FORMAT`
- `COMMON`
- `EQUIVALENCE`
- statement functions
- separate compilation
- optimization
- multidimensional arrays
- full FORTRAN compatibility

## Long-term direction

Possible later stages include:

- richer FORTRAN subset levels
- arithmetic IF
- subroutines and functions
- software floating point
- direct or indirect lowering into COR24-oriented toolchains

## Research

See `docs/research.txt` for detailed design research and historical context.

## Related Repositories

| Repository | Description |
|---|---|
| [sw-cor24-emulator](https://github.com/sw-embed/sw-cor24-emulator) | COR24 emulator + ISA |
| [sw-cor24-x-assembler](https://github.com/sw-embed/sw-cor24-x-assembler) | COR24 assembler |
| [sw-cor24-project](https://github.com/sw-embed/sw-cor24-project) | Ecosystem hub |

## License

See repository for license details.
