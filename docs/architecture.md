# Architecture

## Overview

FTI-0 is a source-to-source compiler:

```text
FTI-0 source
  -> normalization
  -> statement classification
  -> expression parsing
  -> semantic analysis
  -> lowering
  -> PL/SW emission
```

The implementation language is SNOBOL4.  
The emitted target language is PL/SW.

## Architectural priorities

The architecture prioritizes:

- phase separation
- inspectability
- deterministic output
- explicit intermediate representations
- easy extension in later revisions

## Compiler phases

### 1. Driver

Responsibilities:

- read options
- open input/output files
- coordinate passes
- select dump modes
- report final success/failure

Primary file:
- `snobol4/src/driver.sno`

### 2. Normalization

Responsibilities:

- read fixed-form physical lines
- detect comments
- extract label field
- process continuation
- assemble logical statements
- preserve source line mapping

Output:
- normalized statement records

Primary file:
- `snobol4/src/normalize.sno`

### 3. Statement classification

Responsibilities:

- identify statement kind
- split major fields
- route expressions and lists to specialized parsing

Recognized statement families include:

- program start
- declarations
- assignment
- branch
- loop
- I/O
- terminators

Primary file:
- `snobol4/src/classify.sno`

### 4. Expression parsing

Responsibilities:

- tokenize expressions
- parse precedence and parentheses
- construct expression trees or equivalent records

Supported expression forms in FTI-0:

- integer literals
- scalar references
- array references
- unary minus
- `+ - * /`

Primary file:
- `snobol4/src/expr.sno`

### 5. Semantic analysis

Responsibilities:

- symbol declaration tracking
- scalar vs array validation
- label definition/reference tracking
- duplicate declaration detection
- undefined label detection
- statement-specific checks

Primary files:
- `snobol4/src/symbols.sno`
- `snobol4/src/labels.sno`

### 6. Lowering

Responsibilities:

- convert parsed statements into a smaller normalized control-flow-oriented form
- make loop expansion explicit
- assign generated temporary names and internal labels

Lowering is deliberately simple and not intended as a stable external IR.

Primary file:
- `snobol4/src/lower.sno`

### 7. PL/SW emission

Responsibilities:

- map symbols to PL/SW declarations
- emit readable labels and branches
- emit runtime calls for basic I/O and stop
- preserve useful comments/source mapping when practical

Primary file:
- `snobol4/src/emit_plsw.sno`

## Data flow

### Source input

Input is a fixed-form `.f` source file.

### Intermediate forms

The compiler uses several conceptual representations:

1. physical line records
2. logical normalized statement records
3. classified statement records
4. expression nodes
5. semantic tables
6. lowered normalized statements
7. PL/SW output text

## Error model

Errors should be reported with:

- phase name
- source line number if available
- original or normalized source text if useful
- concise explanation

Example classes:

- invalid fixed-form source
- unknown statement form
- malformed expression
- duplicate declaration
- use of undeclared variable
- undefined label
- type/class mismatch

## Observability modes

Recommended dump modes:

- `-dump-lines`
- `-dump-statements`
- `-dump-symbols`
- `-dump-labels`
- `-dump-lowered`
- `-dump-plsw`

These modes are essential for incremental compiler development.

## Target architecture relationship

FTI-0 does not directly target COR24 machine code in the first stage.

Instead:

```text
FTI-0
  -> PL/SW
  -> later PL/SW toolchain stages
```

This keeps the frontend stable while backend and runtime choices evolve.

## Rationale for PL/SW target

PL/SW is chosen as the first target because it provides:

- inspectable output
- alignment with the broader toolchain
- a better first stage than direct assembly emission
- a future path toward integer and later floating-point runtime support
