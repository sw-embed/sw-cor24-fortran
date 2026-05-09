Remove the temporary `grep -v '^Loaded '` filter and its accompanying
comment from scripts/verify-snobol4.sh. dcemu has shipped the fix that
classifies 'Loaded N bytes ...' as a log message; cor24-emu --quiet
now correctly puts loader output on stderr (verified against binary
timestamp 2026-05-08 17:22:53).

Acceptance:
- the grep filter is gone
- the comment about the upstream quirk is gone
- scripts/verify-snobol4.sh still exits 0 with 'OK'