Wire the normalization phase into driver.sno and verify end-to-end functionality.

1. Update driver.sno to:
   - Accept command-line arguments: input file path and optional flags
   - Support -dump-lines flag to output normalized statements
   - Read a .f file and invoke normalize.sno
   - Print normalized statement listing to stdout
   - Handle errors gracefully (file not found, invalid source form)

2. Verify end-to-end by running:
   snobol4 snobol4/src/driver.sno -dump-lines examples/hello.f
   And check that output matches expected normalized form.

3. Verify all four example files produce correct normalized output:
   - examples/hello.f
   - examples/sum10.f
   - examples/goto1.f
   - examples/array1.f

4. Update AGENTS.md if any build/run commands changed.

5. Update docs/architecture.md if any phase interfaces were refined during implementation.

This completes Milestone 1: Source Normalization.