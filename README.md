# formal-verification-toolkit

A Claude Code plugin that checks a design or a piece of code with the cheapest formal tool that can produce the failure. A test checks the cases someone wrote. A model checker, a model finder or a property test checks every case in a stated scope.

## Install

```text
/plugin marketplace add aasimsani/formal-verification-toolkit
/plugin install fv-toolkit@formal-verification-toolkit
```

Then install the pinned checkers once. The command needs a JDK 17 or later.

```bash
plugins/fv-toolkit/scripts/fv-install
```

## Skills

| Skill | What it does |
|---|---|
| `formal-verification` | The router. It triages the claims, picks a tool by the question, freezes the properties, and runs the loop: model, check, plant bugs, replay each counterexample in the code, report. |
| `fv-maintain` | Brings models back in line after the code changed, and says whether each failure is drift in the model or a bug in the code. |

The router reads its pattern catalogs, property families and fault models from `plugins/fv-toolkit/references/`. `docs/spec.md` is the design document that those files come from.

## Scripts

Every script prints one verdict per line and documents its exit codes in `--help`.

| Script | What it does |
|---|---|
| `fv-install` | Downloads TLC 1.7.4 and Alloy 6.2.0 into `~/.cache/fv` and verifies each jar by SHA-256. |
| `fv-tlc` | Runs TLC on each config and compares the outcome with the config's `\* expect:` header. |
| `fv-alloy` | Runs every command of an Alloy model and compares each result with its `expect` clause. |
| `fv-mutate` | Plants each bug from a `.mutations` file in a copy and confirms that the check fails. |
| `fv-drift` | Reports whether the code a model covers has changed since the model's sync commit. |

A tool that is not installed makes a script exit 3 and print `UNAVAILABLE`. That result means the model was not checked. It is neither a pass nor a failure.

## Tests

```bash
plugins/fv-toolkit/scripts/fv-install
bash tests/test_scripts.sh
bash tests/test_structure.sh
```

`test_scripts.sh` runs the real TLC and Alloy jars against the fixtures in `tests/fixtures/`. `test_structure.sh` checks that every file a skill names exists.

## License

MIT. See `LICENSE`. `NOTICE.md` lists the open-source work that this project adapts.
