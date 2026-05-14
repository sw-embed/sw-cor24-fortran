Adapt `scripts/fortran` to dcsno's new load-address convention,
unblocking the install of the rebuilt `snobol4.{bin,lgo}` from
sw-cor24-snobol4 main `c675774`+.

Per `tools/briefs/dcftn-classify-empty-on-new-snobol4.md`:
mike's install of the new snobol4 (md5 `837b217e`, the post-
`pr/cap-and-pattern-fixes` + `pr/more-fixes` build) made all 4
demos produce 0-byte classify output. The brief hypothesized
dcftn's .sno code was relying on the old pattern-engine bugs.

Bisecting today: the .sno code is fine. Tested every phase
against the new snobol4 with the documented new load addresses
(`source@0xE0000`, `data@0xF0000`, per dcsno's
`scripts/run-snobol4.sh`) and every demo passes byte-identical
to the old-snobol4 output:

  hello/print-int/print-var/add/goto1/sum10/array1/factorial/
  fibonacci/fizzbuzz -- all 10 pass.

Also verified the dcsno new-fixes work as advertised under the
new build:
  OUTPUT = 'x' SIZE('hello') 'y'    -> 'x5y'  (concat-after-funcall fixed)
  :(L_TEST) ... L_TEST OUTPUT = '..' -> resolves correctly  (underscore label fixed)

Root cause of the install break: `scripts/fortran` hard-coded
`@0x80000` / `@0x90000` from the old snobol4. Those addresses
are now empty memory in the new snobol4's layout, so it reads
garbage and emits nothing.

Fix: parameterise the addresses in scripts/fortran via env
vars with the new convention as default. Old snobol4 callers
(if any are still around) can override via `SNOBOL4_SRC_ADDR=`
and `SNOBOL4_DAT_ADDR=`.

Steps:
1. update-fortran-script-addrs -- parameterise source/data
   load addresses; default to new convention (`0xE0000` / `0xF0000`).
   Verify all 10 demos still pass against the rolled-back old
   snobol4 with the explicit-old-address env vars, and that the
   pipeline produces the expected output structure against the
   new snobol4 build.
2. dgmark-and-pr.

Follow-on (separate saga): once mike installs the new snobol4
and updates `work/bin/snobol4`, the dcsno-source-byte-cap fix
means `emit_asm.sno` can inline the runtime support routines
(`_start/_halt/_putc/_puts/_putint/_aindex`) directly instead
of using the marker + awk-splice workaround. That's the actual
removal of the runtime-splice workaround the user asked about.
Will land as m13.
