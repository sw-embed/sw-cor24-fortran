#!/usr/bin/env bash
# test-classify.sh -- run snobol4/src/classify.sno against each
# fixture in snobol4/tests/classify/ and diff the captured UART
# output against the matching .expected file.
#
# Canonical dcsno invocation (post-bootstrap + dcemu fixes):
#
#     snobol4 --load-binary <prog>.sno@0x080000 \
#             --load-binary <data>.in@0x090000 \
#             --entry 0 --quiet --speed 0 -n 100000000 -t 60
#
# Exit codes:
#   0 -- all fixtures pass
#   1 -- at least one fixture failed
#   2 -- prereq missing (snobol4 wrapper, classify.sno, fixtures)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FIXTURE_DIR="$REPO_DIR/snobol4/tests/classify"
CLASSIFY_SNO="$REPO_DIR/snobol4/src/classify.sno"

if ! command -v snobol4 >/dev/null 2>&1; then
    echo "test-classify: PREREQ MISSING -- 'snobol4' wrapper not on PATH." >&2
    exit 2
fi

if [ ! -f "$CLASSIFY_SNO" ]; then
    echo "test-classify: PREREQ MISSING -- $CLASSIFY_SNO not found." >&2
    exit 2
fi

if [ ! -d "$FIXTURE_DIR" ]; then
    echo "test-classify: PREREQ MISSING -- $FIXTURE_DIR not found." >&2
    exit 2
fi

shopt -s nullglob
fixtures=("$FIXTURE_DIR"/test_*.in)
if [ ${#fixtures[@]} -eq 0 ]; then
    echo "test-classify: PREREQ MISSING -- no test_*.in fixtures under $FIXTURE_DIR." >&2
    exit 2
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

passed=0
failed=0
total=${#fixtures[@]}

for fixture in "${fixtures[@]}"; do
    name="$(basename "$fixture" .in)"
    expected="$FIXTURE_DIR/${name}.expected"
    if [ ! -f "$expected" ]; then
        echo "FAIL  $name  (no $expected)"
        failed=$((failed+1))
        continue
    fi

    actual=$(snobol4 --load-binary "$CLASSIFY_SNO@0x080000" \
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
echo "test-classify: $passed/$total passed, $failed failed."

if [ "$failed" -gt 0 ]; then
    exit 1
fi
exit 0
