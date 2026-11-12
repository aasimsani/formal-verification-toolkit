# needs: fv-install --check tla
# Example checks for the fv-tlaplus skill. tests/test_examples.sh sources this file.

G="$K/fv-tlaplus/examples/good"
B="$K/fv-tlaplus/examples/bad"

t "refund-race: every config meets its declared outcome" 0 'PASS CheckThenRefund.cfg: violated NeverOverRefund' \
  fv-tlc "$G/refund-race/RefundRace.tla"
t "refund-race: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/refund-race/RefundRace.mutations"

t "idempotent-receiver: every config meets its declared outcome" 0 'PASS EffectThenRecord.cfg: violated AtMostOnce' \
  fv-tlc "$G/idempotent-receiver/IdempotentReceiver.tla"
t "idempotent-receiver: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/idempotent-receiver/IdempotentReceiver.mutations"

t "bad/merged-atomicity: the merged model passes, which is the symptom" 0 'PASS Merged.cfg: holds' \
  fv-tlc "$B/merged-atomicity/MergedRefund.tla"
t "bad/liveness-without-fairness: TLC answers with a stuttering counterexample" 0 'PASS NoFairness.cfg: liveness' \
  fv-tlc "$B/liveness-without-fairness/Worker.tla"
t "bad/unreachable-state: the invariant holds and only the witness exposes it" 1 'FAIL Witness.cfg: expected violated NeverCommitted, got holds' \
  fv-tlc "$B/unreachable-state/Commit.tla"
