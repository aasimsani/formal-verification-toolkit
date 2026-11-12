# formal-verification-toolkit

A Claude Code plugin that checks a design or a piece of code with the cheapest formal tool that can produce the failure. A test checks the cases someone wrote. A model checker, a model finder or a property test checks every case in a stated scope.

## Install

```text
/plugin marketplace add aasimsani/formal-verification-toolkit
/plugin install fv-toolkit@formal-verification-toolkit
```

In Codex:

```text
codex plugin marketplace add https://github.com/aasimsani/formal-verification-toolkit
codex plugin add fv-toolkit@formal-verification-toolkit
```

Then install the pinned checkers once. The command needs a JDK 17 or later.

```bash
plugins/fv-toolkit/scripts/fv-install
```

## Skills

| Skill | What it does |
|---|---|
| `formal-verification` | The router. It triages the claims, picks a tool by the question, freezes the properties, and runs the loop: model, check, plant bugs, replay each counterexample in the code, report. |
| `fv-tlaplus` | Writes and checks a TLA+ model with TLC: one action per atomic step, one config per design with a declared outcome, witnesses and mutations. It ships two checked examples and three reproduced anti-patterns. |
| `fv-hypothesis` | Writes property-based and stateful tests on real Python code, and requires each property to fail on a planted bug in that code. It ships one test file that detects every planted bug beside three that detect none. |
| `fv-alloy` | Writes and checks an Alloy 6 model of structure: permissions, ownership, isolation, compatibility. Every check is paired with a satisfiable run, and the check of a rejected design must find its counterexample. |
| `fv-maintain` | Brings models back in line after the code changed, and says whether each failure is drift in the model or a bug in the code. |

The router reads its pattern catalogs, property families and fault models from `plugins/fv-toolkit/references/`. `docs/spec.md` is the design document that those files come from.

## Tools on demand

The two core jars install with `fv-install`. Every other tool installs when it is named, for example `fv-install z3`. `fv-install --list` prints every tool the script can install, and `fv-install --check <tool>` reports whether one is ready without installing it. `docs/adding-a-tool.md` is the contract for a new tool.

| Skill | What it does |
|---|---|
| `fv-z3` | Encodes a rule table, a policy diff or a config invariant as a Z3 formula and searches for a violation. It reports `unknown` as an error and never as a pass. |
| `fv-schemathesis` | Generates requests from an OpenAPI schema, checks each response against the schema, and runs sequences of calls such as create, get, delete. |
| `fv-crosshair` | Searches symbolically for an input on which a Python function breaks its contract, and for an input on which two versions of a function disagree. |

## Scripts

Every script prints one verdict per line and documents its exit codes in `--help`.

| Script | What it does |
|---|---|
| `fv-install` | Downloads TLC 1.7.4 and Alloy 6.2.0 into `~/.cache/fv` and verifies each jar by SHA-256. A named on-demand tool runs its installer from `scripts/installers/`. |
| `fv-tlc` | Runs TLC on each config and compares the outcome with the config's `\* expect:` header. `--json` prints each counterexample as parsed states. |
| `fv-alloy` | Runs every command of an Alloy model and compares each result with its `expect` clause. |
| `fv-mutate` | Plants each bug from a `.mutations` file in a copy and confirms that the check fails. |
| `fv-replay` | Turns a TLC counterexample into a pytest file that drives the real code through the same steps. |
| `fv-conform` | Checks that a recorded run of the real system, one JSON line per step, is a behaviour of the spec. |
| `fv-pin` | Records a SHA-256 for each confirmed property and declared outcome, and reports any that changed. |
| `fv-drift` | Reports whether the code a model covers has changed since the model's sync commit. |

A tool that is not installed makes a script exit 3 and print `UNAVAILABLE`. That result means the model was not checked. It is neither a pass nor a failure.

## Tests

```bash
plugins/fv-toolkit/scripts/fv-install
bash tests/test_scripts.sh
bash tests/test_structure.sh
bash tests/test_examples.sh            # every tool that is installed
bash tests/test_examples.sh alloy      # one tool
```

The Hypothesis examples need `uv`, which supplies Hypothesis and pytest for the run. `test_scripts.sh` runs the real TLC and Alloy jars against the fixtures in `tests/fixtures/`. `test_structure.sh` checks that every file a skill names exists. `test_examples.sh` runs every shipped example: a good example must meet its declared outcomes and detect its mutations, and a bad example must produce the symptom its README states.

## CI

`.github/workflows/ci.yml` installs the pinned jars and runs the three suites on every pull request and on every push to `main`. Each on-demand tool has its own job. A pull request runs the jobs of the tools whose files it changed, and a push to `main` runs every tool.

## License

MIT. See `LICENSE`. `NOTICE.md` lists the open-source work that this project adapts.
