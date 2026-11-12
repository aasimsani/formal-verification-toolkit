# Formal Verification Toolkit: Architecture Patterns → Tools

Nov 12, 2026 · @Aasim

## How to use this doc

This is the input spec for a Claude Code skill that takes a piece of software, classifies its architecture patterns, picks the right verification tool per pattern, writes the model or property, runs the checker, and turns counterexamples into regression tests. Every pattern row below is meant to become a template in that skill.

**Core selection rule:** pick the tool by the *question*, not by the pattern's name. Four questions cover almost everything:

1. **Can bad interleavings happen?** (concurrency, retries, crashes, message loss) → a behavioral model checker: TLA+/Quint, P, FizzBee.
2. **Can the data or config reach an invalid shape?** (relations, permissions, schemas, policies) → a relational/constraint solver: Alloy, Z3/SMT.
3. **Is this code correct for all inputs?** (functions, algorithms, calculations) → code-level verification: Dafny, Lean, Kani, Verus, CrossHair; or property-based testing as the cheap version.
4. **Does the real system obey the model?** (conformance) → model-based testing, trace validation, deterministic simulation, Jepsen-style history checking.

**How the doc is organized:** tool catalog → selection framework (decision flow, property families, fault models) → seven pattern catalogs (A–G) → linking models to code → the skill's design spec → sources.

**How to read a pattern row:** *What breaks* is the failure the model must be able to produce. *Model* is the abstraction level (what to keep, what to throw away). *Properties* are the invariants (safety, always true) and liveness (eventually true) to check. *Code link* is how the model's findings reach the real codebase.

## Tool catalog

The skill should carry about 30 tools, each grouped into one of six families. Every tool is listed with the one job it does best. The skill should never pick a tool outside this list without saying why.

### Behavioral model checkers (designs, before or beside code)

| Tool | Best at | Strength | Limit | Run |
| --- | --- | --- | --- | --- |
| [TLA+](https://lamport.azurewebsites.net/tla/tla.html) + TLC / Apalache / TLAPS | Concurrent and distributed protocols; safety + liveness | Industry standard; >100 models inside Amazon ([TLA+ conf 2023](https://conf.tlapl.us/2023/dragoischwiderski/)); proofs via TLAPS | Math syntax; engineers struggle to learn it ([CACM 2025](https://cacm.acm.org/practice/systems-correctness-practices-at-amazon-web-services)) | `java -cp tla2tools.jar tlc2.TLC Spec.tla` |
| PlusCal | Same as TLA+, written as pseudocode | Easier for engineers; translates to TLA+ | Labels set atomicity; easy to get wrong | `pcal.trans` then TLC |
| [Quint](https://github.com/informalsystems/quint) | TLA+ semantics with typed, programmer syntax | Random simulation + Apalache SMT checking; emits ITF traces for model-based testing ([quint-connect](https://docs.rs/quint-connect)) | Younger ecosystem | `npm i -g @informalsystems/quint`; `quint run --mbt`, `quint verify` |
| [P](https://p-org.github.io/P/casestudies) | Message-passing state machines (microservices, protocols) | Used for S3 strong consistency, DynamoDB, EBS, Aurora; PObserve checks prod logs against the model | Event/state-machine style only | `dotnet tool install P`; `p check` |
| [FizzBee](https://fizzbee.io) | Distributed designs in Python-like (Starlark) syntax | Lowest learning curve; sequence diagrams and state graphs out of the box | No proof system; does not spill state to disk ([Vanlightly](https://jack-vanlightly.com/analyses/2024/12/5/verifying-kafka-transactions-diary-entry-4-writing-an-initial-fizzbee-spec)) | Playground or bazel build |
| Spin / Promela, NuSMV / nuXmv | Classic protocol and hardware-style state machines | Mature, fast | Dated tooling | CLI |
| UPPAAL | Timed automata: timeouts, deadlines, SLAs | Real clocks in the model | Niche syntax | GUI + `verifyta` |
| Event-B (Rodin) | Refinement from abstract to concrete with proof obligations | Each refinement step is proved | Heavyweight | Rodin IDE |

### Relational and constraint solvers (structure, config, rules)

| Tool | Best at | Strength | Limit | Run |
| --- | --- | --- | --- | --- |
| [Alloy 6](https://alloytools.org/alloy6.html) | Data models, relationships, permissions, schemas; light behavior | Relational logic + (since v6) mutable state and temporal operators; latest 6.2.0 ([alloytools.org](https://alloytools.org/)) | Bounded scopes; long traces get weak | JAR GUI or CLI |
| [Z3](https://github.com/Z3Prover/z3) / cvc5 (SMT) | Rule tables, policy equivalence, "can X ever happen" queries | Proves or gives a concrete counterexample; Python API | You write the encoding | `pip install z3-solver` |
| [Zelkova](https://www.amazon.science/publications/projective-model-counting-for-ip-addresses-in-access-control-policies)-style policy SMT | IAM / access policy analysis | Encodes policies to SMT; 99% of real queries < 160 ms ([paper](https://discovery-pp.ucl.ac.uk/id/eprint/10081411/1/Semantic-based%20Automated%20Reasoning%20for%20AWS%20Access%20Policies%20using%20SMT.pdf)) | AWS-internal; replicate the idea with Z3 | Build on Z3 |
| Cedar analyzer | Authorization policies written in Cedar | Verified symbolic compiler to SMT ([SymCert](https://cdn.amazon.science/9f/c9/5d18658a41c48628b686493aa327/scipub-approval152134-46496997-symcert-verifying-smtbased-policy-analyses.pdf)) | Cedar only | `cedar` CLI |
| [VeriEQL](https://www.vldb.org/pvldb/vol17/p4437-zhao.pdf) / SQLSolver / QED | SQL query equivalence, rewrite safety | Proves or disproves with concrete counterexample tables | Bounded (VeriEQL) or SQL-subset limits | Research tools |

### Code-level verifiers (prove the real code)

| Tool | Language | Best at | Limit |
| --- | --- | --- | --- |
| Dafny | Own language, compiles to C#/Java/Go/Python/JS | Verified algorithms and core logic; was Cedar's first model | Proofs can turn brittle as code grows ([Cedar poster](https://bhaktishh.github.io/papers/popl-24-src-poster.pdf)) |
| Lean 4 | Own language | Executable reference models + proofs; Cedar's current model ([AWS blog](https://aws.amazon.com/blogs/opensource/lean-into-verified-software-development)) | Steep; strict termination checking |
| Rocq (Coq), Isabelle, F\* | Own languages | Deep proofs, verified compilers and crypto | Expert-only |
| [Kani](https://cdn.amazon.science/05/be/d3a0c9c241e1b6ffbf5b2e6eddb4/scipub-approval152129-47347564-kani-a-model-checker-for-rust.pdf) | Rust | Bounded model checking of panics, overflow, unsafe code; runs in Firecracker CI | Sequential Rust only, no concurrency ([summary](https://www.emergentmind.com/papers/2607.01504)) |
| Verus, Prusti, Creusot | Rust | Deductive proofs on Rust code | Annotation effort |
| CBMC, Frama-C | C | Memory safety, bounded proofs | C only |
| Gobra | Go | Viper-based verification | Research-grade |
| [Nagini](https://github.com/marcoeilers/nagini) | Python | Full Python verification | Annotation effort; research-grade |
| [CrossHair](https://crosshair.readthedocs.io/en/latest/related_work.html) | Python | Finds counterexamples to contracts/type hints with Z3; `diffbehavior` compares two functions | Finds bugs, cannot generally prove |
| Liquid Haskell, Stainless | Haskell, Scala | Refinement types | Language-bound |

### Concurrency testers (real code, controlled schedules)

| Tool | Language | Best at |
| --- | --- | --- |
| [Shuttle](https://github.com/awslabs/shuttle) | Rust | Randomized scheduling (PCT); scales; used on S3 ShardStore ([AWS](https://aws.amazon.com/blogs/storage/how-automated-reasoning-helps-us-innovate-at-s3-scale)) |
| Loom | Rust | Exhaustive interleavings of small tests |
| Coyote | .NET | Systematic testing of async actors |
| [Stateright](https://docs.rs/crate/stateright/latest) | Rust | Model checker embedded in an actor library; same code runs on a real network; linearizability tester |

### Property-based and model-based testing

| Tool | Language | Best at |
| --- | --- | --- |
| [Hypothesis](https://hypothesis.works/articles/rule-based-stateful-testing/) | Python | Properties + `RuleBasedStateMachine` stateful tests with invariants |
| fast-check, jqwik, proptest, QuickCheck | TS, Java, Rust, Haskell | Same idea per language |
| [Schemathesis](https://pypi.org/project/schemathesis/4.15.1/) | Any HTTP API | Generates tests from OpenAPI/GraphQL; stateful API workflows from links |
| [XState graph](https://stately.ai/docs/xstate-graph) | TS | Paths through UI/workflow state machines as test cases |
| quint-connect | Rust, TS | Replays Quint traces against the implementation |

### System-level conformance and fault testing

| Tool | Best at |
| --- | --- |
| [Antithesis](https://antithesis.com/resources/deterministic_simulation_testing/) | Deterministic hypervisor: any stack, reproducible fault injection |
| Hand-built DST (FoundationDB, [TigerBeetle VOPR](https://docs.tigerbeetle.com/about/vopr)) | Simulating a whole cluster in one deterministic process |
| Jepsen + [Elle](https://arxiv.org/pdf/2003.10554) | Black-box histories checked for isolation anomalies (G0, G1a–c, G-single, G2) |
| TLA+ trace validation, [FETCh](https://www.datadoghq.com/blog/engineering/continuous-formal-spec-validation), PObserve | Checking real logs against a spec, in test or production |
| Tamarin, ProVerif | Security protocols against an active attacker |

## De-duplicated core toolkit

After the review, the \~35 tools above reduce to **9 core tools plus 7 opt-in specialists**. Most of the rest are the same technique in a different syntax or language. The skill should install and template only the core set, and reach for a specialist only when its trigger applies.

### Substitution groups

| Job | Substitutable tools | Keep | Why this one | Drop / demote |
| --- | --- | --- | --- | --- |
| Behavioral model checking | TLA+ (TLC, Apalache), PlusCal, Quint, P, FizzBee, Spin, NuSMV, Event-B, UPPAAL | **TLA+** (PlusCal allowed inside it) | Same semantics as Quint and covers what P and FizzBee do; the only one with trace validation, runtime monitors (FETCh), proofs (TLAPS), and a large corpus of real specs (Raft, Kafka, Cosmos DB) to template from | Quint: same semantics, nicer syntax and MBT. Switch to it *instead of* TLA+ if readability matters more, never alongside. P, FizzBee, Spin, NuSMV, Event-B dropped. UPPAAL → model clocks in TLA+ |
| Structural / relational modeling | Alloy 6, TLA+ (sets), Z3 | **Alloy** | Relations, permissions, and schemas are its native shape; instant visual counterexamples | Use Alloy for structure only; its temporal mode duplicates TLA+ |
| Constraint / rule / policy solving | Z3, cvc5, Zelkova-style encodings, Cedar analyzer | **Z3** | Python API; same SMT core the AWS policy tools use | cvc5 dropped; Cedar analyzer is a specialist |
| Property-based + stateful testing | Hypothesis, fast-check, proptest, jqwik, QuickCheck | **Hypothesis** (+ the one PBT library per other language in use) | Stateful `RuleBasedStateMachine` doubles as the MBT driver | Libraries for languages you don't ship |
| API contract testing | Schemathesis, Hypothesis by hand | **Schemathesis** | Generates tests from the OpenAPI spec you already have | — |
| Function contracts on code | CrossHair, Nagini, Gobra, Liquid Haskell, Stainless, Frama-C, CBMC | **CrossHair** for Python; **Kani** for Rust | Push-button counterexamples on real code | Per-language verifiers kept only for the language in use; Nagini/Gobra demoted |
| Proof of critical cores | Dafny, Lean 4, Rocq, Isabelle, F\*, Verus, Prusti, Creusot | **Dafny** | Most automation for small cores; compiles the model to Python/JS/Go for differential testing | Lean when proofs outgrow Dafny (Cedar's reason for moving); the rest dropped |
| Consistency checking of datastores | Jepsen + Elle, Porcupine, Knossos, Stateright tester | **Elle** | Checks many isolation levels from one history, in polynomial time | Others dropped |
| Model ↔ code conformance | TLC trace validation, FETCh, PObserve, quint-connect, Hypothesis MBT | **TLC trace validation + Hypothesis-driven MBT** | Both hang off the chosen TLA+ model | PObserve goes with P; quint-connect goes with Quint |

### Final shape

| Tier | Tools | Installed by default |
| --- | --- | --- |
| Core (9) | TLA+ (TLC, Apalache), Alloy 6, Z3, Hypothesis, Schemathesis, CrossHair, Kani (Rust repos only), Dafny, Elle | Yes |
| Specialists (7) | Tamarin (auth/crypto protocols), VeriEQL (SQL rewrites), Cedar analyzer (Cedar policies), Shuttle/Loom (Rust concurrency), Stateright (Rust actors as model), XState graph (XState UIs), Antithesis or hand-built DST (whole-cluster faults) | Only when its trigger appears |
| Dropped | Quint (unless chosen *instead of* TLA+), P, FizzBee, PlusCal as a separate tool, Spin, NuSMV, Event-B, UPPAAL, cvc5, Nagini, Gobra, Lean (unless Dafny is outgrown), Rocq, Isabelle, F\*, Verus, Prusti, Creusot, Coyote, Porcupine, Knossos, ProVerif, SQLSolver, QED, PObserve | No |

The catalogs keep mentioning dropped tools where they are the classic reference. The skill should map each such mention to the core tool in this table.

## Selection framework

Two axes decide the tool: *what is being checked* (structure, behavior over time, code) and *against what* (a separate model or the real code). The skill should first classify the question, then pick the cheapest tool that can produce the failure, and add a code link before calling anything verified.

### Escalation ladder (cheapest first)

1. **Property-based tests** on real code (Hypothesis, fast-check). Minutes to write, find most bugs per hour.
2. **Symbolic / bounded checks** on real code (CrossHair, Kani, Z3 encodings). Exhaustive within bounds.
3. **Design model + model checker** (Quint/TLA+, P, FizzBee, Alloy). Finds design bugs no test reaches.
4. **Conformance** between model and code (model-based testing, trace validation, DST).
5. **Proof** (Dafny, Lean, Verus, TLAPS). Only for components where a bug is unacceptable: auth, money movement, consensus.

### Property families (the reusable library)

| Family | Statement | Kind | Typical tools |
| --- | --- | --- | --- |
| Conservation | Nothing created or lost: rows in = rows out + rejected; debits = credits | Safety | Hypothesis, Z3, TLA+ |
| Idempotence | f(f(x)) = f(x); redelivery has no extra effect | Safety | Hypothesis stateful, TLA+ |
| Order independence | Result is the same for any permutation of inputs | Safety | Hypothesis, Z3 |
| Oracle equivalence | Optimized = naive; streaming = batch; incremental = full recompute; replay = live | Safety | Hypothesis, CrossHair `diffbehavior`, VeriEQL |
| Mutual exclusion | At most one leader, owner, or writer per resource | Safety | TLA+/Quint, P |
| Monotonicity | Offsets, watermarks, versions, terms never go backward | Safety | TLA+/Quint |
| Structural integrity | Keys unique, references resolve, intervals don't overlap, tenants isolated | Safety | Alloy, Z3 |
| Consistency model | Linearizable / serializable / snapshot / causal / read-your-writes | Safety | TLA+ refinement, Elle, Stateright |
| Convergence | Replicas, caches, projections, reconcilers eventually agree | Liveness | TLA+/Quint, P, FizzBee |
| Progress | Every request is eventually completed, rejected, or parked; nothing stuck | Liveness | TLA+/Quint, P |
| Bounded resources | Queues, retries, memory stay within limits | Safety | TLA+, UPPAAL |
| Non-vacuity | The model actually reaches the interesting states ("sometimes" checks) | Sanity | Every model checker |

### Fault model library

Each template should expose these faults as switches so a model can run with them on or off.

| Fault | Model as | Applies to |
| --- | --- | --- |
| Process crash + restart | Lose volatile state, keep durable state, at any step | Every stateful service |
| Crash between two writes | Split one logical operation into separate atomic steps | Outbox, sagas, dual writes |
| Message loss / duplication / reordering | Network as a bag (unordered multiset) with nondeterministic drop/dup | Queues, RPC, CDC |
| Network partition | Subsets of nodes cannot exchange messages | Replication, leader election |
| Timeout / slow node / GC pause | Process takes no steps for an unbounded period, then resumes with stale beliefs | Leases, locks |
| Clock skew | Each node has its own clock variable with bounded drift | Leases, TTLs, watermarks, schedulers |
| Concurrent writers | Two actors run the same action interleaved | OCC, upserts, caches |
| Partial failure of a batch | Some items succeed, some fail, caller sees one result | Bulk APIs, ETL loads |
| Storage faults | Torn writes, lost fsync, misdirected reads ([TigerBeetle](https://pierrez.github.io/moonpool/part1-why/04-history.html)) | Storage engines, WALs |
| Byzantine / malicious input | Adversary controls fields or messages | Webhooks, auth, protocols |

## Catalog A — In-process code architecture

Most local patterns are about structure or single-threaded logic, so property-based tests and Alloy cover them. Model checkers come in only where threads, async tasks, or actors share state. Purely structural patterns with no invariants of their own (Factory, Builder, Adapter, Decorator, DI containers) are listed at the end as low-value targets.

### A1. Structural / layering

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| Layered / N-tier | Lower layers call upward; domain imports infra | Alloy (or import-linter / ArchUnit) | Modules as atoms, `imports` relation | No dependency from domain to infra; acyclic | Generate the relation from the real import graph |
| Hexagonal (ports & adapters) / Clean / Onion | Adapters leak into core; port contract drifts between adapters | Alloy for dependencies; Hypothesis for port contracts | One contract test suite per port, run against every adapter | All adapters satisfy the same contract | Shared parametrized test over all adapters |
| Modular monolith / bounded contexts | Context reaches into another's tables | Alloy | Contexts, tables, access relation | Each table owned by exactly one context | Generate from SQL access logs or ORM metadata |
| Plugin / microkernel | Plugin breaks host invariants; load-order bugs | Hypothesis stateful | Random load/unload/call sequences | Host invariants hold for any plugin order | Stateful test with fake plugins |
| Middleware / interceptor chain | Order-sensitive bugs (auth after logging of secrets) | Alloy or Z3 | Chain as a sequence; required orderings as constraints | Required precedences always hold | Assert on the configured chain at startup |

### A2. Data access

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| Repository | In-memory and DB implementations disagree; query semantics drift | Hypothesis stateful (model = dict) | `RuleBasedStateMachine` with add/get/remove/query rules against a dict model | Repository == dict model after every step | Same test runs against in-memory and real-DB repos |
| Unit of Work | Partial commits; identity map returns stale objects | Hypothesis stateful; TLA+ if concurrent | Begin/register/commit/rollback actions | Commit is all-or-nothing; rollback restores prior state | Stateful test with injected failure on Nth write |
| Active Record vs Data Mapper | Save hooks fire twice; dirty tracking misses changes | Hypothesis | Random field mutations then save/reload | reload(save(x)) == x | Round-trip property |
| Optimistic locking (version column) | Lost update when two sessions save | TLA+/Quint or FizzBee | Two clients, read-modify-write, version check | No lost update; version strictly increases | Concurrent integration test replaying counterexample |
| Caching (memoize, LRU, read-through) | Stale entries; wrong eviction; key collisions | Hypothesis stateful vs. uncached oracle | Cache + backing store + invalidations | Cached read == uncached read (after invalidation) | Oracle comparison test |

### A3. Domain logic

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| DDD aggregate | Invariants broken across a sequence of commands | Hypothesis stateful; Dafny for core math | Commands as rules, aggregate invariant as `@invariant` | Invariant holds after every command | Stateful test on the aggregate class |
| Domain events | Event emitted but state not changed (or the reverse) | Hypothesis stateful | Fold events into a shadow state | fold(events) == aggregate state | Compare projection with the aggregate |
| State pattern / explicit FSM | Illegal transitions; unreachable or dead states | Alloy, XState graph, or TLA+ | States + allowed transitions | Only allowed transitions; every state reachable; terminal states final | Generate the transition table from code (enum + map) |
| Specification pattern | Composed specs contradict or are always-false | Z3 | Each spec as a predicate | Satisfiable; and/or/not behave as expected | Encode predicates from code |
| Rules engine / decision table | Overlaps, gaps, contradictory rules, order dependence | Z3 (or Alloy) | Rule conditions as constraints over input fields | Completeness (some rule fires), uniqueness (one fires), determinism | Generate SMT from the rule table |
| Interpreter / DSL | Evaluator crashes or diverges on valid programs | Hypothesis + Lean/Dafny reference model | Grammar-based generators | Evaluator == reference semantics; well-typed programs don't error | Differential testing (the Cedar approach) |
| Strategy / policy objects | Strategies disagree on shared guarantees | Hypothesis | One property suite for all strategies | Each strategy meets the shared contract | Parametrized tests |

### A4. Concurrency inside a process

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| Mutex / RW lock | Deadlock; forgotten release on error path | TLA+/PlusCal; Shuttle/Loom (Rust) | Processes + lock variable, one step per lock op | Mutual exclusion; deadlock freedom | Controlled-scheduler test on real code |
| Producer–consumer / bounded queue | Lost items; deadlock on full/empty; spurious wakeups | TLA+/PlusCal | Buffer, producers, consumers, condition waits | Conservation; no deadlock; bounded size | Shuttle/Loom or stress test with counterexample schedule |
| Thread pool / executor | Starvation; task lost on shutdown | TLA+ | Workers, queue, shutdown flag | Every submitted task runs or is rejected | Shutdown-race test |
| async/await, event loop | Lost wakeups; interleaving across `await` points; cancellation leaks | FizzBee or TLA+ (each `await` = a step) | Tasks yield at awaits | No shared-state invariant broken across awaits | Deterministic event-loop test |
| Actor model | Mailbox ordering assumptions; lost messages on restart | P or Stateright | Actors + mailboxes + supervisor restarts | No message lost; state consistent after restart | Stateright runs the same actor code |
| CSP channels (Go) | Goroutine leaks; deadlock on unbuffered channels | TLA+/PlusCal or Spin | Channels as sequences with capacity | Deadlock freedom; all goroutines terminate | `go test -race` + counterexample replay |
| Lock-free structures | ABA; memory-order bugs | Loom (Rust), CDSChecker (C++), TLA+ for algorithm | Atomic ops as steps | Linearizability | Linearizability checker on recorded history |
| Reactive streams | Backpressure violations; out-of-order emission | TLA+ or Hypothesis stateful | Demand counter + emissions | Never emit more than requested | Stateful test on the operator |

### A5. Low-value targets

Factory, Builder, Adapter, Decorator, Facade, Proxy, Singleton, DI containers. Verify only the contract of what they wrap. The skill should say so and skip them, so the toolkit doesn't spend effort where no property exists.

## Catalog B — Distributed and cloud patterns

This is where behavioral model checkers pay off most: almost every pattern here is a protocol between processes that can crash, retry, and see messages late or twice. Default to Quint/TLA+ or P for the design, then link to code with model-based tests, trace validation, or deterministic simulation.

### B1. Messaging and integration

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| Pub/sub, event notification | Duplicates, reordering, consumers missing events after restart | Quint/TLA+, P | Broker log, per-consumer offsets, at-least-once delivery | Every published event eventually processed; effect applied once | MBT: replay traces against consumer with a fake broker |
| Event-carried state transfer | Consumers apply stale snapshots over newer ones | Quint/TLA+ | Versioned events, out-of-order delivery | Consumer state version is monotonic | Hypothesis: shuffle events, check final state |
| Competing consumers | Same message processed by two workers after visibility timeout | TLA+/P with timeout fault | Queue with leases/visibility timeouts, slow worker | No double effect (with idempotency key) | Integration test with paused worker |
| Idempotent receiver (inbox) | Dedup record written after effect, crash between them | TLA+/Quint, FizzBee | Effect write and dedup write as separate steps + crash | Exactly-once effect despite redelivery | Crash-injection test at each step |
| Transactional outbox | Commit without event, or event without commit; relay publishes twice | TLA+/Quint | DB txn, outbox table, relay, broker, crash points | Committed change ⇔ eventually published; consumers dedupe | Trace validation on relay logs |
| Claim check | Payload deleted before consumer reads it | TLA+ | Blob store + message + GC | Referenced blobs are never collected | Test GC vs. slow consumer |
| Dead-letter queue / poison message | Message stranded forever; DLQ replay re-poisons | P or TLA+ | Retry counter, DLQ, replay action | Every message is processed or explicitly parked | Stateful test of retry policy |
| Request–reply over queues | Reply correlated to wrong request; orphaned replies | P | Correlation ids, timeouts | Reply matches request; timed-out requests release resources | MBT on the client library |
| Webhooks (outbound) | Lost on receiver downtime; reordering; retries flood | P or TLA+ | Delivery attempts, backoff, receiver state | Each event eventually delivered or dead-lettered; bounded attempts | Schemathesis on receiver + replay |

### B2. Workflows and transactions

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| Saga (orchestrated) | Compensation for a step that never happened; compensation races retry | P (AWS's sweet spot) or TLA+ | Orchestrator FSM + participants + compensations + crashes | Every saga ends fully committed or fully compensated | MBT against orchestrator; PObserve-style log check |
| Saga (choreographed) | No one owns completion; cycles of events | TLA+/Quint | Participants reacting to events | Termination; no orphaned partial state | Trace validation across services |
| Two-phase commit | Coordinator crash leaves participants blocked | TLA+ (classic example), Stateright | TM, RMs, prepare/commit/abort | Atomicity; liveness only if TM recovers ([Demirbas](https://muratbuffalo.blogspot.com/2018/12/2-phase-commit-and-beyond.html)) | Stateright runs the same actors |
| Workflow engine / durable execution (Temporal, Step Functions, Airflow) | Non-deterministic workflow code breaks replay; activities run twice; tasks stuck "running" | Quint/TLA+ for the workflow; Hypothesis for replay determinism | Workflow as FSM; activity retries; worker crash | Each step runs ≥ 1 time with idempotent effect; workflow terminates; replay(history) == state | Replay tests against recorded histories |
| Distributed cron / scheduler | Job runs twice across nodes or never after failover | TLA+ | Scheduler leases, clock skew | At most once per period (with lease); at least once eventually | Fault-injection test |
| Compensating transaction | Compensation not inverse (fees, rounding) | Hypothesis | Random op + compensation | compensate(apply(s)) == s on business fields | Property test on domain code |

### B3. Coordination and replication

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| Leader election | Two leaders after partition | TLA+/Quint | Nodes, terms, votes, partitions | At most one leader per term | Trace validation (etcd did this) |
| Leases + fencing tokens | Paused holder writes after lease expiry | TLA+ with clock skew + pause | Lease grant, expiry, storage checking token | Storage rejects any write with a stale token | Integration test with forced GC pause |
| Consensus (Raft, Paxos, VSR) | Log divergence, lost commits on membership change | TLA+ (+ TLAPS); DST for code | Standard Raft spec, extended per feature | Log matching; leader completeness; state-machine safety | Trace validation ([CCF, etcd](https://arxiv.org/pdf/2404.16075)); DST |
| Primary–backup / async replication | Acknowledged writes lost on failover | TLA+ | Primary, replicas, ack policy, failover | No acknowledged write is lost (under chosen ack policy) | Jepsen-style test |
| Leaderless / quorum (Dynamo-style) | Stale reads when R + W ≤ N; sloppy quorum anomalies | TLA+, Stateright | Replicas, quorum reads/writes, hinted handoff | Read-your-writes under R + W > N | Stateright linearizability tester |
| Multi-leader / active-active multi-region | Write conflicts; divergence | TLA+, Alloy for conflict rules | Regions, async replication, conflict resolution | Convergence; resolution is deterministic | Hypothesis: random concurrent ops, check convergence |
| CRDTs | Merge not commutative/associative/idempotent | Hypothesis (or Dafny/Lean proof) | Random states and merges | merge is commutative, associative, idempotent; convergence | Property test on merge function |
| Gossip / anti-entropy (Merkle trees) | Never converges under churn | FizzBee (its quick-start is gossip), TLA+ | Nodes exchanging digests | Eventual convergence with fair exchange | Simulation |
| Vector clocks / HLC | Wrong causality ordering | Hypothesis | Random message histories | Happens-before preserved by timestamps | Property test |
| Consistency guarantees exposed to clients | Docs and implementation disagree on what clients can observe | TLA+ client-centric spec + refinement ([Cosmos DB](https://arxiv.org/pdf/2210.13661)) | Clients + abstract store, no internals | Session/prefix/bounded-staleness/strong as stated | Elle or linearizability checker on histories |

### B4. Partitioning and scaling

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| Sharding / partition rebalancing | Two owners during handoff; data lost in move | TLA+/Quint | Partitions, owners, migration steps, crash | One active writer per partition; no key lost | Trace validation on rebalance logs |
| Consistent hashing | Excess movement on node join/leave | Hypothesis | Random ring changes | Only \~K/N keys move; every key has an owner | Property test |
| Service discovery | Clients route to dead or draining instances | TLA+ | Registry, health checks, client caches, TTL | Traffic to draining node eventually stops | Fault test |
| Autoscaling / scale-in | Work lost when instance terminated mid-task | TLA+ | Instances, tasks, termination hook | Every task completes or is re-queued | Termination test |

### B5. Resilience

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| Retry with backoff + jitter | Retry storms; metastable failure | TLA+/P + probabilistic simulation (AWS does this) | Clients, server capacity, retry policy | Load stays bounded; system recovers after spike | Load test with the failing parameters |
| Circuit breaker | Never closes; half-open lets a flood through | Alloy or TLA+ (small FSM) | Closed/Open/Half-open + counters + timer | Half-open admits ≤ N probes; eventually closes when healthy | XState-style path tests |
| Bulkhead / rate limiter / token bucket | Limit exceeded under concurrency | TLA+; Hypothesis for the bucket math | Concurrent acquires | Never more than N in flight / R per window | Concurrency test |
| Timeouts + cancellation | Work continues after caller gave up; resources leak | TLA+ | Caller, callee, cancel signal | Cancelled work releases resources eventually | Fault test |
| Health check / load shedding | Healthy-but-overloaded nodes kill themselves in a loop | TLA+/P | Health signal, load, restart | No restart cascade | Chaos test |

### B6. Edge, API, and deployment

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| API gateway / BFF / gateway aggregation | Partial failure produces inconsistent response; auth skipped on some routes | Alloy (route × policy coverage); Schemathesis | Routes, middleware, policies | Every route has auth; aggregation handles each sub-failure | Schemathesis on gateway |
| Sidecar / service mesh | mTLS gaps; retry at two layers multiplies load | Alloy (config), TLA+ (retry amplification) | Hops × retry policies | Total attempts ≤ budget | Config lint generated from model |
| Strangler fig / anti-corruption layer | Old and new paths disagree during migration | Hypothesis differential | Same request to both | new(x) == old(x) on shared fields | Shadow traffic comparison |
| Blue-green / canary / rolling deploy | Mixed versions break wire or schema compatibility | Alloy (version pairs), TLA+ (rollout steps) | Versions in flight, schema versions | Every co-existing version pair is compatible | Contract tests per pair |
| Feature flags / config propagation | Inconsistent flag state across services mid-rollout | TLA+ | Flag store, caches, TTLs | Dependent flags never observed in a forbidden combination | Runtime assertion |
| Serverless / FaaS | At-least-once triggers; cold-start ordering; concurrency limits | P or TLA+ | Trigger source, retries, concurrent invocations | Effects idempotent; no lost event | Same as idempotent receiver |

## Catalog C — Data systems

Data-system bugs are mostly silent: rows dropped, double-counted, or landing in the wrong window, with no crash. So the most useful checks here are conservation and oracle-equivalence properties on real transforms, plus TLA+/Quint models of the cursors, commits, and orchestration around them.

### C1. Batch and orchestration

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| Batch ETL / ELT stage | Rows dropped or duplicated by joins, filters, dedup | Hypothesis (dataframes), Z3 for transform predicates | Random input tables through the real transform | Conservation: in = out + rejected; key uniqueness; types/nullability | Property tests in CI on each transform |
| SQL transform / dbt model | Rewrite changes semantics; NULL handling | VeriEQL / SQLSolver; Hypothesis-generated tables | Old query vs. new query | Equivalent on all (bounded) databases | Run equivalence check on refactor PRs |
| DAG orchestration (Airflow, Dagster, Prefect) | Task runs twice after scheduler restart; downstream runs on partial upstream | Quint/TLA+ | Tasks, dependencies, states, scheduler crash | Dependencies respected; every run terminates; no task runs twice concurrently | MBT against a fake executor |
| Incremental load (watermark / cursor) | Boundary rows missed (`>` vs `>=`), late-committing rows skipped, clock skew | TLA+/Quint | Source rows with commit times, cursor, concurrent commits | Every source row loaded exactly once across all runs | Hypothesis: random commit timings vs. full reload oracle |
| Backfill / reprocessing | Backfill overwrites newer live data | TLA+/Quint | Live writer + backfill writer, versions | No regression to older data | Trace validation on writes |
| Idempotent re-runs (partition overwrite) | Re-run appends instead of replaces | Hypothesis | Run job twice | run(run(x)) == run(x) | Property test |
| Reconciliation jobs | Reconciler "fixes" in-flight writes, fights live path | TLA+ | Live path + reconciler + delays | Converges; never reverts a newer write | Fault test |
| Data contracts / schema evolution | Producer change breaks a consumer; nullability drift | Alloy or Z3 | Schema versions, compatibility rules (backward/forward/full) | Every live producer–consumer pair compatible | Schema-registry check in CI |

### C2. Streaming

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| Stream windowing + watermarks | Late events dropped or double-counted; windows close too early | TLA+/Quint for watermark logic; Hypothesis for aggregates | Event time vs. processing time, out-of-order arrival, allowed lateness | Final result == batch recompute on the same events (within lateness bound) | Oracle test: streaming vs. batch |
| Exactly-once via checkpoints (Flink-style) | Sink writes not tied to checkpoint; duplicates after restore | TLA+ | Operators, barriers, checkpoint store, two-phase sink | Output after restore == output without failure | Fault-injection in DST |
| Kafka transactions / EOS | Zombie producers; aborted records visible | TLA+ ([Vanlightly's spec](https://jack-vanlightly.com/analyses/2024/12/2/verifying-kafka-transactions-diary-entry-1-a-first-step)) or FizzBee | Producers, coordinators, txn log, fencing | read\_committed consumers never see aborted data | Integration test |
| Consumer groups / rebalancing | Two consumers own a partition; offsets committed before processing | TLA+/Quint | Members, generation ids, offset commits | One owner per partition per generation; at-least-once | MBT on the consumer wrapper |
| Stream–table join / enrichment | Join against wrong version of the table | Quint/TLA+ | Versioned table + stream timestamps | Join uses table state as of event time | Hypothesis oracle |
| Lambda architecture | Batch and speed layers disagree at handoff | Hypothesis | Same input to both paths | Merged view == batch view after catch-up | Oracle test |
| Kappa / replay from log | Replay not deterministic (wall clock, random, external calls) | Hypothesis + CrossHair | Replay twice | replay(log) is deterministic and == live state | Replay test |

### C3. Change data capture and storage formats

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| CDC (log-based) | Gaps or reorders on connector restart or snapshot-to-stream switch | TLA+/Quint | Source log, snapshot, connector offset, restart | Downstream eventually equals source; no gap at handoff | Trace validation on connector offsets |
| Lakehouse commits (Iceberg, Delta, Hudi) | Concurrent writers conflict; retries after "unknown" commit state duplicate data | TLA+ ([Vanlightly's Delta/Hudi models](https://jack-vanlightly.com/analyses)) | Writers, catalog pointer swap (OCC), retries, status checks | Serializable/snapshot commits; no duplicate commit on retry | Multi-writer integration test |
| Compaction / vacuum | Files deleted while a reader's snapshot uses them | TLA+ | Snapshots, retention, readers | No live snapshot references a deleted file | Fault test |
| Medallion (bronze/silver/gold) | Layer contracts drift; gold double-counts | Hypothesis per layer + Alloy for contracts | Each hop is a transform with a contract | Conservation and uniqueness at each hop | Layer-level property tests |
| Partitioned tables / late partitions | Late data lands in a closed partition and is never re-aggregated | TLA+ | Partitions, closure, late arrivals | Every row is eventually in the aggregate | Oracle test |

### C4. Modeling and analytics correctness

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| Slowly changing dimensions (SCD2) | Overlapping or gappy validity intervals; two current rows | Alloy; Hypothesis | Rows with \[valid\_from, valid\_to) per key | Intervals contiguous and non-overlapping; exactly one current row | Property test on the merge |
| Upsert / MERGE / dedup | Order-dependent results; key collisions | Hypothesis; Z3 for key design | Random duplicates and orderings | Result independent of input order; last-writer rule applied | Property test |
| Incremental materialized views | Incremental result ≠ full recompute after deletes/updates | Hypothesis | Random change streams | incremental == full recompute | Oracle test |
| Feature store (point-in-time joins) | Label leakage from future feature values | Hypothesis; Alloy | Entities, feature timestamps, label times | Feature time ≤ label time for every training row | Property test on training-set builder |
| Data lineage / PII propagation | PII flows into an unmasked output | Alloy | Columns, transforms, `derives_from` relation | No path from PII column to unmasked sink | Generate relation from lineage metadata |
| Multi-tenant pipelines | Tenant data mixed in shared jobs or caches | Alloy | Tenants, datasets, jobs, outputs | No output depends on another tenant's input | Lineage-derived check |
| Ledger / double-entry | Unbalanced entries; mutation of posted entries | Hypothesis; Dafny for core posting logic; TLA+ if concurrent | Accounts, entries, postings | Sum of debits == sum of credits; posted entries immutable; balance = sum of entries | Property + stateful tests |

### C5. Integration, identity, and signal data

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| Entity resolution / identity merge | Merges not transitive; unmerge loses data; two golden records for one person | Alloy (merge graph) + Hypothesis | Records, match edges, merge/unmerge actions | Each record in exactly one cluster; merge order-independent; unmerge restores originals | Property tests on merge engine with random match orders |
| Bi-directional sync with external systems (CRM, ticketing, calendars) | Ping-pong update loops; last-writer clobbers; deletes resurrect | TLA+/Quint | Two stores, sync jobs both ways, change markers, conflict rule | No infinite echo; convergence; deletes stay deleted | MBT with fake external API |
| Third-party API ingestion (rate-limited, paginated) | Gaps when rate-limited mid-page; duplicate pages after token refresh | TLA+/Quint; Hypothesis stateful | Cursor, rate-limit backoff, token expiry, crash | Every remote record ingested once; ingestion resumes after limits | Stateful test against a fake API with injected 429s |
| Inbound webhook ingestion | Duplicate and out-of-order deliveries; missed events with no replay | TLA+ + periodic reconciliation model | Webhook stream + reconciliation poll | Final state == source of truth after reconciliation | Oracle test vs. full pull |
| Enrichment pipelines | Enrichment overwrites user-entered data; stale enrichment wins | Alloy (field precedence) + Hypothesis | Sources with precedence and timestamps | Higher-precedence source never overwritten by lower | Property tests on merge-by-precedence |
| Activity / event aggregation (signals, analytics counters) | Double-counting on replay; late events missed | Hypothesis oracle | Event streams with duplicates and lateness | Aggregate == dedup'd batch recompute | Streaming vs. batch oracle |
| Segmentation / audience rules | Segment membership disagrees between UI, API, and exports | Z3 + Hypothesis differential | Rule expressions over profile fields | Same membership from every evaluator | Differential tests across evaluators |

## Catalog D — Storage and database internals

Treat the database as a component with a stated contract (isolation level, durability), and check that your application only relies on what that contract gives. Jepsen's MySQL analysis is the cautionary case: Repeatable Read there still allows G2-item, G-single, and lost updates ([Jepsen](https://jepsen.io/analyses/mysql-8.0.34)).

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| Transactions at a given isolation level | App assumes serializable but runs on read committed / snapshot; write skew | TLA+ app model over an abstract store parameterized by isolation; Elle on real histories | Concurrent app transactions; store allows the anomalies of the chosen level | App invariant (e.g. balance ≥ 0, one booking per seat) holds under that level | Run Elle on histories from integration tests |
| Read-modify-write without locks | Lost update | TLA+/FizzBee (FizzBee's wire-transfer example) | Two clients interleaving read and write | No lost update | Concurrency test from counterexample |
| SELECT … FOR UPDATE / pessimistic locking | Deadlocks across tables; lock order inversions | TLA+/PlusCal | Lock acquisition order per code path | Deadlock freedom (global lock order) | Static check of lock order + test |
| Optimistic concurrency (version / ETag / CAS) | ABA; retries livelock under contention | TLA+ | Readers, CAS writers, retry loop | Linearizable updates; progress under bounded contention | Stateright / linearizability checker |
| MVCC / snapshot reads | Long-running snapshot sees inconsistent cross-table state (if app splits reads) | TLA+ | Versions, snapshots, GC | Reads within one snapshot are consistent | Elle |
| WAL / commit log | Torn write or lost fsync after crash | TLA+ for protocol; DST for code | Log, fsync, crash at any point | Recovered state = prefix of acknowledged writes | DST with storage faults |
| LSM tree / B-tree / custom storage engine | Lost keys after compaction or split | Hypothesis stateful vs. dict; Kani/Shuttle in Rust | Random put/get/delete/compact | Engine == dict model; crash consistency | ShardStore-style PBT ([AWS](https://aws.amazon.com/blogs/storage/how-automated-reasoning-helps-us-innovate-at-s3-scale)) |
| ID / sequence generation (Snowflake ids, ULIDs) | Duplicates across nodes or after clock rollback | TLA+ with clock skew; Hypothesis | Nodes, clocks, counters | Uniqueness; monotonic per node | Property test with fake clocks |
| Soft delete / tombstones | Deleted rows resurface in queries or replication | Alloy (query coverage) + Hypothesis | Queries × deleted filter | No query returns tombstoned rows | Lint queries |
| Row-level security / multi-tenant schemas | Missing tenant predicate on one query path | Alloy or Z3 over policy definitions | Roles, tenants, policies | No principal reads another tenant's rows | Generated negative tests |
| Migrations (expand/contract) | Code version N and schema version N+1 incompatible mid-deploy | Alloy (version matrix), TLA+ (rollout order) | Code versions × schema versions over time | Every co-existing pair works | Run old-code tests against new schema |
| Distributed SQL / Raft-replicated KV | Stale reads after leader change | TLA+ + Jepsen/Elle | Leader leases, follower reads | Linearizable reads where claimed | Jepsen-style tests |

## Catalog E — Infrastructure, security, and policy

Configuration is data, so SMT and relational solvers fit it best. AWS's own practice is the template: Zelkova turns IAM policies into SMT to answer questions like "is this public?", and Tiros proves VPC reachability without sending packets ([Backes et al.](https://conf.researchr.org/getImage/icst-2020/orig/liana-summary.pdf)). Controllers and reconcilers are the exception: they are behavioral, so they need TLA-style liveness.

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| IAM / access policies | Unintended public or cross-account access; policy change broadens access | Z3 (Zelkova approach); IAM Access Analyzer where available | Request context as symbolic variables; allow/deny semantics | Policy B ≤ policy A (no broadening); no public principal | Policy diff check in CI |
| RBAC | Role explosion; escalation through role grants | Alloy | Users, roles, permissions, `grants` relation | No user can grant a permission they don't hold | Generate from role config |
| ABAC / policy languages (Cedar, OPA/Rego) | Policies overlap, shadow, or contradict | Cedar analyzer / Z3; OPA tests | Attributes symbolic | Default deny; forbid overrides permit; equivalence of refactored policies | Run the analyzer on every policy PR |
| ReBAC (Zanzibar-style) | Relation rewrite cycles; unexpected inheritance | Alloy | Objects, relations, rewrite rules | Expected access matrix; no unintended path | Generated tuples → check service answers |
| Network reachability (VPC, security groups, k8s NetworkPolicy) | DB reachable from internet; segmentation gaps | Z3 / MonoSAT (Tiros approach); Batfish for on-prem | Graph of subnets, rules, routes | No path from internet to private tiers | Generate model from IaC state |
| Infrastructure as code (Terraform, CDK) | Drift; invariants (encryption, tagging, regions) violated | Z3 or Alloy over the plan JSON; policy-as-code | Resources + attributes from `terraform show -json` | All buckets encrypted; no public ingress; required tags | Gate the plan in CI |
| Kubernetes controllers / operators (reconcile loops) | Never converges; flaps; acts on stale cache | TLA+/Quint for design; Anvil + Verus for verified Rust controllers ([OSDI '24](https://www.usenix.org/conference/osdi24/presentation/sun-xudong)) | Desired state, observed state, API server, stale reads, crashes | Eventually stable reconciliation (ESR); safety on owned resources | Quint MBT against the reconcile function ([example](https://see-quick.github.io/posts/model-based-testing-with-formal-verification)) |
| Secrets / certificate / key rotation | Window where old secret revoked before all clients switched | TLA+ | Issuer, distribution, clients, revocation | At every moment, every client holds a valid credential | Rotation drill test |
| OAuth / OIDC / session protocols | Token replay; mix-up attacks; CSRF in flows | Tamarin or ProVerif | Protocol roles + Dolev–Yao attacker | Secrecy; authentication; no replay | Conformance tests per message |
| Webhook signatures / HMAC verification | Timing attacks; replay of signed payloads | Tamarin (protocol) + Hypothesis (verifier) | Signed payload, timestamp, nonce | Replay outside the window rejected | Property tests on the verifier |
| Multi-account / landing-zone guardrails (SCPs) | Guardrail gap allows forbidden action | Z3 | SCP + identity + resource policies combined | Forbidden actions denied in every account | Policy-combination check |
| Disaster recovery / backups | Restore produces inconsistent cross-system state | TLA+ | Snapshot times across stores | Restored state is a consistent cut | Scheduled restore drill |

## Catalog F — APIs, frontend, and domain logic

These patterns sit closest to users and money, and most of them are checked best on the real code: schema-driven API fuzzing, state-machine path coverage, and properties over calculations. Z3 handles the rule tables that encode business policy: eligibility, pricing, promotions, routing, or jurisdiction rules.

### F1. APIs and protocols

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| REST / OpenAPI contract | Responses violate schema; 500s on edge inputs; spec drift | Schemathesis | Generated from the spec | Status codes and bodies conform; no 5xx | `st run` in CI |
| Stateful API workflows (create → get → update → delete) | Resource lifecycle bugs | Schemathesis state machine (OpenAPI links) or Hypothesis stateful | Links between operations | Created resources retrievable; deleted resources gone | `schema.as_state_machine()` |
| Idempotency keys on POST | Retry creates a duplicate charge; key reuse with different body accepted | TLA+/Quint for concurrent retries; Hypothesis for API | Client retries, concurrent duplicates, server crash after effect | Same key ⇒ same result and one effect; different body ⇒ rejected | Concurrent duplicate-request test |
| Cursor pagination | Items skipped or repeated when data changes mid-scan | TLA+ or Hypothesis stateful | Inserts/deletes interleaved with page fetches | Every item present for the whole scan is returned exactly once | Stateful test |
| API versioning | Old clients break on new server | Alloy (version matrix) + contract tests | Client versions × server versions | Supported pairs compatible | Contract tests per pair (Pact) |
| gRPC / event schema evolution (protobuf, Avro) | Field reuse; required-field changes | Z3/Alloy over schema diffs; buf breaking | Old and new schema | Wire compatibility rules hold | `buf breaking` in CI |
| Rate-limited public API | Limits bypassed via concurrency or multiple keys | TLA+ | Concurrent requests, token bucket | Never above limit per principal | Concurrency test |

### F2. Frontend and client

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| UI flows as state machines (XState) | Unreachable screens; dead ends; impossible states | XState graph path generation | The machine itself | Every state reachable; every path testable | `getShortestPaths` → Playwright tests |
| Redux / reducers / Elm architecture | Reducer breaks invariants on some action sequence | Hypothesis-style (fast-check `commands`) | Random action sequences | Store invariants hold; reducer pure | fast-check model-based test |
| Optimistic UI updates | UI shows success that the server rejected; rollback fails | TLA+ or fast-check | Client state, pending requests, server responses (out of order) | UI eventually equals server state | Model-based test with mocked server |
| Offline-first sync / local-first (CRDT or op log) | Conflicts lost; divergence after reconnect | Hypothesis/fast-check + TLA+ for protocol | Devices, offline edits, sync | Convergence; no lost edits | Multi-client simulation |
| Forms and multi-step wizards | Validation bypass via back button; partial submits | XState graph | Steps and guards | Submit only reachable with all valid fields | Generated path tests |
| Auth session handling in client | Refresh-token races log users out or double refresh | TLA+ | Tabs, refresh timers, token store | One refresh in flight; no valid session lost | Multi-tab test |

### F3. Domain logic (any industry)

Rows are grouped by the shape of the business rule, not by industry. The same template covers seat booking, hotel rooms, and warehouse stock. Money and tax rows stay, as one domain among many.

| Pattern | Examples | What breaks | Tool | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| Rule / eligibility / decision tables | Insurance eligibility, loan approval, content moderation rules, shipping zones, tax jurisdictions, feature entitlement | Overlapping or missing rules; two outcomes apply; none applies; effective dates overlap | Z3 (Alloy for small tables) | Completeness and uniqueness for every valid input; date ranges non-overlapping | Generate SMT from the rule tables in CI |
| Pricing, fee, and discount calculation | Cart pricing, ride fares, SaaS usage bills, shipping cost, sales tax | Line items don't sum to total; order dependence; rounding drift | Hypothesis; Dafny/Lean core if stakes justify | Sum(lines) == total under the rounding rule; order-independent; refund reverses charge | Property tests on the calculator |
| Promotion / coupon stacking | Retail promos, loyalty multipliers, referral credits | Stacking produces negative price or exceeds caps; exclusive promos combine | Z3 | Price ≥ 0; caps respected; exclusivity constraints hold for every combination | SMT over promo config |
| Inventory and reservations | Seat booking, hotel rooms, warehouse stock, appointment slots, concert tickets | Overbooking under concurrency; holds never released | TLA+/Quint or FizzBee; Hypothesis stateful | Reserved ≤ capacity; every hold expires or converts; no double allocation | Concurrency test from counterexample |
| Order / fulfillment lifecycle | E-commerce orders, food delivery, returns/RMAs | Shipping a cancelled order; refunding twice; stuck states | Quint/TLA+ or XState | Only allowed transitions; terminal states final; each order eventually terminal | MBT on order service |
| Subscriptions and entitlements | SaaS plans, streaming access, software licences, trials | Access after cancellation; proration errors; double renewals | Hypothesis stateful + Alloy for plan/feature matrix | Entitlement == f(current plan, time); one renewal per period | Stateful test with fake clock |
| Quotas, limits, and threshold accumulators | API quotas, spend limits, fraud velocity rules, compliance thresholds | Limit crossed on the wrong event; double-counted on replay | Hypothesis; TLA+ if concurrent ingestion | Crossing point order-independent and idempotent under replay; never exceed hard limit | Oracle test vs. batch recompute |
| Matching and allocation | Ride dispatch, marketplace order books, job scheduling, ad auctions, school/residency matching | Same resource matched twice; unfair or unstable match; auction rule violated | TLA+/Quint for concurrency; Z3 or Hypothesis for the algorithm | Each resource matched at most once; price/priority rules hold (e.g. second-price, stability) | Property tests on matcher + concurrency test |
| Approval and submission workflows | Expense approvals, PR reviews, claims processing, regulatory filings, KYC | Approved without required approvers; submitted twice; amended before accepted | Quint/TLA+ or XState; Alloy for approver rules | Required approvals before submit; one accepted submission per period; separation of duties | MBT on workflow service |
| Permissions on shared content | Docs/folders sharing, project roles, healthcare record access | Inherited access leaks; revocation doesn't propagate | Alloy | Expected access matrix; revocation removes all derived paths | Generated negative tests |
| Collaborative editing / versioning | Document editors, design tools, wikis, config versioning | Concurrent edits lost; merges diverge; history rewritten | Hypothesis (OT/CRDT laws) + TLA+ for sync protocol | Convergence; intention preservation; history append-only | Multi-client simulation |
| Notification and messaging dedup | Email/SMS/push, alerting, reminders | Duplicate sends on retry; missed sends on failover | TLA+/Quint | Each notification sent at most once per key and at least once eventually | Crash-injection test |
| Counters, leaderboards, voting, polls | Likes, game scores, elections, rankings | Lost increments; double votes; ranking ties mishandled | TLA+ (concurrency) + Hypothesis (ranking rules) | Count == accepted events; one vote per voter; total order on ties | Concurrency + property tests |
| Game and simulation state | Turn-based games, physics steps, multiplayer lobbies | Illegal moves accepted; desync between clients | Hypothesis stateful; TLA+ for lobby/sync | Only legal moves; deterministic replay; clients converge | Replay tests |
| Money and rounding | Any currency handling | Float use; half-up vs banker's mismatch; currency mixing | Hypothesis + CrossHair contracts | Allocations sum exactly (largest-remainder); no cross-currency arithmetic | Contracts on a Money type |
| Units and measurement | Dosage, logistics weights, engineering units | Unit mix-ups; precision loss | Hypothesis; type-level units | Round-trip conversions within tolerance; no mixed-unit arithmetic | Unit-typed APIs + property tests |
| Time zones, calendars, periods | Billing periods, payroll, reporting windows, SLAs | Off-by-one at DST and month/year boundaries | Hypothesis datetime strategies | Each instant maps to exactly one period; periods contiguous | Property tests |
| Scheduling and recurrence | Calendars, shift rosters, maintenance windows | Missed or duplicated occurrences across DST; double-booked staff | Hypothesis; Z3 for constraint-based rostering | Occurrences unique and complete; no person in two shifts at once | Property tests + SMT check of roster |
| Search, ranking, recommendation rules | Catalog search filters, feed ranking constraints | Filtered-out items appear; business boosts break hard constraints | Hypothesis metamorphic tests | Adding a filter never adds results; hard constraints always enforced | Metamorphic property tests |
| Reports and exports | Dashboards, CSV exports, invoices, statements | Export totals disagree with source or UI | Hypothesis differential | Export totals == report totals == source aggregates | Oracle test |

## Catalog G — Real-time communication and collaboration

Real-time systems combine distributed protocols with hard timing, so they need two kinds of tool: TLA+/Quint or P for signaling and session state, and UPPAAL or timed TLA+ where deadlines matter. Media quality itself is out of scope for formal tools; verify the control plane, and load-test the data plane.

| Pattern | What breaks | Tool | Model | Properties | Code link |
| --- | --- | --- | --- | --- | --- |
| Session / meeting lifecycle | Ghost participants after crash; meeting never ends; host transfer races | Quint/TLA+ or P | Participants, host role, join/leave/crash, server failover | Exactly one host while active; meeting ends when last leaves; no ghosts after timeout | MBT on session service |
| Signaling (SDP offer/answer, ICE, renegotiation) | Glare (both sides offer); stuck renegotiation | P or TLA+ | Two peers + signaling server, message reordering | Every negotiation terminates in a stable state; glare resolved deterministically | Trace validation on signaling logs |
| SFU / media routing control plane | Subscriber routed to a dead forwarder; duplicate streams after migration | TLA+/Quint | Rooms, SFU nodes, subscriptions, node failure | Each subscription served by exactly one live node; migration loses no subscription | Fault-injection test |
| Presence | Users shown online after disconnect; flapping | TLA+ with heartbeats and clock skew | Heartbeats, TTLs, multi-device | Eventually accurate presence; bounded staleness | Simulation with dropped heartbeats |
| Chat / message delivery and ordering | Messages reordered per conversation; duplicates on reconnect; read receipts regress | TLA+/Quint; Hypothesis stateful client | Per-conversation sequence numbers, offline clients, resend | Per-conversation total order; at-most-once display; read pointer monotonic | Multi-client simulation |
| Typing indicators / ephemeral state | Stale indicators never cleared | TLA+ or UPPAAL | Timers + lossy delivery | Indicators expire within bound | Timer test |
| Recording and transcription pipelines | Segments missing or duplicated; transcript doesn't match recording | TLA+ for pipeline; Hypothesis for stitching | Segment upload, retries, assembly | Every segment assembled exactly once, in order | Oracle test on stitcher |
| Permissions in live sessions (waiting room, breakout rooms, screen-share rights) | Unadmitted user receives media; breakout reassignment leaks audio | Alloy + TLA+ | Roles, rooms, admissions, moves | Media only to admitted members of the same room | Generated negative tests |
| Shared whiteboard / co-editing | Diverging canvases | Hypothesis CRDT laws + TLA+ sync | Concurrent ops, reconnects | Convergence | Multi-client simulation |
| Notifications and calendar integration | Duplicate invites; reminders at wrong time across time zones | Hypothesis + TLA+ | Calendar sync, recurrence, time zones | One invite per change; reminders at correct local time | Property tests |

## Linking models to real code

A model that is never tied to code drifts. Datadog found a year-old bug, conflicting placements in under 0.01% of cases that crashed backfill recovery, only after it started checking production telemetry against its TLA+ specs continuously ([Datadog, Nov 2026](https://www.datadoghq.com/blog/engineering/continuous-formal-spec-validation)). Every model the skill writes should therefore ship with at least one of these links.

| Technique | Direction | How it works | Tooling | Use when |
| --- | --- | --- | --- | --- |
| Model-based testing (MBT) | Model → code | Generate traces from the model; a driver replays each action on the implementation and compares state after every step | `quint run --mbt` + quint-connect (Rust, TS); Hypothesis stateful; XState graph; Schemathesis | You can call the implementation's operations directly in a test |
| Counterexample → regression test | Model → code | Translate each violating trace into a deterministic test that forces the same interleaving | Hand-written driver; quint-connect saves failing traces as replayable files | Every time the checker finds a bug |
| Trace validation | Code → model | Log events from real runs, merge logs, check that some spec behavior matches the trace | TLC trace specs ([Kuppe et al.](https://conf.tlapl.us/2024/MarkusAKuppe-ValidatingSystemExecutionsWithTheTLAPlusTools.pdf)); MongoDB, CCF, etcd used it | Distributed code you can instrument but not drive step-by-step |
| Runtime monitoring | Code → model, continuously | Compile spec actions into monitors that check preconditions on live telemetry | FETCh (TLA+ → Rust, \~2% p90 CPU overhead on 1,300 pods); PObserve for P | Long-lived systems where implementations evolve |
| Differential random testing | Both ways | Executable reference model and production code run on millions of random inputs; outputs must match | Cedar: Lean model vs. Rust; Lean evaluates an input in \~5 µs vs. 7 µs for Rust ([AWS](https://aws.amazon.com/blogs/opensource/lean-into-verified-software-development)) | Pure functions: evaluators, calculators, policy engines |
| Deterministic simulation testing | Code under faults | Run the whole system in a deterministic simulator or hypervisor, inject faults, replay any failure by seed | Antithesis; TigerBeetle VOPR; FoundationDB simulation | Systems where concurrency and faults dominate |
| Black-box history checking | Code → consistency model | Record client operations, check histories for anomalies | Jepsen + Elle; Stateright and Porcupine for linearizability | Databases and anything claiming an isolation or consistency level |
| Refinement | Model → model | Prove or check that a detailed model implements an abstract one | TLA+ refinement (Cosmos DB); Anvil/Verus for code | Layered designs; keeping a monitorable spec and a checkable spec in sync |

**Practical defaults for the skill:**

- Python services: Hypothesis stateful tests as the driver, TLC random traces as input (\`-simulate file=…,num=N\` writes one file per behaviour; a small adapter maps each step to a method call), CrossHair for contracts.
- TypeScript: fast-check + `fc.commands` or XState graph.
- Rust: Kani, plus Shuttle/Loom or Stateright when the specialist trigger applies.
- Distributed services you can't drive directly: structured event logs → TLA+ trace validation, then a runtime monitor once stable.

**Trace-validation pitfalls to encode:** implementations are finer-grained than specs, so log at the spec's atomicity; when logs come from separate nodes, use logical or vector clocks; a failed validation can mean a bad log mapping, not a bug, so check the mapping first ([Demirbas on CCF](https://muratbuffalo.blogspot.com/2025/02/smart-casual-verification-of.html)).

## Skill design spec for Claude Code

The skill is a workflow, not a tool wrapper. Its loop: classify → select → model → check → sanity-check the model → link to code → report. Its main risk is LLM-written specs that parse and pass yet don't model the system. Benchmarks show this clearly. SysMoBench found LLM specs pass syntax on complex systems but break down on runtime and conformance checks, often by merging multi-step code into one atomic action ([SIGOPS, 2026](https://sigops.org/2026/can-llms-model-real-world-systems-in-tla)). Another study saw semantic correctness only under progressive, checker-in-the-loop prompting ([AI4FM](https://ai4fm.cs.luc.edu/papers/llm-tla-evaluation/)).

### Folder structure

```
formal-verification/              # router skill (see Example library for per-tool layout)
  SKILL.md                        # workflow, decision procedure, guardrails
  reference/
    tool-catalog.md               # 9 core tools + 7 specialists and their triggers
    pattern-catalog.md            # catalogs A–G from this doc, one entry per pattern
    property-library.md           # the 12 property families, phrased per tool
    fault-models.md               # fault switches and how to encode each per tool
    linking.md                    # MBT, trace validation, DRT, DST recipes
  templates/
    tla/                          # outbox, idempotent-consumer, saga, lease-fencing,
                                  # leader-election, cdc, watermark-cursor, dag-scheduler,
                                  # k8s-reconciler, cache-invalidation, two-phase-commit
    alloy/                        # rbac, rebac, schema-compat, scd2, lineage-pii, tenant-isolation
    z3/                           # rule-table completeness/uniqueness, policy-diff, iac-invariants
    hypothesis/                   # stateful-vs-dict, oracle-equivalence, conservation, idempotence
    dafny/                        # verified calculator core + differential-test harness
  scripts/
    install.sh                    # tla2tools.jar, apalache, alloy jar, z3, hypothesis,
                                  # schemathesis, crosshair, dafny (kani only in Rust repos)
    run_tlc.sh  run_alloy.sh  run_z3.py
    tlc_trace_to_pytest.py        # turn TLC counterexamples into pytest regression tests
    trace_to_tla.py               # structured logs -> TLA+ trace spec
```

### Workflow (what SKILL.md tells Claude to do)

1. **Scope.** Read the code or design doc. List components, shared state, external calls, and every place a crash, retry, or concurrent call can happen.
2. **Classify.** Map each component to pattern ids from catalogs A–G. If none fits, say so and fall back to the four questions in *How to use this doc*.
3. **State properties in English first.** Pick from the property library, and get the user to confirm them before writing any spec. A wrong property is the most expensive mistake.
4. **Select the tool** with the decision procedure below. Prefer the cheapest rung of the escalation ladder that can produce the failure.
5. **Write the model from a template.** Keep the abstraction: model only the state the property mentions plus the fault switches. Write one action per real atomic step in the code (one DB write, one message send), never one per function.
6. **Run the checker** with small bounds first (2–3 processes, 1–2 crashes), then widen.
7. **Sanity-check the model before trusting a pass:**
   - Add reachability ("sometimes") checks for every interesting state: commit, crash-recovery, compensation.
   - Mutation check: break the protocol on purpose (drop a dedup step, swap two writes). The checker must fail. If it still passes, the model or property is vacuous.
   - Check liveness, not only safety, where the pattern has a progress property.
8. **Explain counterexamples** as a numbered timeline in the system's own vocabulary ("worker B's lease expires during GC pause; worker A acquires; B resumes and writes").
9. **Link to code:** generate the regression test from the counterexample, plus an MBT or oracle test from the model. Name the remaining gap if no link is possible.
10. **Report:** properties checked, bounds used, faults enabled, what passed, what failed, what is *not* covered.

### Decision procedure (encode as a table in SKILL.md)

| If the question is… | Use | Unless… |
| --- | --- | --- |
| Interleavings, crashes, retries across processes | TLA+ (PlusCal inside it is fine) | Team writes Rust and wants the model to be the code → Stateright |
| Message-passing services where the model should look like code | P | — |
| Structure, relations, permissions, schema compatibility | Alloy | Large integer/string arithmetic → Z3 |
| Rule tables, policy diffs, config invariants | Z3 | Policies are Cedar → Cedar analyzer |
| Correctness of a pure function or calculator | Hypothesis / fast-check | Bug is unacceptable → Dafny or Lean model + differential testing |
| Python function contracts | CrossHair | Needs proof → Nagini |
| Rust safety / panics / unsafe | Kani | Concurrency → Shuttle or Loom |
| SQL rewrite safety | VeriEQL / SQLSolver | — |
| Does the running system obey the model? | MBT (if drivable) else trace validation | Whole-cluster faults → DST/Antithesis |
| Does a datastore meet its isolation claim? | Jepsen + Elle | — |
| Auth or crypto protocol | Tamarin | — |
| Timing / deadlines | UPPAAL | Coarse timeouts → TLA+ with a clock variable |

### Guardrails

- Never report "verified" without stating the bounds, the faults enabled, and the code link (or its absence).
- Never weaken a property to make the checker pass; ask the user instead.
- Keep each spec under \~300 lines; split by component and compose. The Cosmos DB client-facing spec was 390 lines and still explained a 28-day outage ([Hackett et al.](https://arxiv.org/pdf/2210.13661)).
- Run the checker after every edit; do not write a whole spec before the first run.
- Commit specs, configs, and counterexample traces next to the code they model, and run them in CI.
- Treat a failed trace validation as "mapping or bug" until the log mapping is checked.

## Example library: good and bad uses, packaged as skills

Package this as **one router skill plus one skill per core tool (9)**. Each tool skill carries its own good and bad examples, loaded progressively. A single giant skill would load every tool's examples whenever any of them is relevant. Per-tool skills keep each activation small, and the router (the `formal-verification` skill above) decides which ones to pull in. This follows Anthropic's guidance: keep SKILL.md as a short overview that points to detailed files, and keep it under \~500 lines ([best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)).

### Layout and disclosure levels

```
fv-tlaplus/                       # same shape for fv-alloy, fv-z3, fv-hypothesis, fv-schemathesis,
  SKILL.md                        #   fv-crosshair, fv-kani, fv-dafny, fv-elle
                                  # L2: workflow, 5 golden rules, 1-line summary of top good/bad examples
  examples/
    INDEX.md                      # L3: table of every example: id, pattern ids (A1..G), good|bad, lesson, file
    good/
      two-phase-commit/           # L4: spec + cfg + README (source link, licence, what it teaches)
      raft/ ...
    bad/
      vacuous-liveness/           # L4: broken spec, the checker output, why it is wrong, fixed version
      merged-atomicity/ ...
  reference/                      # L3: syntax cheatsheet, checker flags, error-message decoder
  scripts/                        # run checker, harvest examples, mutation-test a spec
```

Rules for every example entry:

- **Good examples** record: source link and licence, the pattern ids it maps to, the property checked, bounds used, and the one lesson it teaches.
- **Bad examples** record: the broken artifact, the symptom (often "it passes"), why it is wrong, the fix, and a mutation or sanity check that would have caught it. Bad examples should outnumber good ones, because they teach what to check.
- **Vendor files only where the licence allows**; otherwise store a link and a summary. `tlaplus/Examples` and `AlloyTools/models` are open-licensed corpora; check each spec's licence.
- **Harvest, don't hand-copy:** `tlaplus/Examples` keeps a `manifest.json` per spec with feature flags (beginner, TLAPS proof, PlusCal, TLC model, Apalache), so a script can classify the whole repo by feature ([repo](https://github.com/tlaplus/Examples)).

### Seed corpora (where "as many as possible" comes from)

| Tool | Corpus | Notes |
| --- | --- | --- |
| TLA+ | [tlaplus/Examples](https://github.com/tlaplus/Examples) | Official library, CI-validated, tagged by feature and checker |
| TLA+ | [Azure Cosmos DB specs](https://github.com/tlaplus/azure-cosmos-tla), [Kafka specs](https://jack-vanlightly.com/analyses/2024/12/2/verifying-kafka-transactions-diary-entry-1-a-first-step), [MongoDB conformance](https://mongodb.com/blog/post/engineering/conformance-checking-at-mongodb-testing-our-code-matches-our-tla-specs) | Industrial specs and process write-ups |
| TLA+ | [learntla.com](https://learntla.com/core/temporal-logic.html), [tiny-tlaplus-examples](https://github.com/lostbearlabs/tiny-tlaplus-examples) | Small, single-feature teaching specs |
| Alloy | [AlloyTools/models](https://github.com/AlloyTools/models), [Practical Alloy](https://practicalalloy.github.io) book repo, [Software Abstractions models](https://softwareabstractions.org/models/a4-models-index.html) | Book models are Alloy 4; need porting to Alloy 6 syntax |
| Z3 | [Programming Z3](https://theory.stanford.edu/~nikolaj/programmingz3.html), [Z3 guide](https://microsoft.github.io/z3guide/programming/Z3%20Python%20-%20Readonly/Introduction/) | Python API examples by theory |
| Hypothesis | [Rule-based stateful testing](https://hypothesis.works/articles/rule-based-stateful-testing/), [Agentic PBT paper](https://arxiv.org/pdf/2510.09907) | The paper's prompt is a tested recipe for LLM-written property tests |
| Schemathesis | [Docs and CI examples](https://pypi.org/project/schemathesis/4.15.1/) | Stateful workflows via OpenAPI links |
| CrossHair | `examples/` dir + [case studies](https://crosshair.readthedocs.io/en/stable/_sources/case_studies.rst.txt) | Contract styles: asserts, PEP 316, icontract, deal |
| Kani | [Tutorial](https://model-checking.github.io/kani/tutorial-real-code.html) (Rectangle, std CVE, Firecracker) | Also the Rust std-library verification challenges |
| Dafny | [Verification optimisation guide](https://dafny.org/latest/VerificationOptimization/VerificationOptimization), [brittleness post](https://dafny.org/blog/2023/12/01/avoiding-verification-brittleness/) | Before/after pairs of brittle vs. stable proofs |
| Elle | [Jepsen analyses](https://jepsen.io/analyses/mongodb-4.2.6), [Elle paper](https://arxiv.org/pdf/2003.10554) | Real anomaly reports with explanations |
| Prior-art skills | [TLA+ review skill](https://skills.lc/photoszzt/tlaplus-ai-tools/photoszzt-tlaplus-ai-tools-claude-skills-tla-model-checking-skill-md), [Kani skill](https://openskillindex.com/skills/majiayu000-claude-skill-registry-kani-verifier), [Hypothesis skill](https://tessl.io/registry/testland/hypothesis-testing) | Mine their checklists; don't copy wholesale |

### Good-example starter set (named exemplars)

| Tool | Exemplar | What it teaches | Patterns | Source |
| --- | --- | --- | --- | --- |
| TLA+ | Two-phase commit (TCommit / TwoPhase) | Smallest real protocol; atomicity + fault switch (TM may fail) | B2 | [tlaplus/Examples](https://github.com/tlaplus/Examples), [Demirbas walkthrough](https://muratbuffalo.blogspot.com/2018/12/2-phase-commit-and-beyond.html) |
| TLA+ | Raft (Ongaro) and its extensions | Consensus safety properties; how to extend a spec per feature | B3 | [tlaplus/Examples](https://github.com/tlaplus/Examples) |
| TLA+ | EWD998 trace-validation tutorial | Instrumenting code, merging logs, writing the Trace spec | Linking | [Kuppe et al.](https://conf.tlapl.us/2024/MarkusAKuppe-ValidatingSystemExecutionsWithTheTLAPlusTools.pdf) |
| TLA+ | Cosmos DB client-centric spec | Model what clients observe, not internals; refinement between levels | B3, D | [paper](https://arxiv.org/pdf/2210.13661) |
| TLA+ | Kafka transactions, built in diary entries | Growing a large spec incrementally; abstracting subsystems; sanity-checking with liveness | C2 | [Vanlightly](https://jack-vanlightly.com/analyses/2024/12/4/verifying-kafka-transactions-diary-entry-3-getting-confidence-in-the-tla-spec) |
| TLA+ | Iceberg multi-writer commit model with *expected* failures | Configs that must fail prove a patch is necessary | C3 | [pgEdge coldfront](https://docs.pgedge.com/coldfront/v1-0-0-beta1/formal/) |
| Alloy | Hotel room locking (Software Abstractions ch. 6) | Classic security bug found by a model; frame conditions | E, F3 | [models](https://softwareabstractions.org/models/a4-models-index.html) |
| Alloy | Practical Alloy chapters (structural, then protocol design) | Alloy 6 style: `var`, temporal operators, visualizer traces | A1, E | [Practical Alloy](https://practicalalloy.github.io) |
| Z3 | Policy containment (Zelkova idea): "is B ≤ A?" | Encode allow/deny semantics; compare two policies | E | [Zelkova paper](https://discovery-pp.ucl.ac.uk/id/eprint/10081411/1/Semantic-based%20Automated%20Reasoning%20for%20AWS%20Access%20Policies%20using%20SMT.pdf) |
| Z3 | Programming Z3 worked examples | API idioms per theory; when `unknown` appears | F3 | [Programming Z3](https://theory.stanford.edu/~nikolaj/programmingz3.html) |
| Hypothesis | Heap `RuleBasedStateMachine` | Stateful testing with bundles, preconditions, invariants | A2 | [hypothesis.works](https://hypothesis.works/articles/rule-based-stateful-testing/) |
| Hypothesis | Database-vs-dict comparison machine | Model-based testing against a trivial oracle | A2, D | [Hypothesis docs](https://hypothesis-test-zhd.readthedocs.io/en/latest/stateful.html) |
| Hypothesis | S3 ShardStore PBT | PBT as the main correctness tool for a storage engine | D | [AWS](https://aws.amazon.com/blogs/storage/how-automated-reasoning-helps-us-innovate-at-s3-scale) |
| Schemathesis | `schema.as_state_machine()` workflow test | Create → get → delete chains from links | F1 | [PyPI docs](https://pypi.org/project/schemathesis/4.15.1/) |
| CrossHair | `diffbehavior` on a refactor | Find inputs where old and new functions disagree | A3, C1 | [CrossHair](https://crosshair.readthedocs.io/en/latest/related_work.html) |
| Kani | `double()` overflow harness; Firecracker GCD with `unwind` | `kani::any`, `assume`, unwind bounds | A3 | [std verification](https://arxiv.org/pdf/2510.01072), [Kani paper](https://arxiv.org/pdf/2607.01504) |
| Dafny / Lean | Cedar: executable model + proofs + differential random testing | The full verification-guided development loop | E | [Cedar paper](https://arxiv.org/pdf/2407.01688) |
| Elle | MongoDB 4.2.6 and MySQL 8.0.34 analyses | Reading anomaly reports; matching claims to observed isolation | D | [MongoDB](https://jepsen.io/analyses/mongodb-4.2.6), [MySQL](https://jepsen.io/analyses/mysql-8.0.34) |
| Runtime monitoring | Datadog FETCh on Husky routing | Observable vs. checkable spec split; per-process vs. global monitors | Linking | [Datadog](https://www.datadoghq.com/blog/engineering/continuous-formal-spec-validation) |

### Bad-example catalog (anti-patterns per tool)

| Tool | Anti-pattern | Symptom | Fix / check | Source |
| --- | --- | --- | --- | --- |
| TLA+ | One action per function instead of per atomic step | Spec passes; real interleavings are unreachable | One action per DB write / message; trace-validate | [SIGOPS 2026](https://sigops.org/2026/can-llms-model-real-world-systems-in-tla) |
| TLA+ | Liveness checked with no fairness | Liveness fails on stuttering, or is never meaningfully checked | Add WF on the processes that must progress | [learntla](https://learntla.com/core/temporal-logic.html) |
| TLA+ | Strong fairness sprinkled on every action | Liveness "proved" under assumptions no implementation provides | Use SF only where justified; prefer WF | [tlaplus group](https://groups.google.com/g/tlaplus/c/V3XJGR1n67U) |
| TLA+ | Vacuous fairness: action is never continuously enabled | WF holds trivially; property proves nothing | Check enabledness; use SF or restructure | [Sergey course notes](https://ilyasergey.net/CS6213/week-06-tla.html) |
| TLA+ | Symmetry sets used with liveness checking | Unsound liveness results | Symmetry for safety only | [Loncaric slides](https://conferences.mpi-inf.mpg.de/rg1/vtsa25/slides/Loncaric-2.pdf) |
| TLA+ | Unbounded state space (queues, counters) | TLC never finishes | State constraints or bounded constants; say so in report | [Sergey course notes](https://ilyasergey.net/PFM24/week-06-tla.html) |
| TLA+ | Invariants only, no action properties | Implementation violates the spec while the invariant still holds | Add action/refinement properties | [Datadog](https://www.datadoghq.com/blog/engineering/continuous-formal-spec-validation) |
| TLA+ | Trivially true property | "Passes" forever | Mutate the property; it must fail | [TLA-Prover](https://ai4fm.cs.luc.edu/papers/tla-prover/) |
| Alloy | Overconstraint via facts | No instances at all, so every `check` passes | `run` each predicate first; use unsat cores | [Alloy tutorial](https://alloytools.org/tutorials/online/sidenote-overconstraint.html) |
| Alloy | Facts that forbid the illegal states you need to handle | Model can't show how the system reaches a bad state | Move constraints from facts into predicates and assertions | [Hillel Wayne](https://hillelwayne.com/post/alloy-facts/) |
| Alloy | `x.f in S` when `x.f` can be empty | Vacuously true | Add `some x.f` | [Alloy forum](https://alloytools.discourse.group/t/tip-pitfalls-with-using-in-for-typechecking/420) |
| Alloy 6 | Missing or lax frame conditions | Unrelated mutable fields change arbitrarily | Frame every `var` per event; per-element, not union | [Alloy forum](https://alloytools.discourse.group/t/hello-learning-alloy-can-someone-help-me-with-a-basic-question-on-temporal-models/288) |
| Hypothesis | Heavy `assume()` / filters | `Unsatisfied` or `filter_too_much` health check; few real cases | Build constrained strategies | [guide](https://helpmetest.com/blog/hypothesis-python-guide/) |
| Hypothesis | Weak property ("doesn't crash", or one fixed value) | Green suite, no bug-finding power | Round-trip, metamorphic, oracle, or invariant properties | [Tessl reference](https://tessl.io/registry/testland/hypothesis-testing/1.2.16/files/references/hypothesis-reference.md) |
| Hypothesis | Mocks inside the property | Property tests the mock | Real implementations or pure functions | same |
| Hypothesis | Testing properties the code never claims | False alarms | Only claimed properties; check callers for input domain | [Agentic PBT](https://arxiv.org/pdf/2510.09907) |
| Hypothesis | Random seed in CI, `.hypothesis/` not kept | Flaky, unreproducible failures | Fixed seed or `derandomize`; pin failures with `@example` | [Tessl](https://tessl.io/registry/testland/hypothesis-testing/files) |
| Z3 | Non-polynomial arithmetic (e.g. `2**x`) or heavy quantifiers | `unknown` | Bound it, use bit-vectors, or drop quantifiers | [Z3 guide](https://microsoft.github.io/z3guide/programming/Z3%20Python%20-%20Readonly/Introduction/) |
| Z3 | Expecting Z3 to prove inductive facts | Timeouts / unknown | Supply the induction yourself, or use Dafny/Lean | [Z3 tutorial](https://www.cs.colostate.edu/~cs440/spring19/slides/z3-tutorial.pdf) |
| Dafny | Monolithic proofs near the solver's threshold | Breaks on renames or Dafny upgrades (brittleness) | Small lemmas, explicit asserts, measure resource units | [Dafny blog](https://dafny.org/blog/2023/12/01/avoiding-verification-brittleness/) |
| Dafny | Raising the timeout to fix a failure | Still fails; just slower | Find the missing fact; split verification batches | [Dafny IDE paper](https://arxiv.org/pdf/1404.6602) |
| Kani | Unbounded loops without `unwind` | Never terminates | Start at `unwind(1)` and raise; keep unwinding assertions on | [Kani tutorial](https://model-checking.github.io/kani/tutorial-real-code.html) |
| Kani | `kani::assume` narrows inputs silently | "Proof" covers a tiny range | State assumptions in the report; use `requires` contracts | [Rust std verification](https://arxiv.org/pdf/2606.17374) |
| Kani | Using it for concurrency | Not supported | Shuttle / Loom | [Kani summary](https://www.emergentmind.com/papers/2607.01504) |
| CrossHair | Reading "no counterexample" as proof | False confidence | Report as "none found within budget" | [CrossHair docs](https://docsearch.algolia.com/mcp/docs/repo/pschanely/crosshair) |
| CrossHair | Non-deterministic or non-terminating code | Result capped at UNKNOWN | Inject clocks/randomness; bound loops | [CrossHair discussion](https://www.github.com/pschanely/CrossHair/discussions/156) |
| Schemathesis | No OpenAPI links declared | Stateful workflows never exercised | Declare links (create → get → delete) | [guide](https://qaskills.sh/blog/schemathesis-openapi-property-testing) |
| Elle | Taking every reported anomaly at face value | Chasing false leads | Jepsen advises checking anomalies by hand | [Elle README](https://cljdoc.org/d/elle/elle/0.1.0) |
| Elle | Expecting predicate anomalies to be caught | Repeatable read and serializable can't be told apart | Add predicate-specific tests | [Elle paper](https://arxiv.org/pdf/2003.10554) |
| Any | LLM writes spec, runs checker once, reports success | Syntax passes, semantics wrong | Progressive, checker-in-the-loop generation; mutation checks; human review of properties | [AI4FM](https://ai4fm.cs.luc.edu/papers/llm-tla-evaluation/) |

### Next step for the build

Hand Claude Code this doc and ask it to: scaffold the router skill and the 9 tool skills; write `harvest_examples.py` per corpus; populate `examples/bad/` first, one folder per row above, each with a broken artifact, checker output, and fix; then fill `examples/good/` from the corpora, tagged with the pattern ids from catalogs A–G.

## Setup (setup.md)

The full `setup.md` ships alongside this doc as a file, ready to drop into the skill repo. It covers prerequisites, per-tool installs, smoke tests, a CI Docker image, and a GitHub Actions job. The TLC, Alloy, and Z3 smoke tests were run on 2026-11-12 against TLC (latest release), Alloy 6.2.0, and z3-solver, and passed.

| Tool | Install | Smoke test |
| --- | --- | --- |
| TLA+ (TLC, PlusCal) | `tla2tools.jar` from tlaplus releases + Java 17+ | Counter spec → "No error has been found" |
| Apalache | Release archive from apalache-mc | `apalache-mc check --inv=Inv Spec.tla` |
| Alloy 6 | `org.alloytools.alloy.dist.jar` from releases | `java -jar alloy.jar exec a.als` → SAT |
| Z3 | `pip install z3-solver` | `x>2, x<4` → `sat [x = 3]` |
| Hypothesis | `pip install hypothesis pytest` | CI profile with `derandomize=True` |
| Schemathesis | `pip install schemathesis` | `schemathesis run` on the demo API |
| CrossHair | `pip install crosshair-tool` | `crosshair check pkg/` |
| Kani | `cargo install --locked kani-verifier && cargo kani setup` | `cargo kani` |
| Dafny | `dotnet tool install --global dafny` | `dafny verify file.dfy` |
| Elle | Clojure dep `elle/elle`, or a standalone CLI wrapper | Check a recorded list-append history |

Two corrections came out of testing. The current TLC release rejects `-dumpTrace`, so traces for model-based tests come from `-simulate file=…,num=N` (one file per behaviour) or a `Json`-module `ALIAS`. Alloy 6.2 has a headless `exec` subcommand for CI.

## Sources

Industry practice

- [Systems Correctness Practices at AWS](https://cacm.acm.org/practice/systems-correctness-practices-at-amazon-web-services) (CACM 2025): TLA+, P, PObserve, PBT, fuzzing, DST
- [P case studies](https://p-org.github.io/P/casestudies): S3, EBS, DynamoDB, Aurora, EC2
- [TLA+ at AWS: Past, Present, Future](https://conf.tlapl.us/2023/dragoischwiderski/)
- [How automated reasoning helps Amazon S3](https://aws.amazon.com/blogs/storage/how-automated-reasoning-helps-us-innovate-at-s3-scale): ShardStore, Shuttle
- [Datadog: continuously validating formal specs in production](https://www.datadoghq.com/blog/engineering/continuous-formal-spec-validation) (FETCh)
- [MongoDB conformance checking](https://mongodb.com/blog/post/engineering/conformance-checking-at-mongodb-testing-our-code-matches-our-tla-specs)
- [Understanding Inconsistency in Azure Cosmos DB with TLA+](https://arxiv.org/pdf/2210.13661)
- [Smart Casual Verification of CCF](https://arxiv.org/html/2406.17455v1)
- [Verifying Kafka transactions (Vanlightly)](https://jack-vanlightly.com/analyses/2024/12/2/verifying-kafka-transactions-diary-entry-1-a-first-step)
- [How We Built Cedar: verification-guided development](https://arxiv.org/pdf/2407.01688); [Lean at Cedar](https://aws.amazon.com/blogs/opensource/lean-into-verified-software-development)
- [Zelkova / Tiros overview](https://conf.researchr.org/getImage/icst-2020/orig/liana-summary.pdf); [Zelkova paper](https://discovery-pp.ucl.ac.uk/id/eprint/10081411/1/Semantic-based%20Automated%20Reasoning%20for%20AWS%20Access%20Policies%20using%20SMT.pdf)

Tools

- [Quint + quint-connect](https://docs.rs/quint-connect); [MBT with Quint](https://see-quick.github.io/posts/model-based-testing-with-formal-verification)
- [FizzBee](https://fizzbee.io); [FizzBee intro](https://thenewstack.io/introducing-fizzbee-simplifying-formal-methods-for-all/)
- [Alloy 6](https://alloytools.org/alloy6.html); [Alloy releases](https://alloytools.org/)
- [Kani paper](https://cdn.amazon.science/05/be/d3a0c9c241e1b6ffbf5b2e6eddb4/scipub-approval152129-47347564-kani-a-model-checker-for-rust.pdf); [Shuttle](https://github.com/awslabs/shuttle); [Stateright](https://docs.rs/crate/stateright/latest)
- [CrossHair related work](https://crosshair.readthedocs.io/en/latest/related_work.html); [Hypothesis stateful testing](https://hypothesis.works/articles/rule-based-stateful-testing/)
- [Schemathesis](https://pypi.org/project/schemathesis/4.15.1/); [XState graph](https://stately.ai/docs/xstate-graph)
- [Elle paper](https://arxiv.org/pdf/2003.10554); [Jepsen MySQL 8.0.34](https://jepsen.io/analyses/mysql-8.0.34)
- [Antithesis on DST](https://antithesis.com/resources/deterministic_simulation_testing/); [TigerBeetle VOPR](https://docs.tigerbeetle.com/about/vopr)
- [Anvil (OSDI '24)](https://www.usenix.org/conference/osdi24/presentation/sun-xudong)
- [VeriEQL](https://www.vldb.org/pvldb/vol17/p4437-zhao.pdf)

Trace validation and AI-written specs

- [Validating traces against TLA+ specs](https://arxiv.org/pdf/2404.16075); [Kuppe et al. slides](https://conf.tlapl.us/2024/MarkusAKuppe-ValidatingSystemExecutionsWithTheTLAPlusTools.pdf)
- [Can LLMs model real-world systems in TLA+? (SysMoBench)](https://sigops.org/2026/can-llms-model-real-world-systems-in-tla)
- [Can LLMs write correct TLA+ specs? (AI4FM)](https://ai4fm.cs.luc.edu/papers/llm-tla-evaluation/)
