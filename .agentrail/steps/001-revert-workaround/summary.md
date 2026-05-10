Reverted normalize.sno's six * XXX dcsno-funcall-arithmetic sites
after dcsno's pr/builtin-arg-expressions shipped (snobol4.lgo
8756d420..., 11:24). Bare inline forms work: SUBSTR(X, 1, SIZE(X)-1)
and SUBSTR(X, SIZE(X), 1).

Discovered residual double-nesting bug while verifying: predicate
with nested SUBSTR whose own arg is SIZE(...) -- e.g. IDENT(SUBSTR(T,
SIZE(T), 1), Y) -- always succeeds regardless of values. Two of
normalize.sno's IDENT calls hit this. Applied minimal workaround
(extract SIZE to N first, marked * XXX dcsno-ident-double-nested-arg).

normalize.sno: -23 lines net vs the previous full workaround.
Two N = SIZE(...) lines remain.

Updated tools/briefs/dcsno-funcall-arithmetic.md with the
"2026-05-10T11:24: in-arg fix shipped (mostly); residual
double-nesting bug" section: full repro, scope, workaround, likely
root cause hint.

scripts/test-normalize.sh: 8/8 passed.