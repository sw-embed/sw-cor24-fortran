Author scripts/test-normalize.sh. The runner exercises the canonical
pattern:

    snobol4 --load-binary snobol4/src/normalize.sno@0x080000 \
            --entry 0 --uart-file <fixture>.f --quiet \
            --speed 0 -n 100000000 -t 60

For each test_*.f under snobol4/tests/normalize/, capture the
program's UART TX (stdout under --quiet, post the dcemu fix) and diff
against the matching test_*.expected.

Output per fixture: PASS or FAIL with the diff inline. Summary at the
end: N/M passed, exit 0 if all pass else 1. Exit 2 if prereqs missing
(snobol4 not on PATH, normalize.sno missing, or no fixtures).

This step authors the runner only. It does NOT debug normalize.sno
itself -- the draft has visible bugs (loops past input limit, doesn't
skip comments) which are step-004 territory. The runner must
correctly REPORT those failures so step 004 has clear signal to debug
against.

Smoke test: run the runner once and confirm:
  - prereq checks pass
  - it iterates over the 8 fixtures
  - it produces an output diff per fixture (probably all FAIL today)
  - exit 1 (with all fixtures failed)