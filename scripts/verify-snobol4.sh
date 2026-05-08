#!/usr/bin/env bash
# verify-snobol4.sh -- gate that confirms the deployed SNOBOL4
# interpreter behaves the way FTI-0's compiler assumes.
#
# Runs snobol4/tests/builtins/test_builtins.sno via cor24-emu and
# diffs the resulting UART output against test_builtins.expected.
#
# Exit codes:
#   0 -- pass: SIZE, SUBSTR, CHAR all behave as expected
#   1 -- fail: output differs from expected
#   2 -- blocked: snobol4.lgo not deployed yet (toolchain prerequisite)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_DIR="$REPO_DIR/snobol4/tests/builtins"
TEST_SNO="$TEST_DIR/test_builtins.sno"
EXPECTED="$TEST_DIR/test_builtins.expected"

if [ -z "${TOOLROOT:-}" ]; then
    if PL_SW_PATH=$(command -v pl-sw 2>/dev/null); then
        TOOLROOT="$(dirname "$PL_SW_PATH")"
    fi
fi
if [ -z "${TOOLROOT:-}" ]; then
    echo "verify-snobol4: error: TOOLROOT not set and pl-sw not on PATH." >&2
    exit 2
fi

LGO="$TOOLROOT/../lib/cor24/snobol4.lgo"

if [ ! -f "$LGO" ]; then
    echo "verify-snobol4: BLOCKED -- $LGO not deployed."
    echo "  Cannot verify SIZE/SUBSTR/CHAR behavior end-to-end until the dcsno"
    echo "  saga in sw-embed/sw-cor24-snobol4 produces and installs"
    echo "  snobol4.lgo at the path above."
    echo "  See: docs/snobol4-blockers.md"
    exit 2
fi

if [ ! -f "$TEST_SNO" ] || [ ! -f "$EXPECTED" ]; then
    echo "verify-snobol4: error: missing fixture under $TEST_DIR" >&2
    exit 1
fi

# Capture the SNOBOL4 program's UART output. cor24-emu emits framing
# lines around the program output ("UART output:" prefix and an
# "Executed N instructions" trailer). Strip those to get the raw
# program output.
RAW=$(cor24-emu --lgo "$LGO" --uart-file "$TEST_SNO" \
                --speed 0 -n 100000000 -t 60 2>&1)
ACTUAL=$(printf '%s\n' "$RAW" \
    | sed -n '/^UART output:/,/^Executed /{/^Executed /d;p;}' \
    | sed '1s/^UART output: //')

if [ -z "$ACTUAL" ]; then
    echo "verify-snobol4: FAIL -- no UART output captured." >&2
    echo "Raw cor24-emu output:" >&2
    printf '%s\n' "$RAW" >&2
    exit 1
fi

if printf '%s\n' "$ACTUAL" | diff -u "$EXPECTED" - >/tmp/verify-snobol4.diff; then
    echo "verify-snobol4: OK -- SIZE/SUBSTR/CHAR behave as expected."
    rm -f /tmp/verify-snobol4.diff
    exit 0
else
    echo "verify-snobol4: FAIL -- output differs from expected." >&2
    echo "" >&2
    cat /tmp/verify-snobol4.diff >&2
    exit 1
fi
