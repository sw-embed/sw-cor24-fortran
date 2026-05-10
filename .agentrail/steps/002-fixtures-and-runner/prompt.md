Author golden-test fixtures and runner for classify.sno.

Layout under snobol4/tests/classify/:
  test_kinds.in           -- one record of each of 12 kinds
  test_kinds.expected     -- expected classified output
  test_full_hello.in      -- the hello.f normalize output (6 records)
  test_full_hello.expected
  test_full_sum10.in      -- the sum10.f normalize output (10 records)
  test_full_sum10.expected
  README.md               -- format + naming convention

Author scripts/test-classify.sh runner that mirrors
scripts/test-normalize.sh. Iterates over test_*.in fixtures,
runs classify.sno via canonical
  snobol4 --load-binary src/classify.sno@0x080000
          --load-binary <fixture>.in@0x090000
          --entry 0 --quiet --speed 0 -n 100000000 -t 60
captures stdout, diffs against .expected, reports PASS/FAIL per
fixture, exit 0 if all pass else 1.

Acceptance:
- 7 files under snobol4/tests/classify/
- scripts/test-classify.sh exists and is executable
- runner reports all fixtures passing