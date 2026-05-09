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

## Live demo: hello world

A working `Hello, World!` end-to-end demo is live, even though the
full FTI-0 compiler is still under construction:

```
scripts/fortran examples/hello.f > /tmp/hello.s
cor24-asm /tmp/hello.s -o /tmp/hello.lgo
cor24-emu --lgo /tmp/hello.lgo --quiet --speed 0
# prints "Hello, World!"
```

For now, `scripts/fortran` short-circuits `examples/hello.f` to a
hand-written `examples/hello.s` (Path A per
[`tools/briefs/dcftn-fortran-hello-world.md`](file:///disk1/github/softwarewrighter/devgroup/tools/briefs/dcftn-fortran-hello-world.md)).
The pre-built [`examples/hello.lgo`](examples/hello.lgo) is the demo
deliverable that the dwftn web frontend will embed.

Run `scripts/test-hello.sh` to regression-check the pipeline.

The full FTI-0 compiler (the SNOBOL4-based pipeline that consumes
arbitrary `.f` sources) is a separate parallel effort -- see
[`docs/snobol4-blockers.md`](docs/snobol4-blockers.md) for status.

## Status

This repository currently defines:

- the project structure
- the FTI-0 language subset
- the compiler architecture
- the PL/SW mapping contract
- the milestone plan
- a Path-A hello-world fixture (`examples/hello.s` + `examples/hello.lgo`)

Compiler implementation is expected to begin with source normalization and statement classification.

## Repository structure

- `docs/` -- product, architecture, design, plan, subset definition
- `snobol4/` -- compiler source and tests
- `examples/` -- sample FTI-0 input programs
- `plsw/` -- runtime helpers and generated output
- `scripts/` -- development helpers

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

## Links

- Blog: [Software Wrighter Lab](https://software-wrighter-lab.github.io/)
- Discord: [Join the community](https://discord.com/invite/Ctzk5uHggZ)
- YouTube: [Software Wrighter](https://www.youtube.com/@SoftwareWrighter)

## Copyright

Copyright (c) 2026 Michael A. Wright

## License

MIT License. See [LICENSE](LICENSE) for the full text.
