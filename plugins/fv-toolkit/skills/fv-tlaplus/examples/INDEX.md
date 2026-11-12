# TLA+ examples

`tests/test_examples.sh` in the repository runs every example in this table. A good example meets its declared outcomes and detects its mutations. A bad example produces the symptom that its README states.

| Example | Kind | Pattern | The one lesson |
|---|---|---|---|
| [good/refund-race](good/refund-race/README.md) | good | Read-modify-write without a lock (D), idempotency on retries (F1) | One action per atomic step. One knob, one config per design, one witness |
| [good/idempotent-receiver](good/idempotent-receiver/README.md) | good | Idempotent receiver (B1) | A crash is a fault switch. The same design holds with the fault off and breaks with it on |
| [good/cache-invalidation](good/cache-invalidation/README.md) | good | Cache-aside read fills a stale entry (A2) | A version mark left behind on an otherwise empty cache entry, a rejected fill that leaves the cache exactly as it found it, a mixed-type variable replaced with a boolean plus a same-typed value to avoid a TLC equality error |
| [good/cdc-snapshot-handoff](good/cdc-snapshot-handoff/README.md) | good | Change data capture, snapshot-to-stream handoff (C3) | A fenced choice of candidate values standing in for a timing race, an invariant gated on completion so it says nothing about a run still in progress |
| [good/dag-scheduler](good/dag-scheduler/README.md) | good | DAG orchestration, restart and dependency checking (C1) | A worker action that keeps running regardless of the scheduler's own crash flag, a restart that reads a durable effect count instead of guessing, two unrelated checks bundled into one rejected design |
| [good/leader-election](good/leader-election/README.md) | good | Leader election under a partition (B3) | A candidate's own view of the cluster kept separate from the cluster's real size, a partition fault that splits reachability without touching the node set |
| [good/lease-fencing](good/lease-fencing/README.md) | good | Leases with fencing tokens (B3) | A ground-truth property kept separate from the mechanism under test, a high-water mark set at grant time rather than at write time |
| [good/reconciler](good/reconciler/README.md) | good | Kubernetes-style reconcile loop over a stale cache (E) | A controller's own expectation count standing in for ground truth it has no way to read, a watch event that lowers that count instead of a second read of the resource |
| [good/release-ordering](good/release-ordering/README.md) | good | Rolling deploy across an expand-and-contract migration (D) | A fault switch scoped to the one action it actually affects, a non-rolling design that still needs an ordering guard against the step it races |
| [good/saga-orchestrated](good/saga-orchestrated/README.md) | good | Saga, orchestrated (B2) | A timeout fault that lets a step settle before every attempt resolves, a fencing flag that closes that window, a ghost variable that snapshots a decision so a later change can be caught |
| [good/transactional-outbox](good/transactional-outbox/README.md) | good | Transactional outbox (B1) | Three designs behind one knob, a resume point computed from durable state, a relay that retries from a durable flag and can deliver twice, a consumer dedup knob |
| [good/two-phase-commit](good/two-phase-commit/README.md) | good | Two-phase commit (B3) | The coordinator's own durable vote record against a manager's current state, a true deadlock as the declared outcome, a boolean fault switch separate from the count it gates |
| [good/watermark-cursor](good/watermark-cursor/README.md) | good | Incremental load by watermark cursor (C1) | A dedup set bundled with the comparison operator as one design, a slow commit bounded to the model's own run window |
| [bad/merged-atomicity](bad/merged-atomicity/README.md) | bad | Read-modify-write without a lock (D) | One action per function passes on a design that fails in production |
| [bad/liveness-without-fairness](bad/liveness-without-fairness/README.md) | bad | Any pattern with a progress property | Liveness without fairness fails on a stuttering trace and says nothing about the design |
| [bad/unreachable-state](bad/unreachable-state/README.md) | bad | Two-phase commit (B2) | A property holds when its state is unreachable, and only a witness shows it |
| [bad/strong-fairness-everywhere](bad/strong-fairness-everywhere/README.md) | bad | Any pattern with a progress property | Liveness that holds only under strong fairness assumes a scheduler guarantee that most implementations do not give |
| [bad/vacuous-fairness](bad/vacuous-fairness/README.md) | bad | Any | Fairness on an action whose guard is unreachable holds for free and supports nothing |
| [bad/symmetry-with-liveness](bad/symmetry-with-liveness/README.md) | bad | Any pattern with symmetric processes | `SYMMETRY` with a liveness `PROPERTY` prints no warning, and TLC can report a counterexample that breaks the spec's own fairness |
| [bad/unbounded-state](bad/unbounded-state/README.md) | bad | Any | An unbounded counter or queue makes TLC run without end. A `CONSTRAINT` bounds the search |
| [bad/invariants-only](bad/invariants-only/README.md) | bad | Any | An `INVARIANT` cannot relate two consecutive states. Only an action property catches a forbidden step |
