Author examples/hello.s -- a minimal COR24 assembly program that
prints 'Hello, World!\n' via UART and halts. Adapt the structure from
the tc24r demo at sw-cor24-x-tinyc/demos/hello.s (verified working
on cor24-asm + cor24-emu); change the embedded byte sequence to
encode 'Hello, World!\n\0' (15 bytes) instead of 'Hello, COR24!\n\0'.

Verify: cor24-asm examples/hello.s -o /tmp/hello.lgo &&
cor24-emu --lgo /tmp/hello.lgo --quiet --speed 0 -n 1000000
must print 'Hello, World!\n' on stdout with exit 0.