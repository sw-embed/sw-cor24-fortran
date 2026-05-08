Add a regression test that exercises the full Path A pipeline and
diffs the output against the expected string. Place at
scripts/test-hello.sh (matches the test-normalize.sh pattern from
docs/architecture.md):

    scripts/fortran examples/hello.f > $tmp/hello.s
    cor24-asm $tmp/hello.s -o $tmp/hello.lgo
    cor24-emu --lgo $tmp/hello.lgo --quiet --speed 0 -n 1000000

Expected stdout: literal "Hello, World!\n".

Test should:
- exit 0 on success
- exit 1 with a diff on failure
- exit 2 if cor24-asm or cor24-emu missing on PATH

Also add an examples/hello.expected file (plain text) holding the
expected pipeline output. The test script diffs against it.

Make scripts/test-hello.sh executable.