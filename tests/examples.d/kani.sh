# needs: fv-install --check kani
# Example checks for the fv-kani skill. tests/test_examples.sh sources this
# file. This machine's cargo has no rustup, so fv-install --check kani
# reports UNAVAILABLE here and this file is skipped; it runs on CI, which
# has rustup.
#
# bad/unbounded-loop is not run here. Its point is that the harness never
# reaches a verdict, so no bounded command and exit code describes it
# without risking a hung or orphaned process in CI; its README carries the
# real output of a timed, killed run instead.
H="$K/fv-kani/examples"
G="$H/good"
B="$H/bad"

t "allocate-bonus: the harness meets its bounds property" 0 'PASS kani check_every_part_is_at_most_the_total: SUCCESSFUL' \
  sh -c "cd '$G/allocate-bonus' && fv-kani check_every_part_is_at_most_the_total"
t "allocate-bonus: the cover witness is reachable" 0 'COVER a share can equal the whole total: SATISFIED' \
  sh -c "cd '$G/allocate-bonus' && fv-kani check_every_part_is_at_most_the_total"
t "allocate-bonus: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/allocate-bonus/allocate-bonus.mutations"

t "bad/narrow-assume: the narrowed check passes, which is the symptom" 0 'PASS kani check_every_part_is_at_most_the_total: SUCCESSFUL' \
  sh -c "cd '$B/narrow-assume' && fv-kani check_every_part_is_at_most_the_total"

# Invariants of the fv-kani wrapper itself, not of an example. These run
# even when cargo kani is not installed, because they only check PATH.
t "fv-kani exits 3 when cargo or rustup is missing" 3 '^UNAVAILABLE kani' \
  env PATH=/usr/bin:/bin fv-kani somename
t "fv-kani reports a usage error for the wrong number of arguments" 2 'Usage: fv-kani' \
  fv-kani

