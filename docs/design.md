# Design

## Overview

This document describes the concrete design of the FTI-0 compiler.

The compiler is intentionally small and explicit. It does not rely on hidden or overly clever transformations. The design emphasizes named phases, normalized records, and readable generated PL/SW.

## Source form

FTI-0 uses a restricted fixed-form source layout.

### Columns

- columns 1-5: optional numeric label
- column 6: continuation marker
- columns 7-72: statement text
- column 1 containing `C` or `*`: comment line

Anything beyond column 72 is ignored in the first implementation.

## Statement model

Each logical statement should be represented internally as a record with at least:

- statement id
- source line mapping
- optional label
- statement kind
- statement-specific payload

Example conceptual record:

```text
stmt_id=7
label=100
kind=DO
payload:
  var=I
  start_expr=1
  limit_expr=N
  step_expr=1
  end_label=100
```

## Statement kinds

Initial kinds:

- `PROGRAM`
- `INTEGER_DECL`
- `DIMENSION_DECL`
- `ASSIGN`
- `GOTO`
- `IF_GOTO`
- `DO`
- `CONTINUE`
- `PRINT`
- `READ`
- `STOP`
- `END`

## Symbol table design

Each symbol entry should include:

- source name
- generated PL/SW name
- class: scalar or array
- type: integer
- array length if applicable
- declaration source location

Example:

```text
name=I
plsw_name=F_I
class=scalar
type=integer
```

For arrays:

```text
name=A
plsw_name=F_A
class=array
type=integer
extent=10
```

## Label table design

Each label entry should include:

- FORTRAN label number
- generated PL/SW label name
- defining statement
- references

Example:

```text
fortran_label=100
plsw_label=L_100
defined_at=stmt_9
referenced_by=stmt_4,stmt_8
```

## Expression design

Expressions should be parsed separately from statement classification.

Supported node kinds:

- integer literal
- scalar variable reference
- array reference
- unary operator
- binary operator

Supported operators:

- unary `-`
- binary `+`
- binary `-`
- binary `*`
- binary `/`

Parentheses are supported.

## Expression parsing approach

Recommended implementation approach:

- tokenize expression text
- convert with precedence handling
- build expression nodes

Either precedence climbing or shunting-yard is acceptable.  
The preferred initial design is **shunting-yard** because it is easy to debug with dump output.

## Lowered normalized form

Before emission, control-flow-heavy statements should be lowered.

Lowered forms may include:

- label
- assignment
- conditional branch
- unconditional branch
- print call
- read call
- stop call

This form is internal to the compiler and does not need a stable file format.

## DO loop lowering

A counted DO loop:

```fortran
      DO 100 I = 1, N
```

should lower to an explicit sequence conceptually equivalent to:

```text
I := 1
L_DO_TEST_1:
if I > N goto L_DO_EXIT_1
... body ...
L_100:
I := I + 1
goto L_DO_TEST_1
L_DO_EXIT_1:
```

The exact generated labels may differ, but the semantics must be documented and consistent.

## Conditional transfer design

For the first version, prefer a simplified conditional transfer form rather than classic arithmetic IF.

Recommended supported form:

```fortran
      IF (expr) GOTO label
```

with semantics:

- branch if `expr` is nonzero

Arithmetic IF may be added later as a separate milestone.

## I/O design

Initial I/O is intentionally small.

### Supported forms

- `PRINT *, expr-list`
- `READ *, var-list`

### Emission strategy

Generated PL/SW should call runtime helpers such as:

- `FTI_PRINT_INT(x)`
- `FTI_PRINT_NL()`
- `FTI_READ_INT(x)`
- `FTI_STOP()`

This keeps the generated code simple.

## Naming conventions

To avoid collisions and keep generated code readable:

- user scalar or array names map to `F_<name>`
- generated internal labels map to `L_<n>` or `L_<fortran_label>`
- generated temporaries map to `T_<n>`

Examples:

- `I` -> `F_I`
- `A` -> `F_A`
- source label `100` -> `L_100`

## Declaration policy

FTI-0 requires explicit declaration of variables through:

- `INTEGER`
- `DIMENSION`

No implicit typing is enabled in the initial version.

## Unsupported constructs in design v0

Not supported yet:

- multidimensional arrays
- subroutines
- functions
- `COMMON`
- `EQUIVALENCE`
- floating-point types
- `FORMAT`
- `DATA`
- computed GOTO
