Authored examples/hello.s (115 lines, COR24 assembly) and assembled
examples/hello.lgo (284 bytes, ASCII .lgo). Verified end-to-end:
cor24-emu --lgo examples/hello.lgo --quiet -> "Hello, World!\n",
exit 0, 408 instructions.

Structure adapted from the tc24r demo's hello.s (proven working);
only delta is the _S0 byte sequence encoding "Hello, World!\n\0".

Path A chosen to sidestep the dcemu --lgo X.lgo --uart-file Y bug
entirely (no SNOBOL4 invocation in this saga's path).