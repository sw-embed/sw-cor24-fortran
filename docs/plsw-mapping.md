# PL/SW Mapping

## Overview

FTI-0 compiles to PL/SW as its initial target language.

This document defines the source-to-target mapping contract. The mapping is intended to produce readable PL/SW suitable for inspection and debugging.

## Design goals

The mapping should:

- preserve source intent clearly
- avoid unnecessary temporary values where possible
- generate stable names
- isolate runtime-dependent behavior in helper calls

## Naming conventions

### User variables

User variables are mapped with an `F_` prefix.

Examples:

- `I` -> `F_I`
- `N` -> `F_N`
- `SUM` -> `F_SUM`
- `A` -> `F_A`

### Source labels

FORTRAN source labels map to PL/SW labels with an `L_` prefix.

Example:

- `100` -> `L_100`

### Generated internal labels

Generated compiler labels use a distinct naming scheme such as:

- `L_DO_TEST_1`
- `L_DO_EXIT_1`

### Temporaries

Compiler-generated temporaries use:

- `T_1`
- `T_2`

## Declarations

### INTEGER scalar

FTI-0 source:

```fortran
      INTEGER I
```

Conceptual PL/SW target:

```plsw
DCL F_I FIXED BIN(24);
```

Exact PL/SW declaration syntax may be adjusted to match supported PL/SW rules.

### DIMENSION array

FTI-0 source:

```fortran
      DIMENSION A(10)
```

Conceptual PL/SW target:

```plsw
DCL F_A(10) FIXED BIN(24);
```

## Assignment mapping

FTI-0 source:

```fortran
      I = N + 1
```

PL/SW:

```plsw
F_I = F_N + 1;
```

Array assignment:

```fortran
      A(I) = I * 10
```

PL/SW:

```plsw
F_A(F_I) = F_I * 10;
```

## Branch mapping

### GOTO

FTI-0 source:

```fortran
      GOTO 100
```

PL/SW:

```plsw
GOTO L_100;
```

### IF (...) GOTO

FTI-0 source:

```fortran
      IF (I) GOTO 100
```

PL/SW:

```plsw
IF F_I <> 0 THEN GOTO L_100;
```

Exact relational syntax may be adapted to actual PL/SW supported syntax.

## DO loop mapping

FTI-0 source:

```fortran
      DO 100 I = 1, N
```

Conceptual PL/SW:

```plsw
F_I = 1;
L_DO_TEST_1:
IF F_I > F_N THEN GOTO L_DO_EXIT_1;
...
L_100:
F_I = F_I + 1;
GOTO L_DO_TEST_1;
L_DO_EXIT_1:
```

The compiler may emit equivalent structure with different generated labels.

## I/O mapping

FTI-0 uses runtime helper routines for I/O.

### PRINT

FTI-0 source:

```fortran
      PRINT *, I, SUM
```

Conceptual PL/SW:

```plsw
CALL FTI_PRINT_INT(F_I);
CALL FTI_PRINT_INT(F_SUM);
CALL FTI_PRINT_NL();
```

### READ

FTI-0 source:

```fortran
      READ *, I, N
```

Conceptual PL/SW:

```plsw
CALL FTI_READ_INT(F_I);
CALL FTI_READ_INT(F_N);
```

### STOP

FTI-0 source:

```fortran
      STOP
```

Conceptual PL/SW:

```plsw
CALL FTI_STOP();
```

## Runtime contract

The initial runtime surface is expected to contain helpers such as:

- `FTI_PRINT_INT`
- `FTI_PRINT_NL`
- `FTI_READ_INT`
- `FTI_STOP`

These may later be expanded or renamed based on PL/SW conventions.

## Integer semantics

FTI-0 is integer-only.

The exact storage width may depend on PL/SW and target runtime constraints, but the likely practical execution model is a signed integer aligned with COR24-oriented runtime assumptions.

## Source comments

The emitter may optionally preserve original source lines as comments in generated output to aid debugging.

Example:

```plsw
/* FTI-0: I = N + 1 */
F_I = F_N + 1;
```

## Unsupported mappings for now

No initial mapping is defined for:

- floating point
- formatted I/O
- subprogram linkage
- `COMMON`
- `EQUIVALENCE`
- multidimensional arrays
