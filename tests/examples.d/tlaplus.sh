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

t "transactional-outbox: every config meets its declared outcome" 0 'PASS SeparateWrites.cfg: deadlock' \
  fv-tlc "$G/transactional-outbox/TransactionalOutbox.tla"
t "transactional-outbox: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/transactional-outbox/TransactionalOutbox.mutations"

t "saga-orchestrated: every config meets its declared outcome" 0 'PASS BlindCompensate.cfg: violated CompensateImpliesRan' \
  fv-tlc "$G/saga-orchestrated/SagaOrchestrated.tla"
t "saga-orchestrated: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/saga-orchestrated/SagaOrchestrated.mutations"

t "two-phase-commit: every config meets its declared outcome" 0 'PASS BlockOnCrashNoRecovery.cfg: deadlock' \
  fv-tlc "$G/two-phase-commit/TwoPhaseCommit.tla"
t "two-phase-commit: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/two-phase-commit/TwoPhaseCommit.mutations"

t "lease-fencing: every config meets its declared outcome" 0 'PASS NoFencing.cfg: violated StaleWriteRejected' \
  fv-tlc "$G/lease-fencing/LeaseFencing.tla"
t "lease-fencing: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/lease-fencing/LeaseFencing.mutations"

t "leader-election: every config meets its declared outcome" 0 'PASS LocalMajority.cfg: violated AtMostOneLeaderPerTerm' \
  fv-tlc "$G/leader-election/LeaderElection.tla"
t "leader-election: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/leader-election/LeaderElection.mutations"

t "cdc-snapshot-handoff: every config meets its declared outcome" 0 'PASS WrongOffset.cfg: violated ExactlyOnce' \
  fv-tlc "$G/cdc-snapshot-handoff/CdcSnapshotHandoff.tla"
t "cdc-snapshot-handoff: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/cdc-snapshot-handoff/CdcSnapshotHandoff.mutations"

t "watermark-cursor: every config meets its declared outcome" 0 'PASS GtNoDedup.cfg: violated ExactlyOnce' \
  fv-tlc "$G/watermark-cursor/WatermarkCursor.tla"
t "watermark-cursor: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/watermark-cursor/WatermarkCursor.mutations"

t "dag-scheduler: every config meets its declared outcome" 0 'PASS NaiveRestart.cfg: violated NeverRunsTwice' \
  fv-tlc "$G/dag-scheduler/DagScheduler.tla"
t "dag-scheduler: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/dag-scheduler/DagScheduler.mutations"

t "reconciler: every config meets its declared outcome" 0 'PASS StaleRead.cfg: violated NeverOvershoots' \
  fv-tlc "$G/reconciler/Reconciler.tla"
t "reconciler: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/reconciler/Reconciler.mutations"

t "bad/merged-atomicity: the merged model passes, which is the symptom" 0 'PASS Merged.cfg: holds' \
  fv-tlc "$B/merged-atomicity/MergedRefund.tla"
t "bad/liveness-without-fairness: TLC answers with a stuttering counterexample" 0 'PASS NoFairness.cfg: liveness' \
  fv-tlc "$B/liveness-without-fairness/Worker.tla"
t "bad/unreachable-state: the invariant holds and only the witness exposes it" 1 'FAIL Witness.cfg: expected violated NeverCommitted, got holds' \
  fv-tlc "$B/unreachable-state/Commit.tla"
