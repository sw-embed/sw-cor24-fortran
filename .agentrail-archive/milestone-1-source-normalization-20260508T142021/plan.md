Milestone 1: Source Normalization

Create the repo skeleton and implement the FTI-0 source normalizer.

Steps:
1. create-repo-skeleton - Create snobol4/src/ with empty .sno placeholder files, examples/ with sample .f files, plsw/runtime/ and plsw/generated/ directories, snobol4/tests/ directories
2. implement-normalize - Implement normalize.sno: read fixed-form .f source, detect comments (C or * in col 1), extract label field (cols 1-5), detect continuation (col 6), assemble logical statements from continued lines, preserve source line mapping, produce normalized statement records
3. normalize-tests - Create golden-file tests for normalize.sno covering: comments, labels, continuation lines, blank lines, column rules (ignore beyond col 72), multi-line statements, source line mapping
4. integrate-driver - Wire normalize.sno into driver.sno with -dump-lines output mode, verify end-to-end from .f input to normalized statement listing