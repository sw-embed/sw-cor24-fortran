Author snobol4/src/classify.sno. Reads normalized records from RAWINPUT
(loaded at INP_LOAD_ADDR = 0x090000), classifies each statement by
keyword inspection, emits the same record with a kind=<KIND> field
inserted between label= and text=:

  input:  stmt1 line=2 label= text=PROGRAM HELLO
  output: stmt1 line=2 label= kind=PROGRAM text=PROGRAM HELLO

Detection rules (first non-space token of <text>):
  PROGRAM    -> kind=PROGRAM
  INTEGER    -> kind=INTEGER_DECL
  DIMENSION  -> kind=DIMENSION_DECL
  GOTO       -> kind=GOTO
  IF         -> kind=IF_GOTO   (assume IF (expr) GOTO label form per FTI-0)
  DO         -> kind=DO
  CONTINUE   -> kind=CONTINUE
  PRINT      -> kind=PRINT
  READ       -> kind=READ
  STOP       -> kind=STOP
  END        -> kind=END
  (text contains '=' and starts with an identifier other than the
   above keywords) -> kind=ASSIGN

Use extract-to-temp idiom for any function-call arithmetic /
function-call as argument to other function call (the
dcsno-funcall-arithmetic in-arg cases are still broken on the
deployed snobol4.lgo as of 2026-05-10). Mark each site with
* XXX dcsno-funcall-arithmetic so they can be reverted later.

Acceptance: file exists, has substantive implementation (not stub),
covers all 12 kinds in comments, will be tested in step 2.