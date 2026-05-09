#!/usr/bin/env bash
# test-normalize.sh -- run snobol4/src/normalize.sno against each
# fixture in snobol4/tests/normalize/ and diff the captured UART
# output against the matching .expected file.
#
# Canonical dcsno invocation (post-bootstrap + dcemu fixes):
#
#     snobol4 --load-binary <prog>.sno@0x080000 \
#             --load-binary <data>@0x090000 \
#             --entry 0 --quiet --speed 0 -n 100000000 -t 60
#
# - 0x080000 = INP_PROG_ADDR (the SNOBOL4 program source).
# - 0x090000 = INP_LOAD_ADDR (the runtime data file the program
#   reads via INPUT/RAWINPUT). When data is loaded here, the
#   interpreter sets INP_TTY=0 and runs in batch mode -- no
#   line-echo, no live UART_GETCHAR.
# - --quiet sends program UART TX to stdout; loader / executed
#   counts go to stderr.
#
# Exit codes:
#   0 -- all fixtures pass
#   1 -- at least one fixture failed
#   2 -- prereq missing (snobol4 wrapper, normalize.sno, fixtures)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FIXTURE_DIR="$REPO_DIR/snobol4/tests/normalize"
NORMALIZE_SNO="$REPO_DIR/snobol4/src/normalize.sno"

if ! command -v snobol4 >/dev/null 2>&1; then
    echo "test-normalize: PREREQ MISSING -- 'snobol4' wrapper not on PATH." >&2
    exit 2
fi

if [ ! -f "$NORMALIZE_SNO" ]; then
    echo "test-normalize: PREREQ MISSING -- $NORMALIZE_SNO not found." >&2
    exit 2
fi

if [ ! -d "$FIXTURE_DIR" ]; then
    echo "test-normalize: PREREQ MISSING -- $FIXTURE_DIR not found." >&2
    exit 2
fi

shopt -s nullglob
fixtures=("$FIXTURE_DIR"/test_*.f)
if [ ${#fixtures[@]} -eq 0 ]; then
    echo "test-normalize: PREREQ MISSING -- no test_*.f fixtures under $FIXTURE_DIR." >&2
    exit 2
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

passed=0
failed=0
total=${#fixtures[@]}

for fixture in "${fixtures[@]}"; do
    name="$(basename "$fixture" .f)"
    expected="$FIXTURE_DIR/${name}.expected"
    if [ ! -f "$expected" ]; then
        echo "FAIL  $name  (no $expected)"
        failed=$((failed+1))
        continue
    fi

    actual=$(snobol4 --load-binary "$NORMALIZE_SNO@0x080000" \
                     --load-binary "$fixture@0x090000" \
                     --entry 0 \
                     --quiet --speed 0 -n 100000000 -t 60 2>/dev/null)

    if printf '%s\n' "$actual" | diff -u "$expected" - >"$WORK/${name}.diff"; then
        echo "PASS  $name"
        passed=$((passed+1))
    else
        echo "FAIL  $name"
        sed 's/^/      /' "$WORK/${name}.diff"
        failed=$((failed+1))
    fi
done

echo
echo "test-normalize: $passed/$total passed, $failed failed."

if [ "$failed" -gt 0 ]; then
    exit 1
fi
exit 0
