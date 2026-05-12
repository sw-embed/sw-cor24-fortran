Extend emit_asm.sno to handle kind=PRINT with a quoted string literal.

For each PRINT record:
  - Extract the string literal from text=PRINT *, '<lit>' using
    SNOBOL4 pattern matching (BREAK and literal patterns).
  - Assign a unique label _S<N> (use a LITNUM counter).
  - Emit asm:  la r0,_S<N>; push r0; la r0,_puts; jal r1,(r0); add sp,3
  - Track the literal in a LITDATA accumulator (the bytes that will
    be emitted in the .data section at END).

For string -> .byte sequence: each char of the literal becomes a
decimal byte value; append 10 (newline) and 0 (null terminator).
SNOBOL4's CHAR(n) is the int-to-char direction; I need the inverse
(char-to-int). If the dialect doesn't expose ORD/ASC, fall back to
emitting an `.ascii "<lit>"` + `.byte 10,0` directive if cor24-asm
supports it; verify before authoring.

On END: emit the LEND: epilogue, then the .data section, then
unspool LITDATA (label + .byte directive per tracked literal).

Acceptance: hand-crafted classified records for hello.f (PROGRAM
HELLO, PRINT *, 'Hello, World!', STOP, END) produce a .s that
assembles and runs to print "Hello, World!".