# Test Strategy

## Overview

FTI-0 should be built with visible intermediate results and regression tests at each compiler phase.

The project is small enough that golden-file style testing is appropriate.

## Testing priorities

The most important properties are:

- deterministic output
- stable phase boundaries
- readable diagnostics
- easy debugging of regressions

## Test layers

### 1. Normalization tests

Input:
- fixed-form source fragments

Expected output:
- normalized logical statements

Covers:
- comments
- labels
- continuation
- ignored trailing columns
- blank lines

### 2. Classification tests

Input:
- normalized statements

Expected output:
- statement kind and parsed statement shell

Covers:
- declarations
- assignment
- branch statements
- loop headers
- I/O
- terminators

### 3. Expression tests

Input:
- expression text

Expected output:
- token stream and/or expression tree dump

Covers:
- precedence
- unary minus
- parentheses
- array references

### 4. Semantic tests

Input:
- small programs

Expected output:
- symbol table
- label table
- diagnostics for invalid programs

Covers:
- undeclared variables
- duplicate declarations
- undefined labels
- scalar/array misuse

### 5. Lowering tests

Input:
- parsed valid programs

Expected output:
- lowered control-flow form dump

Covers:
- DO expansion
- branch normalization
- generated labels
- explicit stop behavior

### 6. Emission tests

Input:
- lowered programs

Expected output:
- PL/SW golden text

Covers:
- declarations
- labels
- assignments
- branches
- runtime helper calls

### 7. End-to-end smoke tests

Input:
- example `.f` programs

Expected output:
- generated PL/SW snapshots

## Recommended test assets

Keep examples small and purpose-specific.

Suggested examples:

- hello world integer
- sum 1..10 with DO loop
- simple array store/load
- simple goto/label program
- malformed undeclared variable example
- malformed undefined label example

## Testing style

Preferred testing style:

- golden text files for dumps
- small focused examples
- one feature per test where practical

## Diagnostics policy

Errors should be compared in tests by stable fields such as:

- phase
- source line
- error code or short message

Avoid fragile tests that depend on incidental formatting only.

## Regression policy

Whenever a new language feature is added:

- add at least one success case
- add at least one failure case
- add or update example programs if relevant
