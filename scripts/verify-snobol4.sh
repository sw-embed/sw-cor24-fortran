#!/usr/bin/env bash
# verify-snobol4.sh -- gate that confirms the deployed SNOBOL4
# interpreter behaves the way FTI-0's compiler assumes.
#
# Runs snobol4/tests/builtins/test_builtins.sno through the canonical
# `snobol4` wrapper and diffs the program's UART output against
# snobol4/tests/builtins/test_builtins.expected.
#
# Invocation pattern (canonical, post-dcsno-bootstrap +
# dcemu-lgo-load-binary-merge):
#
#     snobol4 --load-binary <prog>.sno@0x080000 --entry 0 \
#             --quiet --speed 0 -n 100000000 -t 60
#
# - The `snobol4` wrapper resolves to `cor24-emu --lgo snobol4.lgo`
#   plus whatever args we pass.
# - `--load-binary <prog>@0x080000` puts the SNOBOL4 source where the
#   interpreter looks for it.
# - `--entry 0` matches the snobol4.lgo's entry point.
# - `--quiet` makes cor24-emu emit the guest's UART TX as plain text
#   on stdout; loader/exec framing goes to stderr.
#
# Exit codes:
#   0 -- pass: SIZE / SUBSTR / CHAR all behave as expected
#   1 -- fail: program output differs from expected
#   2 -- toolchain prereq missing (snobol4 wrapper not on PATH, or
#        fixture absent from the repo)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_DIR="$REPO_DIR/snobol4/tests/builtins"
TEST_SNO="$TEST_DIR/test_builtins.sno"
EXPECTED="$TEST_DIR/test_builtins.expected"

if ! command -v snobol4 >/dev/null 2>&1; then
    echo "verify-snobol4: PREREQ MISSING -- 'snobol4' wrapper not on PATH." >&2
    echo "  See docs/snobol4-blockers.md and tools/briefs/dcsno-bootstrap-snobol4-toolchain.md." >&2
    exit 2
fi

if [ ! -f "$TEST_SNO" ] || [ ! -f "$EXPECTED" ]; then
    echo "verify-snobol4: PREREQ MISSING -- fixture absent under $TEST_DIR" >&2
    exit 2
fi

# cor24-emu --quiet promises "UART TX on stdout; logs to stderr" but
# leaks `Loaded N bytes from ...` lines onto stdout. Strip them so the
# captured output is just the SNOBOL4 program's UART TX. Worth a small
# follow-up brief to dcemu about classifying loader messages as logs.
ACTUAL=$(snobol4 --load-binary "$TEST_SNO@0x080000" --entry 0 \
                 --quiet --speed 0 -n 100000000 -t 60 2>/dev/null \
         | grep -v '^Loaded ')

DIFF_OUT=$(mktemp)
trap 'rm -f "$DIFF_OUT"' EXIT

if printf '%s\n' "$ACTUAL" | diff -u "$EXPECTED" - >"$DIFF_OUT"; then
    echo "verify-snobol4: OK -- SIZE/SUBSTR/CHAR behave as expected."
    exit 0
fi

echo "verify-snobol4: FAIL -- output differs from expected:" >&2
cat "$DIFF_OUT" >&2
exit 1
