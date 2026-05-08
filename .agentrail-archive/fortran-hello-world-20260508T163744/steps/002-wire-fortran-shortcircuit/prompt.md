Update scripts/fortran so it short-circuits for hello.f. When the
input .f is recognized as our canonical hello (e.g., basename matches
hello.f, or content matches), emit the pre-baked examples/hello.s on
stdout instead of invoking the SNOBOL4-based pipeline. For any other
input, current behavior (error pointing at docs/snobol4-blockers.md)
is preserved -- the full FTI-0 compiler is a separate parallel
effort.

Goal: this command must work end-to-end:

    scripts/fortran examples/hello.f > /tmp/hello.s
    cor24-asm /tmp/hello.s -o /tmp/hello.lgo
    cor24-emu --lgo /tmp/hello.lgo --quiet --speed 0 -n 1000000
    # prints "Hello, World!\n", exit 0

Update the wrapper's header doc-comment to reflect Path-A scope.

Acceptance:
- scripts/fortran examples/hello.f produces examples/hello.s content
  on stdout
- the three-step pipeline above completes with the expected output
- the wrapper still errors cleanly for any non-hello.f input.