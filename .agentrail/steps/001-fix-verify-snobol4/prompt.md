Rewrite scripts/verify-snobol4.sh to use the canonical SNOBOL4
invocation pattern that dcsno's wrapper expects:

    snobol4 --load-binary <prog>.sno@0x080000 --entry 0 \
            --quiet --speed 0 -n 100000000 -t 60

Previous version used `cor24-emu --lgo <lgo> --uart-file <prog>.sno`
which was wrong on two counts:
  (a) bypasses the snobol4 wrapper, which is the canonical entry point
  (b) --uart-file delivers bytes via UART RX, but the SNOBOL4
      interpreter reads its program from memory at 0x080000 -- so the
      .sno never reached the interpreter, the test halted on the first
      stray UART byte ('*' from a comment line), 397 instructions, no
      OUTPUT, and I incorrectly attributed the failure to the dcemu
      bug.

With --quiet, cor24-emu writes the program's UART TX as plain text on
stdout (logs go to stderr). So the script captures stdout and diffs
against snobol4/tests/builtins/test_builtins.expected directly, no
framing-extraction sed magic needed.

Acceptance:
- scripts/verify-snobol4.sh exit 0 with message 'OK' against the
  deployed interpreter
- exit 1 + diff if SIZE/SUBSTR/CHAR misbehave
- exit 2 only as a true 'toolchain prereq missing' signal (snobol4 not
  on PATH, or fixture missing)