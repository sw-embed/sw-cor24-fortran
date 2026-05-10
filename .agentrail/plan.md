Revert the * XXX dcsno-funcall-arithmetic workaround sites in
snobol4/src/normalize.sno now that dcsno's in-arg fix has shipped
(snobol4.lgo 2026-05-10 11:24, sha 8756d420...). The bare inline
forms SUBSTR(X, SIZE(X), 1) and SUBSTR(X, 1, SIZE(X) - 1) now work
correctly.

Single step. Mechanical revert -- read each XXX site, replace the
extract-to-temp pattern with the original inline form, run
scripts/test-normalize.sh, confirm 8/8 still passes.