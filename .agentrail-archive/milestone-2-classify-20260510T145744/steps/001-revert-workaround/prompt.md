git grep -n 'XXX dcsno-funcall-arithmetic' snobol4/src/ to enumerate
the 6 workaround sites in normalize.sno. For each, replace the
extract-to-temp pattern with the inline form:

  WAS:
        * XXX dcsno-funcall-arithmetic: extract SIZE before arith
        SZ = SIZE(LBL)
        SZ = SZ - 1
        LBL = SUBSTR(LBL, 2, SZ)
  NOW:
        LBL = SUBSTR(LBL, 2, SIZE(LBL) - 1)

Three rstrip/lstrip/trim-label loops affected. Update the docstring
"Workaround:" section to note the workaround was removed after the
dcsno fix shipped.

Acceptance:
- git grep finds zero remaining 'XXX dcsno-funcall-arithmetic' marks
- scripts/test-normalize.sh still 8/8
- scripts/test-classify.sh untouched (classify.sno doesn't use the
  workaround pattern)