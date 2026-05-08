Saga: fortran-hello-world (the second of three sagas unblocking the
live-demo at https://sw-embed.github.io/web-sw-cor24-fortran/).

Brief: /disk1/github/softwarewrighter/devgroup/tools/briefs/dcftn-fortran-hello-world.md
Owner: dcftn
Branch: pr/fortran-hello-world
Critical path: dcsno ships -> dcftn ships hello.lgo -> dwftn deploys.

Approach: Path A (per the brief) -- hand-write hello.s as a fixture
rather than wait for the full FTI-0 compiler. Smallest possible
Fortran program that prints "Hello, World!" via UART. Updates
scripts/fortran to short-circuit on hello.f for now. Compiler effort
continues in a separately-resumed milestone-1-source-normalization
saga (currently archived).

Steps:
1. write-hello-asm -- author examples/hello.s by adapting the tc24r
   demo's UART putc/puts pattern. The string is "Hello, World!\n\0".
2. assemble-and-verify -- cor24-asm hello.s -> examples/hello.lgo,
   then cor24-emu --lgo hello.lgo and capture/diff against expected
   output. Both .s and .lgo committed (.lgo is the demo deliverable
   for dwftn).
3. wire-fortran-shortcircuit -- update scripts/fortran so
   `scripts/fortran examples/hello.f` emits the prebaked
   examples/hello.s (Path A: short-circuit). When the compiler is
   ready (separate saga), this short-circuit is removed.
4. add-regression-test -- a test (scripts/test-hello.sh or similar)
   that runs the full pipeline and diffs against expected output.
5. doc-and-readme -- README mention of the live-demo path; brief
   scope notes in docs/ about Path A short-circuit.