# sw-cor24-fortran

Fortran compiler for the COR24 24-bit RISC ISA (future/research).

Part of the [COR24 ecosystem](https://github.com/sw-embed/sw-cor24-project).

## Status

**Research phase** — this repository contains design notes and research
on implementing an early-flavor Fortran compiler targeting COR24.
No compiler code exists yet.

## Design Direction

- Target a FORTRAN II-ish subset (integer-first, optional software REAL)
- Direct native COR24 code generation (no p-code/VM)
- Software floating point via runtime library calls
- Inspired by IBM 1130/1800 FORTRAN approach to integer-only hardware

See `docs/research.txt` for detailed design research and historical context.

## Repository Structure

```
docs/           Design research and notes
scripts/        Build scripts (placeholder)
```

## Related Repositories

| Repository | Description |
|---|---|
| [sw-cor24-emulator](https://github.com/sw-embed/sw-cor24-emulator) | COR24 emulator + ISA |
| [sw-cor24-assembler](https://github.com/sw-embed/sw-cor24-assembler) | COR24 assembler |
| [sw-cor24-project](https://github.com/sw-embed/sw-cor24-project) | Ecosystem hub |

## License

See repository for license details.
