# TLA+ examples

`tests/test_examples.sh` in the repository runs every example in this table. A good example meets its declared outcomes and detects its mutations. A bad example produces the symptom that its README states.

| Example | Kind | Pattern | The one lesson |
|---|---|---|---|
| [good/refund-race](good/refund-race/README.md) | good | Read-modify-write without a lock (D), idempotency on retries (F1) | One action per atomic step. One knob, one config per design, one witness |
| [good/idempotent-receiver](good/idempotent-receiver/README.md) | good | Idempotent receiver (B1) | A crash is a fault switch. The same design holds with the fault off and breaks with it on |
| [bad/merged-atomicity](bad/merged-atomicity/README.md) | bad | Read-modify-write without a lock (D) | One action per function passes on a design that fails in production |
| [bad/liveness-without-fairness](bad/liveness-without-fairness/README.md) | bad | Any pattern with a progress property | Liveness without fairness fails on a stuttering trace and says nothing about the design |
| [bad/unreachable-state](bad/unreachable-state/README.md) | bad | Two-phase commit (B2) | A property holds when its state is unreachable, and only a witness shows it |

## Anti-patterns without a reproduced example yet

`../references/anti-patterns.md` describes each of these. An example folder for each one is still to be written.

- Strong fairness on every action
- Fairness on an action that is never continuously enabled
- A symmetry set used with liveness checking
- An unbounded state space
- Invariants only, with no action property
