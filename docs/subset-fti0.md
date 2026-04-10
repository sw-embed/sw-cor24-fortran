# FTI-0 Language Subset

## Overview

FTI-0 is an educational, integer-only, fixed-form subset inspired by classic FORTRAN.

It is intentionally smaller and simpler than historical FORTRAN dialects. The goal is to support a teachable compiler pipeline rather than to reproduce every legacy feature or edge case.

## Source format

FTI-0 source is fixed-form.

### Columns

- columns 1-5: optional numeric statement label
- column 6: continuation marker
- columns 7-72: statement body
- comment lines begin with `C` or `*` in column 1

Anything beyond column 72 is ignored in version 0.

## Case

The initial implementation may normalize identifiers and keywords to uppercase.

## Program structure

A small program typically has the form:

```fortran
      PROGRAM HELLO
      INTEGER I
      I = 42
      PRINT *, I
      STOP
      END
```

## Declarations

### INTEGER

Declares integer scalar variables.

Example:

```fortran
      INTEGER I, N, SUM
```

### DIMENSION

Declares one-dimensional integer arrays.

Example:

```fortran
      DIMENSION A(10)
```

In FTI-0, arrays are:

- integer arrays
- one-dimensional only
- indexed from 1 to extent

## Statements

### PROGRAM

Defines program name.

Example:

```fortran
      PROGRAM SUM10
```

### Assignment

Example:

```fortran
      I = 3
      SUM = SUM + I
      A(I) = I * 10
```

### GOTO

Example:

```fortran
      GOTO 100
```

### IF (...) GOTO

FTI-0 initially supports the simple form:

```fortran
      IF (expr) GOTO 100
```

Semantics:
- if `expr` is nonzero, branch to label 100

### DO

Counted DO with optional default step of 1.

Example:

```fortran
      DO 100 I = 1, 10
```

A later revision may add explicit step:

```fortran
      DO 100 I = 1, 10, 2
```

### CONTINUE

Example:

```fortran
  100 CONTINUE
```

### PRINT

Only list-directed style is initially supported.

Example:

```fortran
      PRINT *, I
      PRINT *, I, SUM, A(3)
```

### READ

Only list-directed style is initially supported.

Example:

```fortran
      READ *, I, N
```

### STOP

Example:

```fortran
      STOP
```

### END

Example:

```fortran
      END
```

## Expressions

Supported expression forms:

- integer literal
- scalar variable
- array element reference
- unary minus
- binary `+ - * /`
- parentheses

Examples:

```fortran
      I = 1
      N = (A(3) + 2) * 5
      SUM = SUM + I
      X = -I
```

## Semantics

### Variables

All variables must be explicitly declared.

FTI-0 does not initially support implicit typing.

### Types

Only integer values are supported.

### Arrays

Only one-dimensional arrays are supported in FTI-0.

### Division

Integer division semantics are target-defined but intended to behave as truncation toward zero.

## Labels

Labels are numeric and appear in columns 1-5.

Example:

```fortran
  100 CONTINUE
```

## Unsupported features

FTI-0 does not initially support:

- floating point
- `REAL`, `DOUBLE PRECISION`
- `COMMON`
- `EQUIVALENCE`
- `FORMAT`
- `DATA`
- arithmetic IF
- computed GOTO
- statement functions
- subroutines and functions
- multidimensional arrays
- character or string types

## Example programs

### Hello

```fortran
      PROGRAM HELLO
      INTEGER I
      I = 42
      PRINT *, I
      STOP
      END
```

### Sum 1 to 10

```fortran
      PROGRAM SUM10
      INTEGER I, S
      S = 0
      DO 100 I = 1, 10
      S = S + I
  100 CONTINUE
      PRINT *, S
      STOP
      END
```
