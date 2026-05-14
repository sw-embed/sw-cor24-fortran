Per tools/briefs/dcftn-emit-asm-pattern-anchoring.md:
validate captured VN / SRC / token identifiers in emit_asm.sno so
that genuinely-malformed input produces `; WARN:` rather than
bogus assembly labels like `_V_+` or `_V_A(3)`.

The specific demos the brief cited (goto1.f, sum10.f, array1.f)
all work end-to-end now (m6 binary expr, m7 GOTO, m8 DO, m9
array). But the underlying unanchored-pattern issue still bites
on truly unsupported forms:

  X = -5                    (negative literal)
  X = A + B + C             (chained binary)
  PRINT *, A(I, J)          (multi-dim index)

Each can match a pattern with bogus captures and produce
unassemblable `.s`. Brief Option A (POS(0) anchoring) doesn't
work in dcsno -- tested. Brief Option B (identifier validation
of captured VN) does work and is what we'll do.

Approach: after each capture of a name-like field (VN, SRC,
T1/T2, T1IDX, ARVN, ARIDX), validate it matches the Fortran
identifier shape by re-SPANning with the alpha-digit class and
asserting the captured size equals the whole captured size:

  VN SPAN('A..Z0..9') . M  :F(BAD)
  EQ(SIZE(M), SIZE(VN))    :F(BAD)

For literal-vs-identifier IDX fields (which can be either an
integer literal OR a variable name), the dispatch already
branches on SPAN(digits); the var branch picks up the validation.

Constraint: SPAN cannot take a variable class in dcsno -- the
literal `'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'` must be inlined.
~2 statements of validation per site. Sites: KASN scalar VN,
KASNA ARVN+ARIDX, EXPRV SRC, EXPRB T1+T2, EXPRA T1+T1IDX. ~6
validation sites, ~12 new statements. Source-byte budget:
~250 bytes free under the dcsno 12,280-byte cap.

Steps:
1. add-identifier-validation -- inline the size-equality check
   at each capture site. Verify the seven existing demos
   (hello/print-int/print-var/add/goto1/sum10/array1) still
   compile and run correctly. Add a small fixture file with
   3-4 malformed lines that each produce `; WARN:`.
2. dgmark-and-pr.
