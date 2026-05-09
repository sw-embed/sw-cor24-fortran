Run scripts/test-normalize.sh against the draft normalize.sno, read
each failure honestly, fix the SNOBOL4 source, repeat until all 8
fixtures pass.

If the failures expose missing-feature gaps in the deployed SNOBOL4
interpreter, document them as a dcsno-targeted brief and pause this
step until they land (NO WORKAROUNDS).

Acceptance:
- scripts/test-normalize.sh exits 0
- all 8 fixtures pass
- OR step is correctly marked blocked with a brief filed