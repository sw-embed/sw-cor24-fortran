#!/usr/bin/env bash
# test-hello.sh -- regression test for the Path A hello-world pipeline.
#
# Runs the full chain:
#   scripts/fortran examples/hello.f
#     | cor24-asm -> .lgo
#     | cor24-emu --lgo -> UART output
# and diffs the captured UART output against examples/hello.expected.
#
# Exit codes:
#   0 -- pass: UART output matches expected
#   1 -- fail: output differs (diff printed)
#   2 -- blocked: cor24-asm or cor24-emu missing on PATH

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

for tool in cor24-asm cor24-emu; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "test-hello: BLOCKED -- '$tool' not on PATH." >&2
        exit 2
    fi
done

EXPECTED="$REPO_DIR/examples/hello.expected"
INPUT_F="$REPO_DIR/examples/hello.f"

if [ ! -f "$EXPECTED" ] || [ ! -f "$INPUT_F" ]; then
    echo "test-hello: error: missing fixture under $REPO_DIR/examples/" >&2
    exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

"$REPO_DIR/scripts/fortran" "$INPUT_F" > "$WORK/hello.s"
cor24-asm "$WORK/hello.s" -o "$WORK/hello.lgo" >/dev/null
ACTUAL=$(cor24-emu --lgo "$WORK/hello.lgo" --quiet --speed 0 -n 1000000 2>/dev/null)

if printf '%s\n' "$ACTUAL" | diff -u "$EXPECTED" - >"$WORK/diff"; then
    echo "test-hello: OK -- pipeline produces 'Hello, World!'."
    exit 0
fi

echo "test-hello: FAIL -- output differs from expected:" >&2
cat "$WORK/diff" >&2
exit 1
