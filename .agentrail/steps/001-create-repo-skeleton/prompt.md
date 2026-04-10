Create the repository skeleton for the FTI-0 compiler project. This includes:

1. Create directory structure:
   - snobol4/src/
   - snobol4/tests/normalize/
   - snobol4/tests/classify/
   - snobol4/tests/expr/
   - snobol4/tests/lower/
   - snobol4/tests/emit/
   - examples/
   - plsw/runtime/
   - plsw/generated/

2. Create empty SNOBOL4 compiler phase files in snobol4/src/:
   - driver.sno (stub: reads options, prints 'FTI-0 compiler not yet implemented')
   - normalize.sno (stub)
   - classify.sno (stub)
   - expr.sno (stub)
   - symbols.sno (stub)
   - labels.sno (stub)
   - lower.sno (stub)
   - emit_plsw.sno (stub)
   - errors.sno (stub)

3. Create example FTI-0 source files in examples/:
   - hello.f (PROGRAM HELLO, INTEGER I, I=42, PRINT *, I, STOP, END)
   - sum10.f (PROGRAM SUM10, INTEGER I S, S=0, DO 100 I=1,10, S=S+I, 100 CONTINUE, PRINT *, S, STOP, END)
   - goto1.f (PROGRAM COUNT, INTEGER I, I=1, 100 PRINT *, I, I=I+1, IF (I-6) GOTO 100, STOP, END)
   - array1.f (PROGRAM ARR1, INTEGER I, DIMENSION A(5), DO 100 I=1,5, A(I)=I*10, 100 CONTINUE, PRINT *, A(3), STOP, END)

4. Create empty runtime placeholder: plsw/runtime/fti0_runtime.msw (with a comment header)

Use fixed-form FORTRAN column conventions in the .f files (cols 1-5 for labels, col 6 for continuation, cols 7-72 for statement text).

After creating all files, verify the structure matches docs/architecture.md and the repository structure in AGENTS.md.