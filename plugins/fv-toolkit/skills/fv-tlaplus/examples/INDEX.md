# TLA+ examples

`tests/test_examples.sh` in the repository runs every example in this table. A good example meets its declared outcomes and detects its mutations. A bad example produces the symptom that its README states.

| Example | Kind | Pattern | The one lesson |
|---|---|---|---|
| [good/refund-race](good/refund-race/README.md) | good | Read-modify-write without a lock (D), idempotency on retries (F1) | One action per atomic step. One knob, one config per design, one witness |
| [good/idempotent-receiver](good/idempotent-receiver/README.md) | good | Idempotent receiver (B1) | A crash is a fault switch. The same design holds with the fault off and breaks with it on |
| [bad/merged-atomicity](bad/merged-atomicity/README.md) | bad | Read-modify-write without a lock (D) | One action per function passes on a design that fails in production |
| [bad/liveness-without-fairness](bad/liveness-without-fairness/README.md) | bad | Any pattern with a progress property | Liveness without fairness fails on a stuttering trace and says nothing about the design |
| [bad/unreachable-state](bad/unreachable-state/README.md) | bad | Two-phase commit (B2) | A property holds when its state is unreachable, and only a witness shows it |
| [bad/strong-fairness-everywhere](bad/strong-fairness-everywhere/README.md) | bad | Any pattern with a progress property | Liveness that holds only under strong fairness assumes a scheduler guarantee that most implementations do not give |
| [bad/vacuous-fairness](bad/vacuous-fairness/README.md) | bad | Any | Fairness on an action whose guard is unreachable holds for free and supports nothing |
| [bad/symmetry-with-liveness](bad/symmetry-with-liveness/README.md) | bad | Any pattern with symmetric processes | `SYMMETRY` with a liveness `PROPERTY` prints no warning, and TLC can report a counterexample that breaks the spec's own fairness |
| [bad/unbounded-state](bad/unbounded-state/README.md) | bad | Any | An unbounded counter or queue makes TLC run without end. A `CONSTRAINT` bounds the search |
| [bad/invariants-only](bad/invariants-only/README.md) | bad | Any | An `INVARIANT` cannot relate two consecutive states. Only an action property catches a forbidden step |
