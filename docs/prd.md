# Product Requirements Document

## Product name

**FTI-0**  
FORTRAN Teaching Integer subset, revision 0.

## Tagline

A small educational FORTRAN subset compiler in SNOBOL4 targeting PL/SW.

## Purpose

FTI-0 exists to provide a small, historically inspired, educational compiler project that is:

- understandable
- testable
- incrementally buildable
- suitable for demonstration and experimentation
- compatible with a larger toolchain centered around PL/SW and COR24-related systems

The compiler implementation language is **SNOBOL4**.  
The initial code generation target is **PL/SW**.

## Users

Primary users are:

- the project author
- language and compiler experimenters
- people interested in small historical language subsets
- users who want inspectable compiler output rather than opaque code generation

## Core value

The core value of the project is not full FORTRAN compatibility.  
The core value is:

- educational compiler construction
- fixed-form source handling
- explicit statement normalization
- readable lowering into PL/SW
- a platform for later experiments such as software floating point

## FTI-0 scope

FTI-0 is an integer-only subset with fixed-form source and explicit declarations.

Initial supported capabilities:

- `PROGRAM`
- `INTEGER`
- `DIMENSION`
- assignment
- `GOTO`
- counted `DO`
- `CONTINUE`
- simple conditional transfer form
- `PRINT *`
- `READ *`
- `STOP`
- `END`

## Goals

### G1. Fixed-form educational subset

The compiler shall accept a narrow, documented, fixed-form source format inspired by classic FORTRAN.

### G2. Clear compiler phases

The compiler shall be structured into explicit passes:

- normalization
- classification
- expression parsing
- semantic analysis
- lowering
- PL/SW emission

### G3. Readable emitted PL/SW

The compiler shall generate PL/SW that is intended to be read and debugged by humans.

### G4. Strong observability

The compiler shall support intermediate dumps for:

- normalized statements
- symbols
- labels
- lowered form
- emitted PL/SW

### G5. Incremental development

The implementation shall be milestone-driven, with working behavior at each step.

## Non-goals

FTI-0 does not initially attempt to provide:

- full FORTRAN IV/66/77 compatibility
- floating point types
- formatted I/O
- `COMMON`
- `EQUIVALENCE`
- `DATA`
- subprogram linkage
- optimization
- multidimensional arrays
- exact compatibility with vendor quirks

## Constraints

### C1. Implementation language

The compiler implementation language is SNOBOL4.

### C2. First target

The first target language is PL/SW.

### C3. Simple semantics

Semantics should favor clarity over historical edge-case fidelity.

### C4. Explicit declarations

Initial versions shall require explicit declarations for variables.

## Success criteria

Phase 1 success:

- a small source file can be normalized and classified

Phase 2 success:

- a small assignment-and-print program can be translated to PL/SW

Phase 3 success:

- labels, branches, and counted loops compile correctly

Phase 4 success:

- one-dimensional integer arrays compile correctly

## Out of scope for now

Floating point support is explicitly deferred pending one or more of:

- a software floating point library in PL/SW
- a C compiler path with software floating point
- a later FTI subset revision
