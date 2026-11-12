# needs: fv-install --check tla && command -v uv
# Checks for the scripts that link a TLA+ model to real code. tests/test_examples.sh sources this file.

L="$K/fv-tlaplus/examples/linking"
R="$K/fv-tlaplus/examples/good/refund-race"
lpy() { (cd "$L" && uv run --quiet --with pytest "$@"); }

t "replay: the generated test reproduces the double refund on the check-then-refund service" 1 "refunded 20 on a payment of 10" \
  lpy python -m pytest -q -p no:cacheprovider test_replay_check_then_refund.py
t "replay: the same test passes on the atomic service" 0 "1 passed" \
  lpy env REFUND_DESIGN=atomic python -m pytest -q -p no:cacheprovider test_replay_check_then_refund.py
t "replay: the shipped test equals what fv-replay generates from the model" 0 "^same$" \
  sh -c "fv-replay '$R/RefundRace.tla' '$R/CheckThenRefund.cfg' | diff -q - '$L/test_replay_check_then_refund.py' >/dev/null && echo same"
t "replay: a config that holds has no counterexample to replay" 1 "^FAIL AtomicRefund.cfg: no counterexample to replay" \
  fv-replay "$R/RefundRace.tla" "$R/AtomicRefund.cfg"

t "conform: the log of the check-then-refund service is a behaviour of that design" 0 "^PASS trace check_then_refund.jsonl: accepted \\(5 events\\)" \
  fv-conform "$R/RefundRace.tla" "$R/CheckThenRefund.cfg" "$L/logs/check_then_refund.jsonl"
t "conform: the log of the atomic service is rejected by the check-then-refund design" 1 "^FAIL trace atomic.jsonl: expected accepted, got rejected at event 5" \
  fv-conform "$R/RefundRace.tla" "$R/CheckThenRefund.cfg" "$L/logs/atomic.jsonl"
t "conform: a rejection that was declared passes" 0 "^PASS trace atomic.jsonl: rejected at event 5" \
  fv-conform --expect rejected "$R/RefundRace.tla" "$R/CheckThenRefund.cfg" "$L/logs/atomic.jsonl"
t "conform: the shipped logs equal what the services produce" 0 "^same$" \
  sh -c "cd '$L' && python3 record.py check-then-refund | diff -q - logs/check_then_refund.jsonl >/dev/null && python3 record.py atomic | diff -q - logs/atomic.jsonl >/dev/null && echo same"
t "conform: a log line that is not JSON is an error" 1 "^ERROR trace broken.jsonl" \
  sh -c "d=\$(mktemp -d) && echo not-json > \$d/broken.jsonl && fv-conform '$R/RefundRace.tla' '$R/CheckThenRefund.cfg' \$d/broken.jsonl"
