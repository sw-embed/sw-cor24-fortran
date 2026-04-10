# Plan

## Overview

This plan is milestone-driven. Each milestone should produce something observable and testable.

## Milestone 0 — Repository and documents

### Goals

- establish project naming
- define repository structure
- create architectural and subset documentation
- create sample input programs

### Deliverables

- README
- PRD
- architecture
- design
- plan
- subset definition
- PL/SW mapping
- test strategy
- example `.f` files
- SNOBOL4 module placeholders

## Milestone 1 — Source normalization

### Goals

- read fixed-form source
- detect comments
- extract labels
- merge continuation lines
- produce logical statements

### Deliverables

- `normalize.sno`
- normalized statement dump mode
- tests for comments, labels, continuation, column rules

### Success criteria

Given a small input file, the compiler emits a correct normalized statement listing.

## Milestone 2 — Statement classification

### Goals

- identify supported statement kinds
- split declarations and I/O lists
- isolate expression text for later parsing

### Deliverables

- `classify.sno`
- classified statement dump mode
- tests per statement form

### Success criteria

A small file with declarations, assignments, and terminators is correctly classified.

## Milestone 3 — Expression parsing

### Goals

- tokenize and parse arithmetic expressions
- support literals, variables, arrays, unary minus, binary ops, parentheses

### Deliverables

- `expr.sno`
- expression dump mode
- precedence tests

### Success criteria

Expressions in assignment and print statements parse correctly.

## Milestone 4 — Symbols and labels

### Goals

- build symbol table
- build label table
- report duplicate declarations and undefined labels
- distinguish scalar and array usage

### Deliverables

- `symbols.sno`
- `labels.sno`
- symbol/label dump modes
- semantic tests

### Success criteria

Compiler rejects malformed inputs and accepts valid ones with correct symbol/label tables.

## Milestone 5 — Lowering

### Goals

- lower high-level statements to simple explicit control-flow forms
- make loop expansion visible

### Deliverables

- `lower.sno`
- lowered form dump mode
- loop lowering tests

### Success criteria

Assignments, branches, and counted loops lower consistently.

## Milestone 6 — PL/SW emission

### Goals

- emit readable PL/SW
- generate declarations, labels, branches, runtime calls
- preserve useful source correspondence

### Deliverables

- `emit_plsw.sno`
- output `.msw` or equivalent generated text
- snapshot tests

### Success criteria

Hello-world-like integer examples compile to plausible PL/SW.

## Milestone 7 — End-to-end examples

### Goals

- compile a small suite of example programs
- validate emitted PL/SW for readability and correctness

### Deliverables

- working example set
- generated PL/SW checked into or regenerated under scripts
- smoke test script

### Success criteria

The example suite passes regression checks.

## Milestone 8 — Arrays and richer control flow

### Goals

- one-dimensional array support
- loop/indexing validation
- refine conditional forms

### Deliverables

- array tests
- updated emitter
- updated runtime helpers if required

## Deferred milestones

Deferred until later:

- arithmetic IF
- subroutines
- integer functions
- multidimensional arrays
- software floating point
- REAL support
- formatted I/O
